#----------------------------------------------------------------
#-- Implementacion de las palabras primitivas
#----------------------------------------------------------------			
	
		
	.globl do_1, do_add, do_point, do_lit			
					
	.include "macros.h"
	
	.text			
#---------------
#-- Palabra 1	
#--
#-- Meter 1 en la pila (PUSH 1)
#---------------

do_1:
      
	#-- Guardar el 1 en la pila
	PUSH_BYTE (1)
	
	#-- Hemos terminado
	ret
	
#---------------
#-- Palabra +
#--
#-- Obtener los dos ultimos elementos de la pila,
#-- sumarlos y depositar el resultado en la pila
#---------------
do_add:

	#-- Leer el primer elemento en t1
	POP_T0
	mv t1,t0
	
	#-- Leer segundo elemento
	POP_T0
	
	#-- Realizar la suma
	add t0, t0,t1
	
	#-- Guardar resultado en la pila
	PUSH_T0
	
	#-- Hemos terminado
	ret
	
#-------------------------
#-- Palabra .
#--
#-- Sacar el ultimo elemento de la pila e
#-- imprimirlo
#-------------------
do_point:
	
	#-- Sacar el elemento de la pila
	POP_T0
	
	#-- Imprimirlo
	PRINT_T0
	
	ret
	
	
#-----------------------------------
#-- Meter un literal en la pila
#-- a0: Literal a meter en la pila
#-----------------------------------	
do_lit:
	mv t0,a0
	PUSH_T0
	ret
		