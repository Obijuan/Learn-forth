#-- Palabras primitivas: W1 ,W2
#-- Simplemente imprimen los caracteres A y B en pantalla, respectivamente
#-- También EX para terminar

#-- El primer programa lo que hace es imprimir AB y termina

#-- Mejora: Añadimos macros para los servicios del sistema operativo
#--  así no hay que repetir codigo

    .include "so.s"

    .text

    #-- Implementacion de W1
    #-- Imprimir 'A'
    SO_PRINT_CHAR('A')

    #-- Implementacion de W2
    SO_PRINT_CHAR('B')

    #---- Implementacion de EX
    SO_PRINT_CHAR('\n')
    SO_EXIT
