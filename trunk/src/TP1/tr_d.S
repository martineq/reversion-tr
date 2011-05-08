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

	//Stack frame unwinding
		move	sp,$fp
		.cprestore  O_GP
		sw	$fp,O_FP(sp)
		sw	ra,O_RA(sp)
		addiu	sp,sp,SSIZE

	.end tr_d

