\--- Desensamblador para RV

." -- DASM-RV " CR 

\-- 0x Palabra para introducir numero en hexadecimal
: 0x HEX WORD NUMBER 0<> IF ." Error" CR THEN DECIMAL ;

\-- Mascara para obtener el codigo de operacion
0x 7F CONSTANT OPCODE_MASK
0x 1F CONSTANT REG_MASK     \-- Mascara para registros
   7  CONSTANT RD_POS       \-- Posicion del campo RD
   7  CONSTANT FUNC3_MASK   \-- Mascara para FUNC3
   12 CONSTANT FUNC3_POS    \-- Posicion del campo FUNC3
   

\-- Obtener el campo RD del codigo maquina
\-- ( x -- x )
: >RD 
   REG_MASK RD_POS LSHIFT   \--     |...| rd   | .. |
                            \--          <Mask>     
   AND  \-- Aislar el campo RD             rd
   RD_POS RSHIFT            \--                    rd
;                           \-- Desplazarlo a la derecha

\-- Obtener el campo FUNC3 del codigo maquina
\-- ( x -- x)
: >FUNC3
  FUNC3_MASK FUNC3_POS LSHIFT
  AND
  FUNC3_POS RSHIFT
;

\-- Instruccion de prueba: addi x1, x0, 1  (Tipo I)
\-- | imm (12) | rs1 | func3 | rd | opcode |
0x 00100093

HEX

\-- TEST
." Instruccion: " DUP . CR
." Opcode     : " DUP OPCODE_MASK AND . CR
." RD         : x" DUP >RD . CR 
." FUNC3      : " DUP >FUNC3 . CR 





