#---------------------------------------------
#-- Palabras de alto nivel: Creadas a partir de
#--   palabras primitivas o de alto nivel
#------------------------------------------------

	.global do_u0, do_ninit, do_count, do_twodup
	.global do_add3, do_home, do_test_rfetch, do_test_rpfetch

	.include "macros.h"

	.text

#-------------------------------------------------------------
#- u0      -- a-addr       current user area adrs
#- Devolver direccion de la zona de usuario (parte inferior)
#-------------------------------------------------------------
do_u0:
    DOUSER
    DW(0)


#----------------------------------------------------
#--  #init    -- n    #bytes of user area init data
#----------------------------------------------------
do_ninit:
  DOCON
  DW(36)  #-- 9 palabras (de 4 bytes)

#----------------------------------------------------
#-- COUNT   c-addr1 -- c-addr2 u  counted->adr/len
#   DUP CHAR+ SWAP C@ ;
#----------------------------------------------------
do_count:
	DOCOLON
	DUP
	CHARPLUS
	SWOP      #-- Es swap
	CFETCH
	EXIT

#----------------------------------------------------
#-- 2DUP   x1 x2 -- x1 x2 x1 x2   dup top 2 cells
#   OVER OVER ;
#----------------------------------------------------
do_twodup:
	DOCOLON
	OVER
	OVER
	EXIT

#------------------------- PRUEBAS ------------------------------------------

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

#--- Prueba para RP@
do_test_rpfetch:
    #-- Guardar direccion de retorno
	PUSH_RA
	
	RPFETCH

	#-- Recuperar direccion de retorno
	POP_RA
	ret
				