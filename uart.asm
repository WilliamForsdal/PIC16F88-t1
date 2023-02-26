

; Transmit what's in the W reg, return when complete.
uart_tx:
    BANKSEL     TXSTA
    ; Wait for prev tx complete
_uart_tx_wait:
    btfss       TXSTA, 1
    goto        _uart_tx_wait
    ; Start tx
    BANKSEL     TXREG
    MOVWF       TXREG ; starts tx
    retlw       0

; RX uart byte and store in W.
uart_rx:
    BANKSEL     PIR1
    ; MOVLW       0xaa
    ; RETURN

_uart_rx_wait:
    btfss       PIR1, 5
    goto        _uart_rx_wait
    MOVF        RCREG, W
    ; MOVLW       0xaa
    RETURN ; w has value now