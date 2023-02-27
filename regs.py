
from yaml import load, dump
try:
    from yaml import CLoader as Loader, CDumper as Dumper
except ImportError:
    from yaml import Loader, Dumper


def main():
    s = open("regs.yaml").read()
    ret = "// Autogen \n"
    ret += "// gr: Global register (0x70-0x7F)\n"
    data = load(s, Loader=Loader)
    reg_idx = 0x70 # global regs start at 0x70, end at 0x7f
    for r in data["regs"]["global_regs"]:
        ret += f"#define gr_{r:20}    0x{reg_idx:2x}\n"        
        reg_idx += 1
        if reg_idx > 0x7f:
            raise Exception("Too many global regs!")

    with open("regdefs.h", "w") as fh:
        fh.write(ret)

main()