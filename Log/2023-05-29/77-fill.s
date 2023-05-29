#--------------------------------------------------------------------
#-- INTERPRETE DE FORTH. Version 77
#-- 
#--  Implementación en ensamblador del programa Forth:
#--  0x20f8 48 DUMP 0x2108 16 0xAA 0x20f8 16 DUMP
#--  
#--  Resultado: 
#--    20F8 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
#--    2108 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F 
#--    2118 20 6F 6B 0A 00 00 00 00 00 00 00 00 00 00 00 00 
#--    
#--    20F8 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
#--    2108 AA AA AA AA AA AA AA AA AA AA AA AA AA AA AA AA 
#--    2118 20 6F 6B 0A 00 00 00 00 00 00 00 00 00 00 00 00 
#--     ok
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

	.include "macros.h"

    .global dovar, docreate, enddict

#---------------------------------
#-- SEGMENTO DE DATOS
#---------------------------------	
	.data

#-- Datos para hacer pruebas
test1: .word 73           #-- 0x2000
test2: .word 2531313      #-- 0x2004
test3: .byte 65  #-- 'A'  #-- 0x2008
test4: .byte 49  #-- '1'  #-- 0x2009
test5: .byte 50  #-- '2'  #-- 0x200A
test6: .byte 51  #-- '3'  #-- 0x200B
test7: .byte 0            #-- 0x200C
test8: .byte 0            #-- 0x200D
test9: .byte 0            #-- 0x200E
test10:.byte 0            #-- 0x200F

   #-----------------------
   #-- PILA de Datos
   #----------------------	
	.space 16  #-- Tamaño 4 palabras
	.align 2
stack:

   #-- Otra Pila, para pruebas
    .space 16
    .align 2
tstack:

   #-----------------------
   #-- PILA de retorno
   #-- Elementos de 32 bits
   #-----------------------
    #-- Tamaño: 4 palabras
    #-- Estan inicializadas para hacer pruebas
    .word 0x01
    .word 0x02
    .word 0x03
    .word 0x04
rstack:
    .word 0xFF  #-- Valor inicial. Usado para pruebas

   #-- Otra Pila R, para pruebas
   .space 16  #-- Tamaño: 4 palabras
   .align 2
rstack2:      #-- Dir: 0x2054

#--------------------------------
#-- Valores iniciales para el area de usuario
#-----------------------------------------
#-- Cabeza
#-- Cuerpo
#-- HACK: En el rars en el segmento de datos NO SE PUEDE METER
#--   codigo directamente en ensamblador, por lo que hay que ponerlo
#--   directamente en codigo máquina (y lo ejecuta ok)
#--   En el GNU-AS no hace falta. El codigo se puede poner directamente
do_uinit:
    .word 0xFFC40413  #-- addi s0,s0,-4  | PUSH_RA
    .word 0x00142023  #-- sw ra,0(s0)    |
    .word 0x004000e7  #-- jalr ra,zero,4    (jal docreate) (4 es la dir de dovar)

#-- Parametros: valores iniciales area de usuario
uinit_params:
    .word 0,0,10,0  # reserved, >IN, BASE, STATE
    .word enddict   # DP
    .word 0,0       # SOURCE init'd elsewhere
    .word lastword  # LATEST
    .word 0         # HP init'd elsewhere


#-------------------------
#-- Diccionario
#-------------------------

#-- Nota: Debe valer link (enlace a la ultima palabra del diccionario)
#-- Pero de momento ponemos su valor a 0
lastword: .word 0   # nfa of last word in dict. 

#-- Fin del diccionario
enddict: #-- Aqui comienza el codigo del usuario

#-----------------------
#-- USER AREA (128 bytes)
#-----------------------
user_area: #-- Botom of user area
    .space 128


test:
    .byte 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07
    .byte 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F 

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
dovar:
docreate:

    #-- La direccion de la variable esta en ra
	#-- La matemos en la pila
	mv t0,ra
	PUSH_T0

	#--- NEXT
	POP_RA
	NEXT


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


	#-- Programa Forth:
    #-- 0x20f8 48 DUMP 0x2108 16 0xAA 0x20f8 16 DUMP
    LIT(0x20f8)
    LIT(48)
    DUMP

    LIT(0x2108)
    LIT(16)
    LIT(0xAA)
    FILL

    LIT(0x20f8)
    LIT(48)
    DUMP
    
	#-- Interprete de forth: Imprimir " ok"
	PRINT_STRING (" ok\n")
	
	#-- Terminar
	BYE
	




