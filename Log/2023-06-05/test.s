#---------------------------------------------------------
#---- Palabras para hacer pruebas del kernel minimo
#---- de Camelforth
#---------------------------------------------------------
    .include "macroCPU.h"
    .include "primitives.h"

    .globl do_swab, do_lo, do_hi, do_tohex, do_dothh, do_dotb, do_dota
    .globl do_dump, do_zquit

    .text

#-------------------------------------------------
#-- ><   u1 -- u2    swap the bytes of TOS
#-------------------------------------------------
do_swab:

	#-- Leer el TOS
    POP_T0

    #-- Nos quedamos solo con los 16-bits de menor
    #-- peso (el resto los ponemos a cero)
    li t1, 0xFFFF
    and t0,t0,t1

    #----- Meter en t1 el byte alto
    srli t1,t0,8

    #-- Dejar en t0 el byte bajo
    andi t0,t0,0xFF

    #-- Desplazar a la izquierda el byte bajo (para darle peso)
    slli t0,t0,8

    #-- Componer la nueva palabra (con los bytes ya cambiados)
    or t0,t0,t1
    
    #-- Meterla en la pila
    PUSH_T0
    
	ret

#-------------------------------------------------
#-- LO   c1 -- c2    return low nybble of TOS
#-------------------------------------------------
do_lo:

	#-- Leer el TOS
    POP_T0

    andi t0,t0,0xF
    
    #-- Meterla en la pila
    PUSH_T0
    
	ret

#-------------------------------------------------
#-- HI   c1 -- c2    return high nybble of TOS
#-------------------------------------------------
do_hi:

	#-- Leer el TOS
    POP_T0

    #-- Aislar el nibble (resto de bits a 0)
    andi t0,t0,0xF0

    #-- Desplazarlo a la derecha 4 bits
    srli t0,t0,4
    
    #-- Meterlo en la pila
    PUSH_T0
    
	ret

#-------------------------------------------------
#-- >HEX  c1 -- c2    convert nybble to hex char
#-------------------------------------------------
do_tohex:

	#-- Leer el TOS
    POP_T0

    li t1, 10
    blt t0, t1, numeric

    #-- El nibble es A-F
    #-- Hay que sumar 55 para convertirlo a caracter
    addi t0, t0, 55
    j end_tohex

    #-- El nibble es 0-9
numeric:

    #-- Hay que sumar 48
    addi t0,t0, 48
    
end_tohex: 
    #-- Meterlo en la pila
    PUSH_T0
    
	ret

#-------------------------------------------------
#--  .HH   c --       print byte as 2 hex digits
#-- NIVEL SUPERIOR (NO PRIMITIVA)
#--   DUP HI >HEX EMIT LO >HEX EMIT ;
#-------------------------------------------------
do_dothh:
    #-- Guardar direccion de retorno en la pila r
	PUSH_RA
	
	DUP
    HI
    TOHEX
    EMIT
    LO
    TOHEX
    EMIT
	
	#-- Recuperar la direccion de retorno de la pila r
	POP_RA

	#-- Devolver control
	ret	

#-------------------------------------------------
#--  .HH   c --       print byte as 2 hex digits
#-- NIVEL SUPERIOR (NO PRIMITIVA)
#--   DUP C@ .HH 20 EMIT 1+ ;
#-------------------------------------------------
do_dotb:

    #-- Guardar direccion de retorno en la pila r
	PUSH_RA
	
	DUP
    CFETCH
    DOTHH
    LIT(0x20)
    EMIT
    ONEPLUS
	
	#-- Recuperar la direccion de retorno de la pila r
	POP_RA

	#-- Devolver control
	ret	

#-------------------------------------------------
#--  .A   u --       print unsigned as 4 hex digits
#-- NIVEL SUPERIOR (NO PRIMITIVA)
#--   DUP >< .HH .HH 20 EMIT ;
#-------------------------------------------------
do_dota:

    #-- Guardar direccion de retorno en la pila r
	PUSH_RA
           #-- Ejemplo: u = 0xABCD
    DUP    #-- 0xABCD 0xABCD
    SWAB   #-- 0xABCD 0xCDAB
    DOTHH  #-- 0xABCD (prints AB)
    DOTHH  #--  (prints CD)
    LIT(0x20)
    EMIT
	
	#-- Recuperar la direccion de retorno de la pila r
	POP_RA

	#-- Devolver control
	ret	

#-------------------------------------------------
#-- ;X DUMP   addr u --      dump u locations at addr
#-- NIVEL SUPERIOR (NO PRIMITIVA)
#-- ;   0 DO
#-- ;      I 15 AND 0= IF CR DUP .A THEN
#-- ;      .B
#-- ;   LOOP DROP ;
#-------------------------------------------------
do_dump:

   #-- Internal code fragment
   DOCOLON

   #-- New high level Thread
    
    LIT(0)
    XDO
dump2:
      II
      LIT(15)
      LAND
      ZEROEQUAL
      QBRANCH
      ADDR(dump1)
      #CR
      LIT(10)
      EMIT
      LIT(13)
      EMIT
      DUP
      DOTA
dump1:
      DOTB
    XLOOP
    ADDR(dump2)
    DROP

    # CR
    LIT(10)
    EMIT
    LIT(13)
    EMIT
	
	EXIT

#-------------------------------------------------
#-- ZQUIT   --    endless dump for testing
#--   0 BEGIN  0D EMIT 0A EMIT  DUP .A
#--       .B .B .B .B .B .B .B .B
#--       .B .B .B .B .B .B .B .B
#--   AGAIN ;
#-------------------------------------------------
do_zquit:

    #-- Guardar direccion de retorno en la pila r
	PUSH_RA

    LIT(0)
zquit1:
    LIT(0xD)
    EMIT
    LIT(0xA)
    EMIT
    DUP
    DOTA
    DOTB
    DOTB
    DOTB
    DOTB
    DOTB
    DOTB
    DOTB
    DOTB
    DOTB
    DOTB
    DOTB
    DOTB
    DOTB
    DOTB
    DOTB
    DOTB
    BRANCH
    ADDR(zquit1)

    #-- Recuperar la direccion de retorno de la pila r
	POP_RA

	#-- Devolver control
	EXIT
