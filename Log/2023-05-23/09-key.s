#--------------------------------------------------------------------
#-- INTERPRETE DE FORTH. Version 9
#-- 
#--  Implementación en ensamblador del programa Forth:
#--  key .
#--
#-- Se queda esperando a que se apriete una tecla y se imprime su
#--   codigo ascii
#--
#--  NOTA: En forth no se hace eco de la tecla pulsada...
#--   sin embargo en el RARS sí... y no hay un servicio para
#--   que no salga...
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
	KEY
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
