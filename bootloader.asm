
rx_pkt:
    BANKSEL     PORTA
    ; Set FSR to rx new pkt.
    movlw       0x20 ; Bank 1 first gpreg
    MOVWF       FSR
    CRC_INIT() ; Clear CRC
_rx_pkt_preamble:
    call        uart_rx
    XORLW       0xFF
    IF_NOT_ZERO
    goto _rx_pkt_preamble
_rx_pkt_consume_preambles:
    call        uart_rx
    XORLW       0xFF
    IF_ZERO
    goto        _rx_pkt_consume_preambles
    ; Got first byte here. Now calc crc and rx next bytes.
; rx length byte:
    XORLW       0xFF ; Xor with FF again to get the original value back :)
    MOVWF       INDF
    MOVWF       PKT_BYTE_ITER ; save length here for later
    INCF        FSR, F
    call        crc8    ; update CRC

_rx_pkt_data:
    call        uart_rx
    MOVWF       INDF
    INCF        FSR, F
    call        crc8    ; update crc
    DECFSZ      PKT_BYTE_ITER, F
    goto        _rx_pkt_data
_rx_pkt_end:
    call        crc8_finalize
    return      ; Caller can check if zero after return
    



handle_pkt:
    BANKSEL     PORTA
    CRC_INIT() ; Clear CRC
    movlw       0x21 ; Bank 1 first gpreg
    MOVWF       FSR

    ; PING
    MOVLW       CMD_PING
    XORWF       INDF, W
    IF_BIT_SET  STATUS, ZERO
    goto        _handle_pkt_ping

    ; ; CMD_READ_PORTA
    ; MOVLW       CMD_READ_PORTA
    ; XORWF       INDF, W
    ; IF_BIT_SET  STATUS, ZERO
    ; goto        _handle_pkt_read_port

    ; ; CMD_READ_PORTB
    ; MOVLW       CMD_READ_PORTB
    ; XORWF       INDF, W
    ; IF_BIT_SET  STATUS, ZERO
    ; goto        _handle_pkt_read_port

    ; UNKNOWN CMD
    MOVLW       CMD_UNKNOWN
    call        uart_tx
    MOVF        INDF, W
    call        uart_tx
    MOVLW       CMD_UNKNOWN
    call        uart_tx
    return


; ----------------------------
; PING
; ----------------------------
_handle_pkt_ping:
    CRC_INIT() ; Clear CRC
    TP_ON()
    TP_OFF()
    ; store length in PKT_BYTE_ITER:
    movlw       0x20 ; Bank 1 first gpreg
    MOVWF       FSR
    MOVF        INDF, W
    INCF        FSR, F
    call        uart_tx
    call        crc8
    MOVWF       PKT_BYTE_ITER
    DECF        PKT_BYTE_ITER, F
    ; Handle tx all bytes except CRC here
_handle_pkt_ping_loop:
    MOVF        INDF, W
    call        uart_tx
    call        crc8
    INCF        FSR, F
    DECFSZ      PKT_BYTE_ITER, F
    goto        _handle_pkt_ping_loop

    ; now send our calculated CRC.
    call        crc8_finalize
    call        uart_tx

    return

;
; CMD_READ_PORTA
;
_handle_pkt_read_port:
    movlw       0x20 ; Bank 1 first gpreg
    MOVWF       FSR
    MOVF        INDF, W
    call        uart_tx 
    call        crc8

    ; tx len
    movlw       2
    call        uart_tx 
    call        crc8

    BANKSEL     PORTA
    btfss       INDF, 0 ; 0 for PORTA, 1 for PORTB
    MOVF        PORTA, W
    btfsc       INDF, 0 ; 0 for PORTA, 1 for PORTB
    MOVF        PORTB, W

    call        uart_tx 
    call        crc8
    call        crc8_finalize
    call        uart_tx 
    return
