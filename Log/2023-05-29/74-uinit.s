#--------------------------------------------------------------------
#-- INTERPRETE DE FORTH. Version 73
#-- 
#--  Implementación en ensamblador del programa Forth:
#--  UINIT .A UINIT 36 DUMP
#--  
#--  Resultado: 
#--  2060 
#--  2060 00 00 00 00 00 00 00 00 0A 00 00 00 00 00 00 00 
#--  2070 88 20 00 00 00 00 00 00 00 00 00 00 84 20 00 00 
#--  2080 00 00 00 00 
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

#---------------------------
#-- CODIGO
#---------------------------
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


	#-- Programa Forth:
    #-- UINIT .A UINIT 36 DUMP
    UINIT
    DOTA           #-- Mostrar direccion inicializacion

    UINIT          #-- Volcar 36 bytes de la zona de inicializacion
    LIT(36)
    DUMP
    
	#-- Interprete de forth: Imprimir " ok"
	PRINT_STRING (" ok\n")
	
	#-- Terminar
	BYE
	


