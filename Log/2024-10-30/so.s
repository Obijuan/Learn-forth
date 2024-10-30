
    #-- Servicios del S.O del RARs
    .eqv _PRINT_INT  1    #-- Imprimir numero entero
    .eqv _EXIT       10   #-- Terminar
    .eqv _PRINT_CHAR 11   #-- Imprimir un caracter

    #-- Macros de acceso al S.O
    .macro SO_EXIT
      li a7, _EXIT
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

    #-- Macros estandares de FORTH
    .macro NEXT
      lw a0, 0(s1) #-- a0: Apunta a la codeword
      addi s1,s1,4 #-- s1: Apunta la siguiente palabra
      lw t0, 0(a0) #-- t0: Direccion del codigo ejecutable
      jalr t0      #-- Ejecutar la palabra!
    .end_macro
