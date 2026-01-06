ZP	= $42	; 67 bytes free, through $84

ROW	= ZP+$00
COL	= ZP+$01
ZONE	= ZP+$02
ZONECOL	= ZP+$03
REVCELL	= ZP+$03+$11
NEXTVAR	= ZP+$14+$05
UNDER85	= NEXTVAR
.if UNDER85 >= $85
.warn "too much zero page memory used? may interfere with BASIC"
.endif
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
	.text	$99,$22		; PRINT "
	.text	$09		; CHR$(9) // enable
	.text	$8e,$08		; CHR$(142) CHR$(8) // UPPER,disabl
	.text	$13,$13		; HOME HOME // (undoes windows on C16,C128,...)
	.text	"github:daudzoss/mlink"
	.text	$13,$22,$3b	; HOME ";
	.text	$3a,$9e		; : SYS start
	.null	format("%4d",start)
+	.word 0

*	= SYSCALL
start
	lda	#$0f		;// has to start in bank 15
	sta	$01		;static volatile int execute_bank = 15;
	rts			;void main(void) {}

columns	.byte	$00,$06,$0a,$0d	;
	.byte	$12,$16,$1a,$1d	;
	.byte	$22,$26,$2a,$2d	;
	.byte	$32,$36,$3a,$3d	;
	.byte	$42,$46		;
finish
.if start >= $c000 && (finish-start) > $1000
.warn "exceeded bank 15's high 4KB RAM block"
.elsif start >= $0400 && (finish-start) > $0400
.warn "exceeded bank 15's low 1KB RAM block"
.endif
.end
	
