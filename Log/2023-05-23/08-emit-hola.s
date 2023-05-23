#--------------------------------------------------------------------
#-- INTERPRETE DE FORTH. Version 8
#-- 
#--  Implementación en ensamblador del programa Forth:
#--  72 emit 79 emit 76 emit 65 emit
#--
#-- Se imprime la palabra "HOLA"
#--
#--------------------------------------------------------------------

	.include "macros.h"

	.text

	#-- Inicializar la pila de datos
	la sp, stack
	
	#-- Inicializar la pila de retorno
	la s0, rstack

	#-- Programa Forth: 
	LIT(72)
	EMIT
	LIT(79)
	EMIT
	LIT(76)
	EMIT
	LIT(65)
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
	.space 4  #-- Tamaño 4 bytes
stack:

   #-----------------------
   #-- PILA de retorno
   #-- Elementos de 32 bits
   #-----------------------
   	.align 2  #-- Alinear a palabra
        .space 16  #-- Tamaño: 4 palabras
rstack:
