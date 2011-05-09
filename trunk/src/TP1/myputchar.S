/* Código en C:

static void
myputchar(ch)
	char ch;
{
	if (putchar(ch) == EOF)
		errx(1, "error writing to stdout");
}

------------------------------------------------------------------


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

#define ARG0	40
#define O_RA	36
#define O_FP	32
#define O_GP	28
#define SSIZE	40

	.text					// Lo pone en la sección de código de la memoria.
	.align	2				// 2^2 = 4 bytes -> Me dice que las instrucciones son de 4 bytes.
	.globl	myputchar
	.ent	myputchar			// Instrumenta símbolo de debugging.
myputchar:
		.frame	$fp,SSIZE,ra		// un Frame Pointer de tamaño SSIZE=8
		.set	noreorder
		.cpload	t9			// t9 se usa para guardar la llamada a func que vaya a usar.
		.set	reorder			

	//Stack frame creation
		subu		sp,sp,SSIZE
		sw	    	a0,ARG0(sp)	//almacena el argumento en la ABA de la función invocante.		
		sw	    	ra,O_RA(sp)
		.cprestore  	O_GP		// equivale a sw gp,O_GP(sp). Para código independiente de la función.
		sw	    	$fp,O_FP(sp) 	// Register saving: gp y fp. Leaf function.
		move		$fp,sp

	//llamada al sistema para imprimir por pantalla el caracter -- putchar(ch)	
		li      v0, SYS_write 		// Aquí hago uso de <sys/syscall.h>. ssize_t write(int archivo, const void *buffer, size_t cantidad); 
		li      a0, 1         		// a0: Salida standard.
		la      a1, ARG0($fp)     	// Puntero al caracter.
		li      a2, 1         		// a2: Longitud de caracteres (en este caso 1 byte). Lee solo de a uno.
		syscall				// Llamo a write
	
	// Reviso si hay errores
		bne	a3, zero, errorSYS_write// Reviso que el SYS_write no me mande error, si lo hay, salta al área de error
		li	t0, 1			// Con esta linea y la de abajo me aseguro de haber...
		bne	v0, t0, errorSYS_write	// ...mandado un solo caracter, sino envio error
		j	fin_myputchar			// Si no hay errores llego hasta aquí y salto al fin

errorSYS_write:

	//Si tengo error debo enviar msg de error, devolver un 1 y terminar el programa. 
		li      v0, SYS_write 		// Aquí hago uso de <sys/syscall.h>. ssize_t write(int archivo, const void *buffer, size_t cantidad); 
        	li      a0, 2         		// a0: Salida de error.
        	la      a1, msgerr_myputchar       	// a1: Puntero al mensaje de error.
        	li      a2, 24         		// a2: Longitud de caracteres (en este caso 24 bytes).
        	syscall	
		li	v0, SYS_exit		// Aquí hago uso de exit(1); 
		li	a0, 1			// a0: Valor de retorno:1
		syscall				// Llamo a exit
		bne	a3, zero,errorGenerico	// Reviso que el syscall no me mande error, si lo hay, salta al área de error

errorGenerico:
	// Acá falta agregar el caso donde los sys calls fallan, incluso el syscall exit.
	// Hay un comando en assembler para mandar un error, si alguien lo sabe que avise o lo agregue acá...

fin_myputchar:
		move	sp,$fp
		lw 	$fp,O_FP(sp)		// Cargo el fp del stack frame a $fp...
		lw 	gp,O_GP(sp)		// Cargo el gp del stack frame a gp...
		lw 	ra,O_RA(sp)
		addiu 	sp,sp,SSIZE		// Muevo el Stack pointer
		jr ra				// Vuelvo por donde me llamaron

.end	myputchar
	

        .rdata
msgerr_myputchar:
        .asciiz "error writing to stdout\n"
