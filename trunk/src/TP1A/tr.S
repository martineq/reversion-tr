/*
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

#define	OOBCH		257
#define NCHARS		256
#define SIGKILL		9

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


//FUNCION TR_DS //////////////////////////////////////////////////

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

//FUNCION TR_DS //////////////////////////////////////////////////


//FUNCION TR_D ///////////////////////////////////////////////////

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

	mientras_trd:
	// Empieza el ciclo mientras con la condición
		addiu	t0,zero,0
		jal	mygetchar
		move	t0,v0			// ch = mygetchar()
		sw	t0,VAR1($fp)		// Pongo el valor de mygetchar en VAR1=ch
		not	t1,zero			// Cargo en t1 una señal de EOF
		beq	t0,t1,finMientras_trd	// Si es EOF, termino el ciclo mientras.

	// Si cumplo la condición entro al ciclo.
		la	s0,map1			// Cargo la dirección del mapa en s0
		sll	t1,t0,2			// Corrimiento de 2 a izquierda de v0 (el ch)
		addu	t1,s0,t1		// t1 = map1[ch]
		lw	t1,0(t1)		// t1 = *map1[ch]
		sw	t1,VAR1($fp)		// ch = t1
		bne	t1,zero,mientras_trd
		move	a0,t0
		jal	myputchar
		j	mientras_trd	// Hago el loop del mientras

	finMientras_trd:
		move	sp,$fp			//Stack frame unwinding
		lw	$fp,O_FP(sp)
		lw	gp,O_GP(sp)
		lw	ra,O_RA(sp)
		addiu	sp,sp,SSIZE
		jr	ra
	.end tr_d

//FUNCION TR_D ///////////////////////////////////////////////////

//FUNCION TR_S1 //////////////////////////////////////////////////

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

//FUNCION TR_S1 //////////////////////////////////////////////////

//FUNCION TR_S2 //////////////////////////////////////////////////

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
       	la      a1, msgerr_set2    	// a1: Puntero al mensaje de error.
       	li      a2, 11         		// a2: Longitud de caracteres (en este caso 24 bytes).
       	syscall
	li v0, SYS_exit			// Aquí hago uso de exit(1);
	li a0, 1 			// a0: Valor de retorno: 1
	syscall				//hace una llamada al sistema errx(1,"empty set2")
	bne	a3, zero,sysKILL	// Reviso que el syscall no me mande error, si lo hay, salta al área de error

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

//FUNCION TR_S2 //////////////////////////////////////////////////

//FUNCION TR /////////////////////////////////////////////////////

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

	sw	a0,ARG0($fp)		// Almacena el argumento en la ABA de la función invocante. Guardo set1 en el SF.		
	sw	a1,ARG1($fp)		// Guardo set2 en el SF.
	sw	zero,VAR1($fp)		// Inicializo en 0 ch (VAR1=0)

	lb	t0,ARG1($fp);		// Cargo set2 (ARG0=set1 y ARG1=set2)
	beq	t0,zero,errorEmpty_tr	// Chequeo si no es el puntero nulo, si es nulo me voy a mandar el err

	// Empieza: setup(map1,set1,set2)
	la	a0,map1		// Asigna map1 al argumento a0
	lw	a1,ARG0($fp)	// Cargo el set1
	lw	a2,ARG1($fp)	// Cargo el set2
	jal	setup		// Salto a la función setup

mientras_tr:
	// Empieza el ciclo mientras con la condición
	addiu	t0,zero,0
	jal	mygetchar
	move	t0,v0			// ch = mygetchar()
	sw	t0,VAR1($fp)		// Pongo el valor de mygetchar en VAR1=ch
	not	t1,zero			// Cargo en t1 una señal de EOF
	beq	t0,t1,finMientras_tr	// Si es EOF, termino el ciclo mientras.

	// Si cumplo la condición entro al ciclo.
	la	s0,map1			// Cargo la dirección del mapa en s0
	sll	t1,t0,2			// Corrimiento de 2 a izquierda de v0 (el ch)
	addu	t1,s0,t1		// t1 = map1[ch]
	lb	t0,0(t1)		// t0 = *map1[ch]
	sw	t0,VAR1($fp)		// ch = t0
	move	a0,t0
	jal	myputchar

	j	mientras_tr	// Hago el loop del mientras

// Errores

errorEmpty_tr:
	// Si tengo error debo enviar msg de error, devolver un 1 y terminar el programa. 
		li      v0, SYS_write 		// Aquí hago uso de <sys/syscall.h>. ssize_t write(int archivo, const void *buffer, size_t cantidad); 
        	li      a0, 2         		// a0: Salida de error.
        	la      a1, msgerr_set2       	// a1: Puntero al mensaje de error.
	       	li      a2, 11         		// a2: Longitud de caracteres (en este caso 11 bytes).
        	syscall				// Llamo al write()
		li	v0, SYS_exit		// Aquí hago uso de exit(1); 
		li	a0, 1			// a0: Valor de retorno:1
		syscall				// Llamo a exit
		bne	a3, zero,sysKILL	// Reviso que el syscall no me mande error, si lo hay, salta al área de error

finMientras_tr:
	// Stack Frame unwinding
	move	sp,$fp
	lw	$fp,O_FP(sp)
	lw	gp,O_GP(sp)
	lw	ra,O_RA(sp)
	addiu	sp,sp,SSIZE
	jr	ra

	.end	tr

//FUNCION TR /////////////////////////////////////////////////////

//FUNCION SETUP //////////////////////////////////////////////////

	.globl	setup
	.ent	setup
setup:
		.frame	$fp,SSIZE,ra
		.set	noreorder
		.cpload	t9		
		.set	reorder			

	//Stack frame creation
		subu	sp,sp,SSIZE
		sw	a2,ARG2(sp)	
		sw	a1,ARG1(sp)	
		sw	a0,ARG0(sp)	
		sw	ra,O_RA(sp)
		sw	$fp,O_FP(sp)
		.cprestore  O_GP 
		sw	zero,VAR1(sp)
		move	$fp,sp

	//Inicio función setup
		lw	s0,ARG0($fp)
		lw	s1,ARG1($fp)
		lw	s2,ARG2($fp)
if1:
		bne	s1,zero,if2		// Si set1 != NULL voy a if2
		li	v0, SYS_exit		// Aquí hago uso de exit(1); 
		li	a0, 1			// a0: Valor de retorno:1
		syscall				// Llamo a exit
		bne	a3, zero,sysKILL	// Reviso que el syscall no me mande error, si lo hay, termina abruptamente el programa.

if2:
		bne	s2,zero,fin_if2		//Si set2 != NULL voy a fin_if2
		addiu	t0,zero,NCHARS		// t0 = NCHARS

	memset:					// inicializa los elementos de
						// map1(s0) en 0
		sw	zero,0(s0)		// *s0 = 0
		subu	t0,t0,1			// t0 = t0-1
		addiu	s0,s0,4			// siguiente elemento de map1
		bne	t0,zero,memset

		lw	s0,ARG0($fp)		// vuelvo a apuntar al primer elemento de map
	while_if2:				// while(*set1)
		lb	t0,0(s1)		// cargo lo apuntado por s1 en t0
		beq	t0,zero,fin_setup;	// cuando t0 = 0 termina el while
		addiu	t1,zero,1		// t1 = 1
		sll	t0,2			
		addu	t0,s0,t0		// to = direccion de map[*set1]
		sw	t1,0(t0)		// map[*set1] = 1
		addiu	s1,s1,1			// set1++
		j	while_if2
fin_if2:
		lw	s0,ARG0($fp)		// vuelvo a apuntar al primer elemento de map
while_2:
		lb	t0,0(s1)
		beq	t0,zero,fin_while2

		lb	t1,0(s2)
		beq	t1,zero,fin_while2

		sll	t0,2
		addu	t0,s0,t0		// t3 = direccion de MAP[*set1]
		sw	t1,0(t0)		// MAP[*set1] = *SET2
		addiu	s1,s1,1			// set1++
		addiu	s2,s2,1			// set2++
		j	while_2	

fin_while2:
		lw	t1,VAR1($fp)
		addiu	t2,s2,-1
		lb	t1,0(t2)
		lw	s0,ARG0($fp)		// vuelvo a apuntar al primer elemento de map
while3:						//while(*set1)
		lb	t0,0(s1)		// t3 = *SET1
		beq	t0,zero,fin_setup;

		sll	t0,t0,2			// multiplo por 4 el contenido
		addu	t0,s0,t0		// direccion de map[*set1] en t3
		sw	t1,0(t0)		// map[*set1] = lastch
		addiu	s1,s1,1			// set1++
		j	while3

fin_setup:
		move	sp,$fp
		lw 	ra,O_RA(sp)
		lw 	gp,O_GP(sp)		
		lw 	$fp,O_FP(sp)
		addiu 	sp,sp,SSIZE		
		jr 	ra

	.end	setup

//FUNCION SETUP //////////////////////////////////////////////////

//FUNCION MYPUTCHAR //////////////////////////////////////////////

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
		bne	a3, zero,sysKILL	// Reviso que el syscall no me mande error, si lo hay, salta al área de error

fin_myputchar:
		move	sp,$fp
		lw 	$fp,O_FP(sp)		// Cargo el fp del stack frame a $fp...
		lw 	gp,O_GP(sp)		// Cargo el gp del stack frame a gp...
		lw 	ra,O_RA(sp)
		addiu 	sp,sp,SSIZE		// Muevo el Stack pointer
		jr ra				// Vuelvo por donde me llamaron

.end	myputchar

//FUNCION MYPUTCHAR //////////////////////////////////////////////

//FUNCION MYGETCHAR //////////////////////////////////////////////	

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
		bne	a3, zero,sysKILL	// Reviso que el syscall no me mande error, si lo hay, salta al área de error

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

//FUNCION MYGETCHAR //////////////////////////////////////////////

//sysKILL ////////////////////////////////////////////////////////

sysKILL:
	li      v0, SYS_kill 		// invocación a terminar abruptamente el programa
       	move	a0, zero       		// pid = 0, programa actual
       	li      a1, SIGKILL		// SIGKILL = 9, terminar abruptamente
       	syscall

///////////////77/////////////////////////////////////////////////

//DATA ///////////////////////////////////////////////////////////

	.data
	.align	2
	
msgerr_myputchar:
        .asciiz "error writing to stdout\n"

msgerr_mygetchar:
        .asciiz "error reading from stdin\n"

msgerr_set2:
        .asciiz "empty set2\n"

	.type	map1, @object
	.size	map1, 1024
map1:
	.word	0
	.word	1
	.word	2
	.word	3
	.word	4
	.word	5
	.word	6
	.word	7
	.word	8
	.word	9
	.word	10
	.word	11
	.word	12
	.word	13
	.word	14
	.word	15
	.word	16
	.word	17
	.word	18
	.word	19
	.word	20
	.word	21
	.word	22
	.word	23
	.word	24
	.word	25
	.word	26
	.word	27
	.word	28
	.word	29
	.word	30
	.word	31
	.word	32
	.word	33
	.word	34
	.word	35
	.word	36
	.word	37
	.word	38
	.word	39
	.word	40
	.word	41
	.word	42
	.word	43
	.word	44
	.word	45
	.word	46
	.word	47
	.word	48
	.word	49
	.word	50
	.word	51
	.word	52
	.word	53
	.word	54
	.word	55
	.word	56
	.word	57
	.word	58
	.word	59
	.word	60
	.word	61
	.word	62
	.word	63
	.word	64
	.word	65
	.word	66
	.word	67
	.word	68
	.word	69
	.word	70
	.word	71
	.word	72
	.word	73
	.word	74
	.word	75
	.word	76
	.word	77
	.word	78
	.word	79
	.word	80
	.word	81
	.word	82
	.word	83
	.word	84
	.word	85
	.word	86
	.word	87
	.word	88
	.word	89
	.word	90
	.word	91
	.word	92
	.word	93
	.word	94
	.word	95
	.word	96
	.word	97
	.word	98
	.word	99
	.word	100
	.word	101
	.word	102
	.word	103
	.word	104
	.word	105
	.word	106
	.word	107
	.word	108
	.word	109
	.word	110
	.word	111
	.word	112
	.word	113
	.word	114
	.word	115
	.word	116
	.word	117
	.word	118
	.word	119
	.word	120
	.word	121
	.word	122
	.word	123
	.word	124
	.word	125
	.word	126
	.word	127
	.word	128
	.word	129
	.word	130
	.word	131
	.word	132
	.word	133
	.word	134
	.word	135
	.word	136
	.word	137
	.word	138
	.word	139
	.word	140
	.word	141
	.word	142
	.word	143
	.word	144
	.word	145
	.word	146
	.word	147
	.word	148
	.word	149
	.word	150
	.word	151
	.word	152
	.word	153
	.word	154
	.word	155
	.word	156
	.word	157
	.word	158
	.word	159
	.word	160
	.word	161
	.word	162
	.word	163
	.word	164
	.word	165
	.word	166
	.word	167
	.word	168
	.word	169
	.word	170
	.word	171
	.word	172
	.word	173
	.word	174
	.word	175
	.word	176
	.word	177
	.word	178
	.word	179
	.word	180
	.word	181
	.word	182
	.word	183
	.word	184
	.word	185
	.word	186
	.word	187
	.word	188
	.word	189
	.word	190
	.word	191
	.word	192
	.word	193
	.word	194
	.word	195
	.word	196
	.word	197
	.word	198
	.word	199
	.word	200
	.word	201
	.word	202
	.word	203
	.word	204
	.word	205
	.word	206
	.word	207
	.word	208
	.word	209
	.word	210
	.word	211
	.word	212
	.word	213
	.word	214
	.word	215
	.word	216
	.word	217
	.word	218
	.word	219
	.word	220
	.word	221
	.word	222
	.word	223
	.word	224
	.word	225
	.word	226
	.word	227
	.word	228
	.word	229
	.word	230
	.word	231
	.word	232
	.word	233
	.word	234
	.word	235
	.word	236
	.word	237
	.word	238
	.word	239
	.word	240
	.word	241
	.word	242
	.word	243
	.word	244
	.word	245
	.word	246
	.word	247
	.word	248
	.word	249
	.word	250
	.word	251
	.word	252
	.word	253
	.word	254
	.word	255
	.word	0

	.comm	map2,1024,4
