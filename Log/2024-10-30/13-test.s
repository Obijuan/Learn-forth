
#-- Cambio/mejora: 
#-- Este programa NO FUNCIONA!!!
#-- Imprime AB en la consola y termina de forma abrupta, dando un 
#-- mensaje de error: Error in : Instruction load access error
#-- Ejecutandolo en la version grafica se ve mas informacion
#--   Error in : Runtime exception at 0x10010018: 
#--   undefined instruction (0x00400000)
#--
#-- El error se ha generado a posta. El cambio introducido simplemente
#-- es que la palabra TEST ahora llama a la palabra TEST2 que esta
#-- definida a su vez definida por mas palabras
#--
#-- El problema es que TEST2 NO tiene un codeword.. es decir, no hay
#--   codigo maquina que indique COMO ejecutar palabras definidas
#--   por otras palabras...
#--
#-- Sí tenemos código máquina en las palabras primitivas: El indicado
#-- por su codeword... pero NO para el caso de instrucciones definidas
#-- unicamente por palabras
#--
#-- Hay que crear este código máquina que implemente el comportamiento
#-- de ejecutar instrucciones definidas en Forth... Es lo que llamamos
#-- el intérprete. En el caso de una palabra primitiva, su interprete es
#-- ejecutar directamente el codigo maquina... pero en el caso de una
#-- palabra definida mendiante otras palabras, hay que ejecutar ese
#-- mini-interprete que sepa como llamar a las palabras
#--
#-- Esa es la mision de DOCOL que usaremos para solucionar este problema
#-- en las siguientes versiones


    .include "so.s"

#---------------------------------------------------
#-- Definimos las palabras de nuestro sistema
#---------------------------------------------------
    .data

TEST2:
    .word W1
    .word W2
    .word EX

    #-- Palabra de prueba a Ejecutar
TEST:   
    .word W1   
    .word W2     
    .word TEST2

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