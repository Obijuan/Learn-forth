#!/bin/sh
#-- Assemble and run the given program
#-- Example:
#--   ./run.sh 01-suma_1_1.s

#----- Parameters:
#-- nc : No copyright (no message printed)
#-- mc CompactTextAtZero  : Compact memory map (not the standar)
#-- smc: Self Modifying 
#-- dump --> Volcar el segmento de codigo al fichero binario firmware.bin
#java -jar rars1_6.jar nc smc mc CompactTextAtZero dump .text Binary firmware.bin  $1 primitives.s higher_level.s test.s dependencies.s
java -jar rars1_6.jar nc smc dump .text Binary firmware.bin  $1 primitives.s dependencies.s high.s test.s 
