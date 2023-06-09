#--------------------------------------------------------------------
#-- INTERPRETE DE FORTH. Version 190
#-- 
#--  Implementación en ensamblador del programa Forth:
#--  LATEST @ .WINFO  
#--  LIT(0xCACA) CONSTANT 
#--  LATEST @ .WINFO  LATEST @ 6 .WCODE 
#--  QUIT
#--  
#--  Resultado: 
#--  Z80 CamelForth v1.01  25 Jan 1995
#--  
#--  0x10010118  Link: 0x100100f9 
#--  0x1001011c  Inmd: 0 
#--  0x1001011d  NLen: 03
#--  0x1001011e  Name: ESC
#--  0x10010124  CFA:  0x10010128 
#--  
#--  0x10010140  Link: 0x1001011d 
#--  0x10010144  Inmd: 0 
#--  0x10010145  NLen: 02
#--  0x10010146  Name: NL
#--  0x10010148  CFA:  0x1001014c 
#--  0x1001014c : 0xffc40413 
#--  0x10010150 : 0x00142023 
#--  0x10010154 : 0x004002b7 
#--  0x10010158 : 0x01c28293 
#--  0x1001015c : 0x000280e7 
#--  0x10010160 : 0x0000caca 
#--   ok
#--   ok
#--
#--------------------------------------------------------------------
#-- HACK PARA LITERALES!
#--
#-- Como dentro del codigo NO SE PUEDEN meter datos, los
#-- incrustamos en la instrucción lui (en sus 20-bits de mayor peso)
#--------------------------------------------------------------------
#-- HACK PARA LAS LITERALES DE DIRECCION DE SALTO:
#-- Se almacenan directamente con una instruccion j. Para realizar
#-- el salto se ejecuta esta instruccion directamente
#--------------------------------------------------------------------
#-- (TODO) Optimizacion para el futuro:
#--   -Dejar el elemento superior (TOS: Top of Stack) en un registro
#--     en vez de en la pila. Ahorra operaciones
#--------------------------------------------------------------------

#-------------------------------------------
#-- Registros: 
#--    sp = PSP  Param Stack Pointer
#--    s0 = RSP  Return Stack Pointer
#--    t0 = Forth TOS (top Param Stack item)
#--    t1 = W working register
#--    s1 = IP Interpreter Pointer
#--    s2 = UP User area Pointer
#----------------------------------------------------------------
#-- Nuestro IP es en realidad el PC. Al llamar a una palabra
#-- de alto nivel, tenemos en RA la siguiente instrucción forth
#----------------------------------------------------------------

	.include "macroCPU.h"
    .include "primitives.h"
    .include "high.h"

    .global do_uinit, ptib, docolon, dovar_code, docon_code, exit

#---------------------------------
#-- SEGMENTO DE DATOS
#---------------------------------	
	.data

#--------------------------------
#-- Terminal Input Buffer (TIB)
#-- Tamaño: 128 bytes
#-- Direccion: 0x2000
#--------------------------------
ptib:  #-- Puntero
    .byte '.', '.', ' ', ' '
    .byte ' ', 't', 'e', 's'
    .word 0x0,0x0,0x0,0,0,0,0,0,0,0,0,0,0,0 #-- 14 palabras
    .word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 #-- 16 palabras

.include "dicctionary.s"

#--- NOTA: Reservar espacio para el usuario!!!
    .space 1024

#--------------------------------
#-- Valores iniciales para el area de usuario
#-----------------------------------------
#-- Cabeza
#-- Cuerpo
#-- HACK: En el rars en el segmento de datos NO SE PUEDE METER
#--   codigo directamente en ensamblador, por lo que hay que ponerlo
#--   directamente en codigo máquina (y lo ejecuta ok)
#--   En el GNU-AS no hace falta. El codigo se puede poner 
#--   
#--  Se deposita en la pila la direccion de los valores iniciales
#--  del area de usuario
#       -- addr 
do_uinit: #--- CODIGO!!!!
    .word 0xFFC40413  #-- addi s0,s0,-4  | PUSH_RA
    .word 0x00142023  #-- sw ra,0(s0)    |

    #-- Saltar a la direccion del segmento de texto + 4 (offset de docreate)
    #-- Si segmento de texto comienza en 0, poner este salto:
    # .word 0x00000013  #-- nop
    # .word 0x00000013  #-- nop
    # .word 0x004000e7  #-- jalr ra,zero,4
    #-- Si segmento de texto comienza en 0x00400000 poner este otro salto:
    .word 0x004002b7  #-- lui t0, 0x400 | li t0, 0x00400000 (Dir seg texto)
    .word 0x00028293  #-- addi t0,t0,0  |
    .word 0x004280e7  #-- jalr ra,t0,4  | Saltar a 0x400004 (Dir de docreate)
                      #-- ra contiene la direccion de los datos que vienen
                      #-- a continuacion
#-- Parametros: valores iniciales area de usuario
uinit_params:
    .word 0,0,10,0  # reserved, >IN, BASE, STATE
    .word enddict   # DP
    .word 0,0       # SOURCE init'd elsewhere
    .word lastword   # LATEST
    .word 0         # HP init'd elsewhere



#----------- SITUAR AL FINAL DE LA RAM ----------------

#-----------------------
#-- USER AREA (128 bytes)
#-----------------------
user_area: #-- Botom of user area
    .word 0  #-- u0: Reservado.  Offset: 0x00
    .word 0  #-- >IN: Offset dentro de TIB. Offset: 0x04
    .word 0  #-- BASE: Conversion radix. Offset: 0x08
    .word 0  #-- STATE: Compiler state. Offset: 0x0C
    .word 0  #-- DP: Dictionary pointer. Offset: 0x10
    .word 0  #-- 'SOURCE: Two cells: len, addrs. Offset: 0x14
    .word 0  #--
    .word 0  #-- LATEST: Last word in dict. Offset: 0x1C
    .word 0  #-- HP: HOLD Pointer. Offset: 0x20
    .word 0  #-- LP: Leave-stack pointer. Offset: 0x24
    .space 88

   #-----------------------
   #-- PILA de Datos (Parameter stack. 128 bytes. Crece hacia abajo)
   #----------------------	
	.space 128  #-- Tamaño 32 palabras
	.align 2
stack:

#--------------------------------
#-- HOLD AREA 
#-- 40 bytes. Crece hacia abajo
#--------------------------------
    .space 40
    .align 2
phold:

#---------------------------------
#-- PAD BUFFER
#--  88 bytes
#---------------------------------
    .space 88
    .align 2
ppad:

#-----------------------
#-- PILA de retorno
#-- 128 bytes. Crece hacia abajo
#-----------------------
    .space 128
rstack:

#---------------------------------------------------------------
#-- CODIGO
#---------------------------------------------------------------
	.text

    j start

#--------------------------------------------------------------
#-- Codigo en direcciones fijas
#--------------------------------------------------------------
#---------------------------------------------------
#--  DOVAR, code action of VARIABLE, entered by CALL
#-- DOCREATE, code action of newly created words
#--    --- a-addr
#--
#-- Meter la direccion de la variable en la pila
#---------------------------------------------------
#-- Dirección 0x0004
dovar2:
docreate:

    #-- La direccion de la variable esta en ra
	#-- La matemos en la pila
	mv t0,ra
	PUSH_T0

	#--- NEXT
	POP_RA
	NEXT

#---------------------------------------------------
#-- DOCON, code action of CONSTANT
#---------------------------------------------------
#-- Direccion 0x001C
docon2:
	#-- Leer la constante en t0
	lw t0, 0(ra)

	#-- Meterla en la pila
	addi sp,sp,-4
	sw t0, 0(sp)

	#---- NEXT
	lw ra,0(s0)
	addi s0,s0,4
	ret

#-------------------------------------------------
#-- Codigo a copiar en el diccionario al crear
#-- una palabra nueva
#-------------------------------------------------
docolon:
    addi s0,s0,-4 # 0xffc40413  
    sw ra,0(s0)   # 0x00142023

#-------------------------------------------------
#-- Codigo a copiar en el diccionar al terminar
#-- una palabra nueva
#-------------------------------------------------
exit:
    lw ra,0(s0)   # 0x00042083  
    addi s0,s0,4  # 0x00440413  
    ret           # 0x00008067  

#-------------------------------------------------
#-- Codigo a copiar en el diccionar al crear
#-- una variable
#-------------------------------------------------
dovar_code:
    addi s0,s0, -4    # 0xffc40413   0
    sw ra, 0(s0)      # 0x00142023   4
    li t0, 0x00400004 # 0x004002b7   8
                      # 0x00428293   C
    jalr ra,t0,0      # 0x000280e7   10 

#-------------------------------------------------
#-- Codigo a copiar en el diccionar al crear
#-- una constante
#-------------------------------------------------
docon_code:
    addi s0,s0, -4    # 0xffc40413   0
    sw ra, 0(s0)      # 0x00142023   4
    li t0, 0x0040001C # 0x004002b7   8
                      # 0x01C28293   C
    jalr ra,t0,0      # 0x000280e7   10 


#-----------------------------------------------------------------------------
#--- INICIALIZACION DEL FORTH KERNEL
#-----------------------------------------------------------------------------
start:

	#-- Inicializar la pila de datos
	la sp, stack
	
	#-- Inicializar la pila de retorno
	la s0, rstack

    #-- Inicializar el puntero a la zona de usuario (UP)
    la s2, user_area

    #-- Inicializacion del sistema
    #-- (COLD)
    #-- COLD llama a quit, pero de momento lo hacemos manualmente
    COLD

    #-- Arrancar el modo interactivo (intérprete)
    #QUIT  #-- Nunca retorna de aquí

    #-- Modo ejecución directa (No interactivo)
    #-- Programa Forth: 
    QUIT 
   

    #-- Fin ejecución direct
    XSQUOTE(4," ok\n")
    TYPE

    QUIT

	#-- Terminar
	BYE
