@set ONAME=numdrives
@set OBJ_PATH=objs\rom\
@set DEFS=-DROM_OUTPUT_FILE=1 
@set SRC=src\

sdasz80 -o -s -p -w -Isrc %OBJ_PATH%crt.rel %SRC%crt.s
sdasz80 -o -s -p -w -Isrc %OBJ_PATH%msx_rom_header.rel %SRC%msx_rom_header.s
sdasz80 -o -s -p -w -Isrc %OBJ_PATH%check_asm.rel %SRC%check_asm.s
sdcc -c -mz80 -Wa-Isrc -Isrc --opt-code-speed %DEFS% %SRC%check.c -o %OBJ_PATH%check.rel

sdcc -d -mz80 --no-std-crt0 --opt-code-speed --code-loc 0x4000 --data-loc 0xC000 %OBJ_PATH%crt.rel %OBJ_PATH%msx_rom_header.rel %OBJ_PATH%check_asm.rel %OBJ_PATH%check.rel -o %OBJ_PATH%%ONAME%.ihx

@REM Building ROM file is dependent on MSXhex instead of makebin found in SDCC
@REM https://aoineko.org/msxgl/index.php?title=MSXhex
MSXhex %OBJ_PATH%%ONAME%.ihx -s 0x4000 -b 0x4000 -o rom\%ONAME%.rom