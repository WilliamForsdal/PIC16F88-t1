

from yaml import load, dump
try:
    from yaml import CLoader as Loader, CDumper as Dumper
except ImportError:
    from yaml import Loader, Dumper



yaml_config = """
regs:
    global_regs: # F0h-FFh
      - CRC # Stores crc working value
      - CRC_BYTE # current byte being calculated
      - CRC_BIT_ITER # iterator
      - CRC_BYTE_ITER # iterator

      # interrupt temp vars
      - W_TEMP
      - PCLATH_TEMP
      - STATUS_TEMP
      - UART_RX # save last UART rx byte here.

    bank0:
        # bank0 regs, from 0x20 to 0x6F
    bank1:
        # bank1 regs, from 0xA0 to 0xEF
    bank2:
        # bank2 regs, from 0x110 to 0x16F
    bank3:
        # bank3 regs, from 0x190 to 0x1EF

"""


def main():
    s = yaml_config
    ret = "// Autogen \n"
    ret += "// gr: Global register (0x70-0x7F)\n"
    data = load(s, Loader=Loader)
    reg_idx = 0x70 # global regs start at 0x70, end at 0x7f
    for r in data["regs"]["global_regs"]:
        ret += f"#define {r:20}    0x{reg_idx:2x}\n"        
        reg_idx += 1
        if reg_idx > 0x7f:
            raise Exception("Too many global regs!")

    with open("regdefs.h", "w") as fh:
        fh.write(ret)

main()