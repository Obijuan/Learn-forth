#-- Palabras primitivas: W1 ,W2
#-- Simplemente imprimen los caracteres A y B en pantalla, respectivamente
#-- También EX para terminar

#-- El primer programa lo que hace es imprimir AB y termina

#-- Mejora: 
#-- Convertimos el codigo a subrutinas. Nuestro programa principal
#-- simplemente llama a las diferentes subrutinas, secuencialmente

    .include "so.s"

    .text

    #-- Ejecutar W1: Imprimir A
    jal code_W1

    #-- Ejecutar W2: Imprimir B
    jal code_W2

    #-- Ejecutar EX: Terminar
    jal code_EX

    .text
#-----------------------
# W1: Imprimir A 
#-----------------------
code_W1:
   SO_PRINT_CHAR('A')
   ret

    .text
#-----------------------
# W2: Imprimir B 
#-----------------------
code_W2:
   SO_PRINT_CHAR('B')
   ret

    .text
#-----------------------
# EX: Terminar
#-----------------------
code_EX:
   SO_PRINT_CHAR('\n')
   SO_EXIT
