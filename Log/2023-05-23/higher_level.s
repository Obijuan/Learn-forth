#---------------------------------------------
#-- Palabras de alto nivel: Creadas a partir de
#--   palabras primitivas o de alto nivel
#------------------------------------------------

	.global do_add3

	.include "macros.h"

	.text
#--------------------------------
#-- Palabras de nivel superior	
#--------------------------------
do_add3:
	#-- Guardar direccion de retorno en la pila r
	PUSH_RA
	
	#-- Llamar a las palabras + +
	jal do_add
	jal do_add
	
	#-- Recuperar la direccion de retorno de la pila r
	POP_RA

	#-- Devolver control
	ret	
	
