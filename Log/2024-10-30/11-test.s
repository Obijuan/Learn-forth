#-- Palabras primitivas: W1 ,W2
#-- Simplemente imprimen los caracteres A y B en pantalla, respectivamente
#-- También EX para terminar

#-- El primer programa lo que hace es imprimir AB y termina

#-- Mejora: 
#-- Pasamos el flag sm al RARS para que comience ejecutando
#-- el codigo que se encuentra definido en la etiqueta global main
#-- Por ello ahora ya SÍ que podemos poner el programa principal
#-- en CUALQUIER PARTE de la memoria
#--
#-- Comenzamos primero definiendo el segmento de datos
#-- con sus palabras (que tienen datos y codigo)
#-- Al final ponemos el main


    .include "so.s"

#---------------------------------------------------
#-- Definimos las palabras de nuestro sistema
#---------------------------------------------------
    .data
    #-- Palabra a ejecutar. Formada por otras 3 palabras
    #-- La ejecucion de TEST significa llamar secuencialmente
    #-- a W1, W2 y EX
TEST:   
    .word W1   #-- Variable: Palabra 1 (apunta al codeword de W1)
    .word W2   #-- Variable: Palabra 2
    .word EX   #-- Variable: Palabra 3

#------------------------
#-- W1: Imprimir A
#------------------------
    .data
W1: .word code_W1   #-- Codeword: Direccion codigo ejecutable
    #-- Implementacion de W1
    .text
code_W1:
   SO_PRINT_CHAR('A')
   NEXT     #-- Ejecutar siguiente instruccion

#-----------------------
# W2: Imprimir B 
#-----------------------
    .data
W2: .word code_W2   #-- Codeword
    .text
code_W2:
   SO_PRINT_CHAR('B')
   NEXT  

#-----------------------
# EX: Terminar
#-----------------------
    .data
EX: .word code_EX   #-- Codeword 
    .text
code_EX:
   SO_PRINT_CHAR('\n')
   SO_EXIT
   #-- Es una instruccion especial
   #-- Se termina, por lo que NO se llama a NEXT


#-------------------------------------------
#-- Programa principal
#-- ARRANCA AQUI!!!!
#-------------------------------------------
    .text
    .global main
main:

    #-- S1 apunta la primera palabra a ejecutar (W1)    
    la s1,TEST  #-- s1 apunta a la Variable con la palabra a ejecutar
                #-- s1 es el IP (Puntero de instruccion)

    #-- Ejecutar primera instruccion (W1)
    NEXT  #-- Ejecuta la instruccion apuntada por s1
          #-- y Apuntar a la siguiente

    #-- Nunca llega aqui!!!!!