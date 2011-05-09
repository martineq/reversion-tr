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

	subu	sp,sp,SSIZE		//Stack frame creation
	sw	ra,O_RA(sp)
	sw	$fp,O_FP(sp)
	.cprestore  O_GP
	move	$fp,sp

	sw	a0,ARG0($fp)		// almaceno a0 en ABA caller
	addiu	t0,zero,OOBCH		// lastch = OOBCH
	sw	t0,VAR1($fp)		// inicializo en OOBCH lastch
	sw	zero,VAR2($fp)		// inicializo en 0 ch

	la	s0,map1

	move	a0,s0			//asigna MAP0 al argumento 0
	lw	t0,ARG0($fp)
	move	a1,t0
	move	a2,zero
	jal	setup			//Invocación a setup
	j	condicion

   ciclo:
	sll	t0,t1,2
	la	s0,map1
	add	t0,s0,t0		// address de map1 +desfasaje ch
	lw	t2,0(t0)
	beq	t2,zero,imprimirCaracter// !map1[ch] es equivalente a que map1[ch]==0
	lw	t0,VAR1($fp)
	bne	t0,t1,imprimirCaracter	// si lastch != ch => almacena
	j	condicion		// si no se cumple ninguna no almacena nada

   imprimirCaracter:
	sw	t1,VAR1($fp)
	move	a0,t1
	jal	myputchar
	j	condicion

   condicion:
	addiu	t0,zero,1
	jal	mygetchar
	move	t1,v0			// ch = mygetChar()
	not	t3,zero			// señal de EOF
	bne	t1,t3,ciclo		// verifica EOF
	move	sp,$fp			//stack frame unwinding
	lw	$fp,O_FP(sp)
	lw	gp,O_GP(sp)
	lw	ra,O_RA(sp)
	addiu	sp,sp,SSIZE
	jr	ra

	.end	tr_s1
