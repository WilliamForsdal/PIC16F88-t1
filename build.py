import os
import subprocess

from yaml import load, dump
try:
    from yaml import CLoader as Loader, CDumper as Dumper
except ImportError:
    from yaml import Loader, Dumper



yaml_config = """
regs:
    global_regs: # F0h-FFh
    #   - CRC # Stores crc working value
    #   - CRC_BYTE # current byte being calculated
    #   - CRC_BIT_ITER # iterator
    #   - CRC_W_TEMP # Save W and restore it after crc?

      - FCS_1
      - FCS_2

      # packet handler byte counter
      - PKT_BYTE_ITER

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

def gen_cfg():
    s = yaml_config
    ret = "// Autogen \n"
    ret += "// gr: Global register (0x70-0x7F)\n"
    data = load(s, Loader=Loader)
    reg_idx = 0x70 # global regs start at 0xF0?, end at 0xFf?
    for r in data["regs"]["global_regs"]:
        ret += f"#define {r:20}    0x{reg_idx:2x}\n"        
        reg_idx += 1
        if reg_idx > 0xFf:
            raise Exception("Too many global regs!")

    with open("regdefs.h", "w") as fh:
        fh.write(ret)

def main():
    try:
        os.mkdir("obj")
    except:
        pass
    

    gen_cfg()

    # description of args to pic-as:
    # pic-as is the MPLABS assembly compiler. It also calls the linker to create the final hex-file (intel hex format).
    
    # -mcpu:                    which target device
    # -o:                       kinda output dir but not exactly
    # -xassembler-with-cpp:     allows cpp preprocessor to run before assembler, can use // comments etc.
    # -Xlinker:                 arg following this will be passed to the linker
    # -p______=x:               specify where the psect should be placed in memory.
    # ./main.asm                which file to compile

    for target in ["main"]:
        file = f"./{target}.asm"
        args = " ".join([
            "-mcpu=16F88",
            f"-o\"obj/{target}.hex\"",
            "-xassembler-with-cpp",
            "-Xlinker",
            "-prstVector=0",
            "-Xlinker",
            "-pcode=2",
            file,
        ])
        call = f"{'pic-as.exe'} {args}"
        print (call)
        print(subprocess.call(call))

    for f in [os.path.join("obj", f) for f in os.listdir("obj") if os.path.isfile(os.path.join("obj", f)) if not f.endswith("hex")]:
        try:
            os.remove(f)
        except:
            print("Failed to remove file " + f)





if __name__ == "__main__":
    print("main")

    main()