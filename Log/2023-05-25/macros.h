#------------------------------------------------
#-- MACROS
#------------------------------------------------

	#-----------------------------------
	#-- DE ACCESO AL SISTEMA OPERATIVO
	#-----------------------------------
	#-- Terminar el programa
	.macro EXIT
	  li a7, 10
	  ecall
	.end_macro	
	
	#-- Imprimir en la consola el registro t0
	.macro PRINT_T0
	  mv a0, t0
	  li a7, 1
	  ecall
	.end_macro
	
	#-- Imprimir la cadena indicada
	.macro PRINT_STRING (%str)
	  .data
myLabel:   .string %str
	  .text
	    la a0, myLabel
	    li a7, 4
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
	
	#----------------------------------------------------
	#-- PRIMITIVAS Y FUNCIONES DE ALTO NIVEL  
	#-- PARA LOS PROGRAMAS EN FORTH
	#----------------------------------------------------

	#--------- Alto nivel
	.macro HOME
	  jal do_home
	.end_macro

	.macro TEST_RFETCH
	  jal do_test_rfetch
	.end_macro

	.macro TEST_RPFETCH
	  jal do_test_rpfetch
	.end_macro

	#-- Primitivas
	.macro LIT (%val)
	   li a0, %val
	   jal do_lit
	.end_macro
	
	.macro EMIT
	  jal do_emit 
	.end_macro
	
	.macro KEY
	  jal do_key
	.end_macro
	
	.macro STORE
	  jal do_store
	.end_macro
	
	.macro PLUS
	  jal do_plus
	.end_macro
	
	.macro MINUS
	  jal do_minus
	.end_macro
	
	.macro LAND
	  jal do_and
	.end_macro

	.macro LOR
	  jal do_or
	.end_macro

	.macro LXOR
	  jal do_xor
	.end_macro

	.macro INVERT
	  jal do_invert
	.end_macro

	.macro NEGATE
	  jal do_negate
	.end_macro

	.macro ONEPLUS
	  jal do_oneplus
	.end_macro

	.macro ONEMINUS
	  jal do_oneminus
	.end_macro

	.macro TWOSTAR
	  jal do_twostar
	.end_macro

	.macro TWOSLASH
	  jal do_twoslash
	.end_macro

	.macro LSHIFT
	  jal do_lshift
	.end_macro

	.macro RSHIFT
	  jal do_rshift
	.end_macro

	.macro ZEROEQUAL
	  jal do_zeroequal
	.end_macro

	.macro ZEROLESS
	  jal do_zeroless
	.end_macro

	.macro EQUAL
	  jal do_equal
	.end_macro

	.macro LESS
	  jal do_less
	.end_macro

	.macro ULESS
	  jal do_uless
	.end_macro

	.macro DUP
	  jal do_dup
	.end_macro

	.macro QDUP
	  jal do_qdup
	.end_macro

	.macro DROP
	  jal do_drop
	.end_macro

	.macro SWAP
	  jal do_swap
	.end_macro

	.macro OVER
	  jal do_over
	.end_macro

	.macro ROT
	  jal do_rot
	.end_macro

	.macro FETCH
	  jal do_fetch
	.end_macro

	.macro CFETCH
	  jal do_cfetch
	.end_macro

	.macro CSTORE
	  jal do_cstore
	.end_macro

	.macro SPFETCH
	  jal do_spfetch
	.end_macro

	.macro SPSTORE
	  jal do_spstore
	.end_macro

	.macro RFETCH
	  jal do_rfetch
	.end_macro

	.macro RPFETCH
	  jal do_rpfetch
	.end_macro

	.macro RPSTORE
	  jal do_rpstore
	.end_macro

	




	

	
	
