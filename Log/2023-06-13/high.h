#------------------------------------
#- Macros for the High level words
#------------------------------------

.macro U0
	jal do_u0
.end_macro

.macro TICKSOURCE
	jal do_ticksource
.end_macro

.macro SOURCE
	jal do_source
.end_macro

.macro NINIT
	jal do_ninit
.end_macro

.macro TWOSTORE
	jal do_twostore
.end_macro

.macro TWOFETCH
	jal do_twofetch
.end_macro

.macro TWOSWAP
	jal do_twoswap
.end_macro

.macro TWOOVER
	jal do_twoover
.end_macro

.macro DEBUG
	jal do_debug
.end_macro

.macro HERE
	jal do_here
.end_macro

.macro WORD
	jal do_word
.end_macro

.macro TOCOUNTED
	jal do_tocounted
.end_macro

.macro SLASHSTRING
	jal do_slashstring
.end_macro


.macro CMOVE
	jal do_cmove
.end_macro

.macro COUNT
	jal do_count
.end_macro

.macro CHARPLUS
	jal do_charplus
.end_macro

.macro TYPE
	jal do_type
.end_macro


	.macro XSQUOTE (%len, %str)
	  .data 
myStr: .byte %len,
       .ascii %str
	  .text
	  la a0, myStr
	  jal do_xsquote
	.end_macro

.macro UINIT
	#-- SALTO LARGO!
	la t0, do_uinit
  	jalr t0
.end_macro

.macro DOTS
	jal do_dots
.end_macro

.macro ALLOT
	jal do_allot
.end_macro

.macro COMMA
	jal do_comma
.end_macro

.macro COMMADEST
	jal do_comma
.end_macro

.macro COMMABRANCH
	jal do_comma
.end_macro

.macro COMPILE
	jal do_comma
.end_macro

.macro TOBODY
	jal do_tobody
.end_macro

.macro ABORT
	jal do_abort
.end_macro

.macro ACCEPT
	jal do_accept
.end_macro

.macro NFATOLFA
	jal do_nfatolfa
.end_macro

.macro NFATOCFA
	jal do_nfatocfa
.end_macro

.macro IMMEDQ
	jal do_immedq
.end_macro

.macro FIND
	jal do_find
.end_macro

.macro NIP
	jal do_nip
.end_macro

.macro QALIGN
	jal do_qalign
.end_macro

.macro ALIGN
	jal do_align
.end_macro

.macro QSIGN
	jal do_qsign
.end_macro

.macro DIGITQ
	jal do_digitq
.end_macro

.macro QNUMBER
	jal do_qnumber
.end_macro

.macro LITERAL
	jal do_literal
.end_macro

.macro INTERPRET
	jal do_interpret
.end_macro

.macro TONUMBER
	jal do_tonumber
.end_macro

.macro STORECF
	jal do_storecf
.end_macro

.macro COMMACF
	jal do_commacf
.end_macro

.macro CCOMMA
	jal do_ccomma
.end_macro

.macro HIDE
	jal do_hide
.end_macro

.macro REVEAL
	jal do_reveal
.end_macro

.macro LEFTBRACKET
	jal do_leftbracket
.end_macro

.macro RIGHTBRACKET
	jal do_rightbracket
.end_macro

.macro CREATE
	jal do_create
.end_macro

.macro STORCOLON
	jal do_storcolon
.end_macro

.macro STORVAR
	jal do_storvar
.end_macro

.macro STORCON
	jal do_storcon
.end_macro



.macro COLON
	jal do_colon
.end_macro

.macro SEMI
	jal do_semi
.end_macro

.macro CEXIT
	jal do_cexit
.end_macro

.macro ENVIRONMENTQ
	jal do_environmentq
.end_macro

.macro DEPTH
	jal do_depth
.end_macro

.macro WORDS
	jal do_words
.end_macro

.macro DOTWINFO
	jal do_dotwinfo
.end_macro

.macro DOTWCODE
	jal do_dotwcode
.end_macro

.macro DOTLWINFO
	jal do_dotlwinfo
.end_macro

.macro DCODE
	jal do_dcode
.end_macro

.macro NULL
	jal do_null
.end_macro

.macro QUIT
	jal do_quit
.end_macro

.macro COLD
	jal do_cold
.end_macro

.macro NOTEQUAL
  jal do_notequal
.end_macro

.macro UGREATER
  jal do_ugreater
.end_macro

.macro LINE
  jal do_line
.end_macro

.macro TEST
  jal do_test
.end_macro

.macro TEST2
  jal do_test2
.end_macro

.macro TEST3
  jal do_test3
.end_macro

.macro TEST4
  jal do_test4
.end_macro

.macro TEST5
  jal do_test5
.end_macro

.macro CJAL
  jal do_cjal
.end_macro

.macro QUOTEHI
  jal do_quotehi
.end_macro

.macro IF
  jal do_if
.end_macro

.macro THEN
  jal do_then
.end_macro

.macro ELSE
  jal do_else
.end_macro

.macro QUOTETRUE
  jal do_quotetrue
.end_macro

.macro QUOTEFALSE
  jal do_quotefalse
.end_macro

.macro TOL
  jal do_tol
.end_macro

.macro LFROM
  jal do_lfrom
.end_macro

.macro DO
  jal do_do
.end_macro

.macro ENDLOOP
  jal do_endloop
.end_macro

.macro LOOP
  jal do_loop
.end_macro

.macro SQUOTE
  jal do_squote
.end_macro

.macro DOTQUOTE
  jal do_dotquote
.end_macro

.macro EESC
  jal do_eesc
.end_macro

.macro CLS
  jal do_cls
.end_macro

.macro HOME
  jal do_home
.end_macro

.macro PAREN
  jal do_paren
.end_macro

.macro STOD
  jal do_stod
.end_macro

.macro DNEGATE
  jal do_dnegate
.end_macro

.macro QDNEGATE
  jal do_qdnegate
.end_macro

.macro DABS
  jal do_dabs
.end_macro

.macro MSTAR
  jal do_mstar
.end_macro

.macro SMSLASHREM
  jal do_smslashrem
.end_macro

.macro FMSLASHMOD
  jal do_fmslashmod
.end_macro

.macro STAR
  jal do_star
.end_macro

.macro SLASHMOD
  jal do_slashmod
.end_macro

.macro SLASH
  jal do_slash
.end_macro

.macro MOD
  jal do_mod
.end_macro

.macro SSMOD
  jal do_ssmod
.end_macro

.macro STARSLASH
  jal do_starslash
.end_macro

.macro MAX
  jal do_max
.end_macro

.macro MIN
  jal do_min
.end_macro

.macro UMIN
  jal do_umin
.end_macro

.macro UMAX
  jal do_umax
.end_macro