

; FSR points to data, W contains num bytes
crc8_fsr:





crc8_finalize:
    movlw       0 ; finalize by calculating one last byte, which is 0
crc8:
    BANKSEL     PORTA
    ; W holds the byte to calc, REG_ACC holds the current val
    MOVWF       gr_CRC_BYTE ; store the byte
    movlw       8
    MOVWF       gr_CRC_ITER ; loop counter: 8,7,6,5,4,3,2,1.
    
    movlw       7 ; 0b111

_crc8_loop:
    CLEAR_CARRY ; Clear carry flag before RLF
    RLF         gr_CRC, F
    IF_IS_CARRY
    goto        _crc8_carry1
    
_crc8_carry0:
    RLF         gr_CRC_BYTE, F
    IF_IS_CARRY
    BSF         gr_CRC, 0
    goto        _crc8_loop_end
    
_crc8_carry1:
    CLEAR_CARRY
    XORWF       gr_CRC, F
    RLF         gr_CRC_BYTE, F
    IF_IS_CARRY
    BCF         gr_CRC, 0

_crc8_loop_end:
    DECFSZ      gr_CRC_ITER, F
    goto        _crc8_loop
    retlw       0 ; retlw to clear W reg after.


;/**
; * \file
; * Functions and types for CRC checks.
; *
; * Generated on Mon Feb 27 07:46:36 2023
; * by pycrc v0.10.0, https://pycrc.org
; * using the configuration:
; *  - Width         = 8
; *  - Poly          = 0x07
; *  - XorIn         = 0x00
; *  - ReflectIn     = False
; *  - XorOut        = 0x00
; *  - ReflectOut    = False
; *  - Algorithm     = bit-by-bit
; */
;#include "crc.h"     /* include the header file generated with pycrc */
;#include <stdlib.h>
;#include <stdint.h>
;#include <stdbool.h>
;
;
;
;crc_t crc_update(crc_t crc, const void *data, size_t data_len)
;{
;    const unsigned char *d = (const unsigned char *)data;
;    unsigned int i;
;    bool bit;
;    unsigned char c;
;
;    while (data_len--) {
;        c = *d++;
;        for (i = 0; i < 8; i++) {
;            bit = crc & 0x80;
;            crc = (crc << 1) | ((c >> (7 - i)) & 0x01);
;            if (bit) {
;                crc ^= 0x07;
;            }
;        }
;        crc &= 0xff;
;    }
;    return crc & 0xff;
;}
;
;
;crc_t crc_finalize(crc_t crc)
;{
;    unsigned int i;
;    bool bit;
;
;    for (i = 0; i < 8; i++) {
;        bit = crc & 0x80;
;        crc <<= 1;
;        if (bit) {
;            crc ^= 0x07;
;        }
;    }
;    return crc & 0xff;
;}
;