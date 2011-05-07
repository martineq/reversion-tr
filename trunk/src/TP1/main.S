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

#define NCHARS		256
#define	OOBCH		257

#define ARG2		48
#define ARG1		44
#define ARG0		40
#define O_RA		36
#define O_FP		32
#define O_GP		28
#define	VAR1		20
#define	VAR2		16

#define SSIZE		40

	.text
	.align	2

//FUNCION MAIN ///////////////////////////////////////////////////

	.globl	main
	.ent	main

main:
	.frame	$fp,SSIZE,ra
	.set	noreorder
	.cpload	t9
	.set	reorder			

	move	v0,zero
	move	v1,zero

	//Stack frame creation
		subu	sp,sp,SSIZE
		sw	ra,O_RA(sp)
		sw	$fp,O_FP(sp)
		.cprestore  O_GP 
		move	$fp,sp
	
	//invocación a la función: setup
		la	a0,map1
		la	a1,set1
		la	a2,set2
		jal	setup

	//Stack frame unwinding
		move	sp,$fp
		lw	ra,O_RA(sp)	
		lw	gp,O_GP(sp)
		lw	$fp,O_FP(sp)
		addiu	sp,sp,SSIZE
		j	ra

	.end main

//FUNCION MAIN ///////////////////////////////////////////////////

//FUNCION TR_S1 //////////////////////////////////////////////////
	.ent	tr_s1
tr_s1:
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

		sw	a0,ARG0($fp)		// almaceno a0 en ABA caller
		sw	zero,VAR1($fp)		// inicializo en 0 lastch
		sw	zero,VAR2($fp)		// inicializo en 0 ch

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

	.end	tr_s1
//FUNCION TR_S1 //////////////////////////////////////////////////

//FUNCION TR_S2 //////////////////////////////////////////////////
	.ent	tr_s2

tr_s2:
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

	//carga los argumentos en la ABA de la caller
		sw	a0,ARG0($fp)
		sw	a1,ARG1($fp)

	//cargamos las variables locales
		sw	zero,VAR1($fp)		//lastch es VAR1
		sw	zero,VAR2($fp)		//ch es VAR2

	//Inicio de la lógica de la función	
		lw	t0,ARG0($fp);
		bne	t0,zero,continuar_trs2

	//hace una llamada al sistema errx(1,"empty set2")
		li      v0, SYS_write 		// Aquí hago uso de <sys/syscall.h>. ssize_t write(int archivo, const void *buffer, size_t cantidad); 
        	li      a0, 2         		// a0: Salida de error.
        	la      a1, msgerr_tr_s2    	// a1: Puntero al mensaje de error.
        	li      a2, 12         		// a2: Longitud de caracteres (en este caso 24 bytes).
        	syscall	

	continuar_trs2:
		//invocacion a setup
		la	a0,map1
		lw	a1,ARG0($fp)
		lw	a2,ARG1($fp)
		jal	setup

		//invocacion a setup
		la	a0,map2
		lw	a1,ARG1($fp)
		move	a2,zero
		jal	setup

		j	condicion_trs2

	ciclo_trs2:
		la	s0,map1
		sll	t0,2		
		addu	t1,s0,t0		// t1 = map1[ch]
		lw	t1,0(t1)

		la	s1,map2
		sll	t0,2
		addu	t2,s1,t0		// t2 = map2[ch]
		lw	t2,0(t2)

		bne	t2,zero,condicion_trs2
		lw	t3,VAR1($fp)		// t3 = lastch
		beq	t3,t0,condicion_trs2

		sw	t0,VAR1($fp)		//lastch = ch
		move	a0,t0
		jal	myputchar

	condicion_trs2:
		jal	mygetchar
		move	t0,v0			// ch = mygetchar()
		not	t1,zero			// señal de EOF
		bne	t0,t1,ciclo_trs2	// verifico si no es EOF

	//Stack frame unwinding
		move	sp,$fp
		.cprestore  O_GP
		sw	$fp,O_FP(sp)
		sw	ra,O_RA(sp)
		addiu	sp,sp,SSIZE

	.end tr_s2
//FUNCION TR_S2 //////////////////////////////////////////////////

//FUNCION TR /////////////////////////////////////////////////////
//FUNCION TR /////////////////////////////////////////////////////

//FUNCION SETUP //////////////////////////////////////////////////

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
		bne	s1,zero,if2
		li	v0, SYS_exit		// Aquí hago uso de exit(1); 
		li	a0, 1			// a0: Valor de retorno:1
		syscall				// Llamo a exit
if2:
		bne	s2,zero,while_2
		addiu	t0,zero,NCHARS

	memset:
		sw	zero,0(s1)
		subu	t0,t0,1			
		addiu	s0,s0,4			
		bne	t0,zero,memset
	
	while_if2:				// while(*set1)
		lw	t0,0(s1)		
		beq	s1,zero,fin_setup;
		addiu	t1,zero,1		
		sll	t0,2			
		addu	t0,s0,t0		// to = direccion de map[*set1]
		sw	t1,0(t0)		// map[*set1] = 1
		addiu	s1,s1,4			// set1++
		j	while_if2

while_2:
		lw	t0,0(s1)		
		beq	t0,zero,fin_while2

		lw	t1,0(s2)		
		beq	t1,zero,fin_while2

		sll	t0,2
		addu	t0,s0,t0		// t3 = direccion de MAP[*set1]
		sw	t1,0(t0)		// MAP[*set1] = *SET2
		addiu	s1,s1,4			// set1++
		addiu	s2,s2,4			// set2++
		j	while_2	

fin_while2:
		lw	t1,VAR1($fp)
		addiu	t2,s2,-4
		lw	t1,0(t2)
while3:						//while(*set1)
		lw	t0,0(s1)		// t3 = *SET1
		beq	t0,zero,fin_setup;

		sll	t0,t0,2			// multiplo por 4 el contenido
		addu	t0,s0,t0		// direccion de map[*set1] en t3
		sw	t1,0(t0)		// map[*set1] = lastch
		addiu	s1,s1,4			// set1++
		j	while3

fin_setup:
		move	sp,$fp
		lw 	ra,O_RA(sp)
		lw 	gp,O_GP(sp)		
		lw 	$fp,O_FP(sp)		
		addiu 	sp,sp,SSIZE		
		jr ra				

	.end setup

//FUNCION SETUP //////////////////////////////////////////////////

//FUNCION MYPUTCHAR //////////////////////////////////////////////

	.ent myputchar			# Instrumenta símbolo de debugging.
myputchar:
		.frame	$fp,SSIZE,ra		# un Frame Pointer de tamaño SSIZE=8
		.set	noreorder
		.cpload	t9			# t9 se usa para guardar la llamada a func que vaya a usar.
		.set	reorder			

	#Stack frame creation
		subu	sp,sp,SSIZE
		sw	a0,ARG0(sp)		#almacena el argumento en la ABA de la función invocante.		
		sw	ra,O_RA(sp)
		.cprestore  O_GP 		# equivale a sw gp,O_GP(sp). Para código independiente de la función.
		sw	$fp,O_FP(sp) 		# Register saving: gp y fp. Leaf function.
		move	$fp,sp

	#llamada al sistema para imprimir por pantalla el caracter -- putchar(ch)	
		li      v0, SYS_write 		# Aquí hago uso de <sys/syscall.h>. ssize_t write(int archivo, const void *buffer, size_t cantidad); 
		li      a0, 1         		# a0: Salida standard.
		la      a1, ARG0($fp)     	# Puntero al caracter.
		li      a2, 1         		# a2: Longitud de caracteres (en este caso 1 byte). Lee solo de a uno.
		syscall				# Llamo a write
	
	# Reviso si hay errores
		bne	a3, zero, errorSYS_write	# Reviso que el SYS_write no me mande error, si lo hay, salta al área de error
		li	t0, 1				# Con esta linea y la de abajo me aseguro de haber...
		bne	v0, t0, errorSYS_write		# ...mandado un solo caracter, sino envio error
		j	fin_myputchar			# Si no hay errores llego hasta aquí y salto al fin

errorSYS_write:

	#Si tengo error debo enviar msg de error, devolver un 1 y terminar el programa. 
		li      v0, SYS_write 		# Aquí hago uso de <sys/syscall.h>. ssize_t write(int archivo, const void *buffer, size_t cantidad); 
        	li      a0, 2         		# a0: Salida de error.
        	la      a1, msgerr_myputchar    # a1: Puntero al mensaje de error.
        	li      a2, 24         		# a2: Longitud de caracteres (en este caso 24 bytes).
        	syscall	
		li	v0, SYS_exit		# Aquí hago uso de exit(1); 
		li	a0, 1			# a0: Valor de retorno:1
		syscall				# Llamo a exit

fin_myputchar:
		lw 	ra,O_RA($fp)
		lw 	gp,O_GP($fp)		# Cargo el gp del stack frame a gp...
		lw 	$fp,O_FP($fp)		# Cargo el fp del stack frame a $fp...
		addiu 	sp,sp,SSIZE		# Muevo el Stack pointer
		jr ra				# Vuelvo por donde me llamaron

	.end myputchar

//FUNCION MYPUTCHAR //////////////////////////////////////////////

//FUNCION MYGETCHAR //////////////////////////////////////////////

	.ent	mygetchar		# Instrumenta símbolo de debugging.

mygetchar:
	.frame	$fp,SSIZE,ra		# un Frame Pointer de tamaño SSIZE=16
	.set	noreorder
	.cpload	t9			# t9 se usa para guardar la llamada a func que vaya a usar.
	.set	reorder			

	#Stack frame creation
		subu	sp,sp,SSIZE
		sw	ra,O_RA(sp)
		sw	$fp,O_FP(sp) 		# Register saving: gp y fp. Leaf function.
		.cprestore  O_GP 		# equivale a sw gp,O_GP(sp). Para código independiente de la función.
		move	$fp,sp

	#lectura de caracter desde entrada
		li      v0, SYS_read 		# Aquí hago uso de <sys/syscall.h>. ssize_t read(int archivo, void *buffer, size_t cantidad);
        	li      a0, 0         		# a0=0 Entrada standard.
        	la      a1, VAR1($fp)       	# a1: Puntero al caracter.
        	li      a2, 1         		# a2: Longitud de caracteres (en este caso 1 byte). Lee solo de a uno.
        	syscall				# Llamo a read
	
	# Reviso si hay errores
		bne	a3, zero, errorSYS_read # Reviso que el SYS_read no me mande error, si lo hay, salta al área de error
		li	t0, 1			# Con esta linea y la de abajo me aseguro de haber...
		bne	v0, t0, errorSYS_read	# ...leido un solo caracter, sino envio error
        	lw      v0, VAR1($fp)   	# Devuelvo en v0 el valor del char leido. O sea hago el "return ch"		
		j	fin_mygetchar		# Si no hay errores llego hasta aquí y salto al fin

errorSYS_read:
	#Compruebo si es la señal de fin de archivo
		not	t0,zero			#señal de EOF
		beq	v0,t0,fin_mygetchar	#Se encontró el EOF

	#Si tengo error debo enviar msg de error, devolver un 1 y terminar el programa. 
		li      v0, SYS_write 		# Aquí hago uso de <sys/syscall.h>. ssize_t write(int archivo, const void *buffer, size_t cantidad); 
        	li      a0, 2         		# a0: Salida de error.
        	la      a1, msgerr_mygetchar   	# a1: Puntero al mensaje de error.
        	li      a2, 25         		# a2: Longitud de caracteres (en este caso 25 bytes).
        	syscall				# Llamo al write()
		li	v0, SYS_exit		# Aquí hago uso de exit(1); 
		li	a0, 1			# a0: Valor de retorno:1
		syscall				# Llamo al exit()

fin_mygetchar:
		move	sp,$fp
		lw	ra,O_RA($fp)
		lw	gp,O_GP($fp)		# Cargo el gp del stack frame a gp
		lw	$fp,O_FP($fp)		# Cargo el fp del stack frame a fp
		addiu sp,sp,SSIZE		# Muevo el Stack pointer
		jr ra				# Vuelvo por donde me llamaron

		.end	mygetchar

//FUNCION MYGETCHAR //////////////////////////////////////////////

//DATA ///////////////////////////////////////////////////////////
	
        .rdata
msgerr_tr_s2:
        .asciiz "empty set2\n"

msgerr_myputchar:
        .asciiz "error writing to stdout\n"

msgerr_mygetchar:
        .asciiz "error reading from stdin\n"

	.data
	.align	2
set1:
	.word	'a'
	.word	'b'
	.word	'c'
	.word	0
set2:
	.word	'A'
	.word	'B'
	.word	0

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
	.word	'\0'
	.local	map2
	.comm	map2,1024,4
