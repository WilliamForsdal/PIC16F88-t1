import os
import subprocess

def main():
    try:
        os.mkdir("obj")
    except:
        pass

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