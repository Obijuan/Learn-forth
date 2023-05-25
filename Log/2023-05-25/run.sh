#!/bin/sh
#-- Assemble and run the given program
#-- Example:
#--   ./run.sh 01-suma_1_1.s

#----- Parameters:
#-- nc : No copyright (no message printed)
#-- mc CompactTextAtZero  : Compact memory map (not the standar)
java -jar rars1_6.jar nc mc CompactTextAtZero  $1 primitives.s higher_level.s
