
#define crc8_ACC      0xFB
#define crc8_BYTE     0xFA
#define crc8_iter     0xF9
#define CLEAR_CARRY BCF STATUS, 0

crc8_finalize:
    movlw       0 ; finalize by calculating one last byte, which is 0
crc8:
    BANKSEL     PORTA
    ; W holds the byte to calc, REG_ACC holds the current val
    MOVWF       crc8_BYTE ; store the byte
    movlw       8
    MOVWF       crc8_iter ; loop counter: 8,7,6,5,4,3,2,1.
    
    movlw       7 ; 0b111

_crc8_loop:
    CLEAR_CARRY ; Clear carry flag before RLF
    RLF         crc8_ACC, F
    IF_IS_CARRY
    goto        _crc8_carry1
    
_crc8_carry0:
    RLF         crc8_BYTE, F
    IF_IS_CARRY
    BSF         crc8_ACC, 0
    goto        _crc8_loop_end
    
_crc8_carry1:
    CLEAR_CARRY
    XORWF       crc8_ACC, F
    RLF         crc8_BYTE, F
    IF_IS_CARRY
    BCF         crc8_ACC, 0

_crc8_loop_end:
    DECFSZ      crc8_iter, F
    goto        _crc8_loop

    retlw       0 ; retlw to clear W reg after.
