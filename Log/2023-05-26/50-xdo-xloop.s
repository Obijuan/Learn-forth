#--------------------------------------------------------------------
#-- INTERPRETE DE FORTH. Version 50
#-- 
#--  Implementación en ensamblador del programa Forth:
#--  5 0 do 65 emit loop (Version compilada)
#--  
#--  Resultado: test AAAAA ok
#--
#-- NOTA: para probarlo en gforth hay que compilarlo primero
#-- metiendolo en una palabra. Por ejemplo:
#-- : test 5 0 do 65 emit loop ;
#--  Y luego ejecutando test
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

ini2:  #-- Dir: 0x10

	#-- Programa Forth:
    LIT(5)   #-- Limite  #-- 0x10 - 0x14 
    LIT(0)   #-- Index   #-- 0x18 - 0x1C
    XDO      #-- 0x20
    LIT(65)  #-- 0x24 - 0x28
    EMIT     #-- 0x2C
    XLOOP    #-- 0x30
    DW(0x24) #-- 0x34  (Almacena direccion siguiente a XDO)
    
	#-- Interprete de forth: Imprimir " ok"
	PRINT_STRING (" ok\n")
	
	#-- Terminar
	EXIT
	


