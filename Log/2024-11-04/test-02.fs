\ Probar el operador =
5 6 .S = .S DROP .S  \ Diferentes. Se deja 0 en la pila
5 5 .S = .S DROP .S  \ Iguales. Se deja 1 en la pila

\ Probar el operador <>
5 6 .S <> .S DROP .S
5 5 .S <> .S DROP .S

\ Probar el operador <  
5 6 .S < .S DROP .S  
5 4 .S < .S DROP .S

