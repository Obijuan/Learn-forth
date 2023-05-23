#--------------------------------------------------------------------
#-- INTERPRETE DE FORTH. Version 10
#-- 
#--  Implementación en ensamblador del programa Forth:
#--  0xCACA 0x2100 !  
#--
#--  0xCACA -> [0x2100]. Almacenar 0xCACA en la dirección 0x2100
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
	LIT(0xCACA)
	LIT(0x2100)
	STORE
			
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
