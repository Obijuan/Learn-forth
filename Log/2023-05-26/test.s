#---------------------------------------------------------
#---- Palabras para hacer pruebas del kernel minimo
#---- de Camelforth
#---------------------------------------------------------
.include "macros.h"

    .globl do_swab

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