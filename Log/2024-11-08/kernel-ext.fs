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


\-----------------------
\-- BEGIN ... AGAIN
\-----------------------
\ BEGIN loop-part AGAIN
\	-- compiles to: --> loop-part BRANCH OFFSET
\	where OFFSET points back to the loop-part
\ Es un bucle infinito. Solo se retorna llamando a EXIT
: AGAIN IMMEDIATE
	' BRANCH ,	\ Compilar BRANCH
	HERE @ -	\ Calcular el offset para volver (loop)
	,		\ Compilar el offset
;


\-------------------------------
\-- BEGIN ... WHILE ... REPEAT
\-------------------------------
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

\-------------------------------
\-- UNLESS
\-------------------------------
\ UNLESS. Es el contrario de IF
: UNLESS IMMEDIATE
	' NOT ,		\ compile NOT (to reverse the test)
	[COMPILE] IF	\ continue by calling the normal IF
;

\ ===========================================================================
\ ==     COMENTARIOS
\ ===========================================================================
\ En el estandar FORTH se definen las palabras ( ... ) que permiten poner
\ comentarios dentro de las funciones. Lo interesante es que...
\ ¡Se definen en Forth!

: ( IMMEDIATE
	1		\ Profundidad. Esto permite anidar los parentesis
	BEGIN
		KEY		\ Leer siguiente caracter
		DUP '(' = IF	\ Abrir parentesis?
			DROP		\ Eliminar el caracter
			1+		\ Incrementar la profundidad
		ELSE
			')' = IF	\ Cerrar parentesis?
				1-		\ Decrementar la profundidad
			THEN
		THEN
	DUP 0= UNTIL		\ Continuar hasta que se alcanza el equilibro: depth 0
	DROP		\ Deshacerse del contador de profundidad
;

(
	A partir de ahora ya podemos usar ( ... ) para comentar!!!
	Lo hemos añadido al FORTH! Impresionante...
)

 
\==========================================================================
\         NOTACION DE PILA
\============================================================================ 

(
	En Forth se utiliza la notacion ( ... -- ... ) para mostrar el efecto que 
	tiene una palabra en los parametros de la pila. Ejemplos:
	
	( n -- )     La palabra consume un entero (n) de la pila de parametros
	( b a -- c)  La palabra usa dos enteros (a y b) y retorna un caracter (c)
	( -- )       La palabra no afecta a la pila de parametros
)

( Some more complicated stack examples, showing the stack notation. )
: NIP ( x y -- y ) SWAP DROP ;
: TUCK ( x y -- y x y ) SWAP OVER ;
: PICK ( x_u ... x_1 x_0 u -- x_u ... x_1 x_0 x_u )
	1+		( add one because of 'u' on the stack )
	8 *		( multiply by the word size )
	DSP@ +		( add to the stack pointer )
	@    		( and fetch )
;

\-- Escribir n espacio en la salida
: SPACES	( n -- )
	BEGIN
		DUP 0>		( while n > 0 )
	WHILE
		SPACE		( print a space )
		1-		( until we count down to 0 )
	REPEAT
	DROP
;

( Standard words for manipulating BASE. )
: DECIMAL ( -- ) 10 BASE ! ;
: HEX ( -- ) 16 BASE ! ;

\ =========================================================================
\ ==    IMPRIMIENDO NUMEROS
\ =========================================================================

\-- Imprimir un numero sin signo
: U.		( u -- )
	BASE @ /MOD	( width rem quot )
	?DUP IF			( if quotient <> 0 then )
		RECURSE		( print the quotient )
	THEN

	( print the remainder )
	DUP 10 < IF
		'0'		( decimal digits 0..9 )
	ELSE
		10 -		( hex and beyond digits A..Z )
		'A'
	THEN
	+
	EMIT
;

	FORTH word .S prints the contents of the stack.  It doesn't alter the stack.
	Very useful for debugging.

: .S		( -- )
	DSP@		( get current stack pointer )
	BEGIN
		DUP S0 @ <
	WHILE
		DUP @ U.	( print the stack element )
		SPACE
		4+		( move up )
	REPEAT
	DROP
;


( This word returns the width (in characters) of an unsigned number in the current base )
: UWIDTH	( u -- width )
	BASE @ /	( rem quot )
	?DUP IF		( if quotient <> 0 then )
		RECURSE 1+	( return 1+recursive call )
	ELSE
		1		( return 1 )
	THEN
;

: U.R		( u width -- )
	SWAP		( width u )
	DUP		( width u u )
	UWIDTH		( width u uwidth )
	ROT		( u uwidth width )
	SWAP -		( u width-uwidth )
	( At this point if the requested width is narrower, we'll have a negative number on the stack.
	  Otherwise the number on the stack is the number of spaces to print.  But SPACES won't print
	  a negative number of spaces anyway, so it's now safe to call SPACES ... )
	SPACES
	( ... and then call the underlying implementation of U. )
	U.
;

(
	.R prints a signed number, padded to a certain width.  We can't just print the sign
	and call U.R because we want the sign to be next to the number ('-123' instead of '-  123').
)
: .R		( n width -- )
	SWAP		( width n )
	DUP 0< IF
		NEGATE		( width u )
		1		( save a flag to remember that it was negative | width n 1 )
		SWAP		( width 1 u )
		ROT		( 1 u width )
		1-		( 1 u width-1 )
	ELSE
		0		( width u 0 )
		SWAP		( width 0 u )
		ROT		( 0 u width )
	THEN
	SWAP		( flag width u )
	DUP		( flag width u u )
	UWIDTH		( flag width u uwidth )
	ROT		( flag u uwidth width )
	SWAP -		( flag u width-uwidth )

	SPACES		( flag u )
	SWAP		( u flag )

	IF			( was it negative? print the - character )
		'-' EMIT
	THEN

	U.
;


( Finally we can define word . in terms of .R, with a trailing space. )
: . 0 .R SPACE ;

( The real U., note the trailing space. )
: U. U. SPACE ;

( ? fetches the integer at an address and prints it. )
: ? ( addr -- ) @ . ;

( c a b WITHIN returns true if a <= c and c < b )
(  or define without ifs: OVER - >R - R>  U<  )
: WITHIN
	-ROT		( b c a )
	OVER		( b c a c )
	<= IF
		> IF		( b c -- )
			TRUE
		ELSE
			FALSE
		THEN
	ELSE
		2DROP		( b c -- )
		FALSE
	THEN
;


( DEPTH returns the depth of the stack. )
: DEPTH		( -- n )
	S0 @ DSP@ -
	4-			( adjust because S0 was on the stack when we pushed DSP )
;


(
	ALIGNED takes an address and rounds it up (aligns it) to the next 8 byte boundary.
)
: ALIGNED	( addr -- addr )
	3 + 3 INVERT AND	( (addr+3) & ~3 )
;

(
	ALIGN aligns the HERE pointer, so the next word appended will be aligned properly.
)
: ALIGN HERE @ ALIGNED HERE ! ;


( C, appends a byte to the current compiled word. )
: C,
	HERE @ C!	( store the character in the compiled image )
	1 HERE +!	( increment HERE pointer by 1 byte )
;

: S" IMMEDIATE		( -- addr len )
	STATE @ IF	( compiling? )
		' LITSTRING ,	( compile LITSTRING )
		HERE @		( save the address of the length word on the stack )
		0 ,		( dummy length - we don't know what it is yet )
		BEGIN
			KEY 		( get next character of the string )
			DUP '"' <>
		WHILE
			C,		( copy character )
		REPEAT
		DROP		( drop the double quote character at the end )
		DUP		( get the saved address of the length word )
		HERE @ SWAP -	( calculate the length )
		8-		( subtract 8 (because we measured from the start of the length word) )
		SWAP !		( and back-fill the length location )
		ALIGN		( round up to next multiple of 8 bytes for the remaining code )
	ELSE		( immediate mode )
		HERE @		( get the start address of the temporary space )
		BEGIN
			KEY
			DUP '"' <>
		WHILE
			OVER C!		( save next character )
			1+		( increment address )
		REPEAT
		DROP		( drop the final " character )
		HERE @ -	( calculate the length )
		HERE @		( push the start address )
		SWAP 		( addr len )
	THEN
;


