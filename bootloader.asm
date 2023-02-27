
rx_pkt:
    call uart_rx
    return
;     BANKSEL     PORTA ; first bank

; _rx_pkt_preambles:
;     call        uart_rx
;     SUBLW       0xff
;     IF_NOT_ZERO
;     goto _rx_pkt_preambles

; _rx_pkt_len_cmd:
;     ; Got preambles. Now rx 2 bytes: len and cmd
;     call        uart_rx
;     MOVWF       BUF_START
;     MOVWF       REG_BYTES_LEFT
;     call        uart_rx
;     MOVWF       BUF_START+1
;     MOVF        REG_BYTES_LEFT, f
;     IF_IS_ZERO
;     goto        _rx_pkt_preambles
; _rx_pkt_data:


; _rx_pkt_end_ok:
;     retlw       0
; _rx_pkt_end_err:
;     retlw       1
    

handle_pkt: 
    CLRF        gr_CRC

_handle_pkt_loop:
    call        uart_rx
    MOVF        gr_UART_RX, F
    IF_IS_ZERO
    goto        _handle_pkt_end

    MOVF        gr_UART_RX, W
    call        crc8
    goto        _handle_pkt_loop
    
_handle_pkt_end:
    call        crc8_finalize
    MOVF        gr_CRC, W
    call        uart_tx
    return ; W holds crc

