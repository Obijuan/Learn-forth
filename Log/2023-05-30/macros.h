#------------------------------------------------
#-- MACROS
#------------------------------------------------

    #----------------------------------
	#-- LOGICA DEL INTERPRETE DE FORTH
	#----------------------------------

	#-- NEXT: Ejecutar la siguiente instruccion Forth
	#-- del hilo actual
	.macro NEXT
	  ret
	.end_macro

	#-- EXIT. Terminar una palabra de alto nivel
	# exit a colon definition
	.macro EXIT
	  #-- Recuperar la direccion de retorno de la pila r
	  POP_RA

	  #-- Devolver control
	  NEXT	
	.end_macro

	.macro EXECUTE
	  j do_execute
	.end_macro

	# ENTER, a.k.a. DOCOLON, entered by CALL ENTER
	# to enter a new high-level thread (colon def'n.)
	# (internal code fragment, not a Forth word)
	.macro DOCOLON
	    #-- Guardar direccion de retorno en la pila r
		PUSH_RA
	.end_macro

	.macro DOCON
	  PUSH_RA
	  jal docon
	.end_macro

	.macro DOVAR
	  PUSH_RA
      jal dovar
	.end_macro

	.macro DOUSER
	  PUSH_RA
	  jal douser
	.end_macro


	#-----------------------------------
	#-- DE ACCESO AL SISTEMA OPERATIVO
	#-----------------------------------
	#-- Terminar el programa
	.macro OS_EXIT
	  li a7, 10
	  ecall
	.end_macro	
	
	#-- Imprimir en la consola el registro t0
	.macro PRINT_T0
	  mv a0, t0
	  li a7, 1
	  ecall
	.end_macro
	
	#-- Imprimir el caracter que hay en T0
	.macro PRINT_CHAR_T0
	  mv a0, t0
	  li a7, 11 #-- Servicio printchar
	  ecall
	.end_macro
	
	#-- Esperar a que el usuario pulse un caracter
	#-- Se devuelve por t0
	.macro READ_CHAR_T0
	  li a7, 12
	  ecall
	  mv t0,a0
	.end_macro
	
	
	#-------------------------------------------
	#-- PARA LA IMPLEMENTACION DE LAS PRIMITIVAS
	#-- DE FORTH
	#--------------------------------------------
	
	#-- Meter un valor en la pila
	#-- PUSH (x)
	.macro PUSH (%valor)
	  li t0, %valor
	  addi sp,sp,-4
	  sw t0, 0(sp)
	.end_macro	
	
	#-- Guardar el registro t0 en la pila
	.macro PUSH_T0
	  addi sp,sp,-4
	  sw t0, 0(sp)
	.end_macro
	
	#-- Meter el elemento de la pila en T0
	.macro POP_T0
	  lw t0, 0(sp)
	  addi sp,sp,4
	.end_macro

	#-- Guardar t0 en rstack
	.macro PUSHR_T0
	  addi s0,s0,-4
	  sw t0,0(s0)
	.end_macro

	#-- Leer la Pila R en t0
	.macro POPR_T0
	  lw t0, 0(s0)
	  addi s0,s0,4
	.end_macro
	
	#-----------------------------------------------
	#-- PARA IMPLEMENTACION DE LAS INSTRUCCIONES
	#-- DE NIVELES SUPERIORES
	#-----------------------------------------------
	#-- Guardar direccion de retorno en rstack
	.macro PUSH_RA
	  addi s0,s0,-4
	  sw ra,0(s0)
	.end_macro
	
	#-- Repucerar direccion de retorno de rstack
	.macro POP_RA
	   lw ra,0(s0)
	   addi s0,s0,4
	.end_macro

	

	
	#----------------------------------------------------
	#-- PRIMITIVAS Y FUNCIONES DE ALTO NIVEL  
	#-- PARA LOS PROGRAMAS EN FORTH
	#----------------------------------------------------

	#--------- Alto nivel
	.macro HOME
	  jal do_home
	.end_macro

	.macro TEST_RFETCH
	  jal do_test_rfetch
	.end_macro

	.macro TEST_RPFETCH
	  jal do_test_rpfetch
	.end_macro

	#--------------- Primitivas

	#--- Para meter literales directamente en el codigo
	.macro DW(%val)
	  lui zero,%val
	.end_macro

	#-- Literal sin argumentos
	.macro LIT
	  jal do_lit
	.end_macro

	#-- Literal con argumentos
	.macro LIT (%val)
	   jal do_lit
	   DW(%val)
	.end_macro

	#--- Leer literal en t0
	.macro READLIT_T0
		#-- ra Contiene la dirección del LITERAL
		lw t0, 0(ra)
		#-- HACK: En realidad no es el literal exacto, esta
		#--  dentro de la instruccion lui (en los 20-bits de mayor peso)
		#-- Desplazar t0 >> 12  (12 bits a la derecha)
		srai t0,t0,12
	.end_macro

	#-- Literal direccion
	.macro ADDR(%label)
	  j %label
	.end_macro

	
	
	.macro EMIT
	  jal do_emit 
	.end_macro
	
	.macro KEY
	  jal do_key
	.end_macro
	
	.macro STORE
	  jal do_store
	.end_macro
	
	.macro PLUS
	  jal do_plus
	.end_macro
	
	.macro MINUS
	  jal do_minus
	.end_macro
	
	.macro LAND
	  jal do_and
	.end_macro

	.macro LOR
	  jal do_or
	.end_macro

	.macro LXOR
	  jal do_xor
	.end_macro

	.macro INVERT
	  jal do_invert
	.end_macro

	.macro NEGATE
	  jal do_negate
	.end_macro

	.macro ONEPLUS
	  jal do_oneplus
	.end_macro

	.macro ONEMINUS
	  jal do_oneminus
	.end_macro

	.macro TWOSTAR
	  jal do_twostar
	.end_macro

	.macro FOURSTAR
	  jal do_fourstar
	.end_macro

	.macro TWOSLASH
	  jal do_twoslash
	.end_macro

	.macro LSHIFT
	  jal do_lshift
	.end_macro

	.macro RSHIFT
	  jal do_rshift
	.end_macro

	.macro ZEROEQUAL
	  jal do_zeroequal
	.end_macro

	.macro ZEROLESS
	  jal do_zeroless
	.end_macro

	.macro EQUAL
	  jal do_equal
	.end_macro

	.macro LESS
	  jal do_less
	.end_macro

	.macro ULESS
	  jal do_uless
	.end_macro

	.macro DUP
	  jal do_dup
	.end_macro

	.macro QDUP
	  jal do_qdup
	.end_macro

	.macro DROP
	  jal do_drop
	.end_macro

	.macro SWOP
	  jal do_swop
	.end_macro

	.macro SWAP
	  jal do_swop
	.end_macro

	.macro OVER
	  jal do_over
	.end_macro

	.macro ROT
	  jal do_rot
	.end_macro

	.macro FETCH
	  jal do_fetch
	.end_macro

	.macro CFETCH
	  jal do_cfetch
	.end_macro

	.macro CSTORE
	  jal do_cstore
	.end_macro

	.macro SPFETCH
	  jal do_spfetch
	.end_macro

	.macro SPSTORE
	  jal do_spstore
	.end_macro

	.macro RFETCH
	  jal do_rfetch
	.end_macro

	.macro RPFETCH
	  jal do_rpfetch
	.end_macro

	.macro RPSTORE
	  jal do_rpstore
	.end_macro

	.macro TOR
	  jal do_tor
	.end_macro

	.macro RFROM
	  jal do_rfrom
	.end_macro

	.macro PLUSSTORE
	  jal do_plusstore
	.end_macro

	.macro BRANCH
	  jal do_branch
	.end_macro

	.macro QBRANCH
	  jal do_qbranch
	.end_macro

	.macro XDO
	  jal do_xdo
	.end_macro

	.macro XLOOP
	  jal do_xloop
	.end_macro

	.macro XPLUSLOOP
	  jal do_xplusloop
	.end_macro

	.macro II
	  jal do_ii
	.end_macro

	.macro JJ
	  jal do_jj
	.end_macro

	.macro UNLOOP
	  jal do_unloop
	.end_macro


#--------------------------------
#-- Palabras para hacer pruebas 
#--------------------------------
	.macro SWAB
	  jal do_swab
	.end_macro

	.macro LO
	  jal do_lo
	.end_macro

	.macro HI
	  jal do_hi
	.end_macro

	.macro TOHEX
	  jal do_tohex
	.end_macro

	.macro DOTHH
	  jal do_dothh
	.end_macro

	.macro DOTB
	  jal do_dotb
	.end_macro

	.macro DOTA
	  jal do_dota
	.end_macro

	.macro DUMP
	  jal do_dump
	.end_macro

	.macro ZQUIT
	  jal do_zquit
	.end_macro

	.macro BYE
	  jal do_bye
	.end_macro
	
	.macro CELL
	  jal do_cell
	.end_macro

	.macro SAVEKEY
	  jal do_savekey
	.end_macro

	.macro CELLPLUS
	  jal do_cellplus
	.end_macro

	.macro CELLS
	  jal do_cells
	.end_macro

	.macro CHARPLUS
	  jal do_charplus
	.end_macro

	.macro CHARS
	  jal do_chars
	.end_macro

	.macro UINIT
	  jal do_uinit
	.end_macro

	.macro U0
	  jal do_u0
	.end_macro

	.macro NINIT
	  jal do_ninit
	.end_macro

	.macro FILL
	  jal do_fill
	.end_macro

	.macro CMOVE
	  jal do_cmove
	.end_macro

	.macro COUNT
	  jal do_count
	.end_macro

	.macro TWODUP
	  jal do_twodup
	.end_macro

	.macro XSQUOTE (%len, %str)
	  .data 
myStr: .byte %len,
       .ascii %str
	  .text
	  la a0, myStr
	  jal do_xsquote
	.end_macro

	.macro TYPE
	  jal do_type
	.end_macro

	.macro BL
	  jal do_bl
	.end_macro

	.macro TIB
	  jal do_tib
	.end_macro

	.macro TIBSIZE
	  jal do_tibsize
	.end_macro

	.macro TOIN
	  jal do_toin
	.end_macro

	.macro BASE
	  jal do_base
	.end_macro

	.macro STATE
	  jal do_state
	.end_macro

	.macro DP
	  jal do_dp
	.end_macro

	.macro TICKSOURCE
	  jal do_ticksource
	.end_macro

	.macro LATEST
	  jal do_latest
	.end_macro

	.macro HP
	  jal do_hp
	.end_macro

	.macro LP
	  jal do_lp
	.end_macro

	.macro S0
	  jal do_s0
	.end_macro

	.macro PAD
	  jal do_pad
	.end_macro

	.macro L0
	  jal do_l0
	.end_macro

	.macro R0
	  jal do_r0
	.end_macro

	.macro TUCK
	  jal do_tuck
	.end_macro

	.macro SPACE
	  jal do_space
	.end_macro

	.macro SPACES
	  jal do_spaces
	.end_macro

	.macro CR
	  jal do_cr
	.end_macro

	.macro COLD
	  jal do_cold
	.end_macro

	.macro LESSNUM
	  jal do_lessnum
	.end_macro

	.macro UMSTAR
	  jal do_umstar
	.end_macro

	.macro UDSTAR
	  jal do_udstar
	.end_macro

	.macro UMSLASHMOD
	  jal do_umslashmod
	.end_macro

	.macro UDSLASHMOD
	  jal do_udslashmod
	.end_macro

	.macro HOLD
	  jal do_hold
	.end_macro

	.macro GREATER
	  jal do_greater
	.end_macro

	.macro TODIGIT
	  jal do_todigit
	.end_macro

	.macro NUM
	  jal do_num
	.end_macro

	







	

	
	
