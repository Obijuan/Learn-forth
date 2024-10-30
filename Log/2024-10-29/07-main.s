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
	
	
	.text
	
	#-- Inicializar la pila R
	la fp, return_stack_top 
	
	#-- Arrancar el interprete
	la s1, cold_start      	
	NEXT
	
	#-- Nunca se retorna  
	
	.data
  	#-- Arranque del interprete
  	#-- Se indica la primera palabra a ejecutar
cold_start:
    .word TEST  #-- Caso especial: No tiene codeword	
	
#---------------------------------------------------
#-- Diccionario 
#---------------------------------------------------

#-- Ejemplo de palabra primitiva
    .data
name_DROP:
    .word 0  #-- NULL (Puntero a siguiente palabra)
    .byte 4  #-- Longitud del nombre + flags
    .ascii "DROP"  #-- Nombre de la palabra FORTH
    .align 2
DROP:
    .word code_DROP  #-- Codeword
    .text
code_DROP:  #-- Codigo en asm
    nop
    nop
    NEXT	


#----------------------------
#-- PA. Imprimir caracter A 
#----------------------------
    .data
name_PA:
    .word name_DROP  #-- NULL (Puntero a siguiente palabra)
    .byte 2          #-- Longitud del nombre + flags
    .ascii "PA"      #-- Nombre de la palabra FORTH
    .align 2
PA:
    .word code_PA  #-- Codeword
    .text
code_PA:  #-- Codigo en asm
    li a0, 'A'
	li a7, PRINT_CHAR
	ecall
	NEXT
	
	
#----------------------------
#-- PB. Imprimir caracter B 
#----------------------------
    .data
name_PB:
    .word name_PA  #-- NULL (Puntero a siguiente palabra)
    .byte 2          #-- Longitud del nombre + flags
    .ascii "PB"      #-- Nombre de la palabra FORTH
    .align 2
PB:
    .word code_PB  #-- Codeword
    .text
code_PB:  #-- Codigo en asm
    li a0, 'B'
	li a7, PRINT_CHAR
	ecall
	NEXT
	
#----------------------------
#-- PC. Imprimir caracter C 
#----------------------------
    .data
name_PC:
    .word name_PB  #-- NULL (Puntero a siguiente palabra)
    .byte 2          #-- Longitud del nombre + flags
    .ascii "PC"      #-- Nombre de la palabra FORTH
    .align 2
PC:
    .word code_PC  #-- Codeword
    .text
code_PC:  #-- Codigo en asm
    li a0, 'C'
	li a7, PRINT_CHAR
	ecall
	NEXT
	
#-------------------------------
#-- EX. Servicio EXIT del RARs 
#-------------------------------
    .data
name_EX:
    .word name_PC  #-- NULL (Puntero a siguiente palabra)
    .byte 2          #-- Longitud del nombre + flags
    .ascii "EX"      #-- Nombre de la palabra FORTH
    .align 2
EX:
    .word code_EX  #-- Codeword
    .text
code_EX:  #-- Codigo en asm
    li a0, '\n'
    li a7, PRINT_CHAR
    ecall
    
    #-- Terminar
	li a7, EXIT
	ecall
	
#--------------------------------------
#-- TEST. Definida en FORTH
#-------------------------------------	
	 .data
name_TEST:
     .word name_EX
     .byte 4
     .ascii "TEST"
     .align 2
TEST:
	 .word DOCOL  # Codeword
	 .word PA
	 .word PB
	 .word PC
	 .word EX
	 

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



	#-- PILA R
	.data
  	.space 40
return_stack_top:

	#-- Pila de datos
	.data
var_S0:
		