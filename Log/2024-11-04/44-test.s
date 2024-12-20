
#-- Cambio/mejora: 
#-- Nuevas palabras en el diccionario:
#-- AND, OR, XOR, INVERT, !, @, +!, -!, 

    .include "so.s"

    #-- Tamano buffer de entrada
    .eqv BUFFER_SIZE, 200

    #-- VERSION DEL FORTH
    .eqv JONES_VERSION 44

    .data
PRUEBA_FETCH: .word 1973   #-- Valor para hacer pruebas de Fetch. Dir: 0x10010000
VAR_BYTE:     .byte 86     #-- Byte para hacer pruebas de Fetch
SRC_BYTE:     .word 65     #-- Byte para pruebas de copias
DST_BYTE:     .word 0      #-- Byte para pruebas de copias
SRC_STR:      .string "HOLA"

              .align 2
DST_STR:      .space 10

#----------------------------------------------------------------------------
#-- Definimos las palabras de nuestro sistema
#----------------------------------------------------------------------------
    .data
    .align 2

TEST_QUIT: .word DOCOL, QUIT
TEST_BRANCH: .word DOCOL, BRANCH, 12, LIT, 1, LIT, 2, DOTS, EXIT
TEST_INTERPRET: .word DOCOL, INTERPRET, DOTS, EXIT 
TEST_F_LENMASK: .word DOCOL, __F_LENMASK, DOT, EXIT 
TEST_F_HIDDEN: .word DOCOL, __F_HIDDEN, DOT, EXIT
TEST_F_IMMED: .word DOCOL, __F_IMMED, DOT, EXIT 
TEST_DOCOL: .word DOCOL, __DOCOL, DOT, EXIT 
TEST_RZ: .word DOCOL, RZ, DOT, EXIT

TEST_VERSION:
    .word DOCOL, VERSION, DOT, EXIT 

TEST_BASE:
    .word DOCOL, BASE, FETCH, DOT, EXIT 

TEST_SZ:
    .word DOCOL, SZ, FETCH, DOT, EXIT 

TEST_HERE:
    .word DOCOL, HERE, FETCH, DOT, EXIT 

TEST_LATEST:
    .word DOCOL, LATEST, FETCH, DOT, EXIT 

TEST_STATE:
    .word DOCOL, STATE, FETCH, DOT, EXIT

TEST_CMOVE:
    .word DOCOL, LIT, SRC_STR, LIT, DST_STR, LIT, 4, CMOVE, DOTS, EXIT

TEST_CCOPY:
    .word DOCOL, LIT, SRC_BYTE, LIT, DST_BYTE, DOTS, CCOPY, DOTS, EXIT

TEST_FETCHBYTE:
    .word DOCOL, LIT, VAR_BYTE, FETCHBYTE, DOT, EXIT

TEST_STOREBYTE:
    .word DOCOL, LIT, 0xA5, LIT, 0x10040000, STOREBYTE, DOTS, EXIT

TEST_COMMA:
    .word DOCOL, WORD, CREATE, LIT, 0xCACA, COMMA, DOTS, EXIT 

TEST_CREATE:
    .word DOCOL, WORD, CREATE, DOTS, EXIT

TEST_TDFA:
    .word DOCOL, WORD, FIND, TDFA, DOTS, EXIT

TEST_TCFA:
    .word DOCOL, WORD, FIND, TCFA, DOTS, EXIT

TEST_FIND:
    .word DOCOL, WORD, FIND, DOTS, EXIT

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


#==================================
#=      FLAGS
#==================================
    .eqv F_IMMED  0x80
	.eqv F_HIDDEN 0x20
	.eqv F_LENMASK 0x1f	    #-- length mask
    .eqv F_HID_LENMASK 0x3f #-- F_HIDDEN | F_LENMASK


#====================================================================
#=                     DICCIONARIO
#====================================================================

#--------------------------------------------------------------------
# EXIT. Palabra que se tiene que ejecutar al final de la definicion
# de una palabra NO primitiva
#--------------------------------------------------------------------
       .data 
name_EXIT:
      .word NULL      
      .byte 4         
      .ascii "EXIT"  
      .align 2
 EXIT: .word code_EXIT
    .text
 code_EXIT:

    #-- Recuperar s1 de la pila
    POPR s1
    NEXT


#-----------------------------------
#-- LIT
#-- Introducir un numero en la pila
#-----------------------------------
       .data 
name_LIT:
      .word name_EXIT      
      .byte 3         
      .ascii "LIT"  
      .align 2
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

#--------------------------------------------
#-- DOTS (.S)
#-- Imprimir el estado de la pila
#-- <n> n1 n2 n3...
#--  n es la profundidad
#--  nx son los elementos de la pila empezando por la base
#--  El numero del extremo derecho es la cima de la pila
#--------------------------------------------
       .data 
name_DOTS:
      .word name_LIT      
      .byte 2
      .ascii ".S"  
      .align 2
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
#-- DROP
#-- Eliminar el ultimo elemento de la pila
#-------------------------------------------
       .data 
name_DROP:
       .word name_DOTS   #-- Link: Puntero a siguiente palabra
       .byte 4           #-- Len: Longitud del nombre + flags
       .ascii "DROP"     #-- Nombre de la palabra FORTH
       .align 2
 DROP:  .word code_DROP #-- Codeword
       .text           #-- Implementacion ASM
 code_DROP:
       #-- Sacar elemento de la pila e ignorarlo
       POP a0
       NEXT

#---------------------------------------------------------
#-- SWAP
#-- Intercambiar los dos elementos superiores de la pila
#---------------------------------------------------------
        .data 
name_SWAP:
       .word name_DROP     
       .byte 4         
       .ascii "SWAP" 
       .align 2
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
name_DUP:
       .word name_SWAP     
       .byte 3         
       .ascii "DUP" 
       .align 2
 DUP:   .word code_DUP
       .text
 code_DUP:
	lw a0, 0(sp) 
	PUSH a0
	NEXT

#----------
#-- OVER
#----------
        .data 
name_OVER:
       .word name_DUP    
       .byte 4         
       .ascii "OVER" 
       .align 2
 OVER:   .word code_OVER
       .text
 code_OVER:
	lw a0, 4(sp)  #-- Obtener el segundo elemento de la pila
	PUSH a0 	  #-- y ponerlo en la pila para quede encima
	NEXT

#----------
#-- ROT
#----------
        .data 
name_ROT:
       .word name_OVER    
       .byte 3         
       .ascii "ROT" 
       .align 2
 ROT:   .word code_ROT
       .text
 code_ROT:
	POP a0
    POP a1
    POP a2
	PUSH a1
    PUSH a0
    PUSH a2
	NEXT

#----------
#-- -ROT
#----------
        .data 
name_NROT:
       .word name_ROT    
       .byte 4         
       .ascii "-ROT" 
       .align 2
 NROT:   .word code_NROT
       .text
 code_NROT:
	POP a0
    POP a1
    POP a2
	PUSH a0
    PUSH a2
    PUSH a1
	NEXT
#----------------------------------------
#-- 2DROP
#-- Sacar los dos elementos de la cima
#----------------------------------------
        .data 
name_TWODROP:
       .word name_NROT    
       .byte 5         
       .ascii "2DROP" 
       .align 2
 TWODROP:   .word code_TWODROP
       .text
 code_TWODROP:
	POP a0
    POP a0
	NEXT

#----------------------------------------
#-- 2DUP
#-- Duplicar los dos elementos de la cima de la pila
#----------------------------------------
        .data 
name_TWODUP:
       .word name_TWODROP    
       .byte 4         
       .ascii "2DUP" 
       .align 2
 TWODUP:   .word code_TWODUP
       .text
 code_TWODUP:
	lw a0, 0(sp) #-- Leer Elemento de la cima
	lw a1, 4(sp) #-- Leer siguiente elemento
	PUSH a1      #-- Meterlos en la pila
    PUSH a0
	NEXT

#----------------------------------------
#-- 2SWAP
#-- Intercambiar los dos pares de elementos de la cima de la pila
#----------------------------------------
        .data 
name_TWOSWAP:
       .word name_TWODUP    
       .byte 5         
       .ascii "2SWAP" 
       .align 2
 TWOSWAP:   .word code_TWOSWAP
       .text
 code_TWOSWAP:
	POP a0
    POP a1 
    POP a2 
    POP a3
	PUSH a1
    PUSH a0
    PUSH a3
    PUSH a2
	NEXT

#----------------------------------------
#-- ?DUP
#-- Duplicar el elemento de la cima si no es cero
#----------------------------------------
        .data 
name_QDUP:
       .word name_TWOSWAP    
       .byte 4         
       .ascii "?DUP" 
       .align 2
 QDUP:   .word code_QDUP
       .text
 code_QDUP:
	lw a0, 0(sp)      #-- Leer elemento de la cima
	beqz a0, _QDUP_1  #-- Si es 0 terminar
	PUSH a0           #-- Es != 0. Duplicarlo

 _QDUP_1:
	NEXT

#----------------------------------------
#-- 1+
#-- Incrementar la cima de la pila
#----------------------------------------
        .data 
name_INCR:
       .word name_QDUP    
       .byte 2         
       .ascii "1+" 
       .align 2
 INCR:   .word code_INCR
       .text
 code_INCR:
	POP a0
	addi a0, a0, 1  #-- Incrementar elemento de la cima
	PUSH a0
	NEXT

#----------------------------------------
#-- 1-
#-- Decrementar la cima de la pila
#----------------------------------------
        .data 
name_DECR:
       .word name_INCR    
       .byte 2         
       .ascii "1-" 
       .align 2
 DECR:   .word code_DECR
       .text
 code_DECR:
	POP a0
	addi a0, a0, -1  #-- Decrementar la cima de la pila
	PUSH a0
	NEXT

#----------------------------------------
#-- 4+
#-- Sumar 4 a la cima de la pila
#----------------------------------------
        .data 
name_INCR4:
       .word name_DECR   
       .byte 2         
       .ascii "4+" 
       .align 2
 INCR4:   .word code_INCR4
       .text
 code_INCR4:
	POP a0
	addi a0, a0, 4  #-- Sumar 4 a la cima de la pila
	PUSH a0
	NEXT

#----------------------------------------
#-- 4-
#-- Restar 4 a la cima de la pila
#----------------------------------------
        .data 
name_DECR4:
       .word name_INCR4   
       .byte 2         
       .ascii "4-" 
       .align 2
 DECR4:   .word code_DECR4
       .text
 code_DECR4:
	POP a0
	addi a0, a0, -4 	#-- Restar 4 a la cima de la pila
	PUSH a0
	NEXT

#----------------------------------------
#-- 8+
#-- Sumar 8 a la cima de la pila
#----------------------------------------
        .data 
name_INCR8:
       .word name_DECR4   
       .byte 2         
       .ascii "8+" 
       .align 2
 INCR8:   .word code_INCR8
       .text
 code_INCR8:
	POP a0
	addi a0, a0, 8	#-- Sumar 8 a la cima de la pila
	PUSH a0
	NEXT


#----------------------------------------
#-- 8-
#-- Restar 8 a la cima de la pila
#----------------------------------------
        .data 
name_DECR8:
       .word name_INCR8   
       .byte 2         
       .ascii "8-" 
       .align 2
 DECR8:   .word code_DECR8
       .text
 code_DECR8:
	POP a0
	addi a0, a0, -8  #-- Restar 8 de la cima de la pila
	PUSH a0
	NEXT


#----------------------------------------
#-- +
#-- Suma de dos operandos
#----------------------------------------
        .data 
name_ADD:
       .word name_DECR8   
       .byte 1        
       .ascii "+" 
       .align 2
 ADD:   .word code_ADD
       .text
 code_ADD:
	POP a0
    POP a1	#-- Leer los dos operandos de la pila
	add a0, a0, a1	#-- Sumarlos
	PUSH a0         #-- Dejar el resultado en la pila
	NEXT

#----------------------------------------
#-- -
#-- Resta de dos operandos
#----------------------------------------
        .data 
name_SUB:
       .word name_ADD   
       .byte 1        
       .ascii "-" 
       .align 2
 SUB:   .word code_SUB
       .text
 code_SUB:
	POP a0
    POP a1	#-- Leer los dos operandos de la pila
	sub a0, a1, a0	#-- Restarlos
	PUSH a0         #-- Meter el resulado en la pila
	NEXT


#----------------------------------------
#-- *
#-- Multiplicacion de dos operandos
#----------------------------------------
        .data 
name_MUL:
       .word name_SUB
       .byte 1        
       .ascii "*" 
       .align 2
 MUL:   .word code_MUL
       .text
 code_MUL:
	POP a0
    POP a1
	mul a0, a0, a1
	PUSH a0	 #-- Se ignora el overflow
	NEXT

#--------------------------------------------
#-- /MOD
#--------------------------------------------
        .data 
name_DIVMOD:
       .word name_MUL
       .byte 4        
       .ascii "/MOD" 
       .align 2
 DIVMOD:   .word code_DIVMOD
       .text
 code_DIVMOD:
	POP a0
    POP a1
	div a3, a1, a0
	rem a4, a1, a0
	PUSH a4
    PUSH a3	#-- push a4 = Resto  a3 = Cociente
	NEXT


#-------------------------------------------------------------------
#-- =
#-- Comprobar si las dos palabras de la cima de la pila son iguales
#-- Si son iguales se deposita 1 en la pila
#-- Si son diferentes se deposita 0 en la pila
#-------------------------------------------------------------------
        .data 
name_EQU:
       .word name_DIVMOD
       .byte 1        
       .ascii "=" 
       .align 2
 EQU:   .word code_EQU
       .text
 code_EQU:
    POP a0
    POP a1
	sub a0, a0, a1
	seqz a0, a0     #-- Poner a0 a 1 si a0 es 0 (sin son iguales) 
	PUSH a0         #-- Guardar el resultado
	NEXT

#-------------------------------------------------------------------
#-- <>
#-- Comprobar si las dos palabras de la cima de la pila son diferentes
#-- Si son diferentes se deposita 1 en la pila
#-- Si son iguales se deposita 0 en la pila
#-------------------------------------------------------------------
        .data 
name_NEQU:
       .word name_EQU
       .byte 2        
       .ascii "<>" 
       .align 2
 NEQU:   .word code_NEQU
       .text
 code_NEQU:
	POP a0
    POP a1
	sub a0, a0, a1
	sltu a0, zero, a0   #--Poner a0 a 1 si a0!=0, de lo contrario poner a 0
	PUSH a0
	NEXT

#-------------------------------------------------------------------
#-- <
#-- Comprobar si N es menor que T (cima de la pila) 
#-------------------------------------------------------------------
        .data 
name_LT:
       .word name_NEQU
       .byte 1      
       .ascii "<" 
       .align 2
 LT:   .word code_LT
       .text
 code_LT:
	POP a0
    POP a1
	slt a0, a1, a0     #-- Poner a0 a 1 si a1 < a0, de lo contrario a 0
	PUSH a0
	NEXT


#-------------------------------------------------------------------
#-- >
#-- Comprobar si N es mayor que T (cima de la pila) 
#-------------------------------------------------------------------
        .data 
name_GT:
       .word name_LT
       .byte 1
       .ascii ">" 
       .align 2
 GT:   .word code_GT
       .text
 code_GT:
	POP a0
    POP a1
	slt a0, a0, a1  #-- Poner a0 a 1 si a0 < a1, de lo contrario poner a0 a 0
	PUSH a0
	NEXT

#-------------------------------------------------------------------
#-- <=
#-- Comprobar si N es menor o igual que T (cima de la pila) 
#-------------------------------------------------------------------
        .data 
name_LE:
       .word name_GT
       .byte 2
       .ascii "<=" 
       .align 2
 LE:   .word code_LE
       .text
 code_LE:
	POP a0
    POP a1
	slt t0, a0, a1 #-- si a1 <= a0, entonces !(a0 < a1)
	li t1, 1
	sub t0, t1, t0
	PUSH t0
	NEXT


#-------------------------------------------------------------------
#-- >=
#-- Comprobar si N es mayor o igual que T (cima de la pila) 
#-------------------------------------------------------------------
        .data 
name_GE:
       .word name_LE
       .byte 2
       .ascii ">=" 
       .align 2
 GE:   .word code_GE
       .text
 code_GE:
	POP a0
    POP a1
	slt t0, a1, a0   #-- Si a1 >= a0, entonces !(a1 < a0)
	li t1, 1
	sub t0, t1, t0
	PUSH t0
	NEXT

#-------------------------------------------------------------
#-- 0=
#-- Comprobar si T = 0
#-------------------------------------------------------------
        .data 
name_ZEQU:
       .word name_GE
       .byte 2
       .ascii "0=" 
       .align 2
 ZEQU:   .word code_ZEQU
       .text
 code_ZEQU:
	POP a0
	seqz a0, a0
	PUSH a0
	NEXT

#-------------------------------------------------------------
#-- 0<>
#-- Comprobar si T != 0
#-------------------------------------------------------------
        .data 
name_ZNEQU:
       .word name_ZEQU
       .byte 3
       .ascii "0<>" 
       .align 2
 ZNEQU:   .word code_ZNEQU
       .text
 code_ZNEQU:
	POP a0
	sltu a0, zero, a0
	PUSH a0
	NEXT

#-------------------------------------------------------------
#-- 0<
#-- Comprobar si T < 0
#-------------------------------------------------------------
        .data 
name_ZLT:
       .word name_ZNEQU
       .byte 2
       .ascii "0<" 
       .align 2
 ZLT:   .word code_ZLT
       .text
 code_ZLT:
	POP a0
	slt a0, a0, zero
	PUSH a0
	NEXT

#-------------------------------------------------------------
#-- 0>
#-- Comprobar si T > 0
#-------------------------------------------------------------
        .data 
name_ZGT:
       .word name_ZLT
       .byte 2
       .ascii "0>" 
       .align 2
 ZGT:   .word code_ZGT
       .text
 code_ZGT:
	POP a0
	slt a0, zero, a0
	PUSH a0
	NEXT


#-------------------------------------------------------------
#-- 0<=
#-- Comprobar si T <= 0
#-------------------------------------------------------------
        .data 
name_ZLE:
       .word name_ZGT
       .byte 3
       .ascii "0<=" 
       .align 2
 ZLE:   .word code_ZLE
       .text
 code_ZLE:
	POP a0
	slt t0, zero, a0
	li t1, 1
	sub t0, t1, t0
	PUSH t0
	NEXT

#-------------------------------------------------------------
#-- 0>=
#-- Comprobar si T >= 0
#-------------------------------------------------------------
        .data 
name_ZGE:
       .word name_ZLE
       .byte 3
       .ascii "0>=" 
       .align 2
 ZGE:   .word code_ZGE
       .text
 code_ZGE:
	POP a0
	slt t0, a0, zero
	li t1, 1
	sub t0, t1, t0
	PUSH t0
	NEXT


#-------------------------------------------------------------
#-- AND
#-- T AND N
#-------------------------------------------------------------
        .data 
name_AND:
       .word name_ZGE
       .byte 3
       .ascii "AND" 
       .align 2
 AND:   .word code_AND
       .text
 code_AND:
	POP a0
    POP a1
	and a0, a0, a1
	PUSH a0
	NEXT

#-------------------------------------------------------------
#-- OR
#-- T OR N
#-------------------------------------------------------------
        .data 
name_OR:
       .word name_AND
       .byte 2
       .ascii "OR" 
       .align 2
 OR:   .word code_OR
       .text
 code_OR:
	POP a0
    POP a1
	or a0, a0, a1
	PUSH a0
	NEXT

#-------------------------------------------------------------
#-- XOR
#-- T XOR N
#-------------------------------------------------------------
        .data 
name_XOR:
       .word name_OR
       .byte 3
       .ascii "XOR" 
       .align 2
 XOR:   .word code_XOR
       .text
 code_XOR:
	POP a0
    POP a1
	xor a0, a0, a1
	PUSH a0
	NEXT

#-------------------------------------------------------------
#-- INVERT
#-- NOT T
#-------------------------------------------------------------
        .data 
name_INVERT:
       .word name_XOR
       .byte 6
       .ascii "INVERT" 
       .align 2
 INVERT:   .word code_INVERT
       .text
 code_INVERT:
	POP a0
	not a0, a0
	PUSH a0
	NEXT


#------------------------------------------------------
#-- ! (STORE)
#-- Almacenar un valor en una dirección
#------------------------------------------------------
       .data 
name_STORE:
       .word name_INVERT
       .byte 1
       .ascii "!" 
       .align 2
 STORE: .word code_STORE
       .text
 code_STORE:
	POP a0    #-- a0: Direccion 
    POP a1    #-- a1: Dato
	sw a1, 0(a0)	#-- Haz el store!
	NEXT

#------------------------------------------------------
#-- @ (FETCH)
#-- Leer valor de una direccion
#------------------------------------------------------
       .data 
name_FETCH:
       .word name_STORE
       .byte 1
       .ascii "@" 
       .align 2
 FETCH: .word code_FETCH
       .text
 code_FETCH:
	POP a0			#-- Direccion a leer
	lw a1, 0(a0)	#-- Leer la direccion 
	PUSH a1			#-- Meter el valor leido en la pila
	NEXT


#------------------------------------------------------
#-- +! (ADDSTORE)
#-- Incrementar una variable en una cantidad
#------------------------------------------------------
       .data 
name_ADDSTORE:
       .word name_FETCH
       .byte 2
       .ascii "+!" 
       .align 2
 ADDSTORE: .word code_ADDSTORE
       .text
 code_ADDSTORE:
	POP a0   #-- a0 = Direccion
    POP a1	 #-- a1 = Cantidad a sumar

	lw a2, 0(a0)    #-- Leer variable
	add a3, a1, a2	#-- Incrementarla
	sw a3, 0(a0)    #-- Almacenar nuevo valor
	NEXT

#------------------------------------------------------
#-- -! (SUBSTORE)
#-- Decrementar una variable en una cantidad
#------------------------------------------------------
       .data 
name_SUBSTORE:
       .word name_ADDSTORE
       .byte 2
       .ascii "-!" 
       .align 2
SUBSTORE: .word code_SUBSTORE
       .text
code_SUBSTORE:
	POP a0   #-- a0 = Direccion
    POP a1	 #-- a1 = Cantidad a restar

	lw a2, 0(a0)    #-- Leer variable
	sub a3, a2, a1	#-- Decrementarla
	sw a3, 0(a0)    #-- Almacenar nuevo valor
	NEXT


#----------------------------------------------------
# BYE: Salir del interprete
# Se invoca al servicio EXIT del systema operativo
#----------------------------------------------------
       .data 
name_BYE:
       .word name_SUBSTORE
       .byte 3         
       .ascii "BYE" 
       .align 2
 BYE: .word code_BYE   #-- Codeword 
    .text
 code_BYE:
   SO_PRINT_CHAR('\n')
   SO_EXIT
   #-- Es una instruccion especial
   #-- Se termina, por lo que NO se llama a NEXT


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
       RCALL _KEY
       
       #-- Guardar el valor devuelto en la pila
	   PUSH a0
	   NEXT

    #-----------------------------
    #-- _KEY: Subrutina interna
    #-- Salida: a0: Siguiente carácter leido
    #-----------------------------
_KEY:
    #-- a1: Apunta al siguiente caracter a leer del buffer
    #-- t0: Apunta al último elemento del buffer
    la t1, currkey
	lw a1, 0(t1)
	la t0, bufftop
	lw t0, 0(t0)

    #-- Comparar las direcciones de los dos punteros
	sltu a2, a1, t0
	beqz a2, _KEY_1		#-- Puntero del siguiente caracter es mayor o igual
                        #-- al ultimo elemento del buffer: Buffer vacio
                        #-- Saltar!

    #-- El buffer no esta vacio
	lb a0, 0(a1)		#-- Leer el siguiente caracter del buffer
	addi a3, a1, 1      #-- Apuntar al siguiente caracter
	sw a3, 0(t1)		#-- Guardar el puntero
	ret

_KEY_1:  #-- Buffer vacio. Realizar llamada al sistema READ
         #-- para leer mas bytes de la entrada estandar
    
	li a0, 0     		#-- a0:  stdin
	la a1, buffer		#-- a1: Buffer 

	la t0, currkey      #-- Currkey apunta al inicio del buffer
	sw a1, 0(t0)

	li a2, BUFFER_SIZE	#-- Longitud maxima del buffer
	li a7, 63	        #-- syscall: read
	ecall
    #-- a0 Contiene la cantidad de bytes leidos

    #-- Si a0 <=0, EXIT!
	slt t0, zero, a0
	beqz t0, _KEY_2

    #-- Actualizar bufftop. buffot = buffer + a0
	add a0, a0, a1
	la t0, bufftop
	sw a0, 0(t0)
	j _KEY

_KEY_2:
    SO_EXIT


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

    .data
    .align 2
currkey:
	.word buffer		#// Current place in input buffer (next character to read).
bufftop:
	.word buffer		#// Last valid data in input buffer + 1.


#--------------------------------------------------------
#-- EMIT
#-- Enviar a la consola de salida el byte de la pila
#--------------------------------------------------------
       .data
EMIT:   .word code_EMIT
       .text
code_EMIT:
	POP a0
    RCALL _EMIT
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
    RCALL _WORD
    PUSH a0     #-- a0: Direccion base
    PUSH a1     #-- a1: Longitud de la palabra
	NEXT

_WORD:
    #/* Search for first non-blank character.  Also skip \ comments. */
_WORD_1:

    #-- Subrutina intermedia
    #-- Leer un caracter
    RCALL _KEY
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
    RCALL _KEY     #-- Leer siguiente caracter. Se devuelve en a0
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
	RCALL _KEY   #-- Leer caracter en a0

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
	RCALL _NUMBER

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

#-------------------------------------------
#-- FIND
#-- Buscar una palabra en el diccionario
#-------------------------------------------
       .data
FIND:  .word code_FIND
       .text
code_FIND:
	POP a1     #-- a1: Longitud de la cadena a buscar
    POP a2	   #-- a2: Dirección de la cadena a buscar

    #-- Ejecutar FIND
	RCALL _FIND

    #-- a0: Direccion en el diccionario (o NULL)
	PUSH a0	
	NEXT

_FIND:

    #// Now we start searching backwards through the dictionary for this word.

    #-- LATEST apunta al nombre de la cabecera de la ultima palabra del diccionario
    #-- a0 = Apunta a la última palabra
	la a0, var_LATEST
	lw a0, 0(a0)

_FIND_1:

	beqz a0, _FIND_4	#-- NULL? Fin de la lista enlazada

    #// Compare the length expected and the length of the word.
	#// Note that if the F_HIDDEN flag is set on the word, then by a bit of trickery
	#// this won't pick the word (the length will appear to be wrong).
	lb a3, 4(a0)		#-- a3 contiene el campo len+flags

    #-- a3 Contiene la longiutd de la palabra actual, y el bit de HIDDEN
	andi a3, a3, F_HID_LENMASK 

    #-- Misma longitud?
	sub t0, a3, a1
	bnez t0, _FIND_3   #-- Distinta longitud. No hay match. siguiente

    #-- Misma longitud

    #-- Comparar las cadenas en detalle
	mv t0, a0  #-- t0: Apunta a la cabecera actual
	mv t2, a2  #-- t2: Direccion de la cadena a buscar

_FIND_2:
    #-- t1: Leer byte del nombre de la palabra actual
	lb t1, 5(t0) 		#-- t0 + 5: Direccion de la cadena del nombre

    #-- Leer byte de la cadena a buscar
	lb t3, 0(t2)

    #-- Comparar los bytes!
	sub t1, t1, t3
	bnez t1, _FIND_3	# No son iguales. Saltar! Pasar a la siguiente palabra

    #-- Caracteres iguales. Avanzamos al siguiente
	addi t0, t0, 1
	addi t2, t2, 1

    #-- Queda un caracter menos por comparar
	addi a3, a3, -1
	bnez a3, _FIND_2  #-- No hemos llegado a 0: Repetir con siguiente caracter

    #-- SON IGUALES!!
    #-- Devolver el puntero a la entrada de la palabra en el diccionaro
	ret

_FIND_3:
	lw a0, 0(a0)	#-- Avanzar a la siguiente palabra
	j _FIND_1	    #-- Y repetir loop


_FIND_4:  #-- No encontrado!
	mv a0, zero		#--- Devolver 0 para indicar que no encontrado
	ret


#------------------------------------------------------
#-- >CFA
#-- Obtener el CODE FIELD ADDRESS: La dir del codeword
#-- Se obtiene a partir de la dirección de la cabecera
#------------------------------------------------------
       .data
TCFA:  .word code_TCFA
       .text
code_TCFA:
	POP a0  #-- Obtener direccion de la cabecera

	RCALL _TCFA  #-- Ejecutar la palabra!

	PUSH a0  #-- Meter en la pila la direccion del codeword
	NEXT

_TCFA:
	lb a1, 4(a0)		# Cargar el flags+len en a1
	andi a1, a1, F_LENMASK	#-- Quedarse solo con la longitud, no los flags
	addi a0, a0, 5		# Saltar el link y el byte de longitud
	add a0, a0, a1		# Saltar el nombre
	addi a0, a0, 3		#-- El codeword está alineado a 4-bytes
	andi a0, a0, 0xFFFFFFFC
	ret

#-------------------------------------------------------
#-- >DFA
#-- Obtener el primer campo de datos de una palabra
#-- Es la primera palabra FOTH tras el DOCOL
#-------------------------------------------------------
       .data
TDFA: .word DOCOL
      .word TCFA   #-- Obtener la direccion del codework
      .word INCR4  #-- Sumar 4 para apuntar a la siguiente palabra
      .word EXIT   #-- Retornar de una palabra FORTH


#------------------------------------------------------
#-- C! (STOREBYTE)
#-- Almacenar un byte en una direccion de memoria
#------------------------------------------------------
       .data
STOREBYTE: .word code_STOREBYTE
       .text
code_STOREBYTE:
	POP a0        #-- a0: Direccion
    POP a1		  #-- a1: Dato a guardar
	sb a1, 0(a0)	#-- Almacenar!
	NEXT


#------------------------------------------------------
#-- C@ (FETCHBYTE)
#-- Leer un byte de una direccion
#------------------------------------------------------
       .data
FETCHBYTE: .word code_FETCHBYTE
       .text
code_FETCHBYTE:
	POP a0			#-- a0: Direccion
	lb a1, 0(a0)	#-- Leer el byte
	PUSH a1			#-- Meterlo en la pila
	NEXT


#------------------------------------------------------
#-- C@C! (CCOPY)
#-- Copiar un byte de una direccion a otra
#------------------------------------------------------
#-- TODO!! REVISAR ESTA FUNCIONA... NO TIENE MUCHO SENTIDO
       .data
CCOPY: .word code_CCOPY
       .text
code_CCOPY:
	POP a0        #-- a0: Direccion destino
    POP a1		  #-- a1: Direccion fuente
	lb a2, 0(a1)		#-- Leer caracter fuente get source
	sb a2, 0(a0)		#-- Copiar a destino
	addi a1, a1, 4      #-- Incrementar direccion fuente
	PUSH a0
    PUSH a1
	NEXT

#------------------------------------------------------
#-- CMOVE
#-- Operacion de copia de un bloque
#------------------------------------------------------
       .data
CMOVE: .word code_CMOVE
       .text
code_CMOVE:
	POP a0      #-- a0: Tamano del bloque a copiar
    POP a1      #-- a1: Direccion destino
    POP a2		#-- a2: Direccion fuente

	RCALL _COPY_BYTES
	NEXT

_COPY_BYTES:
	slti a4, a0, 4		#-- Si longitud <4, salta para copiar byte a byte
	bnez a4, _COPY_BYTES2

_COPY_BYTES1:        #-- Copiar palabra a palabra
	lw a3, 0(a2)     #-- a2: Fuente --> a1: Destino
	sw a3, 0(a1)

	addi a0, a0, -4	 #-- Una palabra menos a copiar
	beqz a0, _COPY_BYTES3  #-- Si 0 palabras por copiar --> Terminar

	addi a1, a1, 4   #-- Actualizar puntero destino
	addi a2, a2, 4   #-- Actualizar puntero fuente
	slti a4, a0, 4	 #-- Si longitud < 4, copiamos byte a byte
	beqz a4, _COPY_BYTES1     #-- Si no, seguimos palabra a palabra

_COPY_BYTES2:      #-- Copy byte
	lb a3, 0(a2)   #-- a2: Fuente --> a1: Destino
	sb a3, 0(a1)

	addi a0, a0, -1  #-- Un byte menos a copiar
	addi a1, a1, 1   #-- Actualizar punteros destino
	addi a2, a2, 1   #-- Actualizar puntero fuente
	bnez a0, _COPY_BYTES2  #-- Loop mientras queden bytes a copiar

_COPY_BYTES3:
	ret










#------------------------------------------------------------
#-- CREATE
#-- Crear la cabecera de una palabra FORTH
#--- Link, len y nombre
#--- En la pila está la direccion del nombre y la longitud
#------------------------------------------------------------
       .data
CREATE: .word code_CREATE
       .text
code_CREATE:
	#-- Leer la longitud y el nombre
    POP a0   #-- a0: Longitud del nombre
    POP a2   #-- a2: Direccion del nombre
    
    #-- a1: Puntero a la nueva cabecera a crear
    #-- Se obtiene su valor de la variable HERE
	la a1, var_HERE		
	lw a1, 0(a1)

    #------- Crear Campo Link

    #-- El valor a meter en el campo link se lee de la variable
    #-- LATEST
	la a3, var_LATEST	
	lw t0, 0(a3)   #-- t0: Puntero a la siguiente palabra

    #-- Almacenar el puntero en la cabecera
	sw t0, 0(a1)

    #-- Incrementar puntero de cabecera para apuntar al siguiente
    #-- campo: Longitud+flags!
	addi a1, a1, 4

    #--- Crear campo de longitud

	sb a0, 0(a1)	  #-- Almacenar la longitud
	addi a1, a1, 1    #-- Actualizar puntero

    #--- Crear campo Nombre
    #-- Copiar a0 bytes desde a2(cadena nombre) a a1 (cabecera)
    PUSH a0    #-- Guardar longitud y direccion en la pila 
    PUSH a1
	RCALL _COPY_BYTES	 #-- Copiar nombre de la palabra
    POP a1
    POP a0     #-- Recuperar longitud y direccion de la cadena

    #-- Actualizar puntero
	add a1, a1, a0	#-- a1: Direccion del final de la palabra

    #-- Alinear la direccion a 4 bytes 
	addi a1, a1, 3
	andi a1, a1, 0xFFFFFFFC

    #-------- Actualizar LATEST y HERE
	la t0, var_HERE
	la t1, var_LATEST

	lw t2, 0(t0)   #-- LATEST apunta donde antes apuntaba HERE
	sw t2, 0(t1)

	sw a1, 0(t0)   #-- HERE apunta al final de la nueva cabecera
	NEXT

#------------------------------------------------------------
#-- , (COMMA)
#-- Añadir un campo de 1 palabra, a partir de la variable HERE
#------------------------------------------------------------
       .data
COMMA: .word code_COMMA
       .text
code_COMMA:
    POP a0   #-- Puntero a almacenar
    RCALL _COMMA  #-- Ejecutar!
    NEXT

_COMMA:
	la t0, var_HERE		#-- t1 = HERE
	lw t1, 0(t0)

	sw a0, 0(t1)		#-- Almacenar puntero
	addi t1, t1, 4		#-- Incrementa la direccion
	sw t1, 0(t0)		#-- Actualiza HERE
	ret

#------------------------------------------------------------
#-- [ (LBRAC)
#-- Pasar a modo inmediato (Fijar variable STATE a 0)
#-- TODO: Flag de inmediato!!!
#------------------------------------------------------------
       .data
LBRAC: .word code_LBRAC
       .text
code_LBRAC:
	la t0, var_STATE
	sw zero, 0(t0)	  #-- Cambiar STATE a 0
	NEXT


#------------------------------------------------------------
#-- ] (RBRAC)
#-- Pasar a modo compilacion (Fijar variable STATE a 1)
#------------------------------------------------------------
       .data
RBRAC: .word code_RBRAC
       .text
code_RBRAC:
	la t0, var_STATE
	li t1, 1
	sw t1, 0(t0)	#-- Poner STATE a 1
	NEXT


#============================================================================
#=   SALTOS!!
#============================================================================

#-----------
#- BRANCH
#-----------
        .data
BRANCH: .word code_BRANCH
        .text
code_BRANCH:
	lw t0, 0(s1)       #-- Leer el Puntero de instruccion (IP)
	add s1, s1, t0	   #-- Sumar el offset al IP
	NEXT

#============================================================================
#=                      INTERPRETE
#============================================================================

#---------------------------------------------------
#- QUIT
#- Inicializar el sistema y arrancar el interprete
#- Es una palabra especial, que nunca retorna, por ello
#- no se llama a EXIT
#---------------------------------------------------
       .data
QUIT:  .word DOCOL
	   .word RZ,RSPSTORE	#// R0 RSP!, clear the return stack
	   .word INTERPRET		#// interpret the next word
	   .word BRANCH, 
       .word -16	#// and loop (indefinitely)

#------------------------------------------------------------
#-- INTERPRET
#-- Interpretar una instrucción
#------------------------------------------------------------
       .data
INTERPRET: .word code_INTERPRET
       .text
code_INTERPRET:

    #-- Leer palabra de la entrada estándar
	RCALL _WORD		
    #-- a1: Longitud, a0: Puntero a la palabra

    #--- Comprobar si esta en el diccionario
    #--- Se usa s2 como flag para indicar si lo introducido es literal o no
	mv s2, zero		#-- s2 = 0: No es un literal (de momento)
	mv a2, a0       #-- a2: Puntero a la palabra
	RCALL _FIND		#-- Devuelve: a0 = Puntero a la cabecera
                    #--  0 si no se encuentra
	beqz a0, _INTERPRET_1     #-- Saltar si no se encuentra!!!    

    #-- Palabra en el diccionario!
    #-- Comprobar si es un codeword imediato
	lb t0, 4(a0)    #-- t0: Leer campo name+flags
	PUSH t0			#-- Guardarlo de momento
	RCALL _TCFA		#-- a0: puntero al codeword
	POP t0          #-- t0: Valor del campo name+flags
	andi t0, t0, F_IMMED	#-- Esta el flag de inmediato activado?
	bnez t0, _INTERPRET_4	#-- Flag INMMED activado: Saltar a ejecutar la palabra

	j _INTERPRET_2

_INTERPRET_1:  #-- No esta en el diccionario. Asumimos que es un numero literal
	addi s2, s2, 1	#-- Activar flag de literal

    RCALL _NUMBER		#-- Devuelve el numero parseado en a0. a1 es > 0 si error

	bnez a1, _INTERPRET_6   #--- ERROR! No es un numero valido. Saltar!

    #-- Numero literal OK
	mv a1, a0     #-- a1: Numero literal
	la a0, LIT	  #-- Palabra a ejecutar: LIT

_INTERPRET_2:  #-- Estamos compilando o ejecutando?
	la t1, var_STATE  
	lw t0, 0(t1)     #-- t0: Estado del interprete (0 ejecutando, 1 compilando)
	beqz t0, _INTERPRET_4	 #-- Saltar si estamos ejecutando

    #-- Compilando! Añadir la palabra a la entrada actual del diccionario
	RCALL _COMMA

	beqz s2, _INTERPRET_3		#-- Es una palabra literal?. NO: Saltar
	mv a0, a1                   #-- Si es literal. LIT va seguido de un numero
	RCALL _COMMA            #-- Añadir el numero al diccionario

_INTERPRET_3:	NEXT  #-- Hemos terminado

_INTERPRET_4:   #-- Ejecuta la palabra!!!!  
    
	bnez s2, _INTERPRET_5		#-- Si es literal, saltar

    #-- NO es un literal. Ejecutarlo ahora! No retorna nunca, ya que el
    #-- codeword llamara a NEXT que devolvera el control a la siguiente palabra
	lw t0, 0(a0)   #-- Leer codeword
	jr t0          #-- Ejecutar el codeword!


_INTERPRET_5: #-- Ejecutar un literal: meterlo en la pila
	PUSH a1   
	NEXT

_INTERPRET_6: #-- Error de parseado (No es una palabra conocido ni un numero
              #-- en la base actual)
              #-- Imprimir un mensaje de error

	li a0, 2		  #-- a0: stderr
	la a1, errmsg	  #-- a1: Mensaje de error
	la t0, errmsgend  #-- a2: Longitud de la cadena
	sub a2, t0, a1		#-- 3rd param: length of string
	li a7, 64           #-- Llamada al sistema write
	ecall


	la a1, currkey	#-- El error ha ocurrido justo antes de la 
	lw a1, 0(a1)    #-- la posicion currkey
                    #-- a1: apunta al caracter donde se ha producido el error

    #-- a2: currkey - buffer: Longitud en el bufer antes de currkey
	la t0, buffer
	sub a2, a1, t0

	li t2, 40
    slt t0, t2, a2		#// if > 40, then print only 40 characters
	beqz t0, _INTERPRET_7
	li a2, 40

_INTERPRET_7:
    sub a1, a1, a2		#-- a1: Comienzo del area a imprimir. a2 = longitud
	li a0, 2
	li a7, 64	#-- Llamada al sistema WRITE
	ecall

	la a1, errmsgnl		# newline
	li a2, 1
	li a0, 2
	li a7, 64	#// write syscall
	ecall

	NEXT

    .data
    .align 2
errmsg: .ascii "PARSE ERROR\n"
errmsgend:
errmsgnl: .ascii "\n"



#============================================================================
#=                              VARIABLES
#============================================================================

#----------------------------------------------------
#-- STATE
#-- Estado del intérprete
#-- 0: El intérprete está ejecutando código
#-- !=0: El intérprete está compilando una palabra
#----------------------------------------------------
      .data
STATE: .word code_STATE
       .text
code_STATE:
       la t0, var_STATE
       PUSH t0
       NEXT
       .data
       .align 2
var_STATE: .word 0  #-- Interpretando por defecto

#------------------------------------------------------
#-- LATEST: Apunta a la última palabra introducida
#-- en el diccionario
#------------------------------------------------------
      .data
LATEST: .word code_LATEST
       .text
code_LATEST:
       la t0, var_LATEST
       PUSH t0
       NEXT
       .data
       .align 2
var_LATEST:
	.word name_BYE


#----------------------------------------------------
#-- HERE
#-- Apunta al siguiente byte disponible de memoria
#----------------------------------------------------
     .data
HERE: .word code_HERE
       .text
code_HERE:
       la t0, var_HERE
       PUSH t0
       NEXT
       .data
       .align 2
var_HERE: .word free_mem


#----------------------------------------------------
#-- S0
#-- Direcciodn de la cime de la pila de parametros
#----------------------------------------------------- 
     .data
SZ: .word code_SZ
       .text
code_SZ:
       la t0, var_SZ
       PUSH t0
       NEXT
       .data
       .align 2
var_SZ: .word stack_top


#-------------------------------------------------------
#-- BASE a utilizar para los numeros que se leen 
#-- y que se imprimen. Por defecto es BASE 10 
#-------------------------------------------------------
    .data
BASE: .word code_BASE
       .text
code_BASE:
       la t0, var_BASE
       PUSH t0
       NEXT
       .data
       .align 2
var_BASE: .word 10

#============================================================================
#=                              CONSTANTES
#============================================================================


#---------------------
#-- VERSION DEL FORTH
#---------------------
    .data
VERSION: .word code_VERSION
    .text
code_VERSION:
    li t0, JONES_VERSION
	PUSH t0
	NEXT

#---------------------------------------------------------------
#-- R0: Valor inicial de la pila de retorno
#-- Es el valor usado para inicializar la pila de retorno. 
#-- Es la direccion de comienzo (top)
#---------------------------------------------------------------
    .data
RZ: .word code_RZ
    .text
code_RZ:
    la t0, return_stack_top
	PUSH t0
	NEXT

#-----------------------------------------------
#-- DOCOL
#-- Puntero a DOCOL
#-----------------------------------------------
    .data
__DOCOL: .word code___DOCOL
    .text
code___DOCOL:
    la t0, DOCOL
	PUSH t0
	NEXT

#------------------------------
#-- F_IMMED
#-- Valor del flag IMMEDIATE
#------------------------------
    .data
__F_IMMED: .word code___F_IMMED
    .text
code___F_IMMED:
    li t0, F_IMMED
	PUSH t0
	NEXT

#-------------------------------
#-- F_HIDDEN
#-- Valor del flag HIDDEN
#-------------------------------
    .data
__F_HIDDEN: .word code___F_HIDDEN
    .text
code___F_HIDDEN:
    li t0, F_HIDDEN
	PUSH t0
	NEXT

#--------------------------------------------
#-- F_LENMASK
#-- Mascara para obtener el campo length
#--------------------------------------------
    .data
__F_LENMASK: .word code___F_LENMASK
    .text
code___F_LENMASK:
    li t0, F_LENMASK
	PUSH t0
	NEXT


#============================================================================
#=                      PILA DE RETORNO
#============================================================================

#-------------------------------------------------------
#-- RSP! (RSPSTORE)
#-- Actualizar el valor puntero de pila R
#-------------------------------------------------------
    .data
RSPSTORE: .word code_RSPSTORE
          .text
code_RSPSTORE:
	POP fp  #-- Actualizar valor de fp con el valor de la pila
	NEXT


#-------------------------------------------
#-- Programa principal
#-- ARRANCA AQUI!!!!
#-------------------------------------------
    .text
    .global main
main:

    #-- Inicializar la pila de datos
    la sp, stack_top

    #-- Guardar el puntero de pila inicial en la variable FORTH S0
    la t0, var_SZ
	sw sp, 0(t0)

    #-- Inicializar el puntero de pila R
	la fp, return_stack_top 

    #-- S1 apunta la primera palabra a ejecutar  
    #-- s1 es el puntero de instruccion (IP)
    la s1,cold_start

    #-- Ejecutar el interprete
    NEXT

    #-- Nunca llega aqui!!!!!

	.data
	.align 2
    #-- Primera Palabra a Ejecutar
    #-- Como es la primera es "especial"
    #-- No tiene codeword propio
cold_start:	
	.dword QUIT



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

#--- Aquí apunta HERE. A partir de aquí es donde se insertan
#--- las nuevas palabras creadas al ejecutar Forth
    .align 2
free_mem:
