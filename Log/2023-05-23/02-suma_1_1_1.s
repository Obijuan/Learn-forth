#--------------------------------------------------------------------
#-- INTERPRETE DE FORTH. Version 1
#--
#--  Implementación en ensamblador del programa Forth:
#--  1 1 1 + + .
#--
#-- El resultado se imprime en la consola del simulador
#-- Una vez completado, termina
#--------------------------------------------------------------------

	#-- Servicios del sistema operativo
	.eqv PRINT_INT 1
	.eqv PRINT_STRING 4
	.eqv EXIT 10
	
	.text

	#-- Inicializar la pila
	la sp, stack

	#-- Programa Forth: 1 1 1 + + .
	jal do_1
	jal do_1
	jal do_1
	jal do_add
	jal do_add
	jal do_point
			
	#-- Interprete de forth: Imprimir " ok"
	la a0, ok_msg
	li a7, PRINT_STRING
	ecall
	
	#-- Terminar
	li a7,EXIT
	ecall
		
#----------------------------------------------------------------
#-- Implementacion de las palabras primitivas
#----------------------------------------------------------------			
					
#---------------
#-- Palabra 1	
#--
#-- Meter 1 en la pila (PUSH 1)
#---------------

do_1:
        #-- Crear espacio en la pila para un byte
	addi sp,sp,-1
	
	#-- Guardar el 1 en la pila
	li t0, 1
	sb t0, 0(sp)
	
	#-- Hemos terminado
	ret
	
#---------------
#-- Palabra +
#--
#-- Obtener los dos ultimos elementos de la pila,
#-- sumarlos y depositar el resultado en la pila
#---------------
do_add:

	#-- Leer el primer elemento
	lb t0, 0(sp)
	addi sp,sp,1
	
	#-- Leer segundo elemento
	lb t1, 0(sp)
	addi sp,sp,1
	
	#-- Realizar la suma
	add t0, t0,t1
	
	#-- Guardar resultado en la pila
	addi sp,sp,-1
	sb t0, 0(sp)
	
	#-- Hemos terminado
	ret
	
#-------------------------
#-- Palabra .
#--
#-- Sacar el ultimo elemento de la pila e
#-- imprimirlo
#-------------------
do_point:
	
	#-- Sacar el elemento de la pila
	lb t0, 0(sp)
	addi sp,sp,1
	
	#-- Imprimirlo
	mv a0, t0
	li a7, PRINT_INT
	ecall
	
	ret
	
	
#---------------------------------
#-- SEGMENTO DE DATOS
#---------------------------------	
	.data
	
   #-----------------------
   #-- PILA
   #----------------------	
	.space 4
stack:

    #---- Mensajes del interprete
ok_msg: .string "  ok\n"


