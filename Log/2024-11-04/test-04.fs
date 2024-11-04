\ Probar operando AND
240 31 .S AND .S DROP .S

\ Probar operando OR
240 15 .S OR .S DROP .S

\ Probar operando XOR
170 255 .S XOR .S DROP .S

\ Probar operando INVERT
170 .S INVERT .S DROP .S

\ Probar !
255 268697600 !   \ mem[268697600] = 255 (0x10040000)  

\ Probar @
268697600 @ .S DROP .S  \ Leer mem[268697600]

\ Probar +!
5 268697600 +! 268697600 @ .S DROP .S 

\ Probar -!
10 268697600 -! 268697600 @ .S DROP .S 

