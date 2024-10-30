#-- Palabras primitivas: W1 ,W2
#-- Simplemente imprimen los caracteres A y B en pantalla, respectivamente
#-- También EX para terminar

#-- El primer programa lo que hace es imprimir AB y termina

    .include "so.s"

    .text

    #-- Implementacion de W1
    #-- Imprimir 'A'
    li a0, 'A'
    li a7, PRINT_CHAR
    ecall

    #-- Implementacion de W2
    li a0, 'B'
    li a7, PRINT_CHAR
    ecall


    #---- Implementacion de EX
 
    #-- Imprimir salto de linea
    li a0, '\n'
    li a7, PRINT_CHAR
    ecall 

    #-- Terminar
    li a7, EXIT
    ecall
