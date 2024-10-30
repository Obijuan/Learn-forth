#-- Ejecutar la palabra TEST, compuesta por otras 3 palabras
#-- Como TEST esta definida en el segmento de datos, podemos
#-- Cambiar el orden de las llamadas, o añadir todas las
#-- instruciones que queramos... ¡Nuestro interprete las ejecutara!
#-- NO hay que saber ensamblador!!! Solo escribir las etiquetas
#-- de las palabras primitivas

#-- En este ejemplo se imprime la cadena ABBA, llamando a las palabras
#-- W1,W2,W2,W1 y EX

#-- Mejora: 
#-- Nuestro programa ya POR FIN esta definido EXCLUSIVAMENTE
#-- en el segmento de datos. Añadiendo, quitando o modificando
#-- la palabras indicadas, hacemos que nuestro programa haga
#-- una cosa u otra


    .include "so.s"

#---------------------------------------------------
#-- Definimos las palabras de nuestro sistema
#---------------------------------------------------
    .data
    #-- Palabra de prueba a Ejecutar
TEST:   
    .word W1   #-- A
    .word W2   #-- B  
    .word W2   #-- B
    .word W1   #-- A
    .word EX   #-- Terminar

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