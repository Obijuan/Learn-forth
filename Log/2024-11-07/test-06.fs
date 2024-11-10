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

\ Probar mas caracteres constantes
'A' 'A' '0' '0' EMIT EMIT EMIT EMIT .S

\ Probando COMPILE
: TEST 'A' [COMPILE] EMIT ; TEST .S

\ Probando IF
: TEST_IF IF 65 EMIT THEN 66 EMIT CR ;
1 TEST_IF .S
0 TEST_IF .S 


\ Probando IF-ELSE
: TEST_IF2 IF 65 EMIT ELSE 66 EMIT THEN CR ;  
1 TEST_IF2 .S
0 TEST_IF2 .S 

\ Probando BEGIN-UNTIL
: TEST_LOOP1 BEGIN 65 EMIT 1 - DUP 0= UNTIL CR ;
5 TEST_LOOP1
10 TEST_LOOP1
30 TEST_LOOP1