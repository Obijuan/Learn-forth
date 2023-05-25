#---------------------------------------------
#-- Palabras de alto nivel: Creadas a partir de
#--   palabras primitivas o de alto nivel
#------------------------------------------------

	.global do_add3, do_home, do_test_rfetch

	.include "macros.h"

	.text
#--------------------------------
#-- Palabras de nivel superior	
#--------------------------------
do_add3:
	#-- Guardar direccion de retorno en la pila r
	PUSH_RA
	
	#-- Llamar a las palabras + +
	PLUS
	PLUS
	
	#-- Recuperar la direccion de retorno de la pila r
	POP_RA

	#-- Devolver control
	ret	
	
#--- HOME: Llevar el cursor a HOme
do_home:
        #-- Guardar direccion de retorno
	PUSH_RA
	
	LIT(27)
	EMIT
	LIT(91)
	EMIT
	LIT(72)
	EMIT
	
	#-- Recuperar direccion de retorno
	POP_RA
	ret

#--- Prueba para R@
#--- Al entrar aquí se guarda la direccion de retorno en la pila R
#--- Se llama a R@ para guardar este valor en la pila
#--- (Desde el nivel 0 la pila R está vacia, por eso hay que
#---  llamarla desde esta palabra de nivel superior)
do_test_rfetch:
    #-- Guardar direccion de retorno
	PUSH_RA
	
	RFETCH

	#-- Recuperar direccion de retorno
	POP_RA
	ret