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

\ Mas caracteres CONSTANTES definidos igual que arriba
: ';' [ CHAR ; ] LITERAL ;
: '(' [ CHAR ( ] LITERAL ;
: ')' [ CHAR ) ] LITERAL ;
: '"' [ CHAR " ] LITERAL ;
: 'A' [ CHAR A ] LITERAL ;
: '0' [ CHAR 0 ] LITERAL ;
: '-' [ CHAR - ] LITERAL ;
: '.' [ CHAR . ] LITERAL ;

\ Compilar la palabra que viene a continuacion
\ [COMPILE] word --> Compila la palabra word
: [COMPILE] IMMEDIATE
	WORD		\ Obtener la siguiente palabra
	FIND		\ Encontrarla en el diccionario
	>CFA		\ Obtener su codeword
	,		    \ y compilarlo
;

\ RECURSE hace una llamada recursiva a la palabra que esta siendo
\ compilada
: RECURSE IMMEDIATE
	LATEST @	\ LATEST points to the word being compiled at the moment
	>CFA		\ get the codeword
	,		\ compile it
;

\ ===========================================================================
\ ==     ESTRUCTURAS DE CONTROL
\ ===========================================================================

\----------------
\---- IF
\----------------
\-- Sintaxis:  Condicion IF parte-verdadera THEN resto;
\-- COMPILA A: --> condicion 0BRANCH OFFSET parte-verdadera resto
\--    OFFSET es el desplazamiento hacia `resto

\-- Sintaxis:  Condicion IF parte-verdadera ELSE parte-falsa THEN resto;
\-- COMPILA A: --> 
\--   condicion 0BRANCH OFFSET parte-verdad BRANCH OFFSET2 parte-falsa resto;
\--	  donde OFFSET es el offset de la parte falsa y OFFSET2 es el offset del resto

\ IF es una palabra IMMEDIATE que compila a 0BRANCH seguida de un offset dummy, 
\ y coloca la dirección de 0BRANCH en la pila. Despues, cuando vemos THEN, sacamos
\ la direccion de la pila, calcula el offset y lo escribe (sustituyendo a dummy)
: IF IMMEDIATE
	' 0BRANCH ,	\-- Compilar 0BRANCH
	HERE @		\-- Guardar la direccion de la posicion del offset en la pila
	0 ,		    \-- Compilar un offset dummy
;

: THEN IMMEDIATE
	DUP
	HERE @ SWAP -	\-- Calcular el offset a partir de la direccion guardada 
                    \-- en la pila
	SWAP !		    \-- Guardar el offset
;


: ELSE IMMEDIATE
	' BRANCH ,	\ definite branch to just over the false-part
	HERE @		\ save location of the offset on the stack
	0 ,		\ compile a dummy offset
	SWAP		\ now back-fill the original (IF) offset
	DUP		\ same as for THEN word above
	HERE @ SWAP -
	SWAP !
;

\-----------------------
\-- BEGIN ... UNTIL
\-----------------------

\ BEGIN loop-part condition UNTIL
\	-- compiles to: --> loop-part condition 0BRANCH OFFSET
: BEGIN IMMEDIATE
	HERE @		\-- Guardar la direccion en la pila (para luego saltar a ella)
;

: UNTIL IMMEDIATE
	' 0BRANCH ,	\-- Compilar 0BRANCH
	HERE @ -	\-- Calcular el offset a partir de la direccion en la pila
	,		    \-- Compilar el offset
;

\ BEGIN loop-part AGAIN
\	-- compiles to: --> loop-part BRANCH OFFSET
\	where OFFSET points back to the loop-part
\ Es un bucle infinito. Solo se retorna llamando a EXIT
: AGAIN IMMEDIATE
	' BRANCH ,	\ Compilar BRANCH
	HERE @ -	\ Calcular el offset para volver (loop)
	,		\ Compilar el offset
;

\ Probando BEGIN-AGAIN
\ BUCLE INFINITO!!! Se deja comentado
\ : INF BEGIN 65 EMIT AGAIN ;
\ INF

\ BEGIN condition WHILE loop-part REPEAT
\	-- compiles to: --> condition 0BRANCH OFFSET2 loop-part BRANCH OFFSET
\	where OFFSET points back to condition (the beginning) and OFFSET2 points to after the whole piece of code
\ So this is like a while (condition) { loop-part } loop in the C language
: WHILE IMMEDIATE
	' 0BRANCH ,	\ compile 0BRANCH
	HERE @		\ save location of the offset2 on the stack
	0 ,		\ compile a dummy offset2
;

: REPEAT IMMEDIATE
	' BRANCH ,	\ compile BRANCH
	SWAP		\ get the original offset (from BEGIN)
	HERE @ - ,	\ and compile it after BRANCH
	DUP
	HERE @ SWAP -	\ calculate the offset2
	SWAP !		\ and back-fill it in the original location
;

\ UNLESS. Es el contrario de IF
: UNLESS IMMEDIATE
	' NOT ,		\ compile NOT (to reverse the test)
	[COMPILE] IF	\ continue by calling the normal IF
;
