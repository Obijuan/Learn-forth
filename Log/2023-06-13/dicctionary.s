.global enddict, lastword

#-------------------------
#-- Diccionario
#-------------------------

#-- Palabra 0
      .word 0   #-- (link) Enlace a la siguiente palabra. Esta es la última
      .byte 0   #-- No inmediato
link0:          #-- Enlace a esta palabra
      .byte 4   #-- Longitud
      .ascii "EXIT" #-- Nombre
      .word -1  #-- jal exit #-- Codigo Forth


#-- Palabra 1
    .align 2
    .word link0
    .byte 0
link1:
    .byte 3
    .ascii "lit"
    .word do_lit  #-- Direccion al codigo


#-- Palabra 2
    .align 2
    .word link1
    .byte 0
link2:
    .byte 3
    .ascii "BYE"
    .word do_bye


#-- Palabra 3
    .align 2
    .word link2
    .byte 0
link3:
    .byte 1
    .ascii "+"
    .word do_plus


#-- Palabra 4
    .align 2
    .word link3
    .byte 0
link4:
    .byte 1
    .ascii "."
    .word do_dot



#-- Palabra 5
    .align 2
    .word link4
    .byte 0
link5:
    .byte 2
    .ascii ".S"
    .word do_dots


#-- Palabra 6
    .align 2
    .word link5
    .byte 0
link6:
    .byte 3
    .ascii "NOP"
    .word do_null


#-- Palabra 7
    .align 2
    .word link6
    .byte 0
link7:
    .byte 5
    .ascii "WORDS"
    .word do_words


#-- Palabra 8: VARIABLE
    .align 2
    .word link7
    .byte 0
link8:
    .byte 1
    .ascii "A"
    .word do_a
do_a:  
     .word 0xffc40413  #-- addi s0,s0, -4
     .word 0x00142023  #-- sw ra, 0(s0)
     .word 0x004002b7  #-- li t0, 0x00400004
     .word 0x00428293
     .word 0x000280e7  #-- jalr ra,t0,0
     .word 0           #-- PARAMETRO: La variable

#-------------------------------------------
#-- Codigo a ejecutar para leer la variable
#-- almacenada en el campo de parametros
#-- 0xffc40413  #-- addi s0,s0, -4
#-- 0x00142023  #-- sw ra, 0(s0)
#-- 0x004002b7  #-- li t0, 0x00400004
#-- 0x00428293  
#-- 0x000280e7  #-- jalr ra,t0,0

#-- Palabra 9: CONSTANTE
    .align 2
    .word link8
    .byte 0
link9:
    .byte 3
    .ascii "ESC"
    .word do_esc
do_esc:  
    .word 0xffc40413  #--addi s0, s0, -4
    .word 0x00142023  #--sw ra, 0(s0)
    .word 0x004002b7  #--li t0, 0x0040001C
    .word 0x01c28293
    .word 0x000280e7  #--jalr ra,t0,0
    .word 0xCAFE  #-- CONSTANTE

#--------------------------------------------
#-- Codigo a ejecutar para leer la constante
#-- almacenada en el campo de parametros
#--  0xffc40413  #--addi s0, s0, -4
#--  0x00142023  #--sw ra, 0(s0)
#--  0x004002b7  #--li t0, 0x0040001C
#--  0x01c28293
#--  0x000280e7  #--jalr ra,t0,0

#-- Palabra 10
    .align 2
    .word link9
    .byte 0
link10:
    .byte 1
    .ascii ":"
    .word do_colon


#-- Palabra 11
    .align 2
    .word link10
    .byte 1
link11:
    .byte 1
    .ascii ";"
    .word do_semi

#-- Palabra 12
    .align 2
    .word link11
    .byte 0
link12:
    .byte 5
    .ascii "TEST5"
    .word do_test5

#-- Palabra 13
    .align 2
    .word link12
    .byte 0
link13:
    .byte 3
    .ascii "ONE"
    .word do_l1
do_l1:
    .word 0xffc40413  #--addi s0, s0, -4
    .word 0x00142023  #--sw ra, 0(s0)
    .word 0x004002b7  #--li t0, 0x0040001C
    .word 0x01c28293
    .word 0x000280e7  #--jalr ra,t0,0
    .word 1  #-- CONSTANTE

#-- Palabra 14
    .align 2
    .word link13
    .byte 0
link14:
    .byte 7
    .ascii ".WLINFO"
    .word do_dotlwinfo

#-- Palabra 15
    .align 2
    .word link14
    .byte 0
link15:
    .byte 3
    .byte 0x22  #-- Caracter "
    .ascii "HI"
    .word do_quotehi

#-- Palabra 16
    .align 2
    .word link15
    .byte 1  #-- IMMED
link16:
    .byte 2
    .ascii "IF"
    .word do_if

#-- Palabra 17
    .align 2
    .word link16
    .byte 1  #-- IMMED
link17:
    .byte 4
    .ascii "THEN"
    .word do_then

#-- Palabra 18
    .align 2
    .word link17
    .byte 1  #-- IMMED
link18:
    .byte 4
    .ascii "ELSE"
    .word do_else

#-- Palabra 19
    .align 2
    .word link18
    .byte 0
link19:
    .byte 4
    .ascii "EMIT"
    .word do_emit

#-- Palabra 20
    .align 2
    .word link19
    .byte 0
link20:
    .byte 5
    .ascii "SPACE"
    .word do_space

#-- Palabra 21
    .align 2
    .word link20
    .byte 1   #-- IMMED
link21:
    .byte 2
    .ascii "DO"
    .word do_do

#-- Palabra 22
    .align 2
    .word link21
    .byte 1   #-- IMMED
link22:
    .byte 4
    .ascii "LOOP"
    .word do_loop

#-- Palabra 23
    .align 2
    .word link22
    .byte 0
link23:
    .byte 2
    .ascii "CR"
    .word do_cr

#-- Palabra 24
    .align 2
    .word link23
    .byte 0
link24:
    .byte 4
    .ascii "TYPE"
    .word do_type

#-- Palabra 25
    .align 2
    .word link24
    .byte 1
link25:
    .byte 2
    .ascii "S"
    .byte 0x22  #-- "
    .word do_squote

#-- Palabra 26
    .align 2
    .word link25
    .byte 1
link26:
    .byte 2
    .ascii "."  #-- ."
    .byte 0x22 
    .word do_dotquote

#-- Palabra 27
 .align 2
    .word link26
    .byte 0
link27:
    .byte 4
    .ascii "EESC"
    .word do_eesc

#-- Palabra 28
 .align 2
    .word link27
    .byte 0
lastword:
link28:
    .byte 3
    .ascii "CLS"
    .word do_cls
    


#-- Fin del diccionario
.align 2
enddict: #-- Aqui comienza el codigo del usuario