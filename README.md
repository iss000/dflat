# About Oric
I've owned the same Oric-1 since 1983 (my first computer!) and thought it was well enough known.. but apparently not!

So for the unitiated, the Oric-1 was a low cost microcomputer designed and built in the UK as a competitor to the ZX Spectrum.

For more information please see: https://en.wikipedia.org/wiki/Oric


# For the impatient (like me)!
If you want to get dflat running quickly:
* Go to the `Oric/emulator` folder
* `oricutron.exe`
* The emulator will start with Oric dflat as the default

In dflat, try a game
* Hit F1 on PC and press 'T'
* At the file dialog, navigate to `software/dflat/games` and select any .tap file
* type : `tload "tetris.tap"`
* Oric will load the program and start it automatically
* Turn *off* music by pressing left cursor!

Keys:
* Space starts the game
* Left and Right cursor moves left and right.
* Down cursor rapidly drops the shape
* Space rotates the shape clockwise
* On highscore table, Up/Down changes the initial, right moves to next, space is done.


# Quick start for LOCI users
If you are lucky to have a LOCI device, please follow these instructions to get going quickly:
* copy the `dfloci.rom` file in `Oric/dflat/rom` to your SD card
* copy the `dflat` folder in `Oric/software/` to the root of your SD card
* In LOCI, select the dfloci.rom file on your SD card and reboot
* Now in dflat if you type `dir` you will see folders in the `dflat` folder of your SD card 


# Note: Wiki
A friend recommended that I should point out there is a fairly extensive wiki on dflat.

So after reading this, please have a look through the wiki to really get a feel for this language targeted at constrained 8-bit machinees.

https://github.com/6502Nerd/dflat/wiki


# About dflat
dflat is a BASIC-like language for 8-bit micros and retro computers running on 6502 and 65c02.  Key features & highlights;
* Procedure orientated structure (all runnable code within def..enddef blocks)
* Local variables - supports recursion
* Structured programming including if..elif..endif, while..wend, repeat..until
* Line numbers only used for sequencing lines, but cannot be referenced - no goto or gosub!
* Support for sound and graphics
* Inline assembler that can access dflat variables and vice-versa
* Fits in to 16KB ROM (including all low-level BIOS)
* Core language can be ported easily - just needs character put and get routines for input/output

Here is hello world in dflat:
* `10 def_hello()`
* `20   println "Hello world!"`
* `30 enddef`
* `_hello()` [immediately invokes the procedure called _hello]

The base version here is targeted for the Oric-1 and Atmos computers from the early 80s and due to being integer only and tokenisation, is much faster than Oric BASIC.

I am in continual refinement and documentation mode as this is an on-going project for my personal enjoyment. Please see the wiki pages for details of the language.

The source and binaries are in the Oric folder - the readme.txt provides a guide to try dflat rather wihtout building it from scratch but also describes all folder/contents in this repo.
