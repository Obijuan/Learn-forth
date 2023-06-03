	#-------------------------------------------
	#-- PARA LA IMPLEMENTACION DE LAS PRIMITIVAS
	#-- DE FORTH
	#--------------------------------------------
	
	#-- Meter un valor en la pila
	#-- PUSH (x)
	.macro PUSH (%valor)
	  li t0, %valor
	  addi sp,sp,-4
	  sw t0, 0(sp)
	.end_macro	
	
	#-- Guardar el registro t0 en la pila
	.macro PUSH_T0
	  addi sp,sp,-4
	  sw t0, 0(sp)
	.end_macro
	
	#-- Meter el elemento de la pila en T0
	.macro POP_T0
	  lw t0, 0(sp)
	  addi sp,sp,4
	.end_macro

	#-- Guardar t0 en rstack
	.macro PUSHR_T0
	  addi s0,s0,-4
	  sw t0,0(s0)
	.end_macro

	#-- Leer la Pila R en t0
	.macro POPR_T0
	  lw t0, 0(s0)
	  addi s0,s0,4
	.end_macro
	
	#-----------------------------------------------
	#-- PARA IMPLEMENTACION DE LAS INSTRUCCIONES
	#-- DE NIVELES SUPERIORES
	#-----------------------------------------------
	#-- Guardar direccion de retorno en rstack
	.macro PUSH_RA
	  addi s0,s0,-4
	  sw ra,0(s0)
	.end_macro
	
	#-- Repucerar direccion de retorno de rstack
	.macro POP_RA
	   lw ra,0(s0)
	   addi s0,s0,4
	.end_macro


    #----------------------------------
	#-- LOGICA DEL INTERPRETE DE FORTH
	#----------------------------------

	#-- NEXT: Ejecutar la siguiente instruccion Forth
	#-- del hilo actual
	.macro NEXT
	  ret
	.end_macro

	#-- EXIT. Terminar una palabra de alto nivel
	# exit a colon definition
	.macro EXIT
	  #-- Recuperar la direccion de retorno de la pila r
	  POP_RA

	  #-- Devolver control
	  NEXT	
	.end_macro

	.macro EXECUTE
	  j do_execute
	.end_macro

	# ENTER, a.k.a. DOCOLON, entered by CALL ENTER
	# to enter a new high-level thread (colon def'n.)
	# (internal code fragment, not a Forth word)
	.macro DOCOLON
	    #-- Guardar direccion de retorno en la pila r
		PUSH_RA
	.end_macro

    	#-----------------------------------
	#-- DE ACCESO AL SISTEMA OPERATIVO
	#-----------------------------------
	#-- Terminar el programa
	.macro OS_EXIT
	  li a7, 10
	  ecall
	.end_macro	
	
	#-- Imprimir en la consola el registro t0
	.macro PRINT_T0
	  mv a0, t0
	  li a7, 1
	  ecall
	.end_macro
	
	#-- Imprimir el caracter que hay en T0
	.macro PRINT_CHAR_T0
	  mv a0, t0
	  li a7, 11 #-- Servicio printchar
	  ecall
	.end_macro
	
	#-- Esperar a que el usuario pulse un caracter
	#-- Se devuelve por t0
	.macro READ_CHAR_T0
	  li a7, 12
	  ecall
	  mv t0,a0
	.end_macro
	
    	#--- Para meter literales directamente en el codigo
	.macro DW(%val)
	  lui zero,%val
	.end_macro

	#-- Literal sin argumentos
	.macro LIT
	  jal do_lit
	.end_macro

	#-- Literal con argumentos
	.macro LIT (%val)
	   jal do_lit
	   DW(%val)
	.end_macro

	#--- Leer literal en t0
	.macro READLIT_T0
		#-- ra Contiene la dirección del LITERAL
		lw t0, 0(ra)
		#-- HACK: En realidad no es el literal exacto, esta
		#--  dentro de la instruccion lui (en los 20-bits de mayor peso)
		#-- Desplazar t0 >> 12  (12 bits a la derecha)
		srai t0,t0,12
	.end_macro

	#-- Literal direccion
	.macro ADDR(%label)
	  j %label
	.end_macro

	.macro DOCON
	  PUSH_RA
	  jal docon
	.end_macro

	.macro DOVAR
	  PUSH_RA
      jal dovar
	.end_macro

	.macro DOUSER
	  PUSH_RA
	  jal douser
	.end_macro