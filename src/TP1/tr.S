/*

void tr(char* set1, char* set2){
	int ch;

	if (!*set2)
		errx(1, "empty set2");

	// If string2 runs out of characters, use the last one specified.
	setup(map1, set1, set2);

	while ((ch = mygetchar()) != EOF)
		myputchar(map1[ch]);
}


------------------------
--Programa en assembly--
------------------------

Stack frame del programa:
(ABA)  48  |ARG2 |	>> n/a
(ABA)  44  |ARG1 |	>> Parámetro: set2	
(ABA)  40  |ARG0 |	>> Parámetro: set1	
	   -----
(SRA)  36  |RA   |	>> Dirección de retorno
(SRA)  32  |FP   |	>> Frame Pointer. SR
(SRA)  28  |GP   |	>> Global Pointer
(SRA)  24  |PAD  |	>> Padding
(LTA)  20  |VAR1 |	>> Variable local: ch
(LTA)  16  |VAR2 |	>> n/a
(ABA)  12  |ARG3 |	>> n/a
(ABA)  8   |ARG2 |	>> n/a
(ABA)  4   |ARG1 |	>> n/a
(ABA)  0   |ARG0 |	>> ARG0: argumento para myputchar
	   -----
*/


#include <mips/regdef.h>
#include <sys/syscall.h>

#define	OOBCH		257

#define SSIZE 		40
#define ARG1		44
#define ARG0		40
#define O_RA		36
#define O_FP		32
#define O_GP		28
#define VAR1		20
#define MY_ARG0		0

	.text
	.align	2
	.globl	tr


	.ent	tr
tr:
	.frame	$fp,SSIZE,ra			# un Frame Pointer de tamaño SSIZE
	.set	noreorder
	.cpload	t9				# t9 se usa para guardar la llamada a func que vaya a usar.
	.set	reorder

	# Construyo el espacio para el Stack frame
	subu	sp,sp,SSIZE
	sw	ra,O_RA(sp)
	sw	$fp,O_FP(sp) 		# Register saving: gp y fp. Obligatorio para las Leaf function.
	.cprestore  O_GP 		# equivale a sw gp,O_GP(sp). Para código independiente de la función.
	move	$fp,sp

	sw	a0,ARG0(sp)		# Almacena el argumento en la ABA de la función invocante. Guardo set1 en el SF.		
	sw	a1,ARG1(sp)		# Guardo set2 en el SF.
	sw	zero,VAR1($fp)		# Inicializo en 0 ch



# LÍMITE DE COSAS NUEVAS. LO DE ABAJO ES SOLO TEMPORAL--------------------------------------------------------------



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

	.end	tr
