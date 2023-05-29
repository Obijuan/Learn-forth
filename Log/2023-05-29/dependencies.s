#---------------------------------------------------------
#-- CPU and Model Dependencies
#---------------------------------------------------------

	.include "macros.h"

  .global do_cell, do_cellplus, do_cells, do_charplus

# ALIGNMENT AND PORTABILITY OPERATORS ===========
# Many of these are synonyms for other words,
# and so are defined as CODE words

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
#-- CHAR+    c-addr1 -- c-addr2   add char size
#-- Añadir el tamaño del tipo char a la direccion
#----------------------------------------------------
do_charplus:
  j do_oneplus