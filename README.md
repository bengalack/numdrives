# numdrives - TEST & HACK
Just a hacky test to see if we can find the number of physical drives on an MSX.

CURRENTLY NOT WORKING! Only 0 and 1 is returned.

Batch files are made for *Windows*, but should be easy to mod for other platforms. 
Use `build.bat / run.bat` for MSXDOS or `build_rom / runrom.bat`.

### Requirements
* [SDCC](https://sdcc.sourceforge.net/) v4.2 or later, is needed though, to enable C.
* [MSXHex](https://aoineko.org/msxgl/index.php?title=MSXhex), the best ihx-to-binary tool for MSX
* MSX DOS if you want to use dos-version (in `dska/`) or use rom-file in `rom/`
