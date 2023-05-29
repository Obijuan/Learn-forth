#---------------------------------------------------------
#-- CPU and Model Dependencies
#---------------------------------------------------------

	.include "macros.h"

  .global do_cell, do_cellplus

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
