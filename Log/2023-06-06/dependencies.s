#---------------------------------------------------------
#-- CPU and Model Dependencies
#---------------------------------------------------------

	.include "macroCPU.h"
  .include "primitives.h"

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
#  !CF    adrs cfa --   set code action of a word
#   0CD OVER C!         store 'CALL adrs' instr
#   1+ ! ;              Z80 VERSION
# Depending on the implementation this could
# append CALL adrs or JUMP adrs.
#----------------------------------------------------
.global do_storecf
do_storecf:
  DOCOLON
  
  #-- Guardar CFA
  SWOP
  STORE

  EXIT  
