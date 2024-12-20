\-- Extension del nucleo

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
	4 *		( multiply by the word size )
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

(
	FORTH word .S prints the contents of the stack.  It doesn't alter the stack.
	Very useful for debugging.

)

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

\ =========================================================================
\=                  STRINGS  
\==========================================================================
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
		4-		( subtract 8 (because we measured from the start of the length word) )
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


(
	." is the print string operator in FORTH.  Example: ." Something to print"
	The space after the operator is the ordinary space required between words and is not
	a part of what is printed.

	In immediate mode we just keep reading characters and printing them until we get to
	the next double quote.

	In compile mode we use S" to store the string, then add TELL afterwards:
		LITSTRING <string length> <string rounded up to 8 bytes> TELL

	It may be interesting to note the use of [COMPILE] to turn the call to the immediate
	word S" into compilation of that word.  It compiles it into the definition of .",
	not into the definition of the word being compiled when this is running (complicated
	enough for you?)
)
: ." IMMEDIATE		( -- )
	STATE @ IF	( compiling? )
		[COMPILE] S"	( read the string, and compile LITSTRING, etc. )
		' TELL ,	( compile the final TELL )
	ELSE
		( In immediate mode, just read characters and print them until we get
		  to the ending double quote. )
		BEGIN
			KEY
			DUP '"' = IF
				DROP	( drop the double quote character )
				EXIT	( return from this function )
			THEN
			EMIT
		AGAIN
	THEN
;

\ ===========================================================================
\ =     CONSTANTES Y VARIABLES
\ ===========================================================================

: CONSTANT
	WORD		( get the name (the name follows CONSTANT) )
	CREATE		( make the dictionary entry )
	DOCOL ,		( append DOCOL (the codeword field of this word) )
	' LIT ,		( append the codeword LIT )
	,		( append the value on the top of the stack )
	' EXIT ,	( append the codeword EXIT )
;

\ CUIDADO! Si n NO es multiplo de 4, HERE queda en direccion desalineada y 
\ al compilar la siguiente palabra se produce un error
: ALLOT		( n -- addr )
	HERE @ SWAP	( here n )
	HERE +!		( adds n to HERE, after this the old value of HERE is still on the stack )
;

(
	Second, CELLS.  In FORTH the phrase 'n CELLS ALLOT' means allocate n integers of whatever size
	is the natural size for integers on this machine architecture.  On this 32 bit machine therefore
	CELLS just multiplies the top of stack by 4.
)
: CELLS ( n -- n ) 4 * ;

(
	So now we can define VARIABLE easily in much the same way as CONSTANT above.  Refer to the
	diagram above to see what the word that this creates will look like.
)
: VARIABLE
	1 CELLS ALLOT	( allocate 1 cell of memory, push the pointer to this memory )
	WORD CREATE	( make the dictionary entry (the name follows VARIABLE) )
	DOCOL ,		( append DOCOL (the codeword field of this word) )
	' LIT ,		( append the codeword LIT )
	,		( append the pointer to the new memory )
	' EXIT ,	( append the codeword EXIT )
;

\ ===========================================================================
\ =     VALORES
\ ===========================================================================
(
    VALUEs are like VARIABLEs but with a simpler syntax.  You would generally use them when you
	want a variable which is read often, and written infrequently.

	20 VALUE VAL 	creates VAL with initial value 20
	VAL		pushes the value (20) directly on the stack
	30 TO VAL	updates VAL, setting it to 30
	VAL		pushes the value (30) directly on the stack

	Notice that 'VAL' on its own doesn't return the address of the value, but the value itself,
	making values simpler and more obvious to use than variables (no indirection through '@').
	The price is a more complicated implementation, although despite the complexity there is no
	performance penalty at runtime.

	A naive implementation of 'TO' would be quite slow, involving a dictionary search each time.
	But because this is FORTH we have complete control of the compiler so we can compile TO more
	efficiently, turning:
		TO VAL
	into:
		LIT <addr> !
	and calculating <addr> (the address of the value) at compile time.

	Now this is the clever bit.  We'll compile our value like this:

	+---------+---+---+---+---+------------+------------+------------+------------+
	| LINK    | 3 | V | A | L | DOCOL      | LIT        | <value>    | EXIT       |
	+---------+---+---+---+---+------------+------------+------------+------------+
                   len              codeword

	where <value> is the actual value itself.  Note that when VAL executes, it will push the
	value on the stack, which is what we want.

	But what will TO use for the address <addr>?  Why of course a pointer to that <value>:

		code compiled	- - - - --+------------+------------+------------+-- - - - -
		by TO VAL		  | LIT        | <addr>     | !          |
				- - - - --+------------+-----|------+------------+-- - - - -
							     |
							     V
	+---------+---+---+---+---+------------+------------+------------+------------+
	| LINK    | 3 | V | A | L | DOCOL      | LIT        | <value>    | EXIT       |
	+---------+---+---+---+---+------------+------------+------------+------------+
                   len              codeword

	In other words, this is a kind of self-modifying code.

	(Note to the people who want to modify this FORTH to add inlining: values defined this
	way cannot be inlined).
)
: VALUE		( n -- )
	WORD CREATE	( make the dictionary entry (the name follows VALUE) )
	DOCOL ,		( append DOCOL )
	' LIT ,		( append the codeword LIT )
	,		( append the initial value )
	' EXIT ,	( append the codeword EXIT )
;

: TO IMMEDIATE	( n -- )
	WORD		( get the name of the value )
	FIND		( look it up in the dictionary )
	>DFA		( get a pointer to the first data field (the 'LIT') )
	4+		( increment to point at the value )
	STATE @ IF	( compiling? )
		' LIT ,		( compile LIT )
		,		( compile the address of the value )
		' ! ,		( compile ! )
	ELSE		( immediate mode )
		!		( update it straightaway )
	THEN
;

( x +TO VAL adds x to VAL )
: +TO IMMEDIATE
	WORD		( get the name of the value )
	FIND		( look it up in the dictionary )
	>DFA		( get a pointer to the first data field (the 'LIT') )
	4+		( increment to point at the value )
	STATE @ IF	( compiling? )
		' LIT ,		( compile LIT )
		,		( compile the address of the value )
		' +! ,		( compile +! )
	ELSE		( immediate mode )
		+!		( update it straightaway )
	THEN
;

\ ===========================================================================
\ ==   IMPRIMIR EL DIRECTORIO
\ ===========================================================================
(
	ID. takes an address of a dictionary entry and prints the word's name.

	For example: LATEST @ ID. would print the name of the last word that was defined.
)

: ID.
	4+		( skip over the link pointer )
	DUP C@		( get the flags/length byte )
	F_LENMASK AND	( mask out the flags - just want the length )

	BEGIN
		DUP 0>		( length > 0? )
	WHILE
		SWAP 1+		( addr len -- len addr+1 )
		DUP C@		( len addr -- len addr char | get the next character)
		EMIT		( len addr char -- len addr | and print it)
		SWAP 1-		( len addr -- addr len-1    | subtract one from length )
	REPEAT
	2DROP		( len addr -- )
;

(
	'WORD word FIND ?HIDDEN' returns true if 'word' is flagged as hidden.

	'WORD word FIND ?IMMEDIATE' returns true if 'word' is flagged as immediate.
)
: ?HIDDEN
	4+		( skip over the link pointer )
	C@		( get the flags/length byte )
	F_HIDDEN AND	( mask the F_HIDDEN flag and return it (as a truth value) )
;

: ?IMMEDIATE
	4+		( skip over the link pointer )
	C@		( get the flags/length byte )
	F_IMMED AND	( mask the F_IMMED flag and return it (as a truth value) )
;

(
	WORDS prints all the words defined in the dictionary, starting with the word defined most recently.
	However it doesn't print hidden words.

	The implementation simply iterates backwards from LATEST using the link pointers.
)
: WORDS
	LATEST @	( start at LATEST dictionary entry )
	BEGIN
		?DUP		( while link pointer is not null )
	WHILE
		DUP ?HIDDEN NOT IF	( ignore hidden words )
			DUP ID.		( but if not hidden, print the word )
			SPACE
		THEN
		@		( dereference the link pointer - go to previous word )
	REPEAT
	CR
;

(
	FORGET ----------------------------------------------------------------------

	So far we have only allocated words and memory.  FORTH provides a rather primitive method
	to deallocate.

	'FORGET word' deletes the definition of 'word' from the dictionary and everything defined
	after it, including any variables and other memory allocated after.

	The implementation is very simple - we look up the word (which returns the dictionary entry
	address).  Then we set HERE to point to that address, so in effect all future allocations
	and definitions will overwrite memory starting at the word.  We also need to set LATEST to
	point to the previous word.

	Note that you cannot FORGET built-in words (well, you can try but it will probably cause
	a segfault).

	XXX: Because we wrote VARIABLE to store the variable in memory allocated before the word,
	in the current implementation VARIABLE FOO FORGET FOO will leak 1 cell of memory.
)
: FORGET
	WORD FIND	( find the word, gets the dictionary entry address )
	DUP @ LATEST !	( set LATEST to point to the previous word )
	HERE !		( and store HERE with the dictionary address )
;

(
	DUMP ----------------------------------------------------------------------

	DUMP is used to dump out the contents of memory, in the 'traditional' hexdump format.

	Notice that the parameters to DUMP (address, length) are compatible with string words
	such as WORD and S".

	You can dump out the raw code for the last word you defined by doing something like:

		LATEST @ 128 DUMP
)
: DUMP		( addr len -- )
	BASE @ -ROT		( save the current BASE at the bottom of the stack )
	HEX			( and switch to hexadecimal mode )

	BEGIN
		?DUP		( while len > 0 )
	WHILE
		OVER 8 U.R	( print the address )
		SPACE

		( print up to 16 words on this line )
		2DUP		( addr len addr len )
		1- 15 AND 1+	( addr len addr linelen )
		BEGIN
			?DUP		( while linelen > 0 )
		WHILE
			SWAP		( addr len linelen addr )
			DUP C@		( addr len linelen addr byte )
			2 .R SPACE	( print the byte )
			1+ SWAP 1-	( addr len linelen addr -- addr len addr+1 linelen-1 )
		REPEAT
		DROP		( addr len )

		( print the ASCII equivalents )
		2DUP 1- 15 AND 1+ ( addr len addr linelen )
		BEGIN
			?DUP		( while linelen > 0)
		WHILE
			SWAP		( addr len linelen addr )
			DUP C@		( addr len linelen addr byte )
			DUP 32 128 WITHIN IF	( 32 <= c < 128? )
				EMIT
			ELSE
				DROP '.' EMIT
			THEN
			1+ SWAP 1-	( addr len linelen addr -- addr len addr+1 linelen-1 )
		REPEAT
		DROP		( addr len )
		CR

		DUP 1- 15 AND 1+ ( addr len linelen )
		TUCK		( addr linelen len linelen )
		-		( addr linelen len-linelen )
		>R + R>		( addr+linelen len-linelen )
	REPEAT

	DROP			( restore stack )
	BASE !			( restore saved BASE )
;

: CASE IMMEDIATE
	0		( push 0 to mark the bottom of the stack )
;

: OF IMMEDIATE
	' OVER ,	( compile OVER )
	' = ,		( compile = )
	[COMPILE] IF	( compile IF )
	' DROP ,  	( compile DROP )
;

: ENDOF IMMEDIATE
	[COMPILE] ELSE	( ENDOF is the same as ELSE )
;

: ENDCASE IMMEDIATE
	' DROP ,	( compile DROP )

	( keep compiling THEN until we get to our zero marker )
	BEGIN
		?DUP
	WHILE
		[COMPILE] THEN
	REPEAT
;

(
	DECOMPILER ----------------------------------------------------------------------

	CFA> is the opposite of >CFA.  It takes a codeword and tries to find the matching
	dictionary definition.  (In truth, it works with any pointer into a word, not just
	the codeword pointer, and this is needed to do stack traces).

	In this FORTH this is not so easy.  In fact we have to search through the dictionary
	because we don't have a convenient back-pointer (as is often the case in other versions
	of FORTH).  Because of this search, CFA> should not be used when performance is critical,
	so it is only used for debugging tools such as the decompiler and printing stack
	traces.

	This word returns 0 if it doesn't find a match.
)

: CFA>
	LATEST @	( start at LATEST dictionary entry )
	BEGIN
		?DUP		( while link pointer is not null )
	WHILE
		2DUP SWAP	( cfa curr curr cfa )
		< IF		( current dictionary entry < cfa? )
			NIP		( leave curr dictionary entry on the stack )
			EXIT
		THEN
		@		( follow link pointer back )
	REPEAT
	DROP		( restore stack )
	0		( sorry, nothing found )
;

(
	SEE decompiles a FORTH word.

	We search for the dictionary entry of the word, then search again for the next
	word (effectively, the end of the compiled word).  This results in two pointers:

	+---------+---+---+---+---+------------+------------+------------+------------+
	| LINK    | 3 | T | E | N | DOCOL      | LIT        | 10         | EXIT       |
	+---------+---+---+---+---+------------+------------+------------+------------+
	 ^									       ^
	 |									       |
	Start of word							      End of word

	With this information we can have a go at decompiling the word.  We need to
	recognise "meta-words" like LIT, LITSTRING, BRANCH, etc. and treat those separately.
)
: SEE
	WORD FIND	( find the dictionary entry to decompile )

	( Now we search again, looking for the next word in the dictionary.  This gives us
	  the length of the word that we will be decompiling.  (Well, mostly it does). )
	HERE @		( address of the end of the last compiled word )
	LATEST @	( word last curr )
	BEGIN
		2 PICK		( word last curr word )
		OVER		( word last curr word curr )
		<>		( word last curr word<>curr? )
	WHILE			( word last curr )
		NIP		( word curr )
		DUP @		( word curr prev (which becomes: word last curr) )
	REPEAT

	DROP		( at this point, the stack is: start-of-word end-of-word )
	SWAP		( end-of-word start-of-word )

	( begin the definition with : NAME [IMMEDIATE] )
	':' EMIT SPACE DUP ID. SPACE
	DUP ?IMMEDIATE IF ." IMMEDIATE " THEN

	>DFA		( get the data address, ie. points after DOCOL | end-of-word start-of-data )

	( now we start decompiling until we hit the end of the word )
	BEGIN		( end start )
		2DUP >
	WHILE
		DUP @		( end start codeword )

		CASE
		' LIT OF		( is it LIT ? )
			4 + DUP @		( get next word which is the integer constant )
			.			( and print it )
		ENDOF
		' LITSTRING OF		( is it LITSTRING ? )
			[ CHAR S ] LITERAL EMIT '"' EMIT SPACE ( print S"<space> )
			4 + DUP @		( get the length word )
			SWAP 4 + SWAP		( end start+8 length )
			2DUP TELL		( print the string )
			'"' EMIT SPACE		( finish the string with a final quote )
			+ ALIGNED		( end start+8+len, aligned )
			4 -			( because we're about to add 8 below )
		ENDOF
		' 0BRANCH OF		( is it 0BRANCH ? )
			." 0BRANCH ( "
			4 + DUP @		( print the offset )
			.
			." ) "
		ENDOF
		' BRANCH OF		( is it BRANCH ? )
			." BRANCH ( "
			4 + DUP @		( print the offset )
			.
			." ) "
		ENDOF
		' ' OF			( is it ' (TICK) ? )
			[ CHAR ' ] LITERAL EMIT SPACE
			4 + DUP @		( get the next codeword )
			CFA>			( and force it to be printed as a dictionary entry )
			ID. SPACE
		ENDOF
		' EXIT OF		( is it EXIT? )
			( We expect the last word to be EXIT, and if it is then we don't print it
			  because EXIT is normally implied by ;.  EXIT can also appear in the middle
			  of words, and then it needs to be printed. )
			2DUP			( end start end start )
			4 +			( end start end start+8 )
			<> IF			( end start | we're not at the end )
				." EXIT "
			THEN
		ENDOF
					( default case: )
			DUP			( in the default case we always need to DUP before using )
			CFA>			( look up the codeword to get the dictionary entry )
			ID. SPACE		( and print it )
		ENDCASE

		4 +		( end start+8 )
	REPEAT

	';' EMIT CR

	2DROP		( restore stack )
;

: :NONAME
	0 0 CREATE	( create a word with no name - we need a dictionary header because ; expects it )
	HERE @		( current HERE value is the address of the codeword, ie. the xt )
	DOCOL ,		( compile DOCOL (the codeword) )
	]		( go into compile mode )
;

: ['] IMMEDIATE
	' LIT ,		( compile LIT )
;




: EXCEPTION-MARKER
	RDROP			( drop the original parameter stack pointer )
	0			( there was no exception, this is the normal return path )
;


: CATCH		( xt -- exn? )
	DSP@ 4+ >R		( save parameter stack pointer (+8 because of xt) on the return stack )
	' EXCEPTION-MARKER 4+	( push the address of the RDROP inside EXCEPTION-MARKER ... )
	>R			( ... on to the return stack so it acts like a return address )
	EXECUTE			( execute the nested function )
;


: THROW		( n -- )
	?DUP IF			( only act if the exception code <> 0 )
		RSP@ 			( get return stack pointer )
		BEGIN
			DUP R0 4- <		( RSP < R0 )
		WHILE
			DUP @			( get the return stack entry )
			' EXCEPTION-MARKER 4+ = IF	( found the EXCEPTION-MARKER on the return stack )
				4+			( skip the EXCEPTION-MARKER on the return stack )
				RSP!			( restore the return stack pointer )

				( Restore the parameter stack. )
				DUP DUP DUP		( reserve some working space so the stack for this word
							  doesn't coincide with the part of the stack being restored )
				R>			( get the saved parameter stack pointer | n dsp )
				4-			( reserve space on the stack to store n )
				SWAP OVER		( dsp n dsp )
				!			( write n on the stack )
				DSP! EXIT		( restore the parameter stack pointer, immediately exit )
			THEN
			4+
		REPEAT

		( No matching catch - print a message and restart the INTERPRETer. )
		DROP

		CASE
		0 1- OF	( ABORT )
			." ABORTED" CR
		ENDOF
			( default case )
			." UNCAUGHT THROW "
			DUP . CR
		ENDCASE
		QUIT
	THEN
;


: ABORT		( -- )
	0 1- THROW
;


: Z" IMMEDIATE
	STATE @ IF	( compiling? )
		' LITSTRING ,	( compile LITSTRING )
		HERE @		( save the address of the length word on the stack )
		0 ,		( dummy length - we don't know what it is yet )
		BEGIN
			KEY 		( get next character of the string )
			DUP '"' <>
		WHILE
			HERE @ C!	( store the character in the compiled image )
			1 HERE +!	( increment HERE pointer by 1 byte )
		REPEAT
		0 HERE @ C!	( add the ASCII NUL byte )
		1 HERE +!
		DROP		( drop the double quote character at the end )
		DUP		( get the saved address of the length word )
		HERE @ SWAP -	( calculate the length )
		4-		( subtract 8 (because we measured from the start of the length word) )
		SWAP !		( and back-fill the length location )
		ALIGN		( round up to next multiple of 8 bytes for the remaining code )
		' DROP ,	( compile DROP (to drop the length) )
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
		0 SWAP C!	( store final ASCII NUL )
		HERE @		( push the start address )
	THEN
;



: STRLEN 	( str -- len )
	DUP		( save start address )
	BEGIN
		DUP C@ 0<>	( zero byte found? )
	WHILE
		1+
	REPEAT

	SWAP -		( calculate the length )
;



: CSTRING	( addr len -- c-addr )
	SWAP OVER	( len saddr len )
	HERE @ SWAP	( len saddr daddr len )
	CMOVE		( len )

	HERE @ +	( daddr+len )
	0 SWAP C!	( store terminating NUL char )

	HERE @ 		( push start address )
;

: UNUSED	( -- n )
	TOP_HERE @		( get end of data segment according to the kernel )
	HERE @		( get current position in data segment )
	-
	4 /		( returns number of cells )
;


: WELCOME
	S" TEST-MODE" FIND NOT IF
		." JONESFORTH VERSION " VERSION . CR
		 UNUSED . ." CELLS REMAINING" CR
		." OK " CR
	THEN
;

WELCOME
HIDE WELCOME
