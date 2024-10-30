#-- JonesForth. Fundamentos de Forth

	#-- Servicios del sistema operativo del RARs
	.eqv EXIT 10        #-- Terminar
	.eqv PRINT_CHAR 11  #-- Imprimir un caracter
	
	#-- Macro para ejecutar la siguiente instruccion
	.macro NEXT
	  lw a0, 0(s1)    #-- a0: Direccion de la siguiente subrutina
	  addi s1, s1, 4  #-- s1: Apunta a la siguiente
	  mv t0,a0        #lw t0, 0(a0)
	  jalr t0	      #-- Ejecutarla!
	.end_macro
	
	 .data
	 
 	  #-- Lista con las subrutinas a ejecutar
 	  #-- Es NUESTRO PROGRAMA!
prog: .word pa, pb, pc, exit   
      #--    1   2   3   4
  
	
	.text
	
	#-- Inicializar registro S1
	#-- Hacemos que apunte a la siguiente subrutina
	la s1, prog
	addi s1,s1,4  #-- S1 apunta a la instruccion 2
	
	#-- Ejecutar la primera instrucciones!
	jal pa
	
	#-- Nunca se retorna
	
#-------------------------------
#-- pa: Imprimir el caracter A
#-------------------------------
pa:
	#-- Imprimir caracter A
	li a0, 'A'
	li a7, PRINT_CHAR
	ecall
	
	#-- Ejecutar siguiente instruccion
	NEXT
	
#-------------------------------
#-- pb: Imprimir el caracter B
#-------------------------------
pb:
	#-- Imprimir caracter B
	li a0, 'B'
	li a7, PRINT_CHAR
	ecall
	
	NEXT
	
#-------------------------------
#-- pc: Imprimir el caracter C
#-------------------------------
pc:
	#-- Imprimir caracter C
	li a0, 'C'
	li a7, PRINT_CHAR
	ecall
	
	NEXT
	
#--------------------
#-- Terminar
#--------------------
exit:

    li a0, '\n'
    li a7, PRINT_CHAR
    ecall
    
    #-- Terminar
	li a7, EXIT
	ecall
	
