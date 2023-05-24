#----------------------------------------------------------------
#-- Implementacion de las palabras primitivas
#----------------------------------------------------------------			
	
		
	.globl do_1, do_plus, do_minus, do_point, do_and, do_lit, do_emit	
	.globl do_key, do_store, do_or, do_xor, do_invert, do_negate, do_oneplus
	.globl do_oneminus, do_twostar, do_twoslash, do_lshift, do_rshift
	.globl do_zeroequal, do_zeroless, do_equal
					
	.include "macros.h"
	
	.text			
#---------------
#-- Palabra 1	
#--
#-- Meter 1 en la pila (PUSH 1)
#---------------

do_1:
      
	#-- Guardar el 1 en la pila
	PUSH (1)
	
	#-- Hemos terminado
	ret
	
#---------------
#-- Palabra +
#--
#-- Obtener los dos ultimos elementos de la pila,
#-- sumarlos y depositar el resultado en la pila
#---------------
do_plus:

	#-- Leer el primer elemento en t1
	POP_T0
	mv t1,t0
	
	#-- Leer segundo elemento
	POP_T0
	
	#-- Realizar la suma
	add t0, t0,t1
	
	#-- Guardar resultado en la pila
	PUSH_T0
	
	#-- Hemos terminado
	ret
	
#-------------------------------------------
#-- n1/u1 n2/u2 -- n3/u3    subtract n1-n2
#------------------------------------------
do_minus:

	#-- Obtener segundo operando en t1
	POP_T0
	mv t1,t0
	
	#-- Obtener primer operando en t0
	POP_T0
	
	#-- Realizar la resta
	sub t0, t0, t1  #-- t0 - t1

	#-- Depositar resultado e la pila
	PUSH_T0

	ret
	
#-------------------------------------------
#-- AND    x1 x2 -- x3      logical AND
#-------------------------------------------
do_and:

	#-- Obtener argumento superior en t1
 	POP_T0
 	mv t1,t0
 	
 	#-- Obtener argumento inferio en t0
 	POP_T0
 	
 	#-- Realizar la operacion
 	and t0, t0, t1
 	
 	#-- Guardar resultado en la pila
 	PUSH_T0
 	
	ret

#--------------------------------------
# OR     x1 x2 -- x3  logical OR
#--------------------------------------									
do_or:

	#-- Obtener argumento superior en t1
 	POP_T0
 	mv t1,t0
 	
 	#-- Obtener argumento inferio en t0
 	POP_T0
 	
 	#-- Realizar la operacion
 	or t0, t0, t1
 	
 	#-- Guardar resultado en la pila
 	PUSH_T0
 	
	ret

#--------------------------------------
# XOR    x1 x2 -- x3   logical XOR
#--------------------------------------									
do_xor:

	#-- Obtener argumento superior en t1
 	POP_T0
 	mv t1,t0
 	
 	#-- Obtener argumento inferio en t0
 	POP_T0
 	
 	#-- Realizar la operacion
 	xor t0, t0, t1
 	
 	#-- Guardar resultado en la pila
 	PUSH_T0
 	
	ret

#--------------------------------------
# INVERT x1 -- x2    bitwise inversion
#--------------------------------------									
do_invert:

	#-- Obtener argumento superior en t0
 	POP_T0
 	
 	#-- Realizar la operacion
 	not t0, t0
 	
 	#-- Guardar resultado en la pila
 	PUSH_T0
 	
	ret	

#--------------------------------------
#  NEGATE x1 -- x2   two's complement
#--------------------------------------									
do_negate:

	#-- Obtener argumento superior en t0
 	POP_T0
 	
 	#-- Realizar la operacion
 	neg t0, t0
 	
 	#-- Guardar resultado en la pila
 	PUSH_T0
 	
	ret	

#----------------------------------------
# 1+   n1/u1 -- n2/u2      add 1 to TOS
#----------------------------------------
do_oneplus:

	#-- Obtener el TOS en t0
	POP_T0

	#-- Incrementarlo en 1
	addi t0,t0,1

	#-- Devolverlo a la pila
	PUSH_T0

	ret

#----------------------------------------------
# 1-  n1/u1 -- n2/u2     subtract 1 from TOS
#----------------------------------------------
do_oneminus:

	#-- Obtener el TOS en t0
	POP_T0

	#-- Decrementarlo en 1
	addi t0,t0,-1

	#-- Devolverlo a la pila
	PUSH_T0

	ret

#----------------------------------------------
# 2*    x1 -- x2        arithmetic left shift
#----------------------------------------------
do_twostar:

	#-- Obtener el TOS en t0
	POP_T0

	#-- Desplazamiento aritmetico a la izquierda
	#-- (El aritmetico a la izquierda es equivalente al logico a la izq.)
	slli t0,t0,1

	#-- Devolverlo a la pila
	PUSH_T0

	ret

#----------------------------------------------
# 2/   x1 -- x2      arithmetic right shift
#----------------------------------------------
do_twoslash:

	#-- Obtener el TOS en t0
	POP_T0

	#-- Desplazamiento aritmetico a la derecha
	srai t0,t0,1

	#-- Devolverlo a la pila
	PUSH_T0

	ret

#----------------------------------------------
# LSHIFT  x1 u -- x2    logical L shift u places
#----------------------------------------------
do_lshift:

	#-- Obtener el TOS en t1 (cantidad a desplazar)
	POP_T0
	mv t1,t0

	#-- Obtener el valor a desplazar en t0
	POP_T0

	#-- Desplazamiento logico a la izquierda
	sll t0,t0,t1

	#-- Devolverlo a la pila
	PUSH_T0

	ret

#----------------------------------------------
# RSHIFT  x1 u -- x2   logical R shift u places
#----------------------------------------------
do_rshift:

	#-- Obtener el TOS en t1 (numero de bits a desplazar)
	POP_T0
	mv t1,t0

	#-- Obtener el valor a desplazar en t0
	POP_T0

	#-- Desplazamiento logico a la derecha
	srl t0,t0,t1

	#-- Devolverlo a la pila
	PUSH_T0

	ret

#----------------------------------------------
# 0=     n/u -- flag    return true if TOS=0
#----------------------------------------------
do_zeroequal:

	#-- Obtener el TOS en t0
	POP_T0

	#-- Es t0=0? Dejar flag en t0 (1 si, 0 no)
	seqz t0, t0 

	#-- Convertir a flags de Forth
	#--- 1 --> -1
	#--- 0 --> 0
	neg t0,t0

	#-- Devolverlo a la pila
	PUSH_T0

	ret

#----------------------------------------------
# 0<     n -- flag      true if TOS negative
#----------------------------------------------
do_zeroless:

	#-- Obtener el TOS en t0
	POP_T0

	#-- Es t0<0? Dejar flag en t0 (1 si, 0 no)
	sltz t0,t0

	#-- Convertir a flags de Forth
	#--- 1 --> -1
	#--- 0 --> 0
	neg t0,t0

	#-- Devolverlo a la pila
	PUSH_T0

	ret

#--------------------------------------
#   =    x1 x2 -- flag   test x1=x2
#--------------------------------------									
do_equal:

	#-- Obtener TOS en t1
 	POP_T0
 	mv t1,t0
 	
 	#-- Obtener otro argumento en t0
 	POP_T0
 	
 	#-- Realizar la operacion de comparacion 
 	sub t0,t0,t1  #-- t0 = t0 - t1
	seqz t0,t0    #-- Comprobar si t0 = 0

	#-- Convertir a flags de Forth
	#--- 1 --> -1
	#--- 0 --> 0
	neg t0,t0
 	
 	#-- Guardar resultado en la pila
 	PUSH_T0
 	
	ret

#-------------------------
#-- Palabra .
#--
#-- Sacar el ultimo elemento de la pila e
#-- imprimirlo
#-------------------
do_point:
	
	#-- Sacar el elemento de la pila
	POP_T0
	
	#-- Imprimirlo
	PRINT_T0

	#-- Imprimir un espacio
	li t0, 32
	PRINT_CHAR_T0
	
	ret
	
	
#-----------------------------------
#-- Meter un literal en la pila
#-- a0: Literal a meter en la pila
#-----------------------------------	
do_lit:
	mv t0,a0
	PUSH_T0
	ret
	
#-----------------------------------------------------
#-- Emit: Imprimir el caracter que está en la pila
#-----------------------------------------------------
do_emit:

	#-- Leer el caracter de la pila
	POP_T0
	
	#-- Imprimir
	PRINT_CHAR_T0

	ret
	
#-----------------------------------------------
#-- Lectura de un caracter. Se deja en la pila 
#-----------------------------------------------
do_key:

	#-- Devolver caracter en t0
	READ_CHAR_T0
	
	#-- Meterlo en la pila
	PUSH_T0

 	ret
 	
#------------------------------------------------
#-- Store (!)  x a-addr ---
#--
#-- Almacenar el valor x en la direccion addr
#------------------------------------------------	
do_store:

	#-- Sacar de la pila la dirección
	#-- t1 --> Direccion donde escribir
	POP_T0				
	mv t1, t0
	
	#-- Sacar de la pila el valor
	#-- t0 = valor
	POP_T0
	
	#-- Ejecutar!
	sw t0, 0(t1)		
		
	ret
	