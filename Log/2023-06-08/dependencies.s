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