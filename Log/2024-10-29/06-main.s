#-- JonesForth. Fundamentos de Forth

	#-- Servicios del sistema operativo del RARs
	.eqv EXIT 10        #-- Terminar
	.eqv PRINT_CHAR 11  #-- Imprimir un caracter
	
	#-- Macro para ejecutar la siguiente instruccion
	.macro NEXT
	  lw a0, 0(s1)    #-- a0: Direccion del codeword de la palabra
	  addi s1, s1, 4  #-- s1: Apunta a la siguiente palabra
	  lw t0, 0(a0)    #-- Leer direccion del interprete
	  jalr t0	      #-- Ejecutar interprete
	.end_macro
	
	 .data
	 
 	  #-- Palabra definida en FORTH
TEST:   .word DOCOL		# codeword
	    .word PA
	    .word PB
	    .word PC
	    .word EX		

  	#-- Arranque del interprete
  	#-- Se indica la primera palabra a ejecutar
cold_start:
    .word TEST  #-- Caso especial: No tiene codeword

	.text
	
	#-- Inicializar la pila R
	la fp, return_stack_top 
	
	#-- Arrancar el interprete
	la s1, cold_start      	
	NEXT
	
	#-- Nunca se retorna  
  
  
#---------------------------------------
#- DOCOL: Interprete de palabras Forth 
#---------------------------------------
#-  a0: Direccion del codeword (interprete)

    .text
DOCOL:
    #-- Insertar s1 en la pila R
	addi fp, fp, -4  
	sw s1, 0(fp)

	#-- a0: que apunte a la siguiente palabra
	addi a0,a0, 4
	
	#-- s1: Apuntar a la siguiente palabra
	mv s1, a0
	
	#-- Ejecutar siguiente palabra
	NEXT
  
  
#-------------------------------
#-- PA: Imprimir el caracter A
#-------------------------------
	  .data
PA:   .word code_pa #-- codeword
	  .text
code_pa:
	li a0, 'A'
	li a7, PRINT_CHAR
	ecall
	
	NEXT



#-------------------------------
#-- PB: Imprimir el caracter B
#-------------------------------
	  .data
PB:   .word code_pb
	  .text
code_pb:
	li a0, 'B'
	li a7, PRINT_CHAR
	ecall
	
	NEXT


#-------------------------------
#-- PC: Imprimir el caracter C
#-------------------------------
	  .data
PC:   .word code_pc
	  .text
code_pc:
	#-- Imprimir caracter C
	li a0, 'C'
	li a7, PRINT_CHAR
	ecall
	
	NEXT


#--------------------
#-- Terminar
#--------------------
	  .data
EX:   .word code_ex
	  .text
code_ex:

    li a0, '\n'
    li a7, PRINT_CHAR
    ecall
    
    #-- Terminar
	li a7, EXIT
	ecall
	
	.data
  	#-- PILA R
  	.space 40
return_stack_top:


	.data
	#-- Pila de datos
var_S0:
		