// Status bits
#define CARRY, 0
#define ZERO, 2


#define CLEAR_CARRY BCF STATUS, 0

#define IF_ZERO  btfsc STATUS, 2
#define IF_IS_ZERO  btfsc STATUS, 2
#define IF_NOT_ZERO btfss STATUS, 2

#define IF_IS_CARRY btfsc STATUS, 0
#define IF_NOT_CARRY btfss STATUS, 0


#define IF_BIT_SET(R, B)    btfsc   R,B
#define IF_BIT_CLR(regg, bitt)    btfss   regg,bitt