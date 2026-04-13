# Copyright:	Public domain.
# Filename:	Print-test.agc
# Purpose:	A simple test program for the yaDSKY print function defined
#		in "Print.agc".
#		Initializes the yaDSKY, prints increasing digits (0, ..., 9,
#		blank, then wrap-around to 0) to the positions in the bottom
#		three rows of the yaDSKY in order, sequentially overwrites all
#		digits with zeros, and finally loops around.
# Assembler:	yaYUL
# Contact:	Lena Ku <lenaku@163.com>
# Contact:	Neil Fraser <agc@neil.fraser.name>
# Contact:	Luca Rosenberg <luca.rosenberg@gmail.com>



# Interrupts, must have 4 lines per interrupt
		SETLOC	4000

# Power up
		CA	100MS		# Schedule T5 soon.
		TS	T5
		TCF	START
		NOOP

# T6 (interrupt #1)
		RESUME
		NOOP
		NOOP
		NOOP

# T5 (interrupt #2)
		XCH	ARUPT
		CAF	100MS		# Reschedule T5 soon.
		TS	T5
		TCF	T5RUPT

# T3 (interrupt #3)
		RESUME
		NOOP
		NOOP
		NOOP

# T4 (interrupt #4)
		RESUME
		NOOP
		NOOP
		NOOP

# DSKY1 (interrupt #5)
		RESUME
		NOOP
		NOOP
		NOOP

# DSKY2 (interrupt #6)
		RESUME
		NOOP
		NOOP
		NOOP

# Uplink (interrupt #7)
		RESUME
		NOOP
		NOOP
		NOOP

# Downlink (interrupt #8)
		RESUME
		NOOP
		NOOP
		NOOP

# Radar (interrupt #9)
		RESUME
		NOOP
		NOOP
		NOOP

# Hand controller (interrupt #10)
		RESUME
		NOOP
		NOOP
		NOOP

T5RUPT		CA	NEWJOB		# Tickle the night watchman.
		XCH	ARUPT
		RESUME

NEWJOB		=	67
T5		=	30
100MS		OCT	37766
ARUPT		=	10

A		=	0
L		=	1
Q		=	2
SR		=	21



# ##############################################################################
# yaDSKY setup and printing loop:
#
# Initializes the yaDSKY and the memory addresses storing the states of its
# position pairs to a valid, blank state using FLSHDSP. Then prints digits
# 0 to 9 and blank to the bottom three rows of the yaDSKY in order (FILLDSP;
# uses the PRNTDIG function). Sequentially overwrites all digits with zeros
# (ZERODSP; uses the PRNTDIG function). And finally loops around.
# ##############################################################################



START		CA	NUM2
		TS	TWO
		CA	NUM4
		TS	FOUR
		CA	NUM11
		TS	ELEVEN
LOOP		TCR	FLSHDSP
		TCR	FILLDSP
		TCR	ZERODSP
		TCF	LOOP

# Import yaDSKY printing function (PRNTDIG and FLSHDSP)
$Print.agc

# ##############################################################################

# GDIG ('Get Digit') function:
#
# Inputs:
# ROW: zero-based row index of the position to print to (0 corresponds to the
# first of the three bottom rows of the yaDSKY)
# COL: zero-based column index of the position to print to
#
# Returns:
# DIGIT: the digit to print to the target position (0 to 9, and 10 for blank)
#
# Returns the appropriate digit for FILLDSP to print at a given display position
# based on the row and column indices.
GDIG		EXTEND
		QXCH	GDIGR
		TCR	GPOSIDX
		CA	POSIDX
		TS	L
		CA	ZERO
		EXTEND
# DV returns floor(AL/OPERAND) in A and mod(AL, OPERAND) in L
		DV	ELEVEN
		CA	L
		TS	DIGIT
		EXTEND
		QXCH	GDIGR
		RETURN

# FILLDSP ('Fill Display') function:
#
# Inputs: None
#
# Returns: None
#
# Moves through the display positions from top left to bottom right and prints
# an increasing digit to each position. After 9, a blank is printed, and then
# the digits wrap around.
FILLDSP		EXTEND
		QXCH	FILLDSPR
		CA	ZERO
		TS	ROWIDX
ROWLOOP1	CA	ZERO		# --- Outer/row loop start
		TS	COLIDX
COLLOOP1	CA	ROWIDX		# --- Inner/column loop start
		TS	ROW
		CA	COLIDX
		TS	COL
		TCR	GDIG
		TCR	PRNTDIG
		INCR	COLIDX
		CA	COLIDX
		EXTEND
		SU	FOUR
		EXTEND
		BZMF	COLLOOP1	# --- Inner/column loop start
		INCR	ROWIDX
		CA	ROWIDX
		EXTEND
		SU	TWO
		EXTEND
		BZMF	ROWLOOP1	# --- Outer/row loop end
		EXTEND
		QXCH	FILLDSPR
		RETURN

# ZERODSP ('Zero Display') function:
#
# Inputs: None
#
# Returns: None
#
# Almost identical to FILLDSP, with the only difference that a 0 is printed to
# each display position.
ZERODSP		EXTEND
		QXCH	ZERODSPR
		CA	ZERO
		TS	ROWIDX
ROWLOOP2	CA	ZERO
		TS	COLIDX
COLLOOP2	CA	ROWIDX
		TS	ROW
		CA	COLIDX
		TS	COL
		CA	ZERO
		TS	DIGIT
		TCR	PRNTDIG
		INCR	COLIDX
		CA	COLIDX
		EXTEND
		SU	FOUR
		EXTEND
		BZMF	COLLOOP2
		INCR	ROWIDX
		CA	ROWIDX
		EXTEND
		SU	TWO
		EXTEND
		BZMF	ROWLOOP2
		EXTEND
		QXCH	ZERODSPR
		RETURN

# ##############################################################################

# Constants that are used by the row/column iteration loops of the FILLDSP and
# DELDSP functions as boundaries.
# Since they are used in operations that require their operands to be in
# erasable memory (SU and DV), they have to be transferred to those during setup
# (see below for the corresponding addresses in erasable memory).
NUM2		DEC	2
NUM4		DEC	4
NUM11		DEC	11

ZERO		=	7

# Loop indices for the FILLDSP and DELDSP functions
ROWIDX		=	61
COLIDX		=	62

# Since the AGC doesn't support a stack, the return addresses of calling
# functions have to be stored to be able to call other functions from within
# called functions.
GDIGR		=	63
FILLDSPR	=	64
ZERODSPR	=	65

TWO		=	66
FOUR		=	67
ELEVEN		=	70