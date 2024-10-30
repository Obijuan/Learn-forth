#!/bin/sh
#-- Assemble and run the given program
#-- Example:
#--   ./run.sh 01-main.s

#----- Parameters:
#-- nc : No copyright (no message printed)
#-- sm : Start execution at statement with global label main
java -jar rars1_6.jar nc sm $1 
