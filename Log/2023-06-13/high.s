#---------------------------------------------------
#-- Implementacion de las palabras de alto nivel 
#---------------------------------------------------

    .include "macroCPU.h"
    .include "primitives.h"
    .include "high.h"

# ========= SYSTEM VARIABLES & CONSTANTS ==================
#-------------------------------------------------------------
#- u0      -- a-addr       current user area adrs
#- Devolver direccion de la zona de usuario (parte inferior)
#-------------------------------------------------------------
.global do_u0
do_u0:
    DOUSER
    DW(0)

#-------------------------------------------------------------
#  >IN     -- a-addr        holds offset into TIB
#  4 USER >IN
#-------------------------------------------------------------
.global do_toin
do_toin:
    DOUSER
    DW(0x4)

#-------------------------------------------------------------
#  BASE    -- a-addr       holds conversion radix
#  8 USER BASE
#-------------------------------------------------------------
.global do_base
do_base:
    DOUSER
    DW(0x8)

#-------------------------------------------------------------
#  STATE   -- a-addr       holds compiler state
#  0xC USER STATE
#-------------------------------------------------------------
.global do_state
do_state:
    DOUSER
    DW(0xC)

#-------------------------------------------------------------
#  dp      -- a-addr       holds dictionary ptr
#  0x10 USER DP
#-------------------------------------------------------------
.global do_dp
do_dp:
    DOUSER
    DW(0x10)

#-------------------------------------------------------------
#  'source  -- a-addr      two cells: len, adrs
# 0x14 USER 'SOURCE
#-------------------------------------------------------------
.global do_ticksource
do_ticksource:
    DOUSER
    DW(0x14)

#-------------------------------------------------------------
# latest    -- a-addr     last word in dict.
#  0x1C USER LATEST
#-------------------------------------------------------------
.global do_latest
do_latest:
    DOUSER
    DW(0x1C)

#-------------------------------------------------------------
#  hp       -- a-addr     HOLD pointer
#   20 USER HP
#-------------------------------------------------------------
do_hp:
    DOUSER
    DW(0x20)

#-------------------------------------------------------------
#  LP       -- a-addr     Leave-stack pointer
#  24 USER LP
#-------------------------------------------------------------
.global do_lp
do_lp:
    DOUSER
    DW(0x24)


#-------------------------------------------------------------
#  s0       -- a-addr     end of parameter stack
#-------------------------------------------------------------
.global do_s0
do_s0:
    DOUSER
    DW(0x100)

#-------------------------------------------------------------
# PAD       -- a-addr    user PAD buffer
#                         = end of hold area!
#-------------------------------------------------------------
do_pad:
    DOUSER
    DW(0x128)

#-------------------------------------------------------------
# l0       -- a-addr     bottom of Leave stack
#-------------------------------------------------------------
.global do_l0
do_l0:
    DOUSER
    DW(0x180)

#-------------------------------------------------------------
# r0       -- a-addr     end of return stack
#-------------------------------------------------------------
.global do_r0
do_r0:	
	DOUSER
    DW(0x200)



#============ DOUBLE OPERATORS ==============================


#--------------------------------------------------------
# 2@    a-addr -- x1 x2    fetch 2 cells
#  DUP CELL+ @ SWAP @ ;
#  the lower address will appear on top of stack
#---------------------------------------------------------
.global do_twofetch
do_twofetch:
    DOCOLON

    DUP
    CELLPLUS
    FETCH
    SWOP
    FETCH
    EXIT


#----------------------------------------------------
#  2!    x1 x2 a-addr --    store 2 cells
#   SWAP OVER ! CELL+ ! ;
#   the top of stack is stored at the lower adrs
#----------------------------------------------------
.global do_twostore
do_twostore:
	DOCOLON
    SWOP   #-- Almacenar x2
    OVER
    STORE
    CELLPLUS #-- Almacenar x1
    STORE
    EXIT

#----------------------------------------------------
#-- 2DUP   x1 x2 -- x1 x2 x1 x2   dup top 2 cells
#   OVER OVER ;
#----------------------------------------------------
.global do_twodup
do_twodup:
	DOCOLON
	OVER
	OVER
	EXIT

#----------------------------------------------------
#  2OVER  x1 x2 x3 x4 -- x1 x2 x3 x4 x1 x2
#   >R >R 2DUP R> R> 2SWAP ;
#----------------------------------------------------
.global do_twoover
do_twoover:
	DOCOLON

	TOR
    TOR
    TWODUP
    RFROM
    RFROM
    TWOSWAP
	EXIT

#----------------------------------------------------
#  2DROP  x1 x2 --          drop 2 cells
#   DROP DROP ;
#----------------------------------------------------
.global do_twodrop
do_twodrop:
    DOCOLON

    DROP
    DROP
    
    EXIT

#----------------------------------------------------
#  2SWAP  x1 x2 x3 x4 -- x3 x4 x1 x2  per diagram
#   ROT >R ROT R> ;
#----------------------------------------------------
.global do_twoswap
do_twoswap:
    DOCOLON

    ROT
    TOR
    ROT
    RFROM
    
    EXIT

#=========== ARITHMETIC OPERATORS ==========================

#----------------------------------------------------
#  DNEGATE   d1 -- d2     negate double precision
#   SWAP INVERT SWAP INVERT 1 M+ ;
#----------------------------------------------------
.global do_dnegate
do_dnegate: 
    DOCOLON

    SWOP
    INVERT
    SWOP
    INVERT
    LIT(1)
    MPLUS

    EXIT


#----------------------------------------------------
#  ?DNEGATE  d1 n -- d2   negate d1 if n negative
#   0< IF DNEGATE THEN ;       ...a common factor
#----------------------------------------------------
.global do_qdnegate
do_qdnegate: 
    DOCOLON

    ZEROLESS
    QBRANCH
    ADDR(DNEG1)
    DNEGATE
DNEG1:

    EXIT


#----------------------------------------------------
#  DABS     d1 -- +d2    absolute value dbl.prec.
#   DUP ?DNEGATE ;
#----------------------------------------------------
.global do_dabs
do_dabs: 
    DOCOLON
    DUP
    QDNEGATE
    EXIT 

#----------------------------------------------------
# M*     n1 n2 -- d    signed 16*16->32 multiply
#  2DUP XOR >R        carries sign of the result
#  SWAP ABS SWAP ABS UM*
#  R> ?DNEGATE ;
#----------------------------------------------------
.global do_mstar
do_mstar: 
    DOCOLON

    TWODUP
    LXOR
    TOR

    SWOP
    ABS
    SWOP
    ABS
    UMSTAR

    RFROM
    QDNEGATE

    EXIT

#----------------------------------------------------
#  S>D    n -- d          single -> double prec.
#   DUP 0< ;
#----------------------------------------------------
.global do_stod
do_stod: 
    DOCOLON
    DUP
    ZEROLESS
    EXIT


#----------------------------------------------------
#  SM/REM   d1 n1 -- n2 n3   symmetric signed div
#   2DUP XOR >R              sign of quotient
#   OVER >R                  sign of remainder
#   ABS >R DABS R> UM/MOD
#   SWAP R> ?NEGATE
#   SWAP R> ?NEGATE ;
# Ref. dpANS-6 section 3.2.2.1.
#----------------------------------------------------
.global do_smslashrem
do_smslashrem: 
    DOCOLON

    TWODUP
    LXOR
    TOR
    OVER
    TOR

    ABS
    TOR
    DABS
    RFROM
    UMSLASHMOD

    SWOP
    RFROM
    QNEGATE
    SWOP
    RFROM
    QNEGATE

    EXIT


#----------------------------------------------------
#  FM/MOD   d1 n1 -- n2 n3   floored signed div'n
#   DUP >R              save divisor
#   SM/REM
#   DUP 0< IF           if quotient negative,
#       SWAP R> +         add divisor to rem'dr
#       SWAP 1-           decrement quotient
#   ELSE R> DROP THEN ;
# Ref. dpANS-6 section 3.2.2.1.
#----------------------------------------------------
.global do_fmslashmod
do_fmslashmod: 
    DOCOLON

    DUP
    TOR
    SMSLASHREM

    DUP
    ZEROLESS
    QBRANCH
    ADDR(FMMOD1)
    SWOP
    RFROM
    PLUS
    SWOP
    ONEMINUS
    BRANCH
    ADDR(FMMOD2)
FMMOD1: 
    RFROM
    DROP
FMMOD2:

    EXIT

#----------------------------------------------------
#  /      n1 n2 -- n3       signed divide
#   /MOD nip ;
#----------------------------------------------------
.global do_slash
do_slash: 
    DOCOLON
    SLASHMOD
    NIP
    EXIT

#----------------------------------------------------
#  */MOD  n1 n2 n3 -- n4 n5    n1*n2/n3, rem&quot
#   >R M* R> FM/MOD ;
#----------------------------------------------------
.global do_ssmod
do_ssmod: 
    DOCOLON
    TOR
    MSTAR
    RFROM
    FMSLASHMOD
    EXIT


#----------------------------------------------------
#  */MOD  n1 n2 n3 -- n4 n5    n1*n2/n3, rem&quot
#   >R M* R> FM/MOD ;
#----------------------------------------------------
.global do_starslash
do_starslash: 
    DOCOLON
    SSMOD
    NIP
    EXIT


#----------------------------------------------------
#  */     n1 n2 n3 -- n4        n1*n2/n3
#   */MOD nip ;
#----------------------------------------------------
.global do_mod
do_mod: 
    DOCOLON
    SLASHMOD
    DROP
    EXIT

#----------------------------------------------------
#--  /MOD   n1 n2 -- n3 n4    signed divide/rem'dr
#--   >R S>D R> FM/MOD ;
#----------------------------------------------------
.global do_slashmod
do_slashmod: 
    DOCOLON

    TOR
    STOD
    RFROM
    FMSLASHMOD

    EXIT





#----------------------------------------------------
#  *      n1 n2 -- n3       signed multiply
#   M* DROP ;
#----------------------------------------------------
.global do_star
do_star: 
    DOCOLON

    MSTAR
    DROP

    EXIT




#----------------------------------------------------
# ?NEGATE  n1 n2 -- n3  negate n1 if n2 negative
#   0< IF NEGATE THEN ;        ...a common factor
#----------------------------------------------------
.global do_qnegate
do_qnegate: 
    DOCOLON

    ZEROLESS
    QBRANCH
    ADDR(QNEG1)
    NEGATE
QNEG1:

    EXIT

#----------------------------------------------------
# ABS     n1 -- +n2     absolute value
#  DUP ?NEGATE ;
#----------------------------------------------------
.global do_abs
do_abs: 
    DOCOLON

    DUP
    QNEGATE

    EXIT


#----------------------------------------------------
#  MAX    n1 n2 -- n3       signed maximum
#   2DUP < IF SWAP THEN DROP ;
#----------------------------------------------------
.global do_max
do_max: 
    DOCOLON
    TWODUP   #-- n1 n2 n1 n2
    LESS     #-- n1 n2 flag
    QBRANCH
    ADDR(MAX1)
    SWOP
MAX1:
    DROP
    EXIT

#----------------------------------------------------
#  MIN    n1 n2 -- n3       signed minimum
#   2DUP > IF SWAP THEN DROP ;
#----------------------------------------------------
.global do_min
do_min: 
    DOCOLON
    TWODUP
    GREATER
    QBRANCH
    ADDR(MIN1)
    SWOP
MIN1:
    DROP
    EXIT


#----------------------------------------------------
#  umin     u1 u2 -- u      unsigned minimum
#   2DUP U> IF SWAP THEN DROP ;
#----------------------------------------------------
.global do_umin
do_umin: 
    DOCOLON
    TWODUP
    UGREATER
    QBRANCH
    ADDR(UMIN1)
    SWOP
UMIN1: 
    DROP
    EXIT

#----------------------------------------------------
#   umax    u1 u2 -- u       unsigned maximum
#    2DUP U< IF SWAP THEN DROP ;
#----------------------------------------------------
.global do_umax
do_umax: 
    DOCOLON
    TWODUP
    ULESS
    QBRANCH
    ADDR(UMAX1)
    SWOP
UMAX1:
    DROP
    EXIT


#----------------------------------------------------
#-- BL      -- char            an ASCII space
#----------------------------------------------------
.global do_bl
do_bl:
  DOCON
  DW(0x20)

#----------------------------------------------------
# tib     -- a-addr     Terminal Input Buffer
# HEX 82 CONSTANT TIB   CP/M systems: 126 bytes
# HEX -80 USER TIB      others: below user area
#----------------------------------------------------
.global do_tib
do_tib:
#--- HACK: Con el RARs no podemos meter directivas .word en el segmento
#--- de codigo. Por ello, la direccion del tib la metemos directamente
#--- en la pila
#--- Como es una implementacion "cableada", no hay problema
    la t0, ptib
    PUSH_T0

    NEXT

#--- Implementacion tipica
#  DOCON
#  DW(0x2000)

#----------------------------------------------------
#  tibsize  -- n         size of TIB
# HEX 82 CONSTANT TIB   CP/M systems: 126 bytes
# HEX -80 USER TIB      others: below user area
#----------------------------------------------------
.global do_tibsize
do_tibsize:
  DOCON
  DW(124)

#== NUMERIC OUTPUT ================================
#== Numeric conversion is done l.s.digit first, so
#== the output buffer is built backwards in memory.

#----------------------------------------------------
#  <#    --             begin numeric conversion
#    PAD HP ! ;          (initialize Hold Pointer)
#----------------------------------------------------
do_lessnum:
    DOCOLON

    PAD  #-- Llevar el puntero PAD --> HP
    HP
    STORE
    EXIT


#----------------------------------------------------
#  #     ud1 -- ud2     convert 1 digit of output
#  BASE @ UD/MOD ROT >digit HOLD ;
#----------------------------------------------------
do_num:
    DOCOLON

    BASE
    FETCH
    UDSLASHMOD
    ROT
    TODIGIT
    HOLD

    EXIT

#----------------------------------------------------
#  #S    ud1 -- ud2     convert remaining digits
#   BEGIN # 2DUP OR 0= UNTIL ;
#----------------------------------------------------
do_nums:
    DOCOLON

NUMS1:
    NUM
    TWODUP
    LOR
    ZEROEQUAL
    QBRANCH
    ADDR(NUMS1)

    EXIT

#----------------------------------------------------
#  #>    ud1 -- c-addr u    end conv., get string
#   2DROP HP @ PAD OVER - ;
#----------------------------------------------------
do_numgreater:
    DOCOLON

    TWODROP
    HP
    FETCH
    PAD
    OVER
    MINUS

    EXIT

#----------------------------------------------------
#  U.    u --           display u unsigned
#   <# 0 #S #> TYPE SPACE ;
#----------------------------------------------------
.global do_udot
do_udot:
    DOCOLON

    LESSNUM
      LIT(0)
      NUMS
    NUMGREATER
    TYPE
    SPACE

    EXIT

#----------------------------------------------------
# SIGN  n --           add minus sign if n<0
#  0< IF 2D HOLD THEN ;
#----------------------------------------------------
do_sign:
    DOCOLON

    ZEROLESS
    QBRANCH
    ADDR(SIGN1)
    LIT(0x2D)
    HOLD

SIGN1:

    EXIT


# =========== OTRAS ========================================

#----------------------------------------------------
#--  ?ALIGN   addr --- flag  
#--  3 AND 0= IF 0 INVERT ELSE 0 THEN ;
#--
#--  Flag: -1: Dir alineda
#--  Flag: 0: Dir no alineada
#----------------------------------------------------
.global do_qalign
do_qalign:
    DOCOLON
    
    #-- Obtener los 2 bits de menor peso
    LIT(3)
    LAND

    #-- Si son 0, es una direccion alineada
    #-- Comprobar si son 0
    ZEROEQUAL
    QBRANCH
    ADDR(no_aligned)

    #-- Direccion alineada
    LIT(0)
    INVERT
    BRANCH
    ADDR(qalign_end)


no_aligned:
    #-- Direccion no alineada
    LIT(0)

qalign_end:
    EXIT


#----------------------------------------------------
#--  ALIGN   addr --- a-addr  
#--  DUP ?ALIGN INVERT IF 4 + 3 INVERT AND THEN ;
#--
#--  Devolver una direccion alineada
#--  Si addr ya estaba alineada, se deja igual
#----------------------------------------------------
.global do_align
do_align:
    DOCOLON

    DUP
    QALIGN
    INVERT
    #-- Si esta alineada terminar. No hacer nada
    QBRANCH
    ADDR(align_end)

    #-- Direccion no alineada: Alinearla
    LIT(4)
    PLUS    #-- Sumar 4

    #-- Poner a 0 los 2 bits de menor peso
    LIT(3)
    INVERT
    LAND

align_end:

    EXIT    

#----------------------------------------------------
#--  #init    -- n    #bytes of user area init data
#----------------------------------------------------
.global do_ninit
do_ninit:
  DOCON
  DW(36)  #-- 9 palabras (de 4 bytes)


#------------------------- PRUEBAS ------------------------------------------

#----------------------------------------------------
#--  DEBUG   i*x --- i*x  Mostrar la pila actual
#--  .S CR
#----------------------------------------------------
.global do_debug 
do_debug:
    DOCOLON

    DOTS
    CR

    EXIT

#--------------------------------
#-- Palabras de nivel superior	
#--------------------------------
do_add3:
	#-- Guardar direccion de retorno en la pila r
	PUSH_RA
	
	#-- Llamar a las palabras + +
	PLUS
	PLUS
	
	#-- Recuperar la direccion de retorno de la pila r
	POP_RA

	#-- Devolver control
	ret	

#--- Prueba para R@
#--- Al entrar aquí se guarda la direccion de retorno en la pila R
#--- Se llama a R@ para guardar este valor en la pila
#--- (Desde el nivel 0 la pila R está vacia, por eso hay que
#---  llamarla desde esta palabra de nivel superior)
do_test_rfetch:
    #-- Guardar direccion de retorno
	PUSH_RA
	
	RFETCH

	#-- Recuperar direccion de retorno
	POP_RA
	ret

#--- Prueba para RP@
do_test_rpfetch:
    #-- Guardar direccion de retorno
	PUSH_RA
	
	RPFETCH

	#-- Recuperar direccion de retorno
	POP_RA
	ret
				
#===================== INPUT/OUTPUT ==================================

#----------------------------------------------------
# SPACE   --               output a space
#  BL EMIT ;
#----------------------------------------------------
.global do_space
do_space:
  DOCOLON
  BL
  EMIT
  EXIT

#----------------------------------------------------
# SPACES   n --            output n spaces
#  BEGIN DUP WHILE SPACE 1- REPEAT DROP ;
#----------------------------------------------------
do_spaces:
	DOCOLON
SPCS1:
	DUP
	QBRANCH
	ADDR(SPCS2)
	SPACE
	ONEMINUS
	BRANCH
	ADDR(SPCS1)
SPCS2:
	DROP
	EXIT

#----------------------------------------------------
# CR      --               output newline
#  0D EMIT 0A EMIT ;
#----------------------------------------------------
.global do_cr
do_cr:
	DOCOLON
	LIT(0xD)
	EMIT
	LIT(0XA)
	EMIT
	EXIT


# ================== NUMERIC OUTPUT ================================
# ; Numeric conversion is done l.s.digit first, so
# ; the output buffer is built backwards in memory.

#----------------------------------------------------
#  >digit   n -- c      convert to 0..9A..Z
#   [ HEX ] DUP 9 > 7 AND + 30 + ;
#----------------------------------------------------
do_todigit:
    DOCOLON

    DUP
    LIT(9)
    GREATER
    LIT(7)
    LAND
    PLUS
    LIT(0x30)
    PLUS

    EXIT


#----------------------------------------------------
#  HOLD  char --        add char to output string
#   -1 HP +!  HP @ C! ;
#----------------------------------------------------
do_hold:
	DOCOLON

    #-- Decrementar puntero
    LIT(-1)
    HP
    PLUSSTORE

    #-- Guardar el caracter en la nueva posicion
    HP
    FETCH
    CSTORE

    EXIT

#----------------------------------------------------
# .     n --           display n signed
#  <# DUP ABS 0 #S ROT SIGN #> TYPE SPACE ;
#----------------------------------------------------
.global do_dot
do_dot:
	DOCOLON

    LESSNUM
      DUP
      ABS
      LIT(0)
      NUMS
      ROT
      SIGN
    NUMGREATER
    TYPE
    SPACE  

    EXIT

#----------------------------------------------------
# HEX     --       set number base to hex
#  16 BASE ! ;
#----------------------------------------------------
do_hex:
	DOCOLON

    LIT(16)
    BASE
    STORE
    EXIT

#----------------------------------------------------
#  DECIMAL  --      set number base to decimal
#   10 BASE ! ;
#----------------------------------------------------
do_decimal:
    DOCOLON

    LIT(10)
    BASE
    STORE

    EXIT

#----------------------------------------------------
#-- COUNT   c-addr1 -- c-addr2 u  counted->adr/len
#   DUP CHAR+ SWAP C@ ;
#----------------------------------------------------
.global do_count
do_count:
	DOCOLON
	DUP
	CHARPLUS
	SWOP      #-- Es swap
	CFETCH
	EXIT

#----------------------------------------------------
#-- (S")     -- c-addr u   run-time code for S"
#--  R> COUNT 2DUP + ALIGNED >R  
#--  Deja en la pila la direccion de la cadena y su longitud
#----------------------------------------------------
.global do_xsquote
do_xsquote:
    DOCOLON
	
    #-- Prólogo no Forth
    #-- Meter a0 en la pila: Direccion de la counted cadena
    mv t0, a0
    PUSH_T0

    #-- Codigo Forth ---
    COUNT

    #-- Como es un STC, las siguientes instrucciones
    #-- no hace falta tenerlas
    #-- TWODUP
    #-- PLUS
    #-- ALIGNED
    #-- TOR

	EXIT

#----------------------------------------------------
#  S"       --         compile in-line string
#   COMPILE (S")  [ HEX ]
#   22 WORD C@ 1+ ALIGNED ALLOT ; IMMEDIATE
#----------------------------------------------------
.global do_squote
do_squote:
    DOCOLON

    #--- Añadir Llamada a xsquote2
    la t0,do_xsquote2
    PUSH_T0
    CJAL

    LIT(0x22)    #-- "
    WORD         #--   c-addr (no alineada)

    #-- Obtener caracteres de la cadena
    CFETCH     #--  u

    #-- Sumar 1 (para dejar espacio para el contador)
    ONEPLUS    #-- u+1

    #-- Reservar espacio para la cadena
    ALLOT    #--
    
    #-- Añadir los bytes necesarios para que la nueva dir de HERE
    #-- este alineada 
    HERE   #-- addr(no-align)

    DUP     #-- addr(no-align) addr(no-align)
    ALIGN   #-- addr(no-align) a-addr
    SWOP    #-- a-addr addr
    MINUS   #-- u  (bytes de desalineamiento)

    #-- Reservar los bytes de desalineamiento
    #-- Ahora HERE debe apuntar a una direccion ALINEADA
    ALLOT

    EXIT

#----------------------------------------------------
#  ."       --         compile string to print"
#   POSTPONE S"  POSTPONE TYPE ; IMMEDIATE"
#----------------------------------------------------
.global do_dotquote
do_dotquote:
    DOCOLON

    SQUOTE

    #--- Añadir Llamada a TYPE
    la t0,do_type
    PUSH_T0
    CJAL

    EXIT

#----------------------------------------------------
#  TYPE    c-addr +n --     type line to term'l
#   ?DUP IF
#     OVER + SWAP DO I C@ EMIT LOOP
#   ELSE DROP THEN ;
#----------------------------------------------------
.global do_type
do_type:
    DOCOLON
	
	#--- Programa Forth
    QDUP
    QBRANCH      # IF
    ADDR(TYP4)

      OVER
      PLUS
      SWOP
      XDO    # DO
TYP3:
        II
        CFETCH
        EMIT
      XLOOP
      ADDR(TYP3)
      BRANCH
      ADDR(TYP5)

TYP4: 
    DROP  #-- Else

TYP5:
	EXIT

# ================ DICTIONARY MANAGEMENT =========================

#-----------------------------------------------------
#  HERE    -- addr      returns dictionary ptr
#   DP @ ;
#-----------------------------------------------------
.global do_here
do_here:
  DOCOLON
    DP
    FETCH
  EXIT


# ==================== UTILITY WORDS AND STARTUP =====================

#-----------------------------------------------------
#  .S      --           print stack contents
#   SP@ S0 - IF
#       SP@ S0 2 - DO I @ U. -2 +LOOP
#   THEN ;
#-----------------------------------------------------
.global do_dots
do_dots:
	DOCOLON

    SPFETCH       
    S0
    MINUS       #-- Tamaño de la pila en bytes

    QBRANCH       #-- Terminar si el tamaño es 0
    ADDR(DOTS2)

    SPFETCH
    S0
    LIT(4)
    MINUS     #-- s0-4 --> Apuntar al primer elemento (desde la base)

    XDO
DOTS1:
      II   
      FETCH 
      UDOT  #-- Mostrar elemento de la pila

      LIT(-4) #-- Siguiente elemento de la pila
      XPLUSLOOP
      ADDR(DOTS1)

DOTS2:

    EXIT

#-----------------------------------------------------
#  WORDS    --          list all words in dict.
#   LATEST @ BEGIN
#       DUP COUNT TYPE SPACE
#       NFA>LFA @
#   DUP 0= UNTIL
#   DROP ;
#-----------------------------------------------------
.global do_words
do_words:
	DOCOLON

   #-- Direccion de la ultima palabra en el diccionario
    LATEST
    FETCH

WDS1: 
    DUP
    COUNT
    TYPE
    SPACE

    #-- Obtener enlace de la siguiente palabra
    NFATOLFA
    FETCH

    #-- Comprobar si la dirección es 0 (ultima palabra)
    DUP
    ZEROEQUAL
    QBRANCH    #-- No es la ultima, imprimir la siguiente
    ADDR(WDS1)

    DROP

    EXIT

#------------------------------------------------------
#-- LIMPIEZA......................
#-----------------------------------------------------
# Z UD*      ud1 d2 -- ud3      32*16->32 multiply
#    DUP >R UM* DROP  SWAP R> UM* ROT + ;
#    head UDSTAR,3,UD*,docolon
#-----------------------------------------------------
.global do_udstar
do_udstar:
	DOCOLON

	#-- Eliminar la celda más significativa
	#-- de ud1
	SWOP
	DROP

	UMSTAR

	EXIT

#-----------------------------------------------------
#  UD/MOD   ud1 u2 -- u3 ud4   32/16->32 divide
#    >R 0 R@ UM/MOD  ROT ROT R> UM/MOD ROT ;
#
#  u3 = resto, ud4 = cociente
#-----------------------------------------------------
.global do_udslashmod
do_udslashmod:
	DOCOLON

	UMSLASHMOD

	#-- HACK!
	#-- Añadir el byte de mayor peso del
	#- resuldado: 0
	mv t0,zero
	PUSH_T0

	EXIT

#----------------------------------------------
# ;C >     n1 n2 -- flag         test n1>n2, signed
#----------------------------------------------
.global do_greater
do_greater:
	DOCOLON

	SWOP
	LESS

	EXIT

#-----------------------------------------------------
#  TUCK   x1 x2 -- x2 x1 x2     per stack diagram
#-----------------------------------------------------
.global do_tuck
do_tuck:
  DOCOLON
  SWOP
  OVER
  EXIT

# ====================== DEPENDENCIES ===============================
#----------------------------------------------------
#-- CHAR+    c-addr1 -- c-addr2   add char size
#-- Añadir el tamaño del tipo char a la direccion
#----------------------------------------------------
.global do_charplus
do_charplus:
  j do_oneplus


# ================== INTERPRETER ===================================
# Note that NFA>LFA, NFA>CFA, IMMED?, and FIND
# are dependent on the structure of the Forth
# header.  This may be common across many CPUs,
# or it may be different.


#--------------------------------------------------------
#  ?SIGN   adr n -- adr' n' f  get optional sign
#   advance adr/n if sign; return NZ if negative
#   OVER C@                 -- adr n c
#   2C - DUP ABS 1 = AND    -- +=-1, -=+1, else 0
#   DUP IF 1+               -- +=0, -=+2
#       >R 1 /STRING R>     -- adr' n' f
#   THEN ;
#--------------------------------------------------------
.global do_qsign
do_qsign:
    DOCOLON

    OVER
    CFETCH
    LIT(0x2C)
    MINUS
    DUP
    ABS
    LIT(1)
    EQUAL
    LAND
    DUP
    QBRANCH
    ADDR(QSIGN1)

    #-- Numero negativo
    ONEPLUS
    TOR
    LIT(1)
    SLASHSTRING
    RFROM

QSIGN1:

    EXIT


#--------------------------------------------------------
#  IMMED?    nfa -- f      fetch immediate flag
#   1- C@ ;                     nonzero if immed
#--------------------------------------------------------
.global do_immedq
do_immedq:
    DOCOLON

    ONEMINUS
    CFETCH

    EXIT


#--------------------------------------------------------
#  NFA>LFA   nfa -- lfa    name adr -> link field
#   5 - ;
#
#  NFA = Name Field Address. Direccion de la celula del
#        diccionario que contiene el nombre de la palabra
#        (el nombre es una cadena contadora)
#
#  LFA = Link Field Address. Direccion de la celula del 
#        diccionario que contiene el enlace a la palabra
#        siguiente
#
#  En esta implementacion hay que ir 5 bytes atras  
#  para obtener el campo del enlace
#--------------------------------------------------------
.global do_nfatolfa
do_nfatolfa:
    DOCOLON

    LIT(5)
    MINUS

    EXIT

#--------------------------------------------------------
#  NFA>CFA   nfa -- cfa    name adr -> code field
#  COUNT 7F AND + ALIGN ;  mask off 'smudge' bit
#
#  NFA = Name Field Address. Direccion de la celula del
#        diccionario que contiene el nombre de la palabra
#        (el nombre es una cadena contadora)
#
#  cFA = Code Field Address. Direccion de la celula del 
#        diccionario que contiene el codigo de la palabra
#        (En esta implementación contiene la dirección
#         al codigo)
#--------------------------------------------------------
.global do_nfatocfa
do_nfatocfa:
    DOCOLON

    COUNT
    LIT(0x7F)
    LAND
    PLUS
    ALIGN
    EXIT

#--------------------------------------------------------
#  NIP    x1 x2 -- x2           per stack diagram
#   SWAP DROP ;
#---------------------------------------------------------
.global do_nip
do_nip:
    DOCOLON

    SWOP
    DROP
    EXIT

#--------------------------------------------------------
#  >counted  src n dst --     copy to counted str
#   2DUP C! CHAR+ SWAP CMOVE ;
#---------------------------------------------------------
.global do_tocounted
do_tocounted:
    DOCOLON

    TWODUP
    CSTORE   #-- Guardar el tamaño primero en zona usuario
    CHARPLUS #-- Incrementar la direccion (TOS) en un caracter
    SWOP
    CMOVE    #-- Copiar la cadena a continuacion de la longitud
    EXIT

#--------------------------------------------------------
#  /STRING  a u n -- a+n u-n   trim string
#   ROT OVER + ROT ROT - ;
#---------------------------------------------------------
.global do_slashstring
do_slashstring:
    DOCOLON

    ROT
    OVER
    PLUS  #-- Incrementar la direccion en n caracteres
 
    ROT
    ROT
    MINUS  #-- Decrementar el numero de caracteres en n (u-n)

    EXIT

#--------------------------------------------------------
# SOURCE   -- adr n    current input buffer
#   'SOURCE 2@ ;        length is at lower adrs
#---------------------------------------------------------
.global do_source
do_source:
    DOCOLON

    TICKSOURCE
    TWOFETCH

    EXIT

#---------------------------------------------------
#-- ACCEPT: c-addr +n1 -- +n2
#-- n1: Numero maximo de caracteres del buffer
#-- n2: Longitud de la cadena leida
#---------------------------------------------------
.global do_accept   
do_accept:
    DOCOLON

     #-- Leer tamano del buffer t1 = n1
    POP_T0
    mv t1, t0

    #-- Leer direccion del buffer
    POP_T0

    #-- Llamar al sistema operativo
    mv a0, t0  #-- Direccion del buffer
    mv a1, t1  #-- Buffer size 
    li a7, 8 #-- Servicio PRINT_STRING
    ecall

    #-- Calcular la longitud de la cadena
    #-- Se elimina el /n
    
    #-- Inicializar contador de caracteres
    li t2, 0

accept_bucle:
    #-- Leer caracter
    lb t3, 0(t0)

    #-- Si es '\n' terminar
    li t4, '\n'
    beq t3, t4, accept_end

    #-- No es \n --> Incrementar contador
    addi t2, t2, 1

    #-- Apuntar al siguiente caracter
    addi t0,t0,1

    #-- Repetir
    j accept_bucle

accept_end:

    #-- Meter longitud cadena en pila
    mv t0, t2
    PUSH_T0

    EXIT

#--------------------------------------------------------
#  WORD   char -- c-addr     word delim'd by char
#   DUP  SOURCE >IN @ /STRING   -- c c adr n
#   DUP >R   ROT SKIP           -- c adr' n'
#   OVER >R  ROT SCAN           -- adr" n"
#   DUP IF CHAR- THEN        skip trailing delim.
#   R> R> ROT -   >IN +!        update >IN offset
#   TUCK -                      -- adr' N
#   HERE >counted               --
#   HERE                        -- a
#   BL OVER COUNT + C! ;    append trailing blank
#---------------------------------------------------------
.global do_word
do_word:
    DOCOLON

    DUP
    SOURCE  #-- Direccion a cadena en buffer, y su longitud (lo pone en la pila)
    TOIN    #-- Obtener la variable TOIN (que no sabemos todavia para que es)
    FETCH
    SLASHSTRING  #--- Recortar (inicialmente se queda igual porque >IN es 0)
    DUP
    TOR
    ROT     #-- En la pila tenemos address long y 32 (espacio)
    SKIP
    OVER
    TOR
    ROT
    SCAN
    DUP
    QBRANCH
    ADDR(WORD1)
    ONEMINUS

WORD1:

    RFROM  #-- Recuperar direccion original
    RFROM #-- Recuperar tamaño original
    ROT
    MINUS
    TOIN
    PLUSSTORE
    TUCK
    MINUS  #-- Direccion inicial y tamaño de la palabra en la pila
    HERE
    TOCOUNTED
    HERE
    
    BL
    OVER
    COUNT
    PLUS
    CSTORE
    EXIT


#--------------------------------------------------------
#  (    --                     skip input until )
#   [ HEX ] 29 WORD DROP ; IMMEDIATE
#---------------------------------------------------------
.global do_paren
do_paren:
    DOCOLON

    LIT(0x29)
    WORD
    DROP

    EXIT

# ================ DICTIONARY MANAGEMENT =========================

#-------------------------------------------------------------
#  ALLOT   n --         allocate n bytes in dict
#   DP +! ;
#-------------------------------------------------------------
.global do_allot
do_allot:
    DOCOLON

    DP
    PLUSSTORE

    EXIT

#-------------------------------------------------------------
#  ,    x --           append cell to dict
#    HERE ! 1 CELLS ALLOT ;
#-------------------------------------------------------------
.global do_comma
do_comma:
    DOCOLON

    #-- Almacenar valor en la celula actual
    HERE
    STORE

    #-- Añadir una celda nueva
    LIT(1)
    CELLS
    ALLOT

    EXIT

# ===========  COMPILER ======================================

#-------------------------------------------------------------
#  CREATE   --      create an empty definition
#   LATEST @ , 0 C,         link & immed field
#   HERE LATEST !           new "latest" link
#   BL WORD C@ 1+ ALLOT         name field
#   docreate ,CF                code field
#-------------------------------------------------------------
.global do_create
do_create:
    DOCOLON

   
    #--- Obtener la dir. de la ultima palabra
    LATEST
    FETCH

    #-- Añadir el link
    COMMA

    #-- Añadir campo inmediato
    LIT(0)
    CCOMMA

    #-- Actualizar el latest link
    HERE
    LATEST
    STORE

    #-- Añadir el campo nombre
    #-- Copiar el nombre del buffer de entrada
    #-- indicado por SOURCE
    BL
    WORD  #--- addr  (no alineada)

    #-- Añadir los bytes del nombre y la longitud
    CFETCH  #--- size
    ONEPLUS #--- size'
    ALLOT 
    
    #-- Añadir el code field
    #-- Se mete un valor de prueba
    la t0, do_dots
    #la t0, do_null
    PUSH_T0    
    COMMACF

    EXIT

#-------------------------------------------------------------
#   HIDE     --      "hide" latest definition
#    LATEST @ DUP C@ 80 OR SWAP C! ;
#-------------------------------------------------------------
.global do_hide
do_hide:
    DOCOLON

    LATEST
    FETCH
    DUP
    CFETCH
    LIT(0x80)
    LOR
    SWOP
    CSTORE

    EXIT

#-------------------------------------------------------------
#   REVEAL   --      "reveal" latest definition
#    LATEST @ DUP C@ 7F AND SWAP C! ;
#-------------------------------------------------------------
.global do_reveal
do_reveal:
    DOCOLON

    LATEST
    FETCH
    DUP
    CFETCH
    LIT(0x7F)
    LAND
    SWOP
    CSTORE

    EXIT


#-------------------------------------------------------------
#  [        --      enter interpretive state
#   0 STATE ! ; IMMEDIATE
#-------------------------------------------------------------
.global do_leftbracket
do_leftbracket:
    DOCOLON

    LIT(0)
    STATE
    STORE

    EXIT

#-------------------------------------------------------------
#   ]        --      enter compiling state
#    -1 STATE ! ;
#-------------------------------------------------------------
.global do_rightbracket
do_rightbracket:
    DOCOLON

    LIT(-1)
    STATE
    STORE

    EXIT

#-------------------------------------------------------------
#  :        --      begin a colon definition
#   CREATE HIDE ] !COLON ;
#-------------------------------------------------------------
.global do_colon
do_colon:
    DOCOLON

    #-- Crear una entrada nueva en el diccionario
    CREATE

    #-- Ocultar la palabra en las busquedas
    #-- Esta a medio construir
    HIDE

    #--- Entrar en modo compilacion
    RIGHTBRACKET

    #-- Añadir las instrucciones para ejecutar DOCOLON
    STORCOLON

    EXIT

#-------------------------------------------------------------
#  ;
#   REVEAL  ,EXIT
#   POSTPONE [  ; IMMEDIATE
#-------------------------------------------------------------
.global do_semi
do_semi:
    DOCOLON

    REVEAL
    CEXIT
    LEFTBRACKET

    EXIT

# =========== CONTROL STRUCTURES ===================================
#-------------------------------------------------------------
#  >L   x --   L: -- x        move to leave stack
#   CELL LP +!  LP @ ! ;      (L stack grows up)
#   head TOL,2,>L,docolon
#-------------------------------------------------------------
.global do_tol
do_tol:
    DOCOLON

    CELL
    LP
    PLUSSTORE  #-- Añadir una celda de espacio en la pila L
    
    LP
    FETCH
    STORE

    EXIT

#-------------------------------------------------------------
#  L>   -- x   L: x --      move from leave stack
#   LP @ @  CELL NEGATE LP +! ;
#-------------------------------------------------------------
.global do_lfrom
do_lfrom:
    DOCOLON

    LP
    FETCH
    FETCH

    CELL
    NEGATE
    LP
    PLUSSTORE

    EXIT


#-------------------------------------------------------------
# DO       -- adrs   L: -- 0
#  ['] xdo ,XT   HERE     target for bwd branch
#  0 >L ; IMMEDIATE           marker for LEAVEs
#-------------------------------------------------------------
.global do_do
do_do:
    DOCOLON

    #-- Añadir llamada a XDO
    la t0,do_xdo
    PUSH_T0
    CJAL

    #-- Direccion a donde saltar para repetir el bucle
    #-- La dejamos en la pila
    HERE 

    #-- No tengo claro porque mete 0 ahí...
    LIT(0)
    TOL

    EXIT


#-------------------------------------------------------------
#  ENDLOOP   adrs xt --   L: 0 a1 a2 .. aN --
#   ,BRANCH  ,DEST                backward loop
#   BEGIN L> ?DUP WHILE POSTPONE THEN REPEAT ;
#                                 resolve LEAVEs
# This is a common factor of LOOP and +LOOP.
#-------------------------------------------------------------
.global do_endloop
do_endloop:
    DOCOLON

LOOP1:
    LFROM
    QDUP #-- Duplicate if non zero

    QBRANCH
    ADDR(LOOP2)

    THEN
    BRANCH
    ADDR(LOOP1)

LOOP2:
    EXIT


#-------------------------------------------------------------
#   LOOP    adrs --   L: 0 a1 a2 .. aN --
#    ['] xloop ENDLOOP ;  IMMEDIATE
#-------------------------------------------------------------
.global do_loop
do_loop:
    DOCOLON

    #-- LOOP
    #-- Añadir Llamada a xloop
    la t0,do_xloop2
    PUSH_T0
    CJAL

    #-- Añadir campo para direccion destino
    COMMA
    ENDLOOP

    EXIT

#-------------------------------------------------------------
#  IF       -- adrs    conditional forward branch
#   ['] qbranch ,BRANCH  HERE DUP ,DEST ;
#   IMMEDIATE
#-------------------------------------------------------------
.global do_if
do_if:
    DOCOLON

    #-- Añadir Llamada a qbranch
    la t0,do_qbranch2
    PUSH_T0
    CJAL

    #-- Añadir campo para direccion destino
    HERE
    DUP
    COMMA

    #-- Deja la dirección del if en la pila

    EXIT

#-------------------------------------------------------------
#  ELSE     adrs1 -- adrs2    branch for IF..ELSE
#   ['] branch ,BRANCH  HERE DUP ,DEST
#   SWAP  POSTPONE THEN ; IMMEDIATE
#-------------------------------------------------------------
.global do_else
do_else:
    DOCOLON

    #-- Añadir Llamada a branch
    la t0,do_branch2
    PUSH_T0
    CJAL

    #-- Añadir campo para direccion destino
    HERE
    DUP
    COMMADEST

    SWOP
    THEN

    EXIT

#-------------------------------------------------------------
#  THEN     adrs --        resolve forward branch
#   HERE SWAP !DEST ; IMMEDIATE
#-------------------------------------------------------------
.global do_then
do_then:
    DOCOLON

    #-- Pila: addrIF --   (addrIF es la dir de salto del IF (qbranch))
    HERE  #-- addrIF addRThen
    SWOP  #-- addrThen AddrIF
    STOREDEST  #-- Almacenar direccion

    EXIT

#===================================================================
#=              INCOMPLETOS.... TO-DO
#===================================================================

# ================== INTERPRETER ===================================
# Note that NFA>LFA, NFA>CFA, IMMED?, and FIND
# are dependent on the structure of the Forth
# header.  This may be common across many CPUs,
# or it may be different.


#-------------------------------------------------------------
#  ?NUMBER  c-addr -- n -1      string->number
#                  -- c-addr 0  if convert error
#
#  La cadena es una counted string
#
#   DUP  0 0 ROT COUNT      -- ca ud adr n
#   ?SIGN >R  >NUMBER       -- ca ud adr' n'
#   IF   R> 2DROP 2DROP 0   -- ca 0   (error)
#   ELSE 2DROP NIP R>
#       IF NEGATE THEN  -1  -- n -1   (ok)
#   THEN ;
#-------------------------------------------------------------
.global do_qnumber
do_qnumber:
    DOCOLON

    DUP
    LIT(0)
    DUP
    ROT

    #-- Convertir counted a addr/len
    COUNT  #-- addr1 0 0  addr2 u

    #-- Comprobar si es positivo o negativo
    #-- flag 0: Positivo
    #-- flag >0: Negativo
    QSIGN  #-- addr1 0 0  addr2 u flag

    #-- Llevar flag a la pila R (Signo)
    TOR    #-- addr1 0 0  addr2 u  R: flag

    #-- Convertir a numero
    TONUMBER  #--addr1 ud addr2 u  R: flag

    #-- Saltar si la conversion es correcta
    QBRANCH
    ADDR(QNUM1)

    #-- Conversion no correcta
             #-- addr1 ud addr2  R:flag
    RFROM    #-- addr1 ud addr2  flag
    TWODROP  #-- addr1 ud 
    TWODROP  #-- addr1
    LIT(0)   #-- addr1 0

    #-- Terminar
    BRANCH
    ADDR(QNUM3)

QNUM1:   #-- addr1 ud addr2  R: flag
    #-- Conversion correcta
    TWODROP  #-- addr1 n  R: flag
    NIP   #-- n   R: flag

    #-- Recuperar el flag de signo de la pila R
    RFROM    #-- n flag
    QBRANCH  #-- Saltar Si es numero positivo
    ADDR(QNUM2)

    #-- Es un numero negativo
    NEGATE #-- n

QNUM2:     #-- n )

    #-- Conversion correcta
    LIT(-1)

    #-- Terminar
QNUM3:
    EXIT


#-------------------------------------------------------------
#  DIGIT?   c -- n -1   if c is a valid digit
#             -- x  0   otherwise
#   [ HEX ] DUP 39 > 100 AND +     silly looking
#   DUP 140 > 107 AND -   30 -     but it works!
#   DUP BASE @ U< ;
#-------------------------------------------------------------
.global do_digitq
do_digitq:
    DOCOLON

    DUP
    LIT(0x39)  #-- '9'
    GREATER
    LIT(0x100)
    LAND
    PLUS

    DUP
    LIT(0x140)
    GREATER
    LIT(0x107)
    LAND

    MINUS
    LIT(0X30)
    MINUS

    #--- Valor del digito calculado
    DUP
    BASE
    FETCH
    ULESS

    EXIT

#-------------------------------------------------------------
#  >NUMBER  ud adr u -- ud' adr' u'
#                       convert string to number
#
#  ud es el numero calculado previamente
#  Si es el primero, hay que ponerlo a 0
#  Sirve para encadenar conversiones
#
#   BEGIN
#   DUP WHILE
#       OVER C@ DIGIT?
#       0= IF DROP EXIT THEN
#       >R 2SWAP BASE @ UD*
#       R> M+ 2SWAP
#       1 /STRING
#   REPEAT ;
#-------------------------------------------------------------
.global do_tonumber
do_tonumber:
    DOCOLON

TONUM1:
    DUP       #--- Si longitud es 0, terminar (nada que convertir)
    QBRANCH
    ADDR(TONUM3)

    #--- Hay una cadena con almenos un caracter
    #-- Leer primer caracter
    OVER
    CFETCH   #-- ud addr u car

    #-- Convertirlo a numero
    #-- Si la conversion es correcta, flag = -1
    #-- Si la conversion falla, flag = 0
    DIGITQ   #-- ud addr u digito flag

    #-- Falla la conversion?
    #-- flag: 0 --> NO. Todo ok
    #-- flag: -1 --> Si
    ZEROEQUAL   #-- 0 0 addr u digito flag2

    #-- Saltar si numero ok
    QBRANCH
    ADDR(TONUM2)

    #-- Conversion incorrecta
    DROP

    #-- EXIT
    BRANCH
    ADDR(TONUM3)

TONUM2:
    #-- Conversion del digito actual es correcta
    #-- Estado de la pila:  ud addr u digito
    
    #-- Guardar el digito en pila R
    TOR  #-- ud addr u  (R: digito)

    TWOSWAP #-- addr u ud  (R: digito)

    #-- Leer la base
    BASE
    FETCH  #-- addr u ud base

    #-- Calcular peso del digito actual 
    UDSTAR #-- addr u ud*base (R: digito)
   
    #-- Recuperar digito de la pila
    RFROM  #-- addr u ud*base digito
    
    #-- Sumar el digito
    MPLUS  #-- addr u (ud*base + digito)
    TWOSWAP #-- (ud*base + digito) addr u

    #-- Trim string
    #-- Avanzar puntero una posicion
    LIT(1)
    SLASHSTRING  #-- (ud*base + digito) addr u

    #-- Repetir: Convertir el siguiente digito
    BRANCH
    ADDR(TONUM1)

TONUM3:
    EXIT


#-------------------------------------------------------
# FIND   c-addr -- c-addr 0   if not found
#                  xt  1      if immediate
#                  xt -1      if "normal"
#
#  La direccion de entrada apunta a una counted string
#
#  LATEST @ BEGIN             -- a nfa
#      2DUP OVER C@ CHAR+     -- a nfa a nfa n+1
#      S=                     -- a nfa f
#      DUP IF
#          DROP
#          NFA>LFA @ DUP      -- a link link
#      THEN
#  0= UNTIL                   -- a nfa  OR  a 0
#  DUP IF
#      NIP DUP NFA>CFA        -- nfa xt
#      SWAP IMMED?            -- xt iflag
#      0= 1 OR                -- xt 1/-1
#  THEN ;
#--------------------------------------------------------
.global do_find
do_find:
    DOCOLON

    LATEST    #-- Palabra en diccionario
    FETCH     #--> Dir_palabra  Dir_ultima_del_dict
FIND1:
    
    TWODUP
    OVER
    CFETCH
    CHARPLUS

    SEQUAL #-- Comprobar si la palabra esta en la entrada actual
           #-- del dicionario

    DUP         #-- Saltar a FIND2 si la hemos encontrado
    QBRANCH      
    ADDR(FIND2)

    #--- Apuntar a la siguiente palabra del diccionario (TODO)
    DROP

    #-- Obtener direccion a la siguiente palabra
    NFATOLFA
    FETCH

    #-- Comprobar si es la primera palabra (su link apunta a 0)
    DUP

FIND2:
    ZEROEQUAL
    QBRANCH      #--- NO es la primera, comprobar la siguiente
    ADDR(FIND1)

    DUP
    QBRANCH    #-- pALABRA NO encontrada
    ADDR(FIND3)

    #-- Palabra en el direccionario!!

    #-- En la pila se deja solo la direccion de la
    #-- palabra encontrada
    NIP
    DUP

    #-- Obtener el CFA (Code field Address)
    NFATOCFA
    FETCH
    SWOP
    IMMEDQ
    ZEROEQUAL
    LIT(1)
    LOR

FIND3:
    #-- Terminar
    EXIT


#-------------------------------------------------------
#   LITERAL  x --        append numeric literal
#    STATE @ IF ['] LIT ,XT , THEN ; IMMEDIATE
#  This tests STATE so that it can also be used
#  interpretively.  (ANSI doesn't require this.)
#--------------------------------------------------------
.global do_literal
do_literal:
    DOCOLON

    #-- Obtener el estado del compilador
    #-- 0: Interpretando
    #-- 1: Compilando (¿? Check!!)
    STATE
    FETCH

    #-- Saltar si interpretando
    QBRANCH
    ADDR(LITER1)

    #-- Modo de compilacion
    #-- Pila:  n --

    #-- Añadir Llamada a dolit
    la t0,dolit
    PUSH_T0
    CJAL

    #-- Meter el literal
    COMMA

LITER1:
    #-- Modo interpretando
    #-- Pila:  n  (Literal en la pila)
    #-- Terminar
    EXIT


#-------------------------------------------------------
#  INTERPRET    i*x c-addr u -- j*x
#                       interpret given buffer
# This is a common factor of EVALUATE and QUIT.
# ref. dpANS-6, 3.4 The Forth Text Interpreter
#   'SOURCE 2!  0 >IN !
#   BEGIN
#   BL WORD DUP C@ WHILE        -- textadr
#       FIND                    -- a 0/1/-1
#       ?DUP IF                 -- xt 1/-1
#           1+ STATE @ 0= OR    immed or interp?
#           IF EXECUTE ELSE ,XT THEN
#       ELSE                    -- textadr
#           ?NUMBER
#           IF POSTPONE LITERAL     converted ok
#           ELSE COUNT TYPE 3F EMIT CR ABORT  err
#           THEN
#       THEN
#   REPEAT DROP ;
#--------------------------------------------------------
.global do_interpret
do_interpret:
    DOCOLON

    #-- Almacenar direccion y longitud en 'SOURCE
    #-- Primero esta la longitud, y luego la direccion
    TICKSOURCE
    TWOSTORE

    LIT(0)
    TOIN
    STORE

INTER1:
    #-- Interpretar siguiente palabra
    #-- Pila vacia
    BL       #-- Obtener siguiente palabra a interpretar
    WORD     #-- Delimitada por un espacio en blanco
             #-- Pila: addr del buffer

    DUP      #-- Leer la longitud de la palabra
    CFETCH   #-- Pila: Dirección longitud

    QBRANCH       #-- Si la palabra tiene 0 caracteres--> Terminar
    ADDR(INTER9)

    #-- Hay una palabra no nula en el buffer
    #-- Buscar palabra en diccionario
    #-- 0: No encontrada
    #-- -1: Encontrada
    FIND  #-- Dirección flag

    #-- Duplicar si palabra encontrada
    QDUP
    
    #-- Saltar si no encontrada
    QBRANCH
    ADDR(INTER4)

    #-- Palabra en el diccionario: Pila: addr
    ONEPLUS   #-- addr

    #-- Leer estado de compilacion
    STATE
    FETCH #-- addr flag

    ZEROEQUAL #-- addr flag  (-1 --> modo interprete)
    LOR

    #-- Saltar al modo de compilacion
    QBRANCH
    ADDR(INTER2)

    #-- Modo interprete
    EXECUTE

    BRANCH
    ADDR(INTER3)

INTER2:  
    #-- Modo de compilacion
    CJAL

INTER3:
    BRANCH
    ADDR(INTER8)

INTER4:
    #--- Palabra no encontrada en el diccionario
    #-- Pila: addr

    #-- Comprobar si es un numero
    QNUMBER #--  n flag

    #-- Saltar si NO es un numero
    QBRANCH
    ADDR(INTER5)

    #-- Es un numero
    #-- Pila:  n 
    LITERAL

    #-- Interpretar siguiente palabra
    BRANCH
    ADDR(INTER6)

INTER5:
    #-- No es un numero
    COUNT
    TYPE
    LIT(0x3F)
    EMIT
    CR
    ABORT

INTER6:
    #-- Interpretar siguiente palabra
    BRANCH
    ADDR(INTER1)

INTER8:
    BRANCH
    ADDR(INTER1)

    #-- Terminar
INTER9:
    DROP

    EXIT


#-------------------------------------------------------
#  QUIT     --    R: i*x --    interpret from kbd
#   L0 LP !  R0 RP!   0 STATE !
#   BEGIN
#       TIB DUP TIBSIZE ACCEPT  SPACE
#       INTERPRET
#       STATE @ 0= IF CR ." OK" THEN
#   AGAIN ;
#--------------------------------------------------------
.global do_quit
do_quit:
    DOCOLON

   #-- Inicializar leaf-stack para que apunte a la base (L0)
    L0
    LP 
    STORE

    #-- Inicializar la pila R
    R0   #-- Base de la pila R
    RPSTORE

    #-- Inicializar el estado del compilador
    LIT(0)
    STATE
    STORE

QUIT1:
    TIB
    DUP
    TIBSIZE
    ACCEPT
    SPACE

                #-- Pila:  address longitud
    INTERPRET   #--        Numero

    #-- Leer el estado del compilador
    STATE
    FETCH #-- numero state
    

    #-- ¿Estado del compilador 0? (Interpretacion)
    ZEROEQUAL #-- Numero flag (-1 si es 0, 0 si compilacion)

    #-- Saltar si estamos en modo compilacion
    QBRANCH
    ADDR(QUIT2)

    #-- Estamos enmodo intérprete
    XSQUOTE(3," ok ")
    TYPE
    CR

QUIT2:
    #-- MODO COMPILACION
    BRANCH
    ADDR(QUIT1)


#-------------------------------------------------------
# ABORT    i*x --   R: j*x --   clear stk & QUIT
#  S0 SP!  QUIT ;
#--------------------------------------------------------
.global do_abort
do_abort:
    DOCOLON

    S0
    SPSTORE

    # QUIT    #-- Quit never returns (TODO)

    EXIT


# ========== OTHER OPERATIONS ==============================

#-------------------------------------------------------
#  DEPTH    -- +n        number of items on stack
#   SP@ S0 SWAP - 2/ ;   16-BIT VERSION!
#--------------------------------------------------------
.global do_depth
do_depth:
    DOCOLON

    SPFETCH
    S0
    SWOP
    MINUS
    TWOSLASH
    TWOSLASH

    EXIT

#-------------------------------------------------------
#  ENVIRONMENT?  c-addr u -- false   system query
#                         -- i*x true
#   2DROP 0 ;       the minimal definition!
#--------------------------------------------------------
.global do_environmentq
do_environmentq:
    DOCOLON

    #-- Eliminar parametros de entrada
    TWODROP

    #-- Poner un false: No hay variables de entorno
    #- en esta implementacion
    LIT(0)

    EXIT

# ========== UTILITY WORDS AND STARTUP =====================

#----------------------------------------------------
# COLD     --      cold start Forth system
#  UINIT U0 #INIT CMOVE      init user area
#  80 COUNT INTERPRET       interpret CP/M cmd
#  ." Z80 CamelForth etc."
#  ABORT ;
#----------------------------------------------------
.global do_cold
do_cold:
    DOCOLON

    #-- Inicializar las variables de usuario
    UINIT
    U0
    NINIT
    CMOVE

    #-------------- TODO 
    #-- LIT(0X80)
    #-- COUNT
    #-- INTERPRET

    XSQUOTE(35, "Z80 CamelForth v1.01  25 Jan 1995\n\r")
    TYPE
    #-- ABORT  (TODO)

    EXIT

# ============= COMPARISON OPERATIONS =========================

#-----------------------------------------------------
#  <>     x1 x2 -- flag    test not eq (not ANSI)
#-----------------------------------------------------
.global do_notequal
do_notequal:
	DOCOLON

	EQUAL
    ZEROEQUAL

	EXIT

#-----------------------------------------------------
#  U>    u1 u2 -- flag     u1>u2 unsgd (not ANSI)
#-----------------------------------------------------
.global do_ugreater
do_ugreater:
	DOCOLON

    SWOP
    ULESS

    EXIT

# =============== DEFINING WORDS ================================

#-----------------------------------------------------
#   VARIABLE   --      define a Forth variable
#    CREATE 1 CELLS ALLOT ;
#  Action of RAM variable is identical to CREATE,
#  so we don't need a DOES> clause to change it.
#-----------------------------------------------------
.global do_variable
do_variable:
	DOCOLON

	CREATE
    STORCOLON
    STORVAR

	EXIT

#-----------------------------------------------------
#  CONSTANT   n --      define a Forth constant
#   CREATE , DOES> (machine code fragment)
#-----------------------------------------------------
.global do_constant
do_constant:
	DOCOLON

	CREATE
    STORCOLON
    STORCON

	EXIT