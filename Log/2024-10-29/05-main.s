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
TEST: .word PA, PB, PC, EX   
      #--    1   2   3   4
  
	.text
	
	#-- Inicializar registro S1
	#-- Hacemos que apunte a la siguiente subrutina
	la s1, TEST
	addi s1,s1,4  #-- S1 apunta a la instruccion 2
	
	#-- Ejecutar la primera instrucciones!
	jal code_pa
	
	#-- Nunca se retorna  
  
  
#-------------------------------
#-- PA: Imprimir el caracter A
#-------------------------------
	  .data
PA:   .word code_pa
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
	