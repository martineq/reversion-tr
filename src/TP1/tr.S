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
	.frame	$fp,SSIZE,ra		// un Frame Pointer de tamaño SSIZE
	.set	noreorder
	.cpload	t9			// t9 se usa para guardar la llamada a func que vaya a usar.
	.set	reorder

	// Construyo el espacio para el Stack frame
	subu	sp,sp,SSIZE
	sw	ra,O_RA(sp)
	sw	$fp,O_FP(sp) 		// Register saving: gp y fp. Obligatorio para las Leaf function.
	.cprestore  O_GP 		// equivale a sw gp,O_GP(sp). Para código independiente de la función.
	move	$fp,sp

	sw	a0,ARG0(sp)		// Almacena el argumento en la ABA de la función invocante. Guardo set1 en el SF.		
	sw	a1,ARG1(sp)		// Guardo set2 en el SF.
	sw	zero,VAR1($fp)		// Inicializo en 0 ch

	
	lw	t0,ARG1($fp);		// Cargo set2
	bne	t0,zero,errorEmpty	// Chequeo si no es el puntero nulo

	// Empieza: setup(map1,set1,set2)
		la	a0,map1		// Asigna map1 al argumento a0
		lw	a1,ARG0($fp)	// Cargo el set1
		lw	a2,ARG1($fp)	// Cargo el set2
		jal	setup		// Salto a la función setup

mientras1:
		jal	mygetchar	// Salto a la función mygetchar
		move	t0,v0		// ch = mygetchar()
		not	t1,zero		// señal de EOF
		beq	t0,t1,finMientras1	// Verifico: si es EOF voy al finMientras1

	//Cargo el mapa. Esta parte la tengo en vista
		la	s0,map1		
		sll	t0,2		
		addu	t1,s0,t0		// t1 = map1[ch]
		lw	t1,0(t1)
		sw	t0,VAR1($fp)		//lastch = ch
		move	a0,t0
		jal	myputchar

		j	mientras1	// Hago el loop del mientras1


// Errores

errorEmpty:
	// Si tengo error debo enviar msg de error, devolver un 1 y terminar el programa. 
		li      v0, SYS_write 		// Aquí hago uso de <sys/syscall.h>. ssize_t write(int archivo, const void *buffer, size_t cantidad); 
        	li      a0, 2         		// a0: Salida de error.
        	la      a1, msgerr       	// a1: Puntero al mensaje de error.
	       	li      a2, 11         		// a2: Longitud de caracteres (en este caso 11 bytes).
        	syscall				// Llamo al write()
		bne	a3, zero,errorGenerico	// Reviso que el syscall no me mande error, si lo hay, salta al área de error
		li	v0, SYS_exit		// Aquí hago uso de exit(1); 
		li	a0, 1			// a0: Valor de retorno:1
		syscall				// Llamo a exit
		bne	a3, zero,errorGenerico	// Reviso que el syscall no me mande error, si lo hay, salta al área de error

errorGenerico:
	// Acá me falta agregar el caso donde los sys calls fallan, incluso el syscall exit.
	// Hay un comando en assembler para mandar un error, si alguien lo sabe que avise o lo agregue acá...

finMientras1:
	// Stack Frame unwinding
		move	sp,$fp
		.cprestore  O_GP
		sw	$fp,O_FP(sp)
		sw	ra,O_RA(sp)
		addiu	sp,sp,SSIZE

	.end	tr

  .rdata
msgerr:
        .asciiz "empty set2\n"

