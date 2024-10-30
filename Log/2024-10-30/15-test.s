
#-- Cambio/mejora: 
#-- ESTE PROGRAMA NO FUNCIONA
#-- Sabemos que DOCOL se ejecuta. Lo hemos reducido a lo mínimo:
#-- simplemente hace NEXT, pero provoca un Runtime error:
#--
#-- Se imprime AB y luego aparece el error:
#-- Error in /home/obijuan/Develop/Learn-forth/Log/2024-10-30/15-test.s 
#-- line 69->22: Runtime exception at 0x00400054: 
#-- Cannot read directly from text segment!0x00400000
#--
#-- Por qué está pasando esto? Cuaando s1 apunta a la tercera palabra de TEST  
#-- (la que tiene la etiqueta TEST2) se está ejecutando W2, que imprime B y
#-- luego s1 se incrementa en 4 unidades... apuntando fuera de TEST
#-- a0 apunta al codeword de TEST2 (que contiene DOCOL) y se ejecuta DOCOL
#-- Al ejecutarse el NEXT se lee de s1 un valor indefinido (porque está  
#-- apuntando a un sitio que no debería
#--
#-- La solución es configurar s1 correctamente cuando se entra en DOCOL


    .include "so.s"

#---------------------------------------------------
#-- Definimos las palabras de nuestro sistema
#---------------------------------------------------
    .data

TEST2:
    .word DOCOL
    .word W1
    .word W2
    .word EX

    #-- Primera Palabra de prueba a Ejecutar
    #-- Como es la primera es "especial". Su configuracion
    #-- es diferente a la de las demas
    #-- No tiene codeword propio
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


#-----------------------
#-- DOCOL
#-- NO es una palabra de Forth. Es directamente codigo
#-- maquina que dice como ejecutar una palabra no primitiva
#-----------------------
.text
DOCOL:
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