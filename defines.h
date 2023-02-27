// Status bits
#define CARRY  0
#define ZERO   2


#define CLEAR_CARRY BCF STATUS, 0

#define IF_ZERO btfsc STATUS, 2
#define IF_IS_ZERO btfsc STATUS, 2
#define IF_NOT_ZERO btfss STATUS, 2

#define IF_IS_CARRY btfsc STATUS, 0
#define IF_NOT_CARRY btfss STATUS, 0

#define IF_BIT_SET     btfsc
#define IF_BIT_CLR     btfss

#define CRC_INIT()      CLRF     CRC

#define TP_ON()         BSF     PORTA, 0
#define TP_OFF()         BCF     PORTA, 0





#define CMD_PING         0x01

#define CMD_READ_PORTA   0x20
#define CMD_READ_PORTB   0x21
#define CMD_UNKNOWN      0xFF