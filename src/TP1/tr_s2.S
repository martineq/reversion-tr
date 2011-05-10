#include <mips/regdef.h>
#include <sys/syscall.h>

#define	OOBCH		257

#define ARG1		44
#define ARG0		40
#define O_RA		36
#define O_FP		32
#define O_GP		28
#define	VAR1		20
#define VAR2		16

#define SSIZE		40

	.text
	.align	2
	.globl	tr_s2
	.ent	tr_s2

tr_s2:
	.frame	$fp,SSIZE,ra
	.set	noreorder
	.cpload	t9
	.set	reorder

	subu	sp,sp,SSIZE		//Stack frame creation
	sw	ra,O_RA(sp)
	sw	$fp,O_FP(sp)
	.cprestore  O_GP
	move	$fp,sp

	sw	a0,ARG0($fp)		//carga los argumentos en la ABA de la caller
	sw	a1,ARG1($fp)

	addiu	t0,zero,OOBCH		//cargamos las variables locales
	sw	t0,VAR1($fp)		//lastch es VAR1
	sw	zero,VAR2($fp)		//ch es VAR2


	lb	t0,ARG1($fp);		//Inicio de la lógica de la función
	bne	t0,zero,continuar_trs2

	li      v0, SYS_write 		// Aquí hago uso de <sys/syscall.h>. ssize_t write(int archivo, const void *buffer, size_t cantidad);
       	li      a0, 2         		// a0: Salida de error.
       	la      a1, msgerr_tr_s2    	// a1: Puntero al mensaje de error.
       	li      a2, 11         		// a2: Longitud de caracteres (en este caso 24 bytes).
       	syscall
	li v0, SYS_exit			// Aquí hago uso de exit(1);
	li a0, 1 			// a0: Valor de retorno: 1
	syscall				//hace una llamada al sistema errx(1,"empty set2")

  continuar_trs2:
	la	a0,map1			//invocacion a setup
	lw	a1,ARG0($fp)
	lw	a2,ARG1($fp)
	jal	setup
	la	a0,map2			//invocacion a setup
	lw	a1,ARG1($fp)
	move	a2,zero
	jal	setup
	j	condicion_trs2

  ciclo_trs2:
	la	s0,map1
	sll	t1,t0,2
	addu	t1,s0,t1		// t1 = map1[ch]
	lw	t0,0(t1)		// t0 = *map1[ch]
	sw	t0,VAR2($fp)		// ch = t0

	la	s3,map2
	sll	t1,t0,2
	addu	t1,s3,t1		// t1 = map2[ch]
	lw	t3,0(t1)		// t3 = *map2[ch]
	beq	t3,zero,guardarCaracter
	lw	t1,VAR1($fp)		// t1 = lastch
	bne	t1,t0,guardarCaracter	// lastch != ch
	j	condicion_trs2

  guardarCaracter:
	sw	t0,VAR1($fp)		//lastch = ch
	move	a0,t0
	jal	myputchar
	j	condicion_trs2

  condicion_trs2:
	addiu	t0,zero,0
	jal	mygetchar
	move	t0,v0			// ch = mygetchar()
	sw	t0,VAR2($fp)		// ch = t0
	not	t1,zero			// señal de EOF
	bne	t0,t1,ciclo_trs2	// verifico si no es EOF

	move	sp,$fp			//Stack frame unwinding
	lw	$fp,O_FP(sp)
	lw	gp,O_GP(sp)
	lw	ra,O_RA(sp)
	addiu	sp,sp,SSIZE
	jr	ra
	.end tr_s2

	.data
	.align	2
   msgerr_tr_s2:
        .asciiz "empty set2\n"
