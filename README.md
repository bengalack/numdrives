# numdrives - TEST & HACK
This hack can find the number of drives correctly on all msx computers with diskdrive found in openmsx20. That's 59 confirmed. Others without diskdrive report 0 drives. There might be other drivers and computers where this trick does not work.

The idea comes from looking at the drivers [reverse engineered by Arjen Zeilemaker](https://sourceforge.net/p/msxsyssrc/git/ci/master/tree/).

We utilise that there is a pattern in all drivers found in original MSX computers with _internal_ diskdrive(s)*. Here, the number of physical drives is stored in the 6th, 7th, 8th or 9th byte in their work area. We find this location as all legacy drivers put a pointer to their work area in SLTWRK.

__Caveat:__ The current hack must run as ROM file, as diskdrive should not have been in real use when we inspect data. Otherwise diskrom may have started to fill in live data in the region we scan and this will confuse our logic. We also use [H.STKE](https://www.msx.org/wiki/Develop_a_program_in_cartridge_ROM#Method_that_uses_the_hook_H.STKE) when starting up.

Batch files are made for *Windows*, but should be easy to mod for other platforms. 
Use `build_rom / runrom.bat`. Scripts are tailored for the openmsx emulator.

### Requirements
* [SDCC](https://sdcc.sourceforge.net/) v4.2 or later, is needed though, to enable C.
* [MSXHex](https://aoineko.org/msxgl/index.php?title=MSXhex), the best ihx-to-binary tool for MSX
* MSX DOS if you want to use dos-version (in `dska/`) or use rom-file in `rom/`

*) there might be an exception [here](https://sourceforge.net/p/msxsyssrc/git/ci/master/tree/diskdrvs/hb-f700p-alt/driver.mac), but I'm not sure if it is in use (it is not in use in the openmsx config at least)
