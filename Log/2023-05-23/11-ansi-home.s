#--------------------------------------------------------------------
#-- INTERPRETE DE FORTH. Version 11
#-- 
#--  Implementación en ensamblador del programa Forth:
#--  HOME 27 emit 91 emit 50 emit 74 emit
#--
#--  Se borra la pantalla y se lleva el cursor a home
#--  
#--
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
	HOME
	LIT(27)
	EMIT
	LIT(91)
	EMIT
	LIT(50)
	EMIT
	LIT(74)
	EMIT
			
	#-- Interprete de forth: Imprimir " ok"
	PRINT_STRING ("  ok\n")
	
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
