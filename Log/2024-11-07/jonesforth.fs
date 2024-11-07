\ Division /
\ (a b -- a/b ) 
: / /MOD SWAP DROP ;

\ Palabra MOD
\ (a b -- a mod b)
: MOD /MOD DROP ;

\ Definir alcunas CONSTANTES de caracteres
: '\n' 10 ;
: BL   32 ; \ BL (BLank) es la palabra FORTH standard para el espacio

