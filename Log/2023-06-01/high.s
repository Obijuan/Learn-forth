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
do_toin:
    DOUSER
    DW(0x4)

#-------------------------------------------------------------
#  BASE    -- a-addr       holds conversion radix
#  8 USER BASE
#-------------------------------------------------------------
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
do_dp:
    DOUSER
    DW(0x10)

#-------------------------------------------------------------
#  'source  -- a-addr      two cells: len, adrs
# 0x14 USER 'SOURCE
#-------------------------------------------------------------
do_ticksource:
    DOUSER
    DW(0x14)

#-------------------------------------------------------------
# latest    -- a-addr     last word in dict.
#  0x1C USER LATEST
#-------------------------------------------------------------
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


#----------------------------------------------------
#-- 2DUP   x1 x2 -- x1 x2 x1 x2   dup top 2 cells
#   OVER OVER ;
#----------------------------------------------------
do_twodup:
	DOCOLON
	OVER
	OVER
	EXIT

#----------------------------------------------------
#  2DROP  x1 x2 --          drop 2 cells
#   DROP DROP ;
#----------------------------------------------------
do_twodrop:
    DOCOLON

    DROP
    DROP
    
    EXIT

#=========== ARITHMETIC OPERATORS ==========================

#----------------------------------------------------
# ?NEGATE  n1 n2 -- n3  negate n1 if n2 negative
#   0< IF NEGATE THEN ;        ...a common factor
#----------------------------------------------------
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
do_abs: 
    DOCOLON

    DUP
    QNEGATE

    EXIT







#----------------------------------------------------
#-- BL      -- char            an ASCII space
#----------------------------------------------------
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
#--  #init    -- n    #bytes of user area init data
#----------------------------------------------------
.global do_ninit
do_ninit:
  DOCON
  DW(36)  #-- 9 palabras (de 4 bytes)


#------------------------- PRUEBAS ------------------------------------------

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
	
#--- HOME: Llevar el cursor a HOme
do_home:
        #-- Guardar direccion de retorno
	PUSH_RA
	
	LIT(27)
	EMIT
	LIT(91)
	EMIT
	LIT(72)
	EMIT
	
	#-- Recuperar direccion de retorno
	POP_RA
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
do_greater:
	DOCOLON

	SWOP
	LESS

	EXIT

#-----------------------------------------------------
#  TUCK   x1 x2 -- x2 x1 x2     per stack diagram
#-----------------------------------------------------
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
do_charplus:
  j do_oneplus


# ================== INTERPRETER ===================================
# Note that NFA>LFA, NFA>CFA, IMMED?, and FIND
# are dependent on the structure of the Forth
# header.  This may be common across many CPUs,
# or it may be different.

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





#===================================================================
#=              INCOMPLETOS.... TO-DO
#===================================================================

# ================== INTERPRETER ===================================
# Note that NFA>LFA, NFA>CFA, IMMED?, and FIND
# are dependent on the structure of the Forth
# header.  This may be common across many CPUs,
# or it may be different.

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

    #-- INTERPRET (TODO)
    STATE
    FETCH
    ZEROEQUAL
    QBRANCH
    ADDR(QUIT2)
    #CR
    XSQUOTE(3,"ok ")
    TYPE
    CR

QUIT2:
    BRANCH
    ADDR(QUIT1)
    
    EXIT


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