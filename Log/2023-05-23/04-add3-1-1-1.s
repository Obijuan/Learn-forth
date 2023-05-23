#--------------------------------------------------------------------
#-- INTERPRETE DE FORTH. Version 4
#-- 
#--  Implementación en ensamblador del programa Forth:
#--  1 1 1 add3 .
#--
#-- Donde ahora add3 es una instrucción de nivel superior, definida
#--  a partir de palabras primitivas
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

	#-- Programa Forth: 1 1 1 add3 .
	jal do_1
	jal do_1
	jal do_1
	jal do_add3
	jal do_point
			
	#-- Interprete de forth: Imprimir " ok"
	PRINT_STRING ("  ok\n")
	
	#-- Terminar
	EXIT
		
#--------------------------------
#-- Palabras de nivel superior	
#--------------------------------
do_add3:
	#-- Guardar direccion de retorno en la pila r
	addi s0,s0,-4
	sw ra, 0(s0)
	
	#-- Llamar a las palabras + +
	jal do_add
	jal do_add
	
	#-- Recuperar la direccion de retnor de la pila r
	lw ra, 0(s0)
	addi s0,s0,4

	#-- Devolver control
	ret	
		
		
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
