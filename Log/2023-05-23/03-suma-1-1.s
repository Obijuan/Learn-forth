#--------------------------------------------------------------------
#-- INTERPRETE DE FORTH. Version 3
#--
#--  Implementación en ensamblador del programa Forth:
#--  1 1 + .
#--
#-- El resultado se imprime en la consola del simulador
#-- Una vez completado, termina
#--------------------------------------------------------------------

	.include "macros.h"

	.text

	#-- Inicializar la pila
	la sp, stack

	#-- Programa Forth: 1 1 + .
	jal do_1
	jal do_1
	jal do_add
	jal do_point
			
	#-- Interprete de forth: Imprimir " ok"
	PRINT_STRING ("  ok\n")
	
	#-- Terminar
	EXIT
		
#---------------------------------
#-- SEGMENTO DE DATOS
#---------------------------------	
	.data
	
   #-----------------------
   #-- PILA
   #----------------------	
	.space 4
stack:

