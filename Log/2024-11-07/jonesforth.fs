\ Division /
\ (a b -- a/b ) 
: / /MOD SWAP DROP ;

\ Palabra MOD
\ (a b -- a mod b)
: MOD /MOD DROP ;

\ Definir alcunas CONSTANTES de caracteres
: '\n' 10 ;
: BL   32 ; \ BL (BLank) es la palabra FORTH standard para el espacio

\ CR Imprimir un salto de linea
: CR '\n' EMIT ;

\ SPACE Imprimir un espacio  
: SPACE BL EMIT ;

\ NEGATE Cambiar el signo de un entero
: NEGATE 0 SWAP - ;

\ Palabras estandar para BOOLEANOS
: TRUE  1 ;
: FALSE 0 ;
: NOT   0= ;  \-- Operacion NOT con lo que hay en la pila

