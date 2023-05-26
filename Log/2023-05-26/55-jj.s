#--------------------------------------------------------------------
#-- INTERPRETE DE FORTH. Version 55
#-- 
#--  Implementación en ensamblador del programa Forth:
#--  5 0 do 10 0 do  j i + .  loop 10 emit 13 emit loop (Version compilada)
#--  
#--  Resultado: 
#    0 1 2 3 4 5 6 7 8 9 
#    1 2 3 4 5 6 7 8 9 10 
#    2 3 4 5 6 7 8 9 10 11 
#    3 4 5 6 7 8 9 10 11 12 
#    4 5 6 7 8 9 10 11 12 13 
#     ok
#--
#-- NOTA: para probarlo en gforth hay que compilarlo primero
#-- metiendolo en una palabra. Por ejemplo:
#-- : test cr 5 0 do 10 0 do  j i + .  loop 10 emit 13 emit loop ;
#--  Y luego ejecutando test
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

	#-- Programa Forth:
    # 5 0 do 10 0 do  j i + .  loop 10 emit 13 emit loop
    LIT(5)    
    LIT(0) 
    XDO      
bucle_ext:
      LIT(10)
      LIT(0)
      XDO
bucle_int:
        JJ
        II
        PLUS
        jal do_point
        XLOOP
        ADDR(bucle_int)
      LIT(10)
      EMIT
      LIT(13)
      EMIT
      XLOOP
      ADDR(bucle_ext)
    
	#-- Interprete de forth: Imprimir " ok"
	PRINT_STRING (" ok\n")
	
	#-- Terminar
	EXIT
	


