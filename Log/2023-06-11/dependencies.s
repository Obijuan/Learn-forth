#---------------------------------------------------------
#-- CPU and Model Dependencies
#---------------------------------------------------------

	.include "macroCPU.h"
  .include "primitives.h"
  .include "high.h"

  .global do_cell, do_cellplus, do_cells, do_chars

# ALIGNMENT AND PORTABILITY OPERATORS ===========
# Many of these are synonyms for other words,
# and so are defined as CODE words

#----------------------------------------------------
#  >BODY    xt -- a-addr      adrs of param field
#   4 + ;                     
#----------------------------------------------------
.global do_tobody
do_tobody:
  DOCOLON

  LIT(4)
  PLUS

  EXIT

#----------------------------------------------------
#-- CELL     -- n                 size of one cell
#----------------------------------------------------
do_cell:
  DOCON
  DW(4)

#----------------------------------------------------
#-- CELL+    a-addr1 -- a-addr2      add cell size
#-- 4 + ;
#----------------------------------------------------
do_cellplus:
  
  #-- Obtener direccion de la pila
  POP_T0

  #-- Sumar tamaño de celda: 4
  addi t0,t0,4

  #-- Depositar direccion en la pila
  PUSH_T0

  NEXT

#----------------------------------------------------
#-- CELLS    n1 -- n2            cells->adrs units
#-- Devolver el tamaño de n1 celdas en bytes
#----------------------------------------------------
do_cells:
  j do_fourstar


#----------------------------------------------------
#-- CHARS    n1 -- n2            chars->adrs units
#-- Indicar el tamaño en bytes de los caracteres indicados
#----------------------------------------------------
do_chars:
  NEXT

last:

#----------------------------------------------------
#  !CF    cfa addr--   set code action of a word
#   0CD OVER C!         store 'CALL adrs' instr
#   1+ ! ;              Z80 VERSION
# Depending on the implementation this could
# append CALL adrs or JUMP adrs.
#----------------------------------------------------
.global do_storecf
do_storecf:
  DOCOLON
  
  #-- Guardar CFA
  STORE

  EXIT  

#----------------------------------------------------
#  ,CF    cfa --       append a code field
#   HERE !CF 4 ALLOT ;  
#----------------------------------------------------
.global do_commacf
do_commacf:
  DOCOLON

  #-- La dirección no tiene por qué estar alineada
  #-- Vamos a cualquier desalineamiento:
  #--   0: Está alineada
  #--   1-3: No alineada
  #-- En caso de desalineamiento esos bytes hay que 
  #-- sumarlos al puntero del diccionario mediante ALLOC
  HERE      #-- cfa addr
  DUP       #-- cfa addr addr
  ALIGN     #-- cfa addr a-addr
  SWOP      #-- cfa a-addr addr
  MINUS     #-- cfa mis  (numero de bytes de desalineacion 0-3)

  #-- Meterlos en el diccionario
  ALLOT     #-- cfa

  #-- Almacenar CFA en direccion alineada
  HERE
  STORECF

  #-- Incrementar diccionario en 4 bytes
  LIT(4)
  ALLOT

  EXIT

#-------------------------------------------------
#  C,   char --        append char to dict
#   HERE C! 1 CHARS ALLOT ;
#-------------------------------------------------
.global do_ccomma
do_ccomma:
  DOCOLON

  HERE
  CSTORE

  LIT(1)
  CHARS
  ALLOT

  EXIT

#-------------------------------------------------
#  !COLON   --      change code field to docolon
#   -3 ALLOT docolon-adrs ,CF ;
# This should be used immediately after CREATE.
# This is made a distinct word, because on an STC
# Forth, colon definitions have no code field.
#-------------------------------------------------
.global do_storcolon
do_storcolon:
  DOCOLON

  #------- !COLON
  #-- Almacenar la direccion HERE en HERE-4
  #-- Ahora CPA apunta a HERE, y ahí es donde se meterá
  #-- el codigo de la palabra que se está construyendo
  HERE      #-- addr
  DUP       #-- addr addr
  LIT(-4)   #-- addr addr -4
  
  PLUS      #-- addr addr-4
  STORE

  #-- Copiar el codigo de do-colon
  # 0xffc40413  addi s0,s0,-4 
  # 0x00142023  sw ra,0(s0)
  HERE
  POP_T0  #-- t0: Direccion destino
  la t1,docolon  #-- t1: Dirección fuente

  #-- Copiar primera instrucción
  lw t2, 0(t1)
  sw t2, 0(t0)

  #-- Copiar la segunda instrucción
  lw t2, 4(t1)
  sw t2, 4(t0)

  LIT(8)  #-- Generar espacio para 2 instrucciones en el diccionario
  ALLOT

  EXIT

#-------------------------------------------------
#  ,EXIT    --      append hi-level EXIT action
#   ['] EXIT ,XT ;
# This is made a distinct word, because on an STC
# Forth, it appends a RET instruction, not an xt.
#-------------------------------------------------
.global do_cexit
do_cexit:
  DOCOLON

  #-- CEXIT
  #-- Copiar el codigo de exit
  # 0x00042083  lw ra,0(s0)
  # 0x00440413  addi s0,s0,4
  # 0x00008067  ret
  
  HERE
  POP_T0  #-- t0: Direccion destino
  la t1,exit  #-- t1: Dirección fuente

  #-- Copiar primera instrucción
  lw t2, 0(t1)
  sw t2, 0(t0)

  #-- Copiar la segunda instrucción
  lw t2, 4(t1)
  sw t2, 4(t0)

  #-- Copiar la tercera instrucción
  lw t2, 8(t1)
  sw t2, 8(t0)

  LIT(12)  #-- Generar espacio para 3 instrucciones en el diccionario
  ALLOT

  EXIT


#-------------------------------------------------
#  !VAR   --      Añadir campo para variables
#-------------------------------------------------
.global do_storvar
do_storvar:
  DOCOLON

  HERE
  POP_T0  #-- t0: Direccion destino
  la t1,dovar_code  #-- t1: Dirección fuente

  #-- Copiar primera instrucción
  lw t2, 8(t1)
  sw t2, 0(t0)

  #-- Copiar la segunda instrucción
  lw t2, 0xC(t1)
  sw t2, 4(t0)

  #-- Copiar la tercera instrucción
  lw t2, 0x10(t1)
  sw t2, 8(t0)

  LIT(12)  #-- Generar espacio para 3 instrucciones en el diccionario
  ALLOT

  EXIT

#-------------------------------------------------
#  !CON  x --      Añadir campo para constantes
#-------------------------------------------------
.global do_storcon
do_storcon:
  DOCOLON

  HERE
  POP_T0  #-- t0: Direccion destino
  la t1,docon_code  #-- t1: Dirección fuente

  #-- Copiar primera instrucción
  lw t2, 8(t1)
  sw t2, 0(t0)

  #-- Copiar la segunda instrucción
  lw t2, 0xC(t1)
  sw t2, 4(t0)

  #-- Copiar la tercera instrucción
  lw t2, 0x10(t1)
  sw t2, 8(t0)

  LIT(12)  #-- Generar espacio para 3 instrucciones en el diccionario
  ALLOT

  #-- Almacenar la constante
  HERE
  STORE

  LIT(4)
  ALLOT

  EXIT

#----------------------------------------------------------------------
#  ,JAL  x --      Añadir codigo maquina para saltar a la direccion x
#----------------------------------------------------------------------
#--- Añadir las instrucciones de salto
#-- (1) 0x00402337 lui t1, 0x00402
#-- (2) 0x0001c2b7 lui t0, 0x01C
#-- (3) 0x00c2d293 srli t0,t0, 12
#-- (4) 0x005362b3 or t0,t1,t0
#-- (5) 0x000280e7 jalr ra,0(s0)
.global do_cjal
do_cjal:
  DOCOLON

  #-- t4: Direccion destino
  HERE
  POP_T0
  mv t4, t0

  #-- t0: Direccion a la que hay que saltar
  POP_T0

  #-- Meter en t1 la parte alta de la direccion
  li t1, -1      #-- 0xFFFFF_FFF
  slli t1,t1,12  #-- 0xFFFFF_000
  and t1, t1, t0 #-- t1 = %hi(do_line)

  #-- Dejar en t0 la parte baja
  slli t0,t0,20 #-- Dejar lo 12 bits de la direccion en la parte alta
  srli t0,t0,20 #-- Llevarlas a la baja (y los altos quedan a cero)
                #-- t0 = %lo(do_line)

  #--- Generar las instrucciones 1 y 2
  #--- Partimos de tener en t1 y t0 las direcciones
  #--- alta (20-bits) y baja (12-bits) de la subrutina a llamar

  #-- t2 --> Primera instruccion
  ori t2, t1, 0x337  #-- Poner opcode de lui t1 en los 12-bits bajos

  #-- Copiarla a destino
  sw t2, 0(t4)

  #-- t2: Segunda instruccion
  slli t2,t0,12
  ori t2, t2, 0x2B7  #-- 2B7 opcode de lui t0
  
  #-- Copiarla a destino
  sw t2, 4(t4)

  #-- Copiar resto de instrucciones (Son fijas)
  #-- Direccion origen: t3
  la t3, cjal_code

  lw t2, 0(t3)  #-- Copiar tercera instruccion
  sw t2, 8(t4)

  lw t2, 4(t3)  #-- Copiar cuarta instrucción
  sw t2, 0xC(t4)

  lw t2, 8(t3)  #-- Copiar quinta instruccion
  sw t2, 0x10(t4)

  LIT(20) #-- 5 Instrucciones  (5 * 4 bytes)
  ALLOT

  EXIT
