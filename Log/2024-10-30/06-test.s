#-- Palabras primitivas: W1 ,W2
#-- Simplemente imprimen los caracteres A y B en pantalla, respectivamente
#-- También EX para terminar

#-- El primer programa lo que hace es imprimir AB y termina

#-- Mejora: 
#-- Ahora definimos el comportamiento como la palabra TEST
#-- que conlleva la ejecucion secuencial de las palabras W1, W2 y EX
#-- Simplemente cambiando sus valores, podemos definir nuevas
#-- palabras, con comportamientos distintos, sin tocar codigo!!
#-- Ese es el objetivo! Crear cosas nuevas sin escribir codigo
#-- en ensamblador! Solo mediante la definicion de VARIABLES en el
#-- segmento de datos

    .include "so.s"

    .data

    #-- Palabra a ejecutar. Formada por otras 3 palabras
    #-- La ejecucion de TEST significa llamar secuencialmente
    #-- a W1, W2 y EX
TEST:   
    .word W1   #-- Variable: Palabra 1 (apunta al codeword de W1)
    .word W2   #-- Variable: Palabra 2
    .word EX   #-- Variable: Palabra 3

    #-- Definimos las palabras a Ejecutar
W1: .word code_W1   #-- Variable: Codeword: Direccion codigo ejecutable
W2: .word code_W2   #-- Codeword
EX: .word code_EX   #-- Codeword

    .text

    #-- El codigo para ejecutar cada palabra es siempre el mismos
    #-- lo unico que cambia es el valor de s1, que es el que apunta
    #-- a la instruccion a ejecutar
    #-- Basta incrementarlo en 4 unidades para ejecutar la siguiente

    #-- S1 apunta a W1    
    la s1,TEST  #-- s1 apunta a la Variable con la palabra a ejecutar
                #-- s1 es el IP (Puntero de instruccion)

    #-- Ejecutar W1: Imprimir A
    lw a0, 0(s1) #-- a0: Apunta a la codeword
    lw t0, 0(a0) #-- t0: Direccion del codigo ejecutable
    jalr t0

    #-- Hacer que s1 apunte a la siguiente palabra: W2
    addi s1,s1,4

    #-- Ejecutar W2: Imprimir B
    lw a0, 0(s1) #-- a0: Apunta a la codeword
    lw t0, 0(a0) #-- t0: Direccion del codigo ejecutable
    jalr t0

    #-- Apuntar a EX
    addi s1,s1,4

    #-- Ejecutar EX: Terminar
    lw a0, 0(s1) #-- a0: Apunta a la codeword
    lw t0, 0(a0) #-- t0: Direccion del codigo ejecutable
    jalr t0

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
