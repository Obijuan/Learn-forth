#-- Palabras primitivas: W1 ,W2
#-- Simplemente imprimen los caracteres A y B en pantalla, respectivamente
#-- También EX para terminar

#-- El primer programa lo que hace es imprimir AB y termina

#-- Mejora: 
#-- El codigo es practicamente igual que en el ejemplo anterior
#-- Modificamos el programa principal para que el registro s1
#-- se incremente tras leer la codeword. De esta forma s1 SIEMPRE
#-- apunta a la siguiente palabra a ejecutar (por definicion)
#-- Lo que observamos es que ahora: EL CODIGO PARA EJECUTAR
#-- LAS PALABRAS ES SIEMPRE EL MISMO!!! Salvo la inicializacion
#-- de s1... Las 4 instrucciones para ejecutar cada palabra son ahora
#-- exactamente iguales!!!!!!!

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
    addi s1,s1,4 #-- s1: Apunta la siguiente palabra
    lw t0, 0(a0) #-- t0: Direccion del codigo ejecutable
    jalr t0


    #-- Ejecutar W2: Imprimir B
    lw a0, 0(s1) #-- a0: Apunta a la codeword
    addi s1,s1,4 #-- s1: Apunta la siguiente palabra
    lw t0, 0(a0) #-- t0: Direccion del codigo ejecutable
    jalr t0


    #-- Ejecutar EX: Terminar
    lw a0, 0(s1) #-- a0: Apunta a la codeword
    addi s1,s1,4 #-- s1: Apunta la siguiente palabra
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
