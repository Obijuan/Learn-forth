#-- JonesForth. Fundamentos de Forth
#-- En este primer ejemplo se llama a 3 subrutinas

	#-- Servicios del sistema operativo del RARs
	.eqv EXIT 10        #-- Terminar
	.eqv PRINT_CHAR 11  #-- Imprimir un caracter
	
	.text
	
	#-- Ejecutar las subrutinas
	jal pa
	jal pb
	jal pc
	jal exit
	
	#-- Nunca se retorna
	
#-------------------------------
#-- pa: Imprimir el caracter A
#-------------------------------
pa:
	#-- Imprimir caracter A
	li a0, 'A'
	li a7, PRINT_CHAR
	ecall
	
	ret
	
#-------------------------------
#-- pb: Imprimir el caracter B
#-------------------------------
pb:
	#-- Imprimir caracter B
	li a0, 'B'
	li a7, PRINT_CHAR
	ecall
	
	ret
	
	
#-------------------------------
#-- pc: Imprimir el caracter C
#-------------------------------
pc:
	#-- Imprimir caracter C
	li a0, 'C'
	li a7, PRINT_CHAR
	ecall
	
	ret
	
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
	
