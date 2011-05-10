#include <mips/regdef.h>
#include <sys/syscall.h>

#define SSIZE		40

#define ARG2		48
#define ARG1		44
#define ARG0		40

#define O_RA		36
#define O_FP		32
#define O_GP		28
#define VAR1		20
#define VAR2		16

	.text
	.align	2
	.globl	tr_d
	.ent	tr_d

tr_d:
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

		sw	a0,ARG0($fp)		//set1 en ABA
		sw	zero,VAR1($fp)		//ch es VAR1

	//Invocación a setup(map1,set1,0)
		la	a0,map1			//asigna MAP0 al argumento 0
		lw	a1,ARG0($fp)
		move	a2,zero
		jal	setup

mientras:
	// Empieza el ciclo mientras con la condición
		addiu	t0,zero,0
		jal	mygetchar
		move	t0,v0			// ch = mygetchar()
		sw	t0,VAR1($fp)		// Pongo el valor de mygetchar en VAR1=ch
		not	t1,zero			// Cargo en t1 una señal de EOF
		beq	t0,t1,finMientras1	// Si es EOF, termino el ciclo mientras.

	// Si cumplo la condición entro al ciclo.
		la	s0,map1			// Cargo la dirección del mapa en s0
		sll	t1,t0,2			// Corrimiento de 2 a izquierda de v0 (el ch)
		addu	t1,s0,t1		// t1 = map1[ch]
		lw	t1,0(t1)		// t1 = *map1[ch]
		sw	t1,VAR1($fp)		// ch = t1
		bne	t1,zero,mientras
		move	a0,t0
		jal	myputchar
		j	mientras	// Hago el loop del mientras

finMientras1:
		move	sp,$fp			//Stack frame unwinding
		lw	$fp,O_FP(sp)
		lw	gp,O_GP(sp)
		lw	ra,O_RA(sp)
		addiu	sp,sp,SSIZE
		jr	ra
	.end tr_d
