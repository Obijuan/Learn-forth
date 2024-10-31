
#-- Cambio/mejora: 
#-- Nuevas palabras:
#-- NUMBER

    .include "so.s"

    #-- Tamano buffer de entrada
    .eqv BUFFER_SIZE, 10

#---------------------------------------------------
#-- Definimos las palabras de nuestro sistema
#---------------------------------------------------
    .data

    #-- Primera Palabra de prueba a Ejecutar
    #-- Como es la primera es "especial". Su configuracion
    #-- es diferente a la de las demas
    #-- No tiene codeword propio
TEST:
    .word TEST_NUMBER
    #.word TEST_WORD
    #.word TEST_EMIT
    #.word TEST_KEY
    #.word TEST_DUP
    #.word TEST_SWAP
    #.word TEST_DROP
    #.word TEST_LIT
    #.word TEST_DOTS
    #.word TEST_DROP
    #.word TEST_DROP
    #.word TEST_LIT
    .word EX

TEST_NUMBER:
    .word DOCOL, WORD, NUMBER, DOTS, EXIT

#-- Comprobar WORD
TEST_WORD:
    .word DOCOL, WORD, DOTS, EXIT

#-- Comprobar EMIT
TEST_EMIT:
    .word DOCOL, LIT, 65, DUP, EMIT, EMIT, EXIT

#-- Comprobar KEY
TEST_KEY:
    .word DOCOL, KEY, KEY, DOTS, EXIT

#-- comprobar DUP
TEST_DUP:
    .word DOCOL, LIT, 1, LIT 5, DOTS, DUP DOTS, EXIT

#-- Comprobar SWAP
TEST_SWAP:
    .word DOCOL, LIT, 1, LIT, 2, DOTS, SWAP, DOTS, EXIT

#-- Comprobar DROP
TEST_DROP:
    .word DOCOL, DOTS, LIT, 5, DOTS, DROP, DOTS, EXIT

#-- Comprobar .s
TEST_DOTS:
    .word DOCOL, DOTS, LIT, 2, DOTS, LIT, 3, DOTS, EXIT

#-- Comprobar literales
TEST_LIT:
    .word DOCOL, LIT, 2, LIT, 3, DOT, DOT, EXIT

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
    POPR s1
    NEXT

#-----------------------
#-- DOCOL
#-- NO es una palabra de Forth. Es directamente codigo
#-- maquina que dice como ejecutar una palabra no primitiva
#-----------------------
.text
DOCOL:
   #-- Almacenar s1 en la pila R
   PUSHR s1

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
      PUSH a0

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
     POP a0

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
       POP a0
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


#---------------------------------------------------------
#-- SWAP
#-- Intercambiar los dos elementos superiores de la pila
#---------------------------------------------------------
       .data
SWAP:  .word code_SWAP
       .text
code_SWAP:

       #-- Leer elementos
       lw a0, 0(sp)  #-- a0: Primer elemento
       lw a1, 4(sp)  #-- a1: Segundo elemento

       #-- Meter elementos
       sw a0, 4(sp)
       sw a1, 0(sp)
       NEXT


#------------------------------------------------
#-- DUP
#-- Duplicar el elemento en la cima de la pila 
#------------------------------------------------
       .data
DUP:   .word code_DUP
       .text
code_DUP:
	lw a0, 0(sp) 
	PUSH a0
	NEXT

#--------------------------------------------------------
#-- KEY
#-- Leer un byte de la entrada y colocarlo en la pila
#--------------------------------------------------------
       .data
KEY:   .word code_KEY
       .text
code_KEY:
       #-- Llamar a la subrutina _KEY
       #-- Porque se reutiliza en otras partes
       jal _KEY
       
       #-- Guardar el valor devuelto en la pila
	   PUSH a0
	   NEXT

    #-----------------------------
    #-- _KEY: Subrutina interna
    #-- Salida: a0: Tecla leida
    #-----------------------------
_KEY:
    #-- TODO: He omitido la logica de implementacion del buffer
    #-- de momento, porque solo leemos 1 caracter cada vez
    #-- Leer 1 caracter y meterlo en el buffer
    SYS_READ(buffer, 1)
    #-- En a1 esta la direccion del buffer

    #-- a0: Cantidad de caracteres leidos
    #-- Si a0 = -1, ERROR!
    blt a0,zero,_KEY_error

    #-- Leer el caracter del buffer
    lw a0, 0(a1)
    
    #-- a0 contiene el byte leido
    ret 

_KEY_error:
    #-- Error en la lectura de la entrada
    #-- EXIT!
    SO_EXIT

#--------------------------------------------------------
#-- EMIT
#-- Enviar a la consola de salida el byte de la pila
#--------------------------------------------------------
       .data
EMIT:   .word code_EMIT
       .text
code_EMIT:
	POP a0
    jal _EMIT
	NEXT

_EMIT:
    #-- La escritura se usa mediante el servicio WRITE
    #-- del RARS (que es igual al de linux). Por eso
    #-- lo uso aqui

    #-- Almacenar caracter a enviar en buffer
    #-- El caracter esta en a0
    la a1, emit_buffer  #-- a1: Direccion del buffer
    sw a0, 0(a1)        #-- Guardar caracter

	li a0, 1  #-- stdout
    li a2, 1  #-- Escribir 1 byte
    li a7, 64
    ecall
    ret

	.data
    .align 2
emit_buffer:
	.space 1		#-- Guardar byte a enviar a consola

#--------------------------------------------------------
#-- WORD
#-- Leer una palabra FORTH de la entrada estandard
#-- Todos los caracteres blancos se elimina, asi como los  
#-- comentarios. La palabra introducida se almacena en un
#-- buffer interno y se devuelve en la pila la direccion
#-- de este buffer y la longitud de la palabra
#--------------------------------------------------------
       .data
WORD:  .word code_WORD
       .text
code_WORD:
    jal _WORD
    PUSH a0     #-- a0: Direccion base
    PUSH a1     #-- a1: Longitud de la palabra
	NEXT

_WORD:
    #/* Search for first non-blank character.  Also skip \ comments. */
_WORD_1:

    #-- Subrutina intermedia
    #-- Leer un caracter
    PUSH ra
    jal _KEY
    POP ra
    #-- a0: Caracter leido

    #-- Comprobar comentarios
    li a1, '\\'
    beq a0, a1, _WORD_4  #-- Hay comentario. Eliminarlos!

    #-- No son comentarios
    #-- Sera un caracter BLANCO? Para nosotros, cualquier caracter
    #-- que sea <= al espacio ' ', es BLANCO
    li a1, ' ' 
    ble a0, a1, _WORD_1  #-- Es BLANCO. Ignorar. Pedir otro

    #-- NO es Blanco
    #-- 
    #	/* Search for the end of the word, storing chars as we go. */
	la a2, word_buffer	#-- Puntero al buffer

_WORD_2:
	sb a0, 0(a2)    #-- Guardar caracter en el buffer
	addi a2, a2, 1  #-- Apuntar a la siguiente posicion
	PUSH a2
    PUSH ra
    jal _KEY     #-- Leer siguiente caracter. Se devuelve en a0
    POP ra
	POP a2

    li a1, ' '
    bgt a0, a1, _WORD_2  #-- No es blanco: seguimos leyendo y almacenando

    #-- Es BLANCO: fin de la palabra
    #-- Devolver la direccion del buffer y la longitud de la palabra
	la a0, word_buffer	# Direccion de la palabra
	sub a1, a2, a0		# Longitud de la palabra: dir final - dir inicial
	ret

_WORD_4:

    #-- Eliminar los comentarios hasta el final de la linea actual
    PUSH ra
	jal _KEY   #-- Leer caracter en a0
    POP ra

    li a1, '\n'
    bne a0, a1, _WORD_4   #-- Es el fin de la linea? NO --> Leer siguiente

    #-- Fin de linea: volvemos al comienzo
    j _WORD_1
    
	.data
	.align 2
	#// A static buffer where WORD returns.  Subsequent calls
	#// overwrite this buffer.  Maximum word length is 32 chars.
word_buffer:
	.space 32

#---------------------------------------------------------
#-- NUMBER
#--   Convertir una cadena en un numero
#--
#-- Entrada: (Pila) Direccion cadena, longitud cadena
#-- Salida: (Pila) Numero parseado, caracteres no parseados
#---------------------------------------------------------
         .data
NUMBER:  .word code_NUMBER
         .text
code_NUMBER:
	POP a1  #  a1 = Longitud de la cadena 
    POP a2	#  a2 = Direccion de la cadena

    #--- Ejecutar la palabra!
    PUSH ra
	jal _NUMBER
    POP  ra

    #--
	PUSH a0  #-- Meter en la pila el numero parseado 
    PUSH a1	 #-- Numero de caracteres NO parseados (0 = no error)
	NEXT

_NUMBER:

    #-- si la cadena tiene longitud 0, se devuelve 0
    mv a0, zero
    beq a1, zero, _NUMBER_5  #-- Longitud cadena 0: Saltar..

    #-- Se ha introducido una cadena con caracteres
    #-- ¡Hay que parsear!

	la a3, var_BASE
	lw a3, 0(a3)     #-- a3: BASE del sistema numerico

    #-- Comprobar si el primer caracter es -
	lb a4, 0(a2)    #-- a4 = Primer caracter de la cadena
	addi a2, a2, 1  #-- Apuntar al siguiente

    
    #-- a5 = 0 --> Numero negativo. a5 != 0, positivo
    #-- Este valor de a5 lo guardamos para usarlo
    #-- mas adelante
    li t0, '-'
    sub a5, a4, t0  #-- Restar '-' al caracter
	bnez a5, _NUMBER_2	#-- Saltar: Es un numero positivo

    #-- El numero es negativo
    addi a1, a1, -1    #-- Simbolo '-' consumido. Reducir longitud

    #-- ¿Longitud es 0? --> 
    bne a1, zero, _NUMBER_1  #-- Saltar si longitud no 0

    #-- La cadena solo tenia '-' (Error)
    li a1, 1
    ret 


_NUMBER_1:
    #-- Bucle de lectura de los digitos
    #-- Si es negativo se entra por aqui, pero no tiene
    #-- efecto porque a0 es 0, y el siguiente caracter que se lee
    #-- es el que está a continuación del '-'
	mul a0, a0, a3		# a0 *= BASE
	lb a4, 0(a2)		# a4 = Siguiente caracter
	addi a2, a2, 1      # a2 -> Apuntar al siguiente
	
_NUMBER_2:
    #-- Convertir 0-9, A-Z a numero 0-35
	sltiu t0, a4, '0'	#// < '0'?
	bnez t0, _NUMBER_4  #-- Error

    li t0, '0'
	sub a4, a4, t0   #-- Convertir a4 a numero

    li t0, 10
    blt a4, t0, _NUMBER_3   #-- Si <= '9' Saltar 
	
    #-- El caracter es mayor a '9'
    #-- O esta en otra base o es un error

    sltiu t0, a4, 17	#-- // < 'A'? (17 is 'A' - '0')
	bnez t0, _NUMBER_4
	addi a4, a4, -7	    #--// Char - 'A' + 10

_NUMBER_3:
    #-- Esto no lo tengo claro...
    bge a4, a3, _NUMBER_4  #-- Si es >= BASE, saltar

    #-- El digito es correcto
    #-- Añadirlo al resultado: a0
	add a0, a0, a4
	addi a1, a1, -1   #-- Un caracter menos

    #-- Si quedan mas caracteres, repetir el bucle
    bne a1, zero, _NUMBER_1

    #-- Ya no quedan mas caracteres
    #-- Esta es la terminación normal
    #-- Siempre deberia salir por aqui...

_NUMBER_4:
    #-- Terminar. El resultado esta en a0
    #-- Hay que negarlo si era negativo
	bnez a5, _NUMBER_5  #-- Saltar si es positivo

    #-- El numero es negativo
    #-- cambiar de signo el resultado
	neg a0, a0

_NUMBER_5:
    ret


#-----------------------------------
#-- VARIABLES
#-----------------------------------
#-- BASE a utilizar para los numeros que se leen 
#-- y que se imprimen. Por defecto es BASE 10
          .data
var_BASE: .word 2  


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
    .align 2
    .space 40
return_stack_top:

    .align 2
    .space 40
stack_top:

#-- Buffer de entrada
    .align 2
buffer:
	.space BUFFER_SIZE