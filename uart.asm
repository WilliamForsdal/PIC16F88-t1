
; Transmit what's in the W reg, return when complete.
uart_tx:
    BANKSEL     TXSTA
_uart_tx_wait: 
    ; Wait for prev tx complete
    btfss       TXSTA, 1
    goto        _uart_tx_wait
    
    ; Start tx
    BANKSEL     TXREG
    MOVWF       TXREG ; starts tx
    retlw       0



; RX uart byte and store in W.
uart_rx:
    BANKSEL     PIR1
_uart_rx_wait:
    btfss       PIR1, 5
    goto        _uart_rx_wait
    MOVF        RCREG, W
    RETURN ; w has value