# Bare Metal Apollo Guidance Computer

This repository is a source of information on writing code for a bare metal AGC.  No operating system (e.g. Comanche, Luminary, etc).  The directories contain:

* Apps
   * Minimal.agc - A minimal program that counts from zero to infinity in memory (no output).  This program serves as a template for quieting all the alarms that trigger reboots.
   * Random-Die.agc - A minimal program that rolls a D6 die, and shows the result on the DSKY.  This program demonstrates outputing a single digit to the DSKY and reading a button.
   * TicTacToe.agc - Tic-tac-toe game for either one or two human players.
* Editor - Collection of files that help run the CodeBlocks editor.
* Operations - Minimal demo programs for many of the AGC's opcodes.  These are only designed to be stepped through in a debugger.  Running them will result in GOJAM reboots.

All code is public domain.

For documentation, to download the emulator, and all other things AGC, visit http://www.ibiblio.org/apollo/
