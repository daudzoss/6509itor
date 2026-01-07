ZP	= $42	; 67 bytes free, through $84

CURBANK	= ZP+$00
CURADDR	= ZP+$01
ZONE016	= ZP+$03
REVCELL	= ZP+$04
REVTLLY	= ZP+$04+2*$05
UNDER85	= NEXTVAR
.if UNDER85 >= $85
.warn "too much zero page memory used? may interfere with BASIC"
.endif
ROW	= $CA
COL	= $CB

SCREENW = $50
Screenh = $19
SCREENM = $d000

*	= $0002+1		; P500 loads into bank 0 but must run in bank 15
	.word	(+), 3
	.text	$81,$41,$b2,$30	; FOR A = 0
	.text	$a4		; TO finish-start
	.text	format("%4d",finish-start)
	.text	$3a,$dc,$31	; : BANK 1
	.text	$3a,$42,$b2,$c2	; : B = PEEK
	.text	$28		; ( start
	.text	format("%2d",SYSCALL)
	.text	$aa,$41,$29,$3a	; + A ) :
	.text	$dc,$31,$35,$3a	; BANK 1 5 :
	.text	$97		; POKE start
	.text 	format("%2d",SYSCALL)
	.text	$aa,$41,$2c,$42	; + A , B
	.text	$3a,$82,0	; : NEXT
+
	.word	(+), 2055
	.text	$99,$22,$0e,$22	; PRINT " CHR$(14) ""
	.text	$22,$3b,$3a,$93	; " ; : SYS start
	.null	format("%4d",start)
+	.word 0

*	= SYSCALL
start
main
	lda	#$0f		;// has to start in bank 15
	sta	CURBANK		;void main(void) {
	lda	#<(start&$00f0)	; CURBANK = 15;
	sta	CURADDR		;
	lda	#>(start&$ff00)	;
	sta	1+CURADDR	; CURADDR = main;
	lda	#0		;
	sta	ZONE016		; ZONE016 = 0; // address highlighted
	
newaddr	lda	CURBANK	`	;
	sta	$01		; static volatile int indirect_bank = CURBANK;
	ldy	#$0f		;
-	lda	(CURADDR),y	;
	pha			;
	dey			;
	cpy	#0		;
	bpl	-		;
	lda

newzone	lda	ZONE016		;
	jsr	zonewid		;
	sta	REVTLLY		; REVTLLY = zonewid(ZONE016);
loop				;

	rts			;} // main()

zonewid	and	#$ff		;register uint3_t zonewid(register uint8_t a) {
	beq	+		; if (a)
	lda	#$fe		;  return 3; // 1 through 16 are XXXX0 to XXXXF
+	clc			; else
	adc	#5		;  return 5; // 0 is the address: XXXX0
	rts			;} // zonewid()

columns	.byte	$00,$06,$0a,$0d	;static const uint8_t columns { 0,// 20b address
	.byte	$12,$16,$1a,$1d	;  6, 10, 14, 18, 22, 26,
	.byte	$22,$26,$2a,$2d	; 30, 34, 38, 42, 46, 50,
	.byte	$32,$36,$3a,$3d	; 54, 58, 62, 66, 70 // and 16 zones of 8b bytes
	.byte	$42,$46		;};
finish
.if start >= $c000
.if finish > $cfff
.warn "exceeded bank 15's high 4KB RAM block"
.endif	
.elsif start >= $0400
.if finish > $07ff
.warn "exceeded bank 15's low 1KB RAM block"
.endif
.endif
.end
