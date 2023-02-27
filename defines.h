
#define CLEAR_CARRY BCF STATUS, 0

#define IF_ZERO  btfsc STATUS, 2
#define IF_IS_ZERO  btfsc STATUS, 2
#define IF_NOT_ZERO btfss STATUS, 2

#define IF_IS_CARRY btfsc STATUS, 0
#define IF_NOT_CARRY btfss STATUS, 0
