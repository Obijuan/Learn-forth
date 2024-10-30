#-- Palabras primitivas: W1 ,W2
#-- Simplemente imprimen los caracteres A y B en pantalla, respectivamente
#-- También EX para terminar

#-- El primer programa lo que hace es imprimir AB y termina

#-- Mejora: 
#-- Nos llevamos la macro NEXT al fichero so.s
#-- Es importante saber bien lo que hace NEXT:
#-- Ejecuta la palabra apuntada por s1, y hace que s1 apunte
#-- a la siguiente instruccion
#--
#-- Si nos fijamos en el codigo en ensamblador, ya NO es necesario
#-- usar ret... porque al llamar a NEXT una palabra llama a la siguiente
#-- ya no es una subrutina...
#--
#-- Y esa es la mejora de este codigo: Hemos quitado
#-- las instrucciones ret y las hemos sustituido por 
#-- las macros NEXT. En la implementacion de cada instruccion
#-- se termina llamando a NEXT (en vez de ret)
#--
#-- El programa principal llama a NEXT para que se ejecute
#-- la primera palabra.. y luego las demas se encadenan

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

    #-- Ejecutar primera instruccion (W1)
    NEXT  #-- Ejecuta la instruccion apuntada por s1
          #-- y Apuntar a la siguiente


    .text
#-----------------------
# W1: Imprimir A 
#-----------------------
code_W1:
   SO_PRINT_CHAR('A')
   NEXT     #-- Ejecutar siguiente instruccion

    .text
#-----------------------
# W2: Imprimir B 
#-----------------------
code_W2:
   SO_PRINT_CHAR('B')
   NEXT   

    .text
#-----------------------
# EX: Terminar
#-----------------------
code_EX:
   SO_PRINT_CHAR('\n')
   SO_EXIT
   #-- Es una instruccion especial
   #-- Se termina, por lo que NO se llama a NEXT