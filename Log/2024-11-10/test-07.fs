\----- Se prueban las palabras definidas
\----- en jonesforth.fs

CR
." ------------ VERSION " VERSION . ." ------------------------------ " CR
CR

\-- Prueba del comando WORDS
." * WORDS " CR
WORDS CR

\-- Prueba del comando DUMP
." * DUMP " CR
LATEST @ 128 DUMP CR

\-- Probando CASE
." * CASE" CR
: TEST-CASE
CASE
  0 OF ." Valor 0" ENDOF
  1 OF ." Valor 1" ENDOF
  ." Caso por defecto: " DUP .
ENDCASE
;
0 TEST-CASE CR
1 TEST-CASE CR
5 TEST-CASE CR

\-- TESTING SEE 
CR ." ------- Testing SEE " CR
: TEN 10 ;
SEE TEN
: SUMA11 1 1 + ;
SEE SUMA11

\-- TESTING EXECUTE
CR ." ------- Testing EXECUTE " CR
: DOUBLE DUP + ;
: SLOW WORD FIND >CFA EXECUTE ;
5 SLOW DOUBLE . CR   \-- Prints 10
