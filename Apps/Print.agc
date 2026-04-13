# Copyright:	Public domain.
# Filename:	Print.agc
# Purpose:	Implementation of a print function that prints a user-specified
#		digit (0 to 9, and blank) to a user-specified 7-segment display
#		in one of the three bottom rows of the yaDSKY.
#		The 7-segment display to print to is addressed by its zero-based
#		row- and column-indices, and all other 7-segment diplays remain
#		unchanged.
# Assembler:	yaYUL
# Contact:	Neil Fraser <agc@neil.fraser.name>
# Contact:	Luca Rosenberg <luca.rosenberg@gmail.com>



# ##############################################################################
# PRNTDIG DSKY digit printing:
#
# Implementation of a function that prints a user-specified digit (DIGIT;
# 0 to 9, and blank, represented by 10) to any user-specified 7-segment display
# (ROW and COL; zero-based indices, i.e., (ROW, COL) = (0, 0), ..., (2, 4))
# in the three bottom rows of the yaDSKY.
# When printing a digit to any given 7-segment display (from now on called
# "position"), all other positions remain unchanged.
# The PRNTDIG function relies on four subfunctions: GPOSIDX, GPAIRIDX, GCURDIGS,
# and GNEWDIG.
#
# Before using the PRNTDIG function, the yaDKSY and the memory addresses storing
# the current states of the different position pairs must be initialized to a
# blank state with the accompanying FLSHDSP function.
#
# See https://www.ibiblio.org/apollo/developer.html for more information on how
# to interface with the yaDSKY.
# ##############################################################################



# FLSHDSP ('Flush Display') function:
#
# Inputs: None
#
# Returns: None
#
# Initializes the yaDSKY and the memory addresses storing the current states of
# the position pairs (DSPSTATE) to a valid, blank state.
# Must be called before using the PRNTDIG function.
FLSHDSP		CA	NUM8
		TS	L
FLSHLOOP	EXTEND
		DIM	L
		INDEX	L
		CA	PREFIXES
		INDEX	L
		TS	DSPSTATE
		EXTEND
		WRITE	10
		CA	L
		EXTEND
		BZF	FLSHEND
		TCF	FLSHLOOP
FLSHEND		RETURN

# ##############################################################################

# The following four functions are subfunctions that are used by the PRNTDIG
# function.

# GPOSIDX ('Get Position Index') function:
#
# Inputs:
# ROW: zero-based row index of the position to print to (0 corresponds to the
# first of the three bottom rows of the yaDSKY)
# COL: zero-based column index of the position to print to
#
# Returns:
# POSIDX: zero-based overall position index
#
# Returns the zero-based index (0-14) of the position to print a digit to,
# using: POSIDX = ROW * 5 + COL
GPOSIDX		CA	ROW
		EXTEND
		MP	NUM5
		CA	L
		AD	COL
		TS	POSIDX
		RETURN

# GPAIRIDX ('Get Pair Index') function:
#
# Inputs:
# POSIDX: zero-based overall position index
#
# Returns:
# PAIRIDX: zero-based index of the position pair the position to print to
# is part of
#
# Returns the zero-based index (0-7) of the position pair the position to print
# to is part of, using: PAIRIDX = floor((POSIDX + 1)/2)
# This index is required because the yaDSKY positions always have to be
# printed to in pairs
GPAIRIDX	CA	POSIDX
		INCR	A
# Values written to SR are immediately shifted right, which is equivalent to
# a floor division by 2
		TS	SR
		CA	SR
		TS	PAIRIDX
		RETURN

# GCURDIGS ('Get Current Digits') function:
#
# Inputs:
# POSIDX: zero-based overall position index
# PAIRIDX: zero-based index of the position pair the position to print to
# is part of
#
# Returns:
# CURDIG: bit representation of the digit that is currently displayed in the
# position to print to
# CURODIG: bit representation of the digit that is currently displayed in the
# other position of the position pair to print to
#
# Returns the bit representations of the digits that are currently displayed
# in the position pair the position to print to is part of.
# These bit representations are used by the PRNTDIG function to check if the
# digit to print is already being displayed in the target position (in which
# case it does nothing) and to retain the second position when printing
# the updated pair.
GCURDIGS	INDEX	PAIRIDX
# DSPSTATE is an 8-element 'array' in erasable memory that stores the bit
# representations of the digits currently being displayed in all position pairs
		CA	DSPSTATE
		TS	CURDIGS
# Check if POSIDX is even or odd by floor division by 2, then doubling,
# and finally subtraction of the original value
		CA	POSIDX
		TS	SR
		CA	SR
		DOUBLE
		EXTEND
		SU	POSIDX
# Increment, so that if POSIDX is even, the accumulator is 1 and execution
# continues without branching
		INCR	A
		EXTEND
# If odd (position to print to is the left of a pair), branch to LDIG1
		BZF	LDIG1
# The RDIG1 label is not required an only there for clarity
RDIG1		CA	CURDIGS
# MASK bitwise ANDs the contents of RMASK into the accumulator. RMASK is a bit
# mask that selects the five least significant bits ("0000 0 00000 11111")
		MASK	RMASK
# Store the bit representation of the digit currently being displayed in the
# position to print to
		TS	CURDIG
		CA	CURDIGS
# Get the digit currently being displayed in the second position of the pair,
# the one that should be conserved. (LMASK: "0000 0 11111 00000")
		MASK	LMASK
		TS	CURODIG
		TCF	REND1
# Analogous to above, but the digit to print to is the left of a pair
LDIG1		CA	CURDIGS
		MASK	LMASK
		TS	CURDIG
		CA	CURDIGS
		MASK	RMASK
		TS	CURODIG
REND1		RETURN

# GNEWDIG ('Get New Digit') function:
#
# Inputs:
# POSIDX: zero-based overall position index
# DIGIT: the digit to print to the target position (0 to 9, and 10 for blank)
#
# Returns:
# NEWDIG: the bit representation of the digit to print (note that the bit
# representations of the digits are different depending on whether they
# should be printed to the left or right position of a pair)
#
# Returns the bit representation of the digit to print.
# Uses POSIDX to check if the position to print to is the left or right of
# a position pair (same approach as in GCURDIGS above). For any given digit,
# the bit representation for printing it to the left position of a pair is its
# bit representation for printing it to the right position shifted five bit
# positions to the left.
GNEWDIG		CA	POSIDX
		TS	SR
		CA	SR
		DOUBLE
		EXTEND
		SU	POSIDX
		INCR	A
		EXTEND
		BZF	LDIG2
# If it is a right position, 1 is loaded into the accumulator and afterwards
# multiplied by the bit representation of the digit (leaves the representation
# unchanged)
RDIG2		CA	NUM1
		TCF	REND2
# If it is a left position, 32 (SHFTDIGL) is loaded into the accumulator.
# The digit bit representation is then multiplied-in, shifting it five positions
# to the left
LDIG2		CA	SHFTDIGL
REND2		EXTEND
		INDEX	DIGIT
		MP	DIGITS
		CA	L
		TS	NEWDIG
		RETURN



# PRNTDIG ('Print Digit') function:
#
# Inputs:
# ROW: zero-based row index of the position to print to (0 corresponds to the
# first of the three bottom rows of the yaDSKY)
# COL: zero-based column index of the position to print to
# DIGIT: the digit to print to the target position (0 to 9, and 10 for blank)
#
# Returns: None
#
# The function first checks if the digit to print is currently being displayed
# in the target position. If this is the case, it does nothing.
# If the new digit is different, it is printed to the target position,
# while retaining the digit in the other position of the pair.
# Additionally, the address storing the current state of the position pair is
# updated to reflect the change.
PRNTDIG		EXTEND
# To call another function from within PRNTDIG, the return address has to be
# stored first
		QXCH	PRNTDIGR
		TCR	GPOSIDX
		TCR	GPAIRIDX
		TCR	GCURDIGS
		TCR	GNEWDIG
# Check if the digit to print is the same as the one currently being displayed
# in the target position
		CA	CURDIG
		EXTEND
		SU	NEWDIG
		EXTEND
# If the digit is the same, skip to the end of the function
		BZF	SKIPPRNT
# Else, construct the position pair representation by adding the representations
# of the prefix (selects the correct position pair), the digit to write (left or
# right), and the digit to leave unchanged (right or left)
		INDEX	PAIRIDX
		CA	PREFIXES
		AD	NEWDIG
		AD	CURODIG
# Update DSPSTATE to reflect the new digit being displayed at the target position
		INDEX	PAIRIDX
		TS	DSPSTATE
		EXTEND
		WRITE	010		# Print to yaDSKY's IO-channel
SKIPPRNT	EXTEND
		QXCH	PRNTDIGR
		RETURN

# ##############################################################################

NUM1		DEC	1
NUM5		DEC	5
NUM8		DEC	8

# Bit masks used to extract the left and right digit bit representations from a
# position pair
LMASK		DEC	992		# "0000 0 11111 00000"
RMASK		DEC	31		# "0000 0 00000 11111"

# Multiplying by 32 shifts digit bit representation five positions to the left
SHFTDIGL	DEC	32

# Bit representations of the digits in the right position of a position pair
# To place them in the left position, shift five bits left, e.g.:
# - Right position 0: "0000 0 00000 10101" (21)
# - Left position 0: "0000 0 10101 00000" (672 = 21 * 2^5 = 21 * 32)
# Bit representation of (right position) 0
DIGITS		DEC	21
		DEC	3
		DEC	25
		DEC	27
		DEC	15
		DEC	30
		DEC	28
		DEC	19
		DEC	29
# Bit representation of (right position) 9
		DEC	31
# Bit representation of (right position) blank
		DEC	0

# The prefixes to address the different position pairs
# The prefixes occupy the four most significant bits, then comes one bit
# to control the sign, five bits to specify the left digit, and five bits
# to specify the right digit ("PPPP S LLLLL RRRRR").
# To address the last position pair, one would e.g. use "0001 0 00000 00000"
# (2048)
# Prefix of first display position pair: (0,0) (no true pair)
PREFIXES	DEC	16384
# Prefix of second display position pair: (0,1)-(0,2) (first true pair)
		DEC	14336
		DEC	12288
		DEC	10240
		DEC	8192
		DEC	6144
		DEC	4096
# Prefix of last display position pair: (2,3)-(2,4)
		DEC	2048



# The interfaces between calling and called functions are provided by addresses
# in erasable memory (i.e. global variables)
ROW		=	1000
COL		=	1001
DIGIT		=	1002

POSIDX		=	1003
PAIRIDX		=	1004

CURDIGS		=	1005
CURDIG		=	1006
CURODIG		=	1007

NEWDIG		=	1010

# Since the AGC doesn't support a stack, the return addresses of calling
# functions have to be stored to be able to call other functions from within
# called functions.
PRNTDIGR	=	1011

# Addresses 01012-01021 store the digits currently being displayed in the eight
# position pairs
DSPSTATE	=	1012