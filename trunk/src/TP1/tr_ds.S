#include <mips/regdef.h>
#include <sys/syscall.h>

#define	OOBCH		257

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
	.globl	tr_ds
	.ent	tr_ds

tr_ds:
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
		sw	a1,ARG1($fp)		//set2 en ABA
		sw	zero,VAR1($fp)		//ch es VAR1
		addiu	t0,zero,OOBCH
		sw	t0,VAR2($fp)		//lastch = OOBCH, lastch es VAR2

	//Invocación a setup(map1,set1,0)
		la	a0,map1			//asigna MAP0 al argumento 0
		lw	a1,ARG0($fp)
		move	a2,zero
		jal	setup

	//Invocación a setup(map2,set2,0)
		la	a0,map2			//asigna MAP0 al argumento 0
		lw	a1,ARG1($fp)
		move	a2,zero
		jal	setup

	ciclo_trds:
		la	s0,map1
		sll	t1,t0,2			// t0 tiene ch
		addu	t1,s0,t1		// t1 = map1[ch]
		lw	t1,0(t1)		// t1 = *map1[ch]
		beq	t1,zero,segundaCondicion
		j	condicion_trds

	segundaCondicion:
		la	s3,map2
		sll	t1,t0,2			// t0 tiene ch
		addu	t1,s3,t1		// t1 = map2[ch]
		lw	t1,0(t1)		// t1 = *map2[ch]
		beq	t1,zero,almacenarCaracter// map2[ch]==0
		lw	t1,VAR2($fp)		// t1 = lastch
		bne	t1,t0,almacenarCaracter	// lastch != ch
		j	condicion_trds

	almacenarCaracter:
		sw	t0,VAR2($fp)		//lastch = ch
		move	a0,t0
		jal	myputchar
		j	condicion_trds

	condicion_trds:
		addiu	t0,zero,0
		jal	mygetchar
		move	t0,v0			// ch = mygetchar()
		sw	t0,VAR1($fp)		// ch = t0
		not	t1,zero			// señal de EOF
		bne	t0,t1,ciclo_trds	// verifico si no es EOF

	//Stack frame unwinding
		move	sp,$fp
		lw	$fp,O_FP(sp)
		lw	gp,O_GP(sp)
		lw	ra,O_RA(sp)
		addiu	sp,sp,SSIZE
		jr	ra

	.end tr_ds
