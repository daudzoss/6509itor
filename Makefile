all : 6509itor_lo.prg 6509itor_hi.prg

6509itor_lo.prg : main.asm
	64tass -DSYSCALL=1024 -a main.asm -L 6509itor_lo.lst -o 6509itor_lo.prg

6509itor_hi.prg : main.asm
	64tass -DSYSCALL=49152 -a main.asm -L 6509itor_hi.lst -o 6509itor_hi.prg

clean :
	rm -f *.prg *.lst
