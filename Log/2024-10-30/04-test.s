#-- Palabras primitivas: W1 ,W2
#-- Simplemente imprimen los caracteres A y B en pantalla, respectivamente
#-- También EX para terminar

#-- El primer programa lo que hace es imprimir AB y termina

#-- Mejora: 
#-- El comportamiento es el mismo, pero ahora la instruccion para
#-- llamar a las subrutinas es SIEMPRE LA MISMA. Ejecutará
#-- una palabra u otra dependiendo de lo que valga t0
#-- t0 apunta al código ejecutable
#-- Lo interesante de esto es que t0 la inicializaremos a 
#-- partir de VARIABLES en el segmento de datos. Esto nos permitira
#-- definir el comportamiento solo desde el segmento de DATOS

    .include "so.s"

    .text

    #-- Ejecutar W1: Imprimir A
    la t0, code_W1   #-- t0: Direccion del codigo ejecutable
    jalr t0

    #-- Ejecutar W2: Imprimir B
    la t0, code_W2   #-- t0: Direccion del codigo ejecutable
    jalr t0

    #-- Ejecutar EX: Terminar
    la t0, code_EX   #-- t0: Direccion del codigo ejecutable
    jalr t0

    .text
#-----------------------
# W1: Imprimir A 
#-----------------------
code_W1:
   SO_PRINT_CHAR('A')
   ret

    .text
#-----------------------
# W2: Imprimir B 
#-----------------------
code_W2:
   SO_PRINT_CHAR('B')
   ret

    .text
#-----------------------
# EX: Terminar
#-----------------------
code_EX:
   SO_PRINT_CHAR('\n')
   SO_EXIT
