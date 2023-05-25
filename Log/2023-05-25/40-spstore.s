#--------------------------------------------------------------------
#-- INTERPRETE DE FORTH. Version 40
#-- 
#--  Implementación en ensamblador del programa Forth:
#--  0x2030 sp! 2 3 + . sp@ .
#--
#-- Resultado: 5 8240 ok
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
#---------------------------------------------

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
        .space 16  #-- Tamaño: 4 palabras
rstack:


#---------------------------
#-- CODIGO
#---------------------------
	.text

	#-- Inicializar la pila de datos
	la sp, stack
	
	#-- Inicializar la pila de retorno
	la s0, rstack

	#-- Programa Forth: 
    LIT(0x2030)
    SPSTORE
    
    LIT(2)
    LIT(3)
    PLUS
    jal do_point

    SPFETCH
    jal do_point
    
	#-- Interprete de forth: Imprimir " ok"
	PRINT_STRING (" ok\n")
	
	#-- Terminar
	EXIT
	

																							

