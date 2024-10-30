
#-- Cambio/mejora: 
#-- Nuevas palabras primitivas
#-- DROP, DOTS

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
    .word TEST_DOTS
    .word TEST_DROP
    #.word TEST_DROP
    #.word TEST_LIT
    .word EX

#-- Comprobar DROP
TEST_DROP:
    .word DOCOL
    .word DOTS
    .word LIT
    .word 5
    .word DOTS
    .word DROP
    .word DOTS
    .word EXIT

#-- Comprobar .s
TEST_DOTS:
    .word DOCOL
    .word DOTS
    .word LIT
    .word 2
    .word DOTS
    .word LIT
    .word 3
    .word DOTS
    .word EXIT

#-- Comprobar literales
TEST_LIT:
    .word DOCOL
    .word LIT
    .word 2
    .word LIT
    .word 3
    .word DOT
    .word DOT
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

#-----------------------------------
#-- LIT
#-- Introducir un numero en la pila
#-----------------------------------
      .data
LIT:  .word code_LIT
      .text
code_LIT:

      #-- s1 apunta a la siguiente palabra que justo es el
      #-- valor literal
      lw a0, 0(s1)     #-- Leer el valor literal

      #-- Guardar el numero en la pila
      addi sp,sp,-4
      sw a0, 0(sp)

      #-- Apuntar a la siguiente palabra
      addi s1,s1,4
      NEXT

#------------------------------------------
#-- . (DOT)  (DEBUG)
#-- Sacar numero de la pila e imprimirlo
#------------------------------------------
      .data
DOT:  .WORD code_DOT
      .text
code_DOT:
     #-- Sacar numero de la pila
     lw a0, 0(sp)
     addi sp,sp,4

     #-- Imprimir numero!
     SYS_PRINT_INT

     #-- Imprimir espacio
     SO_PRINT_CHAR(' ')
     NEXT

#-------------------------------------------
#-- DROP
#-- Eliminar el ultimo elemento de la pila
#-------------------------------------------
       .data 
DROP:  .word code_DROP
       .text
code_DROP:
       #-- Sacar elemento de la pila e ignorarlo
       lw a0, 0(sp)
       addi sp,sp,4
       NEXT

#--------------------------------------------
#-- DOTS (.S)
#-- Imprimir el estado de la pila
#-- <n> n1 n2 n3...
#--  n es la profundidad
#--  nx son los elementos de la pila empezando por la base
#--  El numero del extremo derecho es la cima de la pila
#--------------------------------------------
       .data
DOTS:  .word code_DOTS
       .text
code_DOTS:
    
       #-- Calcular en t0 la profundidad de la pila
       la t1, stack_top
       sub t0,t1,sp  #-- t0 = stack_top-sp
       srai t0,t0,2  #-- Dividir entre 4 para calcular la profundidad
                     #-- en palabras

       #-- Imprimir profundidad
       SO_PRINT_CHAR('<')
       mv a0,t0
       SYS_PRINT_INT
       SO_PRINT_CHAR('>')

dots_bucle:
       #-- Imprimir todos los numeros que hay en la pila
       #-- Empezando por su base
       #-- Si sp==t1 --> No hay elementos. Terminar
       beq sp,t1,fin

       #-- Leer numero de la pila
       addi t1,t1,-4
       lw t0, 0(t1)

       #-- Imprimirlo!
       SO_PRINT_CHAR(' ')
       mv a0, t0
       SYS_PRINT_INT

       j dots_bucle

fin:
       SO_PRINT_CHAR('\n')

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

    #-- Inicializar la pila de datos
    la sp, stack_top

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

    .space 40
stack_top: