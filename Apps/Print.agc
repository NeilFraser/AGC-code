# Copyright:	Public domain.
# Filename:	Print.agc
# Purpose:	Demonstrating a minimal AGC program that
#		counts in memory.  Handles all the alarms
#		which cause reboots.
# Assembler:	yaYUL
# Contact:	Lena Ku <lenaku@163.com>
# Contact:	Neil Fraser <agc@neil.fraser.name>
# Contact:	Luca Rosenberg <luca.rosenberg@gmail.com>

# Interrupts, must have 4 lines per interrupt
		SETLOC	4000

# Power up
		CA	100MS		# Schedule T5 soon.
		TS	T5
		TC	START
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
		TC	T5RUPT

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

###############################################################################################
# The main program loop:
# It loads some constants into erasable memory, flushes the DSYK display and the corresponding
# array in erasable memory storing its state (FLSHDSP), writes the digits 0 to 9 and blank to
# the 3 x 5 display (FILLDSP; uses the PRNTDIG function), sets all display positions to 0
# (DELDSP; uses the PRNTDIG function), and finally loops around.
###############################################################################################

START		CA	CTWO
		TS	TWO
		CA	CFOUR
		TS	FOUR
		CA	CSEVEN
		TS	SEVEN
		CA	CELEVEN
		TS	ELEVEN
		TCR	FLSHDSP
		TCR	FILLDSP
		TCR	DELDSP
		TCF	START

###############################################################################################
# The PRNTDIG function-of-interest:
# The PRNTDIG function prints the specified digit (0 to 9, and blank, represented by 10;
# expected in DIGIT) to the specified DSKY display position (zero-indexed display row and column,
# expected in ROW and COL, respectively).
# It relies on 5 subfunctions.
###############################################################################################

# The following 5 functions are subfunctions that are used by the main PRNTDIG function.

# Get the zero-based index (0-14) of the display position to write a digit to,
# using: POSIDX = ROW * 5 + COL
GPOSIDX		CA	ROW
		EXTEND
		MP	FIVE
		CA	L
		AD	COL
		TS	POSIDX
		RETURN

# Get the zero-based index (0-7) of the position pair the position to write to is part of,
# using: PAIRIDX = floor((POSIDX + 1)/2)
GPAIRIDX	CA	POSIDX
		INCR	A
		TS	SR		# Values written to SR are immediately shifted right, which is equivalent to a floor division by 2
		CA	SR
		TS	PAIRIDX
		RETURN

# Get the bit representations of the digits that are currently displayed in the position pair
# the position to write to is part of.
GCURDIGS	INDEX	PAIRIDX
		CA	DSPSTATE	# DSPSTATE is an 8-element 'array' in erasable memory that stores the digits currently displayed in all position pairs
		TS	CURDIGS
		CA	POSIDX		# Check if POSIDX is even or odd by floor division by 2, then doubling, and subtraction of the original value
		TS	SR
		CA	SR
		DOUBLE
		EXTEND
		SU	POSIDX
		INCR	A		# Increment so that if POSIDX is even we get 1 and don't branch
		EXTEND
		BZF	LDIG1		# If odd (position to write to is the left of a pair), branch to LDIG1
RDIG1		CA	CURDIGS		# The RDIG1 label is not required an only there for clarity
		MASK	RMASK		# MASK bitwise ANDs the contents of RMASK into the accumulator. RMASK is a bit mask that selects the 5 least significant bits ("0000 0 00000 11111")
		TS	CURDIG		# Store the bit representation of the digit currently displayed in the position to write to
		CA	CURDIGS
		MASK	LMASK		# Get the digit currently displayed in the second position of the pair, the one that should be conserved. LMASK: "0000 0 11111 00000"
		TS	CURODIG
		TCF	REND1
LDIG1		CA	CURDIGS		# Analogous to above, but the digit to write to is the left of a pair
		MASK	LMASK
		TS	CURDIG
		CA	CURDIGS
		MASK	RMASK
		TS	CURODIG
REND1		RETURN

# Get the bit representation of the new digit that will be written to a display position
GNEWDIG		CA	POSIDX		# Use the same approach as in GCURDIGS to find out if the position to write to is the left or right one of a position pair
		TS	SR
		CA	SR
		DOUBLE
		EXTEND
		SU	POSIDX
		INCR	A
		EXTEND
		BZF	LDIG2
RDIG2		CA	ONE		# If it is a right position, we load 1 into the accumulator and afterwards multiply by the bit representation of the digit (leaves the representation unchanged)
		TCF	REND2
LDIG2		CA	SHFTDIGL	# If it is a left position, we load 32 (SHFTDIGL) into the accumulator. When we afterwards multiply-in the digit bit representation, it is shifted 5 positions to the left
REND2		EXTEND
		INDEX	DIGIT
		MP	DIGITS
		CA	L
		TS	NEWDIG
		RETURN

# Get the prefix of the position pair to write to
GPREFIX		INDEX	PAIRIDX
		CA	PREFIXES	# PREFIXES is an 8-element 'array' in fixed memory that holds the position pair addressing prefixes
		TS	PREFIX
		RETURN



# The main PRNTDIG function:
#
# Inputs:
# The position to write to: zero-based indices of the row and column to write to (3 x 5 display);
# the function expects to find those indices in the ROW and COL variables, respectively.
# The digit to write: digits 0 to 9, and 10 for blank; the function expects to find the digit
# in the DIGIT variable.
#
# The function first checks if the digit to write is already being displayed at the specified position.
# If so, it does nothig.
# If the new digit is different, it is written to the selected position, while leaving the digit
# in the other position of the pair unchanged.
PRNTDIG		EXTEND
		QXCH	PRNTDIGR	# To call another function from within this one, the return address has to be first stored
		TCR	GPOSIDX
		TCR	GPAIRIDX
		TCR	GCURDIGS
		TCR	GNEWDIG
		CA	CURDIG		# Check if the digit to be written is the same as the one currently being displayed in the selected position
		EXTEND
		SU	NEWDIG
		EXTEND
		BZF	SKIPPRNT	# If the digit is the same, skip to the end of the function
		TCR	GPREFIX
		CA	PREFIX		# Else, construct the position pair representation by adding the representations of the prefix (selects the correct position pair), the digit to write (left or right), and the digit to leave unchanged (right or left)
		AD	NEWDIG
		AD	CURODIG
		INDEX	PAIRIDX		# Update DSPSTATE to reflect the new digit being displayed at the selected position
		TS	DSPSTATE
		EXTEND			# Write to the DSKY
		WRITE	010
SKIPPRNT	EXTEND
		QXCH	PRNTDIGR
		RETURN

###############################################################################################

ONE		DEC	1
FIVE		DEC	5

# Bit masks used to extract the left and right digit bit representations from a position pair
LMASK		DEC	992		# "0000 0 11111 00000"
RMASK		DEC	31		# "0000 0 00000 11111"

# Multiply by 32 to shift digit bit representation 5 positions to the left
SHFTDIGL	DEC	32

# Bit representation of the digits in the right position of the position pair.
# To place them in the left position, shift 5 bits left, e.g.:
# - Right position 0: "0000 0 00000 10101" (21)
# - Left position 0: "0000 0 10101 00000" (672 = 21 * 2^5 = 21 * 32)
DIGITS		DEC	21		# Bit representation of (right position) 0
		DEC	3
		DEC	25
		DEC	27
		DEC	15
		DEC	30
		DEC	28
		DEC	19
		DEC	29
		DEC	31		# Bit representation of (right position) 9
		DEC	0		# Bit representation of (right position) blank

# The prefixes to address the different display position pairs.
# The prefixes occupy the 4 most significant bits, then comes one bit to control the sign,
# 5 bits to select the left digit, and 5 bits to select the right digit ("PPPP S LLLLL RRRRR").
# To address the last display position pair we would use "0001 0 00000 00000" (2048)
PREFIXES	DEC	16384		# Prefix of first display position pair: (0,0) (no true pair)
		DEC	14336		# Prefix of second display position pair: (0,1)-(0,2) (first true pair)
		DEC	12288
		DEC	10240
		DEC	8192
		DEC	6144
		DEC	4096
		DEC	2048		# Prefix of last display position pair: (2,3)-(2,4)



# The interfaces between calling and called functions are provided by addresses in erasable
# memory (i.e. global variables)
ROW		=	061
COL		=	062
DIGIT		=	063

POSIDX		=	064
PAIRIDX		=	065

CURDIGS		=	066
CURDIG		=	067
CURODIG		=	070

NEWDIG		=	071

PREFIX		=	072

# Since we don't have a stack, we have to store the return address of the calling function
# if we want to call another function from within the called function.
PRNTDIGR	=	073

# Addresses 074-0103 store the digits currently being displayed in the 8 position pairs
DSPSTATE	=	074

# The memory addresses of the different registers we are using
A		=	00
L		=	01
Q		=	02
SR		=	021

###############################################################################################
# The functions that are used in the main loop to test the PRNTDIG function
###############################################################################################

# Flushes DSPSTATE and the DSKY display, by setting all 8 position pairs to blank.
FLSHDSP		EXTEND
		QXCH	FLSHDSPR
		CA	ZERO
		TS	IDX
LOOP		INDEX	IDX
		CA	PREFIXES
		INDEX	IDX
		TS	DSPSTATE
		EXTEND
		WRITE	010
		INCR	IDX
		CA	IDX
		EXTEND
		SU	SEVEN
		EXTEND
		BZMF	LOOP
		EXTEND
		QXCH	FLSHDSPR
		RETURN

# Gets the appropriate digit for FILLDSP to print at a given display position based on the row
# and column indices.
GDIG		EXTEND
		QXCH	GDIGR
		TCR	GPOSIDX
		CA	POSIDX
		TS	L
		CA	ZERO
		EXTEND			# DV returns floor(AL/OPERAND) in A and mod(AL/OPERAND) in L
		DV	ELEVEN
		CA	L
		TS	DIGIT
		EXTEND
		QXCH	GDIGR
		RETURN

# Moves through the display positions from top left to bottom right and writes an increasing
# digit to each position. After 9 a blank is printed, and then the digits wrap around.
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

# Almost identical to FILLDSP, with the only difference that a 0 is printed to each display position.
DELDSP		EXTEND
		QXCH	DELDSPR
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
		QXCH	DELDSPR
		RETURN

###############################################################################################

# Constants that are used by the row/column iteration loops of the FLSHDSP, FILLDSP,
# and DELDSP functions as boundaries.
# Those prefixed with C are used in operations that require their operands to be
# in erasable memory (SU and DV). They are transferred to an address in erasable memory
# during set-up (see below for the corresponding addresses in erasable memory).
ZERO		DEC	0
CTWO		DEC	2
CFOUR		DEC	4
CSEVEN		DEC	7
CELEVEN		DEC	11



# Loop index for the FLSHDSP function
IDX		=	104

# Loop indices for the FILLDSP and DELDSP functions
ROWIDX		=	105
COLIDX		=	106

# Since we don't have a stack, we have to store the return address of the calling function
# if we want to call another function from within the called function.
FLSHDSPR	=	107
GDIGR		=	110
FILLDSPR	=	111
DELDSPR		=	112

TWO		=	113
FOUR		=	114
SEVEN		=	115
ELEVEN		=	116