
    #-- Servicios del S.O del RARs
    .eqv _PRINT_INT  1    #-- Imprimir numero entero
    .eqv _EXIT       10   #-- Terminar
    .eqv _PRINT_CHAR 11   #-- Imprimir un caracter

    .eqv NULL 0

    #--------------------------------
    #-- Macros de acceso al S.O
    #--------------------------------
    .macro SO_EXIT
      li a7, _EXIT
      ecall
    .end_macro

    #-- Entrada: a0: Registro a imprimir
    .macro SYS_PRINT_CHAR
      li a7, _PRINT_CHAR
      ecall
    .end_macro


    .macro SO_PRINT_CHAR (%character)
      li a0, %character
      li a7, _PRINT_CHAR
      ecall
    .end_macro

    .macro SYS_PRINT_INT
      li a7, 1
      ecall
    .end_macro

    .macro SYS_READ (%buffer,%len)
       li a0, 0
       la a1, %buffer
       li a2, %len
       li a7, 63
       ecall
    .end_macro

    #-- Macros estandares de FORTH
    .macro NEXT
      lw a0, 0(s1) #-- a0: Apunta a la codeword
      addi s1,s1,4 #-- s1: Apunta la siguiente palabra
      lw t0, 0(a0) #-- t0: Direccion del codigo ejecutable
      jalr t0      #-- Ejecutar la palabra!
    .end_macro

    #--- Otras macros

    #-- Almacenar un registro en la pila de datos
    .macro PUSH (%reg)
      addi sp,sp,-4
      sw %reg, 0(sp)
    .end_macro

    #-- Recuperar un registro de la pila de Datos
    .macro POP (%reg)
      lw %reg, 0(sp)
      addi sp,sp,4
    .end_macro

    #-- Recuperar un registro de la pila R
    .macro POPR (%reg)
      lw %reg, 0(fp)
      addi fp,fp,4
    .end_macro

    #-- Guardar un registro en la pila R
    .macro PUSHR (%reg)
      addi fp,fp,-4
      sw %reg, 0(fp)
    .end_macro

    .macro RCALL %symbol
	    PUSH ra			
	    jal %symbol
	    POP ra		
	  .end_macro