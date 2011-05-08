#include <mips/regdef.h>
#include <sys/syscall.h>
#define SFsize	32
#define O_A1		48
#define O_A0		48
#define O_RA		44
#define O_FP		40
#define O_GP		36
#define O_SET1		28
#define O_LASTCH	24
#define O_CH		20

	.text
	.align	2
	.globl	tr_s2

	.ent	tr_s2

tr_s2:
	.frame	$fp,SSIZE,ra
	.set	noreorder
	.cpload	t9
	.set	reorder

	//Stack frame creation
		subu	sp,sp,SSIZE
		sw	ra,O_RA(sp)
		sw	$fp,O_FP(sp)
		.cprestore  O_GP
		move	$fp,sp

	//carga los argumentos en la ABA de la caller
		sw	a0,ARG0($fp)
		sw	a1,ARG1($fp)

	//cargamos las variables locales
		sw	zero,VAR1($fp)		//lastch es VAR1
		sw	zero,VAR2($fp)		//ch es VAR2

	//Inicio de la lógica de la función	
		lw	t0,ARG0($fp);
		bne	t0,zero,continuar_trs2

	//hace una llamada al sistema errx(1,"empty set2")
		li      v0, SYS_write 		// Aquí hago uso de <sys/syscall.h>. ssize_t write(int archivo, const void *buffer, size_t cantidad); 
        	li      a0, 2         		// a0: Salida de error.
        	la      a1, msgerr_tr_s2    	// a1: Puntero al mensaje de error.
        	li      a2, 12         		// a2: Longitud de caracteres (en este caso 24 bytes).
        	syscall	
		li v0, SYS_exit			// Aquí hago uso de exit(1); 
		li a0, 1 			// a0: Valor de retorno: 1
		syscall 

	continuar_trs2:
		//invocacion a setup
		la	a0,map1
		lw	a1,ARG0($fp)
		lw	a2,ARG1($fp)
		jal	setup

		//invocacion a setup
		la	a0,map2
		lw	a1,ARG1($fp)
		move	a2,zero
		jal	setup

		j	condicion_trs2

	ciclo_trs2:
		la	s0,map1
		sll	t0,2		
		addu	t1,s0,t0		// t1 = map1[ch]
		lw	t1,0(t1)

		la	s1,map2
		sll	t0,2
		addu	t2,s1,t0		// t2 = map2[ch]
		lw	t2,0(t2)

		bne	t2,zero,condicion_trs2
		lw	t3,VAR1($fp)		// t3 = lastch
		beq	t3,t0,condicion_trs2

		sw	t0,VAR1($fp)		//lastch = ch
		move	a0,t0
		jal	myputchar

	condicion_trs2:
		jal	mygetchar
		move	t0,v0			// ch = mygetchar()
		not	t1,zero			// señal de EOF
		bne	t0,t1,ciclo_trs2	// verifico si no es EOF

	//Stack frame unwinding
		move	sp,$fp
		.cprestore  O_GP
		sw	$fp,O_FP(sp)
		sw	ra,O_RA(sp)
		addiu	sp,sp,SSIZE

	.end tr_s2

        .rdata
msgerr_tr_s2:
        .asciiz "empty set2\n"
