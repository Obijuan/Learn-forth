#------------------------------------
#- Macros for the High level words
#------------------------------------

.macro U0
	jal do_u0
.end_macro

.macro TICKSOURCE
	jal do_ticksource
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

.macro ABORT
	jal do_abort
.end_macro

.macro ACCEPT
	jal do_accept
.end_macro

.macro QUIT
	jal do_quit
.end_macro

.macro COLD
	jal do_cold
.end_macro

