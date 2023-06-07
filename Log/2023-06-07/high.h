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

.macro COLON
	jal do_colon
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

.macro NULL
	jal do_null
.end_macro

.macro QUIT
	jal do_quit
.end_macro

.macro COLD
	jal do_cold
.end_macro

