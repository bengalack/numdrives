@set ONAME=numdrives
@set OBJ_PATH=objs\
@set SRC=src\

sdasz80 -o -s -p -w -Isrc %OBJ_PATH%crt.rel %SRC%crt.s
sdasz80 -o -s -p -w -Isrc %OBJ_PATH%msx_dos_header.rel %SRC%msx_dos_header.s
sdasz80 -o -s -p -w -Isrc %OBJ_PATH%check_asm.rel %SRC%check_asm.s
sdcc -c -mz80 -Wa-Isrc -Isrc --opt-code-speed %SRC%check.c -o %OBJ_PATH%check.rel

sdcc --code-loc 0x0100 --data-loc 0 -mz80 --no-std-crt0 --opt-code-speed %OBJ_PATH%crt.rel %OBJ_PATH%msx_dos_header.rel %OBJ_PATH%check_asm.rel %OBJ_PATH%check.rel -o %OBJ_PATH%%ONAME%.ihx

MSXhex %OBJ_PATH%%ONAME%.ihx -s 0x0100 -o dska\%ONAME%.com
