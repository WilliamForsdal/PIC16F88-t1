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


#define FLETCHER16_INIT()     CLRF        FCS_1 \
                              CLRF        FCS_2


#define PKT_MAX_LEN 0x4F //(0x70-0x20-1)


#define CMD_PING            0x01

#define CMD_WRITE_EEPROM    0x11
#define CMD_READ_EEPROM     0x12



#define CMD_READ_GPIO       0x20
#define CMD_UNKNOWN         0xFF


