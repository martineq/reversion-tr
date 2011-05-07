/*
------------------------
--Programa en assembly--
------------------------

Stack frame del programa:
(ABA)  48  |ARG2 |	
(ABA)  44  |ARG1 |	
(ABA)  40  |ARG0 |	
	   -----
(SRA)  36  |RA   |	>> Dirección de retorno
(SRA)  32  |FP   |	>> Frame Pointer. SR
(SRA)  28  |GP   |
(SRA)  24  |PAD  |
(LTA)  20  |VAR1 |
(LTA)  16  |VAR2 |
(ABA)  12  |ARG3 |	
(ABA)  8   |ARG2 |	
(ABA)  4   |ARG1 |
(ABA)  0   |ARG0 |
	   -----
*/

#include <mips/regdef.h>
#include <sys/syscall.h>

#define	OOBCH		257

#define SSIZE 		40
#define ARG0		40
#define O_RA		36
#define O_FP		32
#define O_GP		28
#define VAR1		20
#define VAR2		16

	.text
	.align	2
	.globl	tr_s1


	.ent	tr_s1
tr_s1:
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

		sw	a0,ARG0($fp)		// almaceno a0 en ABA caller
		sw	zero,VAR1($fp)		// inicializo en 0 lastch
		sw	zero,VAR2($fp)		// inicializo en 0 ch

	//Invocación a setup
		move	a0,s0			//asigna MAP0 al argumento 0
		lw	t0,ARG0($fp)
		move	a1,t0
		move	a2,zero
		jal	setup
		j	condicion

	ciclo:
		add	t3,s0,t1		// address de map1 +desfasaje ch
		lw	t2,0(t3)
		beq	t2,zero,condicion
		beq	t0,t1,condicion
		move	t0,t1
		move	a0,t1
		jal	myputchar

	condicion:
		jal	mygetchar
		addiu	t0,zero,OOBCH		// lastch = OOBCH
		move	t1,v0			// ch = mygetChar()
		not	t3,zero			// señal de EOF
		bne	t1,t3,ciclo		// verifica EOF

	//stack frame unwinding
		move	sp,$fp
		lw	$fp,O_FP(sp)
		lw	gp,O_GP(sp)
		lw	ra,O_RA(sp)
		addiu	sp,sp,SSIZE
		jr	ra

	.end	tr_s1
