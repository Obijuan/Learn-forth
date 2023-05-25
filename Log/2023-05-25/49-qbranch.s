#--------------------------------------------------------------------
#-- INTERPRETE DE FORTH. Version 49
#-- 
#--  Implementación en ensamblador del programa Forth:
#--  Programa sin salto (la condicion es 1)
#--  R@ . 1 ?branch 5 . 7 .
#--  Resultado: 32 5 7  ok
#--
#--  Programa con salto (la condicion es 0)
#--  R@ . 0 ?branch 5 . 7 .
#--  Resultado: 32 7  ok
#--  
#--------------------------------------------------------------------
#-- HACK PARA LITERALES!
#--
#-- Como dentro del codigo NO SE PUEDEN meter datos, los
#-- incrustamos en la instrucción lui (en sus 20-bits de mayor peso)
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

#---------------------------
#-- CODIGO
#---------------------------
	.text

	#-- Inicializar la pila de datos
	la sp, stack
	
	#-- Inicializar la pila de retorno
	la s0, rstack

    #-------------------------------------------
    #-- Hack: Hacemos esto para que en ra se meta
    #-- la dirección de la primera instrucción Forth
    #-- 
    jal ini
ini:
    #-- Meter la direccion de la primera instruccion
    #-- en la pila R (incrementada en 3 palabras)
    addi ra,ra,12
    PUSH_RA
    #-- Fin hack
    #------------------------------------------


	#-- Programa Forth: 7 0x2000 +! 0x2000 @ .
ini2:
    RFETCH          #-- Dir: 0x20
    jal do_point    #-- 0x24

    #--- Condicion de salto
    #--- 0---> Hacer salto
    #--- 1 --> No hacer salto
    LIT(0)          #-- 0x28 - 0x2C

    QBRANCH         #-- 0x30
    DW(0x44)        #-- 0x34

    LIT(5)          #-- 0x38 - 0x3C
    jal do_point    #-- 0x40

    LIT(7)          #-- 0x44 - 0x48
    jal do_point    #-- 0x4C
    
	#-- Interprete de forth: Imprimir " ok"
	PRINT_STRING (" ok\n")
	
	#-- Terminar
	EXIT
	


