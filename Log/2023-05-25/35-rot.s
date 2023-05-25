#--------------------------------------------------------------------
#-- INTERPRETE DE FORTH. Version 35
#-- 
#--  Implementación en ensamblador del programa Forth:
#--  1 2 3 rot . . . 
#--
#-- Resultado: 1 3 2  ok
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

	.text

	#-- Inicializar la pila de datos
	la sp, stack
	
	#-- Inicializar la pila de retorno
	la s0, rstack

	#-- Programa Forth: 
    LIT(1)
    LIT(2)
    LIT(3)
    ROT
    jal do_point
    jal do_point
    jal do_point
    
	#-- Interprete de forth: Imprimir " ok"
	PRINT_STRING (" ok\n")
	
	#-- Terminar
	EXIT
	

																							
#---------------------------------
#-- SEGMENTO DE DATOS
#---------------------------------	
	.data
	
   #-----------------------
   #-- PILA de Datos
   #----------------------	
	.space 16  #-- Tamaño 4 palabras
	.align 2
stack:

   #-----------------------
   #-- PILA de retorno
   #-- Elementos de 32 bits
   #-----------------------
        .space 16  #-- Tamaño: 4 palabras
rstack:
