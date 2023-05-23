#--------------------------------------------------------------------
#-- INTERPRETE DE FORTH. Version 6
#-- 
#--  Implementación en ensamblador del programa Forth:
#--  2 3 + .
#--
#-- Ahora los numeros 2 y 3 son literales, y no palabras
#--
#-- El resultado se imprime en la consola del simulador
#-- Una vez completado, termina
#--------------------------------------------------------------------

	.include "macros.h"

	.text

	#-- Inicializar la pila de datos
	la sp, stack
	
	#-- Inicializar la pila de retorno
	la s0, rstack

	#-- Programa Forth: 2 3 + .
	li a0, 2    
	jal do_lit #-- 2
	
	li a0, 3
	jal do_lit #-- 3
	
	jal do_add   #-- +
	jal do_point #-- .
			
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
