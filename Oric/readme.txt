** dflat for Oric readme **

All the files needed to assemble dflat are here.

For Quick Start
---------------
1) Go to the emulator folder
2) Run oricutron.exe
3) The emulator will start with Oric dflat as the default
4) Try a game
4.1) Hit F1 on PC and press 'T'
4.2) At the file dialog, navigate to software/dflat/games and select any .tap file
4.3) type : tload "tetris.tap"
4.4) Oric will load the program
4.5) type : _start()
4.6) Turn *off* music by pressing left cursor!
     Press space to play
	 Left and Right cursor move left and right
	 Down cursor rapidly drops the shape
	 Space rotates the shape clockwise
	 On highscore table, Up/Down changes the initial, right moves to next,
	 space is done.
	 Enjoy (hopefully!)

See the emulator section for more information.


File structure
--------------

./				: Root folder for the repo
- Oric			: Folder containing Oric version of dflat
- readme.txt	: This file

./Oric
- dflat			: dflat source code and build scripts
- emulator		: Oricutron emulator files plus dflat ROM
- software		: dflat program source and build scripts for Oric
- util			: Utility programs for PC to Oric and vice-versa
- vsc-lang 		: Folder containing Syntax highlighting of dflat in vscode

./Oric/vsc-lang
- dflat_programming_language
                : copy this folder to your .vscode/extensions folder to get
				: syntax highlighting for dflat in VSC

./Oric/dflat
- make.ps1		: Poweshell script  to assemble the source and generate the binaries
				  The dflat.rom is copied to the roms folder of the emulator.
				  This script now also builds a LOCI version of dflat.
- as65.exe,.man	: as65 6502 macro assembler - allowed to be distributed with .man file
- bank			: dflat for Oric is a single bank of ROM, so only bank0 includes
- cia			: 6522 handling code
- dflat			: Main dflat language tokenisation and runtime code
- file			: File handling for tape, sd-card and now LOCI mass storage
- inc			: Incude files for some definitions etc.
- io			: Simple I/O handler (redirect input and output to required devices)
- kernel		: Power-on / reset and interrupt handling plus low-level routines
- keyboard		: keyboard handling
- monitor		: Simple command line monitor
- rom			: 16KB ROM images of standard and LOCI dflat plus 64KB image for EEPROM
- sound			: Sound handling
- utils			: Utility routines e.g. maths
- vdp			: Graphics handling

dflat software
--------------
The ./Oric/software folder contains files to create dflat programs and make them loadable
on a real Oric.
dflat program and data files can be created on PC using a regular editor including VSC
(which has syntax highlighting support) and then minimially converted to allow them to
be loaded on the Oric.
Basically any text file with .prg is converted into .tap file and any other type of file
is converted but maintainig the extension. The need for programs needing to have a '.tap'
extension is to keep the Oricutron emulator happy but also any converted files maintain
some low level structures hence why one cannot simply load a dflat .prg file without
conversion.
To make it easy, a build script regenerated the destination files based on all source
and only takes seconds to do (less than 5 on my PC).

- dfdata		: Source files in raw form (e.g. images converted from jpg)
- dflat			: All dflat software and data files for use on an emulated or real Oric.
- sd-src		: All source software and data files (when editing on PC)
- make.ps1		: Powershell script that takes all files in sd-src and converts them as
				  either dflat (.prg) programs or binary (any other exension).  All
				  converted files are copied to the dflat folder, maintaining the folder
				  structure of sd-src.
				  Assumes ./Oric/util/bin exists for conversion utilities


Emulator
--------
The ./Oric/emulator folder hosts the Oricutron emulator.  All folders and files are
standard emulator files except the ones described here.

./Oric/emulator
oricutron.cfg	: updated configuration file which starts dflat by default

./Oric/emulator/roms
dflat.pch		: patch file required by oricutron for file load/save
dflat.rom		: rom file used by emulator - copied here by the make.ps1 script
                  here

Starting the emulator is straightforward:
a. Naviate to ./Oric/emulator folder
b. Enter './oricutron' to start the emulator
c. Hit F1 and then 'T' to select a tape
d. Navigate to a folder in the ./Oric/software/dflat folder that has .TAP files
e. Using tload with the filename to load programs.


File utilities
--------------
The ./Oric/util folder contains  utilities are to convert between formats used by the emulator,
a text editor and a real Oric.  Built in gcc with a Powershell make script.

- bin			: Executable files for the utilities, copied here by the build script.
				  This folder is assumed by the software build script.
- dftap2txt		: Takes a TAP file format as input and extracts the body as text
				  to allow editing in a PC text editor.
				  Usage : dftap2txt [-l] <source> <destination>
				  Where	: [-l] option supresses line numbers in output file
				          <source> is the file to be read in TAP format
						  <destination> is the file to be written in text format
- dftap2wav		: Takes a TAP file format as input and creates a WAV file that can
				  be loaded on a real Oric through the cassette interface.
				  Usage : dftap2wav [-b] [-dX] [-8|-11] [-a] <source> <destination>
				  Where : -b denotes a binary file with short interblock gaps
						  -dX allows custom interblock gap
						  -8 selects 8KHz sample rate
						  -11 select 11KHz sample rate (default)
						  -a finishes the file with some silence
- dftxt2tap		: Takes a text file format as input and generates a TAP file to
				  allow dflat programs to be edited in a PC text editor and then
				  loaded in to oricutron (then use dftap2wav to use on real Oric)
				  Usage : dftxt2tap [-l] <source> <destination>
				  Where : -l[N] prepends line numbers to the generated files,
				          starting at N and incrementing by 10 (default=10)
						  <source> is the file to be read in TAP format
						  <destination> is the text file to be written
- dfbin2tap		: Takes a binary file format as input and generates a TAP file to
				  allow dflat to load binary data (e.g. to display a screen image).
				  The default start address is 0xa000 (start of Oric HIRES screen)
				  but binary files can be loaded into other parts of memory as
				  required by using the appropriate parameters in the bload command.
				  Usage : dfbin2tap <source> <destination>
- make.ps1		: Powershell build script and assumes gcc installed
