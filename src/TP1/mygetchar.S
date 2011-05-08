/* Código en C:

static int
mygetchar()
{
	int ch;
	if ((ch = getchar()) == EOF && ferror(stdin))
		errx(1, "error reading from stdin");
	return ch;
}

------------------------------------------------------------------

------------------------
--Programa en assembly--
------------------------

Stack frame del programa:

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


#define O_RA	36
#define O_FP	32
#define O_GP	28
#define VAR1	20
#define SSIZE	40

	.text					// Lo pone en la sección de código de la memoria.
	.align	2				// 2^2 = 4 bytes -> Me dice que las instrucciones son de 4 bytes.
	.globl	mygetchar			// Con esta instrucción puedo usar el símbolo fuera de este ambiente, es visible al linker. 
	.ent	mygetchar			// Instrumenta símbolo de debugging.

mygetchar:
	.frame	$fp,SSIZE,ra			// un Frame Pointer de tamaño SSIZE=16
	.set	noreorder
	.cpload	t9				// t9 se usa para guardar la llamada a func que vaya a usar.
	.set	reorder			

	//Stack frame creation
		subu	sp,sp,SSIZE
		sw	ra,O_RA(sp)
		sw	$fp,O_FP(sp) 		// Register saving: gp y fp. Leaf function.
		.cprestore  O_GP 		// equivale a sw gp,O_GP(sp). Para código independiente de la función.
		move	$fp,sp

	//lectura de caracter desde entrada
		li      v0, SYS_read 		// Aquí hago uso de <sys/syscall.h>. ssize_t read(int archivo, void *buffer, size_t cantidad);
        	li      a0, 0         		// a0=0 Entrada standard.
        	la      a1, VAR1($fp)       	// a1: Puntero al caracter.
        	li      a2, 1         		// a2: Longitud de caracteres (en este caso 1 byte). Lee solo de a uno.
        	syscall				// Llamo a read
	
	// Reviso si hay errores
		bne	a3, zero, errorSYS_read // Reviso que el SYS_read no me mande error, si lo hay, salta al área de error
		li	t0, 1			// Con esta linea y la de abajo me aseguro de haber...
		bne	v0, t0, errorSYS_read	// ...leido un solo caracter, sino envio error
        	lw      v0, VAR1($fp)   	// Devuelvo en v0 el valor del char leido. O sea hago el "return ch"		
		j	fin_mygetchar		// Si no hay errores llego hasta aquí y salto al fin

errorSYS_read:
	//Compruebo si es la señal de fin de archivo
		beq	v0,zero,eof		//Se encontró el EOF

	//Si tengo error debo enviar msg de error, devolver un 1 y terminar el programa. 
		li      v0, SYS_write 		// Aquí hago uso de <sys/syscall.h>. ssize_t write(int archivo, const void *buffer, size_t cantidad); 
        	li      a0, 2         		// a0: Salida de error.
        	la      a1, msgerr_mygetchar   	// a1: Puntero al mensaje de error.
        	li      a2, 25         		// a2: Longitud de caracteres (en este caso 25 bytes).
        	syscall				// Llamo al write()
		li	v0, SYS_exit		// Aquí hago uso de exit(1); 
		li	a0, 1			// a0: Valor de retorno:1
		syscall				// Llamo al exit()
eof:
		not	v0,zero			//Señal de EOF
fin_mygetchar:
		move	sp,$fp
		lw	ra,O_RA($fp)
		lw	gp,O_GP($fp)		// Cargo el gp del stack frame a gp
		lw	$fp,O_FP($fp)		// Cargo el fp del stack frame a fp
		addiu sp,sp,SSIZE		// Muevo el Stack pointer
		jr ra				// Vuelvo por donde me llamaron

		.end	mygetchar
	
        .rdata
msgerr_mygetchar:
        .asciiz "error reading from stdin\n"
