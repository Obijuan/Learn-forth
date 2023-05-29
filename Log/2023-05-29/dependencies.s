#---------------------------------------------------------
#-- CPU and Model Dependencies
#---------------------------------------------------------

	.include "macros.h"

  .global do_cell

# ALIGNMENT AND PORTABILITY OPERATORS ===========
# Many of these are synonyms for other words,
# and so are defined as CODE words

#----------------------------------------------------
#-- CELL     -- n                 size of one cell
#----------------------------------------------------
do_cell:
  DOCON
  DW(4)


