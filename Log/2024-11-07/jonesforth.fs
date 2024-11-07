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

\ LITERAL  Leer valor de la pila y compilar LIT <valor>
\ Solo se usa en modo compilacion
: LITERAL IMMEDIATE
	' LIT ,		\ compilar LIT
	,		    \ compilar el propio valor (desde la pila)
;

\ Ahora ya podemos usar [ y ] para insertar literales calculadas en tiempo
\ de compilacion. Dentro de las definiciones se usa [ ... ] LITERAL donde '...'  
\ es una expresion constante que solo queremos calcular una unica vez: 
\ durante la compilacion (en vez de cada vez que se ejecuta la palabra)
\ En este ejemplo se genera el caracter ':'
: ':'
	[		\ Entrar en modo inmediato (temporalmente)
	CHAR :	\ Meter el numero 58 en la pila (ASCII del caracter :)  
	]		\ Volver al modo compilacion
	LITERAL	\ Compilar LIT 58 como definicion de la palabra ':' word
;

