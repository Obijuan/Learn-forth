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
lastword:
link5:
    .byte 2
    .ascii ".S"
    .word do_dots




#-- Fin del diccionario
.align 2
enddict: #-- Aqui comienza el codigo del usuario