\ Probar VERSION
VERSION .S DROP .S

\ Probar R0
R0 .S DROP .S

\ Probar DOCOL
DOCOL .S DROP .S 

\ Probar F_IMMED
F_IMMED .S DROP .S

\ Probar F_HIDDEN
F_HIDDEN .S DROP .S

\ Probar F_LENMASK
F_LENMASK .S DROP .S

\ Probar >R
1973 .S >R .S

\ Probar R>
R> .S DROP .S

\ Probar RSP@
RSP@ .S DROP .S

\ Probar DSP@
DSP@ .S DROP .S

\ Probar KEY
KEY A .S DROP .S

\ Probar WORD
WORD HOLA .S DROP DROP .S

\ Probar FIND
WORD DROP FIND .S DROP .S  \ Buscar la palabra "DROP"
WORD hhh  FIND .S DROP .S  \ Buscar la palabra "hhh" (que no existe)

\ Probar >CFA
WORD DROP FIND >CFA .S DROP .S  \-- Direccion al codeword de DROP

\ Probar >DFA
WORD DROP FIND >DFA .S DROP .S  

\ Probar CREATE
WORD hhh CREATE .S

\ Probar INMEDIATE
INMEDIATE .S

\ Probar HIDE
HIDE SWAP .S   \-- Oculatar palabra SWAP

\ Probar ' 
: TEST ' DROP ; TEST .S DROP .S  

