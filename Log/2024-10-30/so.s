
    #-- Servicios del S.O del RARs
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
