#---------------------------------------------
#-- Palabras de alto nivel: Creadas a partir de
#--   palabras primitivas o de alto nivel
#------------------------------------------------

	.global do_u0, do_ninit, do_count, do_twodup, do_xsquote
	.global do_type, do_bl, do_tib, do_tibsize,do_toin, do_base, do_state
	.global do_dp, do_ticksource, do_latest, do_hp, do_lp, do_s0, do_pad
	.global do_l0, do_r0

	
	.global do_add3, do_home, do_test_rfetch, do_test_rpfetch


	.include "macros.h"

	.text

# ========= SYSTEM VARIABLES & CONSTANTS ==================

#-------------------------------------------------------------
#- u0      -- a-addr       current user area adrs
#- Devolver direccion de la zona de usuario (parte inferior)
#-------------------------------------------------------------
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
do_lp:
    DOUSER
    DW(0x24)


#-------------------------------------------------------------
#  s0       -- a-addr     end of parameter stack
#-------------------------------------------------------------
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
do_l0:
    DOUSER
    DW(0x180)

#-------------------------------------------------------------
# r0       -- a-addr     end of return stack
#-------------------------------------------------------------
do_r0:	
	DOUSER
    DW(0x200)

#----------------------------------------------------
#--  #init    -- n    #bytes of user area init data
#----------------------------------------------------
do_ninit:
  DOCON
  DW(36)  #-- 9 palabras (de 4 bytes)

#----------------------------------------------------
#-- COUNT   c-addr1 -- c-addr2 u  counted->adr/len
#   DUP CHAR+ SWAP C@ ;
#----------------------------------------------------
do_count:
	DOCOLON
	DUP
	CHARPLUS
	SWOP      #-- Es swap
	CFETCH
	EXIT

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
#-- (S")     -- c-addr u   run-time code for S"
#--  R> COUNT 2DUP + ALIGNED >R  
#--  Deja en la pila la direccion de la cadena y su longitud
#----------------------------------------------------
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
do_tib:
  DOCON
  DW(0x2000)

#----------------------------------------------------
#  tibsize  -- n         size of TIB
# HEX 82 CONSTANT TIB   CP/M systems: 126 bytes
# HEX -80 USER TIB      others: below user area
#----------------------------------------------------
do_tibsize:
  DOCON
  DW(124)



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
				