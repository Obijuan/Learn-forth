#-- Palabras primitivas: W1 ,W2
#-- Simplemente imprimen los caracteres A y B en pantalla, respectivamente
#-- También EX para terminar

#-- El primer programa lo que hace es imprimir AB y termina

#-- Mejora: 
#-- Queremos definir este comportamiento de ejecutar 3 palabras
#-- secuencialmente en el SEGMENTO DE DATOS. De manera que solo con  
#-- cambiar DATOS, conseguimos ejecutar diferenets cosas..
#-- Las palabras a Ejecutar ahora son VARIABLES en el segmento
#-- de datos (que contienen la direccion al ejecutable en el 
#-- segmento de codigo)

    .include "so.s"

    .data

    #-- Definimos las palabras a Ejecutar
W1: .word code_W1   #-- Variable: Codeword: Direccion codigo ejecutable
W2: .word code_W2   #-- Codeword
EX: .word code_EX   #-- Codeword

    .text

    #-- Ejecutar W1: Imprimir A
    la a0, W1      #-- a0: Direccion de la palabra a Ejecutar
    lw t0, 0(a0)   #-- t0: Direccion del codigo ejecutable
    jalr t0

    #-- Ejecutar W2: Imprimir B
    la a0, W2      #-- a0: Direccion de la palabra a Ejecutar
    lw t0, 0(a0)   #-- t0: Direccion del codigo ejecutable
    jalr t0

    #-- Ejecutar EX: Terminar
    la a0, EX      #-- a0: Direccion de la palabra a Ejecutar
    lw t0, 0(a0)   #-- t0: Direccion del codigo ejecutable
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
