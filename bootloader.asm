
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
    goto _rx_pkt_consume_preambles
    ; Got first byte here. Now calc crc and rx next bytes.
_rx_pkt_len_and_cmd:
    XORLW       0xFF ; Xor with FF again to get the original value back :)
    MOVWF       INDF
    INCF        FSR, F
    call        crc8    ; update CRC

    ; now rx length byte
    call        uart_rx
    MOVWF       PKT_BYTE_ITER ; save length here for later
    MOVWF       INDF
    INCF        FSR, F
    call        crc8    ; update crc

    MOVF        PKT_BYTE_ITER, F ; Check if any data
    IF_BIT_SET  STATUS, ZERO
    goto        _rx_pkt_rx_crc_finanlize_crc ; skip to end

_rx_pkt_data:
    call        uart_rx
    MOVWF       INDF
    INCF        FSR, F
    call        crc8    ; update crc
    DECFSZ      PKT_BYTE_ITER, F
    goto        _rx_pkt_data

_rx_pkt_rx_crc_finanlize_crc:
    call        uart_rx ; rx last byte (CRC)
    call        crc8
    call        crc8_finalize
    IF_BIT_SET  STATUS, ZERO
    call        uart_tx
    return      ; Caller can check if zero after return
    

handle_pkt:

    return ; W holds crc
