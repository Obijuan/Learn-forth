\ Probar operando AND
240 31 .S AND .S DROP .S

\ Probar operando OR
240 15 .S OR .S DROP .S

\ Probar operando XOR
170 255 .S XOR .S DROP .S

\ Probar operando INVERT
170 .S INVERT .S DROP .S

\ Probar !
255 268697600 .S ! .S   \ mem[268697600] = 255 (0x10040000)  

\ Probar @
268697600 @ .S DROP .S  \ Leer mem[268697600]

\ Probar +!
5 268697600 +! 268697600 @ .S DROP .S 

\ Probar -!
10 268697600 -! 268697600 @ .S DROP .S 

\ Probar C!
55 268697600 .S C! .S  \Leer mem[268697600]  

\ Probar C@
268697600 .S C@ .S DROP .S  \ Leer mem[268697600]

\Probar C@C!
\-- TODO

\Proba CMOVE
\-- TODO

\ Probar STATE
STATE .S @ .S DROP .S  \-- Leer variable STATE
\-- Nota: No se escribe para no cambiar al estado "Compilar"

\ Probar LATEST
LATEST .S @ .S DROP .S \-- Leer variable LATEST

\ Probar HERE
HERE .S @ .S DROP .S    \-- Leer variable HERE

\ Probar S0
S0 .S @ .S DROP .S

\ Probar BASE
BASE .S @ .S DROP .S  \-- Leer variable BASE
