( addr -- flag )
( flag: -1: Dir alineada )
( flag:  0: Dir no alineada )
: ?ALIGN 

    ( Obtener los 2 bits de menor peso )
    ( Estos determinan si es una direccion alineada )
    ( o no:   bits == 00: Alineada )

  3
  and   ( Obtener los 2 bits de menor peso)
  0=    ( Es 0?)
  IF
    0 invert  ( Dir alineada: Dejar -1 )
  ELSE
    0  ( Dir no alineada: Dejar 0 )
  THEN
;


( addr1 -- addr2 )
( Convertir addr1 en una direccion alineada addr2 )
( Si ya esta alineada se quea como esta: addr2 = addr1 ) 
: align 
  dup ?align 
  invert IF 
    ( Sumar 4)
    4 +

    ( Poner a 0 los 2 bits de menor peso )
    3 invert
    and
  THEN 
;

