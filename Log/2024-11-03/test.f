\\-- Probando DOTS
1 2 3 .S

\\-- Probando DROP
DROP DROP DROP .S

\\-- Probando  SWAP
5 6 .S SWAP .S DROP DROP .S

\\-- Prueba de DUP
5 .S DUP .S DROP DROP .S

\\-- Prueba de OVER
1 2 3 .S OVER .S DROP DROP DROP DROP .S 

\\-- Prueba de ROT
10 20 1 2 3 .S ROT .S DROP DROP DROP DROP DROP .S

\\-- Prueba de -ROT
10 20 1 2 3 .S -ROT .S DROP DROP DROP DROP DROP .S

\\-- Prueba de 2DROP
10 1 2 .S 2DROP .S DROP .S

\\-- Prueba de 2DUP
10 1 2 .S 2DUP .S DROP DROP DROP DROP DROP .S

\\-- Prueba de 2WAP
10 1 2 3 4 .S 2SWAP .S DROP DROP DROP DROP DROP .S

\\-- Prueba de ?DUP
10 2 .S ?DUP .S DROP DROP DROP .S  \\-- Hay duplicacion
10 0 .S ?DUP .S DROP DROP .S       \\-- No hay duplicacion

\\-- Prueba de 1+
5 .S 1+ .S DROP .S

\\-- Prueba de 1-
5 .S 1- .S DROP .S

\\-- Prueba de 4+
10 .S 4+ .S DROP .S

\\-- Prueba de 4-
12 .S 4- .S DROP .S

\\-- Prueba de 8+
8 .S 8+ .S DROP .S
