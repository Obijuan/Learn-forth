#!/bin/sh
#-- Assemble and run the given program
#-- Example:
#--   ./run.sh 01-main.s

#-- Hacer que el terminal sea no bloqueante
stty -icanon min 1 #-echo

#----- Parameters:
#-- nc : No copyright (no message printed)
#-- sm : Start execution at statement with global label main
#-- me : Display RARs messages to standar error
java -jar rars1_6.jar nc sm me $1 

#-- Restaurar los parametros del terminal
stty icanon echo
