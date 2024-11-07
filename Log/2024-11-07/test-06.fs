\----- Se prueban las palabras definidas
\----- en jonesforth.fs

\ Probar la division /
10 5 .S / .S DROP .S 

\ Probar el modulo MOD
10 3 .S MOD .S DROP .S 

\ Probar CR y SPACE
CR CR CR SPACE SPACE SPACE .S

\ Probar NEGATE
73 .S NEGATE .S DROP .S  

\ Probar TRUE y FALSE
TRUE FALSE .S DROP DROP .S 

\ Probar ':'
':' EMIT .S 




