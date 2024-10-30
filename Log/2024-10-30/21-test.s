
#-- Cambio/mejora: 
#-- En este ejemplo no se ha añadido nada nuevo en el interprete
#-- Lo que se hace es definir cuatro palabras que se recorren en 
#-- profundidad. TEST llama a TEST2 que llama a TEST3 que a su vez  
#-- llama a TEST4 y retorna. Se vuelve atrás hasta que se imprime A y B
#-- desde la primera palabra, tras ejecutar TEST
#--
#-- La cadena impresa es AB, y luego se termina OK
#--
#-- Llegados a estsa punto YA tenemos un intérprete de FORTH
#-- capaz de ejecutar palabras primitivas y palabras FORTH
#-- Aunque en realidad NO hay palabras definidas del propio FORTH
#-- todavía. Tenemos un MOTOR FORTH mínimo!!

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
    .word W1
    .word W2
    .word EX

TEST2:
    .word DOCOL
    .word TEST3
    .word EXIT

TEST3:
    .word DOCOL
    .word TEST4
    .word EXIT

TEST4:
    .word DOCOL
    .word EXIT

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

#--------------------------------------------------------------------
# EXIT. Palabra que se tiene que ejecutar al final de la definicion
# de una palabra NO primitiva
#--------------------------------------------------------------------
    .data
EXIT: .word code_EXIT  #-- Codeword
    .text
code_EXIT:

    #-- Recuperar s1 de la pila
    lw s1, 0(fp)

    #-- Restaurar pila R
    addi fp,fp,4

    #-- Ejecutar siguiente instruccion!
    NEXT

#-----------------------
#-- DOCOL
#-- NO es una palabra de Forth. Es directamente codigo
#-- maquina que dice como ejecutar una palabra no primitiva
#-----------------------
.text
DOCOL:
   addi fp,fp,-4  #-- Generar espacio en la pila R
   sw s1, 0(fp)   #-- Almacenar s1 en la pila R

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

    #-- Inicializar el puntero de pila R
	la fp, return_stack_top 

    #-- S1 apunta la primera palabra a ejecutar (W1)    
    la s1,TEST  #-- s1 apunta a la Variable con la palabra a ejecutar
                #-- s1 es el IP (Puntero de instruccion)

    #-- Ejecutar primera instruccion (W1)
    NEXT  #-- Ejecuta la instruccion apuntada por s1
          #-- y Apuntar a la siguiente

    #-- Nunca llega aqui!!!!!

    .data
    .space 40
return_stack_top: