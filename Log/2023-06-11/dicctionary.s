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
lastword:
link13:
    .byte 1
    .ascii "1"
    .word do_l1
do_l1:
    .word 0xffc40413  #--addi s0, s0, -4
    .word 0x00142023  #--sw ra, 0(s0)
    .word 0x004002b7  #--li t0, 0x0040001C
    .word 0x01c28293
    .word 0x000280e7  #--jalr ra,t0,0
    .word 1  #-- CONSTANTE


#-- Fin del diccionario
.align 2
enddict: #-- Aqui comienza el codigo del usuario