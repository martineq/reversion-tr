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

#define ARG2		48
#define ARG1		44
#define ARG0		40
#define O_RA		36
#define O_FP		32
#define O_GP		28
#define	VAR1		20

#define SSIZE		40

	.text
	.align	2
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

	.end	setup

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

	.globl map1
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

	.globl	map2
	.comm	map2,1024,4
