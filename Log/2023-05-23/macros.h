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
	
	
	#-------------------------------------------
	#-- PARA LA IMPLEMENTACION DE LAS PRIMITIVAS
	#-- DE FORTH
	#--------------------------------------------
	
	#-- Meter un valor en la pila
	#-- PUSH (x)
	.macro PUSH_BYTE (%valor)
	  li t0, %valor
	  addi sp,sp,-1
	  sb t0, 0(sp)
	.end_macro	
	
	#-- Guardar el registro t0 en la pila
	.macro PUSH_T0
	  addi sp,sp,-1
	  sb t0, 0(sp)
	.end_macro
	
	#-- Meter el elemento de la pila en T0
	.macro POP_T0
	  lb t0, 0(sp)
	  addi sp,sp,1
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
	


	

	
	
