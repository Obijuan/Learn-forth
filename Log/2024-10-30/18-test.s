
#-- Cambio/mejora: 
#-- Todavía no funciona bien... porque NO hace la vuelta atrás. Como ejemplo
#-- definimos unas palabras que hacen PETAR el programa
#-- Se imprime A y luego se produce el Error:
#-- Error in /home/obijuan/Develop/Learn-forth/Log/2024-10-30/18-test.s 
#-- line 35->22: Runtime exception at 0x00400014:
#-- Cannot read directly from text segment!0x00400000
#--
#-- El problema está al ejecutar W1 de TEST2. En ese momento s1 apunta
#-- otra vez fuera de TEST2... al limbo del segmento de datos, y por 
#-- supuesto peta
#--
#-- La solución es que necesitamos añadir código en ensamblador en una nueva
#-- palabra, EXIT, que tome el control y deshaga el entuerto. La solucion
#-- se implementa en el siguiente ejemplo

    .include "so.s"

#---------------------------------------------------
#-- Definimos las palabras de nuestro sistema
#---------------------------------------------------
    .data

    #-- Primera Palabra de prueba a Ejecutar
    #-- Como es la primera es "especial". Su configuracion
    #-- es diferente a la de las demas
    #-- No tiene codeword propio
TEST:   
    .word TEST2  
    .word W2  
    .word W1

TEST2:
    .word DOCOL
    .word W1

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


#-----------------------
#-- DOCOL
#-- NO es una palabra de Forth. Es directamente codigo
#-- maquina que dice como ejecutar una palabra no primitiva
#-----------------------
.text
DOCOL:
   #-- a0 apunta a DOCOL, cuando se empieza a ejecutar
   #-- Si le sumamos 4, apunta a la siguiente palabra
   #-- (Una palabra que empieza por DOCOL esta formada por varias
   #-- palabras. Es decir, que tras DOCOL hay una palabra seguro)
   #-- Hacemos que s1 apunte a esa siguiente palabra
   addi s1, a0, 4  #-- S1 apunta a la siguiente palabra tras DOCOL

   #-- Ejecutar la siguiente instruccion!
   NEXT

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