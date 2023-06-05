#--------------------------------------------------------------------
#-- INTERPRETE DE FORTH. Version 159
#-- 
#--  Implementación en ensamblador del programa Forth:
#--  5 ,  DP @  4 MINUS @ .HEX
#--  
#--  Resultado: 
#--  0x00000005  ok
#--
#--
#--------------------------------------------------------------------
#-- HACK PARA LITERALES!
#--
#-- Como dentro del codigo NO SE PUEDEN meter datos, los
#-- incrustamos en la instrucción lui (en sus 20-bits de mayor peso)
#--------------------------------------------------------------------
#-- HACK PARA LAS LITERALES DE DIRECCION DE SALTO:
#-- Se almacenan directamente con una instruccion j. Para realizar
#-- el salto se ejecuta esta instruccion directamente
#--------------------------------------------------------------------
#-- (TODO) Optimizacion para el futuro:
#--   -Dejar el elemento superior (TOS: Top of Stack) en un registro
#--     en vez de en la pila. Ahorra operaciones
#--------------------------------------------------------------------

#-------------------------------------------
#-- Registros: 
#--    sp = PSP  Param Stack Pointer
#--    s0 = RSP  Return Stack Pointer
#--    t0 = Forth TOS (top Param Stack item)
#--    t1 = W working register
#--    s1 = IP Interpreter Pointer
#--    s2 = UP User area Pointer
#----------------------------------------------------------------
#-- Nuestro IP es en realidad el PC. Al llamar a una palabra
#-- de alto nivel, tenemos en RA la siguiente instrucción forth
#----------------------------------------------------------------

	.include "macroCPU.h"
    .include "primitives.h"
    .include "high.h"

    .global do_uinit, ptib

#---------------------------------
#-- SEGMENTO DE DATOS
#---------------------------------	
	.data

#--------------------------------
#-- Terminal Input Buffer (TIB)
#-- Tamaño: 128 bytes
#-- Direccion: 0x2000
#--------------------------------
ptib:  #-- Puntero
    .byte '1', ' ', ' ', 't'
    .byte 3, 't', 'e', 's'
    .word 0x0,0x0,0x0,0,0,0,0,0,0,0,0,0,0,0 #-- 14 palabras
    .word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 #-- 16 palabras

.include "dicctionary.s"

#--- NOTA: Reservar espacio para el usuario!!!
    .space 1024

#--------------------------------
#-- Valores iniciales para el area de usuario
#-----------------------------------------
#-- Cabeza
#-- Cuerpo
#-- HACK: En el rars en el segmento de datos NO SE PUEDE METER
#--   codigo directamente en ensamblador, por lo que hay que ponerlo
#--   directamente en codigo máquina (y lo ejecuta ok)
#--   En el GNU-AS no hace falta. El codigo se puede poner 
#--   
#--  Se deposita en la pila la direccion de los valores iniciales
#--  del area de usuario
#       -- addr 
do_uinit: #--- CODIGO!!!!
    .word 0xFFC40413  #-- addi s0,s0,-4  | PUSH_RA
    .word 0x00142023  #-- sw ra,0(s0)    |

    #-- Saltar a la direccion del segmento de texto + 4 (offset de docreate)
    #-- Si segmento de texto comienza en 0, poner este salto:
    # .word 0x00000013  #-- nop
    # .word 0x00000013  #-- nop
    # .word 0x004000e7  #-- jalr ra,zero,4
    #-- Si segmento de texto comienza en 0x00400000 poner este otro salto:
    .word 0x004002b7  #-- lui t0, 0x400 | li t0, 0x00400000 (Dir seg texto)
    .word 0x00028293  #-- addi t0,t0,0  |
    .word 0x004280e7  #-- jalr ra,t0,4  | Saltar a 0x400004 (Dir de docreate)
                      #-- ra contiene la direccion de los datos que vienen
                      #-- a continuacion
#-- Parametros: valores iniciales area de usuario
uinit_params:
    .word 0,0,10,0  # reserved, >IN, BASE, STATE
    .word enddict   # DP
    .word 0,0       # SOURCE init'd elsewhere
    .word lastword   # LATEST
    .word 0         # HP init'd elsewhere



#----------- SITUAR AL FINAL DE LA RAM ----------------

#-----------------------
#-- USER AREA (128 bytes)
#-----------------------
user_area: #-- Botom of user area
    .word 0  #-- u0: Reservado.  Offset: 0x00
    .word 0  #-- >IN: Offset dentro de TIB. Offset: 0x04
    .word 0  #-- BASE: Conversion radix. Offset: 0x08
    .word 0  #-- STATE: Compiler state. Offset: 0x0C
    .word 0  #-- DP: Dictionary pointer. Offset: 0x10
    .word 0  #-- 'SOURCE: Two cells: len, addrs. Offset: 0x14
    .word 0  #--
    .word 0  #-- LATEST: Last word in dict. Offset: 0x1C
    .word 0  #-- HP: HOLD Pointer. Offset: 0x20
    .word 0  #-- LP: Leave-stack pointer. Offset: 0x24
    .space 88

   #-----------------------
   #-- PILA de Datos (Parameter stack. 128 bytes. Crece hacia abajo)
   #----------------------	
	.space 128  #-- Tamaño 32 palabras
	.align 2
stack:

#--------------------------------
#-- HOLD AREA 
#-- 40 bytes. Crece hacia abajo
#--------------------------------
    .space 40
    .align 2
phold:

#---------------------------------
#-- PAD BUFFER
#--  88 bytes
#---------------------------------
    .space 88
    .align 2
ppad:

#-----------------------
#-- PILA de retorno
#-- 128 bytes. Crece hacia abajo
#-----------------------
    .space 128
rstack:

#---------------------------------------------------------------
#-- CODIGO
#---------------------------------------------------------------
	.text

    j start

#--------------------------------------------------------------
#-- Codigo en direcciones fijas
#--------------------------------------------------------------
#---------------------------------------------------
#--  DOVAR, code action of VARIABLE, entered by CALL
#-- DOCREATE, code action of newly created words
#--    --- a-addr
#--
#-- Meter la direccion de la variable en la pila
#---------------------------------------------------
#-- Dirección 0x0004
dovar:
docreate:

    #-- La direccion de la variable esta en ra
	#-- La matemos en la pila
	mv t0,ra
	PUSH_T0

	#--- NEXT
	POP_RA
	NEXT


#-----------------------------------------------------------------------------
#--- INICIALIZACION DEL FORTH KERNEL
#-----------------------------------------------------------------------------
start:

	#-- Inicializar la pila de datos
	la sp, stack
	
	#-- Inicializar la pila de retorno
	la s0, rstack

    #-- Inicializar el puntero a la zona de usuario (UP)
    la s2, user_area

    #-- Inicializacion del sistema
    #-- (COLD)
    #-- COLD llama a quit, pero de momento lo hacemos manualmente
    COLD

    #-- Arrancar el modo interactivo (intérprete)
    #QUIT  #-- Nunca retorna de aquí

    #-- Modo ejecución directa (No interactivo)
    #-- Programa Forth: 
    #-- 5 ,  DP @  4 MINUS @ .HEX

    #-- Añadir celula con valor 5
    LIT(5)
    COMMA
    
    #-- Comprobar que se ha añadido
    #-- Puntero al diccionario
    DP
    FETCH

    #-- Apuntar a la celula anterior
    #-- y mostrar su contenido (debe terner 5)
    LIT(4)
    MINUS
    FETCH
    DOTHEX

    #-- Fin ejecución directa
    XSQUOTE(4," ok\n")
    TYPE

	#-- Terminar
	BYE
