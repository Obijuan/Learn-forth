#----------------------------------------------------------------
#-- Implementacion de las palabras primitivas
#----------------------------------------------------------------			
	
		
	.globl do_1, do_plus, do_minus, do_point, do_and, do_lit, do_emit	
	.globl do_key, do_store, do_or, do_xor, do_invert, do_negate, do_oneplus
	.globl do_oneminus, do_twostar, do_twoslash, do_lshift, do_rshift
	.globl do_zeroequal, do_zeroless, do_equal, do_less, do_uless, do_dup
	.globl do_qdup, do_drop, do_swap, do_over, do_rot, do_fetch, do_cfetch
	.globl do_cstore, do_spfetch, do_spstore, do_rfetch, do_rpfetch
	.globl do_rpstore, do_tor, do_rfrom, do_plusstore, do_branch
	.globl do_qbranch, do_xdo, do_xloop, do_xplusloop, do_ii, do_jj
	.globl do_unloop, do_bye, do_execute, docon, do_savekey, do_fourstar
	.globl douser, do_fill, do_cmove
					
	.include "macros.h"
	
	.text

#---------------------------------------------------
#-- DOCON, code action of CONSTANT
#---------------------------------------------------
docon:
	#-- Leer la constante en t0
	READLIT_T0

	#-- Meterla en la pila
	PUSH_T0

	#---- NEXT
	POP_RA
	NEXT

#---------------------------------------------------
#--  DOVAR, code action of VARIABLE, entered by CALL
#-- DOCREATE, code action of newly created words
#--    --- a-addr
#--
#-- Meter la direccion de la variable en la pila
#---------------------------------------------------
dovar:
docreate:

    #-- La direccion de la variable esta en ra
	#-- La matemos en la pila
	mv t0,ra
	PUSH_T0

	#--- NEXT
	POP_RA
	NEXT

#---------------------------------------------------
#--  DOUSER, code action of USER,
#-- entered by CALL DOUSER
#--    --- a-addr
#--
#-- Meter en la pila la direccion de la zona de usuario
#-- (base) menos el offsert indicado por el parámetro
#---------------------------------------------------
douser:
    #-- Leer el parametro en t0 (offset)
	READLIT_T0

    #-- añadir el offser a la direccion de la zona de usuario
    add t0, s2, t0

	#-- Meter direccion en la pila
	PUSH_T0

	#---- NEXT
	POP_RA
	NEXT


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
# 4*    x1 -- x2        arithmetic left shift by 2 bits
#----------------------------------------------
do_fourstar:

	#-- Obtener el TOS en t0
	POP_T0

	#-- Desplazamiento aritmetico a la izquierda
	#-- (El aritmetico a la izquierda es equivalente al logico a la izq.)
	slli t0,t0,2

	#-- Devolverlo a la pila
	PUSH_T0

	NEXT

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

#-------------------------------------------
#  <    n1 n2 -- flag   test n1<n2, signed
#-------------------------------------------									
do_less:

	#-- Obtener TOS en  t1 (t1 = n2)
 	POP_T0
 	mv t1,t0
 	
 	#-- Obtener otro argumento en t0 (t0 = n1)
 	POP_T0
 	
 	#-- Realizar la operacion de comparacion
	slt t0, t0, t1 

	#-- Convertir a flags de Forth
	#--- 1 --> -1
	#--- 0 --> 0
	neg t0,t0
 	
 	#-- Guardar resultado en la pila
 	PUSH_T0
 	
	ret

#----------------------------------------------------
#  U<    u1 u2 -- flag       test u1<n2, unsigned
#----------------------------------------------------									
do_uless:

	#-- Obtener TOS en  t1 (t1 = n2)
 	POP_T0
 	mv t1,t0
 	
 	#-- Obtener otro argumento en t0 (t0 = n1)
 	POP_T0
 	
 	#-- Realizar la operacion de comparacion
	sltu t0, t0, t1 

	#-- Convertir a flags de Forth
	#--- 1 --> -1
	#--- 0 --> 0
	neg t0,t0
 	
 	#-- Guardar resultado en la pila
 	PUSH_T0
 	
	ret

#----------------------------------------------
# DUP      x -- x x     duplicate top of stack
#----------------------------------------------
do_dup:

	#-- Obtener el TOS en t0
	POP_T0

	#-- Devolverlo a la pila dos veces
	PUSH_T0
	PUSH_T0

	ret

#----------------------------------------------
#  ?DUP     x -- 0 | x x    DUP if nonzero
#----------------------------------------------
do_qdup:

	#-- Obtener el TOS en t0
	POP_T0

	#-- En todos los casos este valor debe estar en la pila
	PUSH_T0

	#-- t0=0? --> fin
	beqz t0, qdup_end

	#-- Meter otra copia de t0
	PUSH_T0

qdup_end:
	ret

#----------------------------------------------
# DROP     x --          drop top of stack
#----------------------------------------------
do_drop:

	#-- Obtener el TOS en t0
	POP_T0

	ret

#----------------------------------------------
# SWAP    x1 x2 -- x2 x1    swap top two items
#----------------------------------------------
do_swap:

	#-- Obtener el TOS: t2 = x2
	POP_T0
	mv t2,t0

	#-- Obtener el siguiente elemento: t1 = x1
	POP_T0
	mv t1,t0

	#-- Meter t2 en la pila
	mv t0,t2
	PUSH_T0

	#-- Meter t1 en la pila
	mv t0,t1
	PUSH_T0

	ret

#----------------------------------------------
# OVER    x1 x2 -- x1 x2 x1   per stack diagram
#----------------------------------------------
do_over:

	#-- Obtener el TOS: t2 = x2
	POP_T0
	mv t2,t0

	#-- Obtener el siguiente elemento: t1 = x1
	POP_T0
	mv t1,t0

	#-- Meter t1 en la pila
	mv t0,t1
	PUSH_T0

	#-- Meter t2 en la pila
	mv t0,t2
	PUSH_T0

	#-- Meter t1 en la pila
	mv t0, t1
	PUSH_T0

	ret

#----------------------------------------------
# ROT    x1 x2 x3 -- x2 x3 x1  per stack diagram
#----------------------------------------------
do_rot:

	#-- Obtener el TOS: t3 = x3
	POP_T0
	mv t3,t0

	#-- Obtener el siguiente elemento: t2 = x2
	POP_T0
	mv t2,t0

    #-- Obtener el siguiente elemento: t1 = x1
	POP_T0
	mv t1,t0

	#-- Meter t2 en la pila
	mv t0,t2
	PUSH_T0

	#-- Meter t3 en la pila
	mv t0,t3
	PUSH_T0

	#-- Meter t1 en la pila
	mv t0, t1
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
#-- El literal se encuentra en la posicion siguiente del
#-- Thread de Forth
#-----------------------------------
do_lit:

    READLIT_T0

    #-- Incrementar ra en 4 para que se ejecute la instruccion
    #-- tras el literal (y no el lui)
    addi ra,ra,4
    
    #-- En t0 tenemos el literal
    #-- Lo metemos en la pila
    PUSH_T0
    ret

#-- old version
# do_lit:
# 	mv t0,a0
# 	PUSH_T0
# 	ret
	
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

#------------------------------------------------
#-- @     a-addr -- x   fetch cell from memory
#------------------------------------------------	
do_fetch:
	#-- Sacar de la pila la dirección
	#-- t0 --> Direccion donde leer
	POP_T0				
	mv t1, t0
	
	#-- Lectura de la memoria
	lw t0, 0(t0)

	#-- Guardar el valor en la pila
	PUSH_T0		
		
	ret

#------------------------------------------------
#-- C@     c-addr -- char   fetch char from memory
#------------------------------------------------	
do_cfetch:
	#-- Sacar de la pila la dirección
	#-- t0 --> Direccion donde leer
	POP_T0				
	mv t1, t0
	
	#-- Lectura de la memoria
	lbu t0, 0(t0)

	#-- Guardar el valor en la pila
	PUSH_T0		
		
	ret
	
#------------------------------------------------
#-- C!    char c-addr --    store char in memory
#------------------------------------------------	
do_cstore:

	#-- Sacar de la pila la dirección
	#-- t1 --> Direccion donde escribir
	POP_T0				
	mv t1, t0
	
	#-- Sacar de la pila el valor
	#-- t0 = valor
	POP_T0
	
	#-- Ejecutar!
	sb t0, 0(t1)		
		
	ret
	
#------------------------------------------------
#-- SP@  -- a-addr       get data stack pointer
#------------------------------------------------	
do_spfetch:
	
	#-- Meter sp en la pila
	mv t0,sp
	PUSH_T0		
		
	ret

#------------------------------------------------
#-- SP!  a-addr --       set data stack pointer
#------------------------------------------------	
do_spstore:

	#-- Sacar de la pila la dirección
	#-- t1 --> Direccion donde escribir
	POP_T0				
	
	#-- Establecer el nuevo puntero de pila
	mv sp, t0
		
	ret

#------------------------------------------------
#-- R@    -- x     R: x -- x   fetch from rtn stk
#------------------------------------------------	
do_rfetch:

	#-- Leer el elemento de la pila R (sin sacarlo)
	lw t0, 0(s0)
	
	#-- Meterlo en la pila
	PUSH_T0		
		
	ret

#------------------------------------------------
#-- RP@  -- a-addr       get return stack pointer
#------------------------------------------------	
do_rpfetch:

	#-- Meter el puntero de la pila r en t0
	mv t0, s0
	
	#-- Meterlo en la pila
	PUSH_T0		
		
	ret

#------------------------------------------------
#-- RP!  a-addr --       set return stack pointer
#------------------------------------------------	
do_rpstore:

	#-- Sacar de la pila la dirección
	#-- t1 --> Direccion donde escribir
	POP_T0				
	
	#-- Establecer el nuevo puntero de pila R
	mv s0, t0
		
	ret

#------------------------------------------------
#--  >R    x --   R: -- x   push to return stack
#------------------------------------------------	
do_tor:

	#-- Sacar de la pila el dato (x)
	POP_T0				
	
	#-- Meterlo en la pila R
	PUSHR_T0
		
	ret

#------------------------------------------------
#-- R>    -- x    R: x --   pop from return stack
#------------------------------------------------	
do_rfrom:

	#-- Leer el elemento de la pila R
	POPR_T0
	
	#-- Meterlo en la pila
	PUSH_T0		
		
	ret

#------------------------------------------------
#-- +!     n/u a-addr --       add cell to memory
#------------------------------------------------	
do_plusstore:
	#-- Sacar de la pila la dirección
	#-- t1 --> Direccion donde leer
	POP_T0				
	mv t1, t0

	#-- Sacar el dato a sumar: t0 --> Dato
	POP_T0
	
	#-- Lectura de la memoria
	#-- t2 = Mem[addr]
	lw t2, 0(t1)

	#-- Sumar el dato n (n + mem[addr])
	add t0, t0, t2

	#-- Almacenar el nuevo dato (n + mem[addr])
	sw t0, 0(t1)	
		
	ret

#-------------------------------------------------
#-- branch   --                  branch always
#-------------------------------------------------
do_branch:

	#-- HACK PARA EL RARS:
	#-- Branch no hace nada. Sólo retorna
	#-- Tras el branch se coloca un jump a la
	#-- etiqueta que se quiere

	#-- Implementacion si podemos guardar el literal
	#-- (direccion) a continuacion de branch:

	#READLIT_T0
	
	#-- El literal es la direccion destino a la que
	#-- saltar. Lo guardamos directamente en ra
	#mv ra, t0
   
    #-- Al hacer el ret salta a la direccion
	#-- indicada
	ret

#-------------------------------------------------
#-- ?branch   x --           branch if TOS zero
#-------------------------------------------------
do_qbranch:

	#-- Leer la condicion que está en TOS
	POP_T0

	#-- Si es 0 se hace el salto que indique la literal
	#-- si NO es 0, se continua
	bne t0,zero,skip

	#-- Hay que hacer el salto
	#-- Directamente se termina para que
	#-- se ejecute el salto que sigue a qbranch
	j end_qbranch

	#-- No realizar el salto
	#-- INcrementar ra en 4 para evitar la constante
skip:   
	addi ra,ra,4

end_qbranch:
    #-- Al hacer el ret salta a la direccion
	#-- indicada
	ret

#-------------------------------------------------
#-- (do)    n1|u1 n2|u2 --  R: -- sys1 sys2
#-------------------------------------------------
#-- En una implementacin basica, sys1 es el limite
#-- sys2 el indice, pero en la pila R
do_xdo:

	#-- Leer indice de la pila
	#-- t1=indice
	POP_T0
	mv t1,t0

	#-- Leer limite de la pila
	#-- t0=limite
	POP_T0

	#-- Meter limite en pila R (sys1)
	PUSHR_T0

	#-- Meter indice en pila R (sys2)
	mv t0,t1
	PUSHR_T0

	ret

#-------------------------------------------------
#-- (loop)   R: sys1 sys2 --  | sys1 sys2
#-- sys1: limite
#-- sys2: indice
#-------------------------------------------------
do_xloop:
	#-- Leer el indice. t2 = indice
	#-- sin sacarlo de la pila R
	lw t2, 0(s0)

	#-- Leer el limite. t1 = limite
	#-- sin sacarlo de la pila R
	lw t1, 4(s0)

	#-- Incrementar el indice en 1 unidad
	#-- (+LOOP incrementa en n unidades, tomadas de la pila)
	addi t2,t2,1

	#-- si index < limit --> saltar a DO
	blt t2, t1, xloop_repeat

	#-- Hemos terminado. Vaciar la pila R
	POPR_T0
	POPR_T0

	#-- Incrementar ra para saltar la literal
	addi ra,ra,4
	j end_xloop

	#-- No hemos terminado: Saltar a DO
xloop_repeat:
	#-- Actualizar el indide en la pila R
	sw t2, 0(s0)

end_xloop:
	ret

#-------------------------------------------------
#-- (+loop)   n --   R: sys1 sys2 --  | sys1 sys2
#-- sys1: limite
#-- sys2: indice
#-------------------------------------------------
do_xplusloop:
	#-- Leer el indice. t2 = indice
	#-- sin sacarlo de la pila R
	lw t2, 0(s0)

	#-- Leer el limite. t1 = limite
	#-- sin sacarlo de la pila R
	lw t1, 4(s0)

	#-- Leer de la pila n: el numero a incrementar el indice
	POP_T0

	#-- Incrementar el indice
	add t2,t2,t0

	#-- si index < limit --> saltar a DO
	blt t2, t1, xplusloop_repeat

	#-- Hemos terminado. Vaciar la pila R
	POPR_T0
	POPR_T0

	#-- Incrementar ra para saltar la literal
	addi ra,ra,4
	j end_xplusloop

	#-- No hemos terminado: Saltar a DO
xplusloop_repeat:
	#-- Actualizar el indide en la pila R
	sw t2, 0(s0)

end_xplusloop:
	ret


#-------------------------------------------------
#-- I     -- n   R: sys1 sys2 -- sys1 sys2
#--     get the innermost loop index
#-- sys1: limite
#-- sys2: indice
#-------------------------------------------------
do_ii:
    #-- Leer el indice. t0 = indice
	#-- sin sacarlo de la pila R
	lw t0, 0(s0)

	#-- Guardarlo en la pila
	PUSH_T0
	
	ret

#-------------------------------------------------
#-- J        -- n   R: 4*sys -- 4*sys
#--                  get the second loop index
#-------------------------------------------------
do_jj:
    #-- Leer el indice exterior
	lw t0, 8(s0)

	#-- Guardarlo en la pila
	PUSH_T0
	
	ret

#-------------------------------------------------
#-- UNLOOP   --   R: sys1 sys2 --  drop loop parms
#-------------------------------------------------
do_unloop:

	POPR_T0
	POPR_T0
    
	NEXT

#---------------------------------------------------
# BYE     i*x --    return to OS
#---------------------------------------------------
do_bye:
	OS_EXIT

#---------------------------------------------------
# EXECUTE   i*x xt -- j*x   execute Forth word
#---------------------------------------------------
do_execute:

	#-- xt: Direccion donde está la palabra forth
	#-- a ejecutar

	#-- Obtener la direccion de la pila (xt)
	#-- t0 = xt
	POP_T0

	#-- Meter la dirección en ra
	mv ra,t0

	#-- Y sumar 4 para apuntar a la siguiente instrucción
	addi ra,ra,4

	#-- Ejecutar la palabra
	jalr  zero, t0, 0

#---------------------------------------------------
# EXECUTE   SAVEKEY  -- addr  temporary storage for KEY?
#---------------------------------------------------
do_savekey:
	DOVAR
	DW(0)

#-----------------------------------------------------
#  FILL   c-addr u char --  fill memory with char
#-----------------------------------------------------
do_fill:
	#-- t2 = Caracter a rellenar (char)
	POP_T0
	mv t2, t0

	#-- t1 = Cantidad de caracterer (u)
	POP_T0
	mv t1,t0

	#-- t0 = Direccion de comienzo (c-addr)
	POP_T0

fill_bucle:
	#-- Si contador de caracteres a 0, terminamos
	beq t1,zero, fill_end

	#-- Guardar caracter en la posicion actual
	sb t2, 0(t0)

	#-- Decrementar contador de caracteres
	addi t1,t1,-1

	#-- Incrementar direccion
	addi t0,t0,1

	#-- Repetir
	j fill_bucle

fill_end:

	NEXT

#-----------------------------------------------------
#  X CMOVE   c-addr1 c-addr2 u --  move from bottom
#  Copiar u bytes desdde addr1 hasta addr2 (src-->dst)
#-----------------------------------------------------
do_cmove:

	#-- t2 = Numero de caracteres a copiar (u)
	POP_T0
	mv t2, t0

	#-- t1 = Direccion destino (addr2)
	POP_T0
	mv t1, t0

	#-- t0 = Direccion fuente (addr1)
	POP_T0

cmove_bucle:

	#-- Si no quedan caracteres por copiar, terminar
	beq t2, zero, cmove_end

	#-- Leer byte fuente
	lb t3, 0(t0)

	#-- Escribir byte en destino
	sb t3, 0(t1)

	#-- Decrementar contador de bytes
	addi t2,t2,-1

	#-- Incrementar direccion fuente
	addi t0,t0,1

	#-- Incrementar direccion destino
	addi t1,t1,1

	#-- Repetir
	j cmove_bucle

cmove_end:
	NEXT

