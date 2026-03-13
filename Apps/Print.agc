# Copyright:	Public domain.
# Filename:	Print.agc
# Purpose:	Demonstrating a minimal AGC program that
#		counts in memory.  Handles all the alarms
#		which cause reboots.
# Assembler:	yaYUL
# Contact:	Lena Ku <lenaku@163.com>
# Contact:	Neil Fraser <agc@neil.fraser.name>

# Interrupts, must have 4 lines per interrupt
	SETLOC	4000

	# Power up
	CA		100MS	# Schedule T5 soon.
	TS		T5
	TC		START
	NOOP

	# T6 (interrupt #1)
	RESUME
	NOOP
	NOOP
	NOOP

	# T5 (interrupt #2)
	XCH		ARUPT
	CAF		100MS	# Reschedule T5 soon.
	TS		T5
	TC		T5RUPT

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

T5RUPT	CA NEWJOB	# Tickle the night watchman.
	XCH ARUPT
	RESUME

NEWJOB	= 67
T5	= 30
100MS	OCT	37766
ARUPT	= 10

##################################################
# Function that allows users to specify a digit
# (0-9 or blank) and the position on the 3 x 5
# display (rows x columns) to print it to.

# Increment 1: Print user-specified digit in the
# right position of the position pair the
# user-specified position belongs to.
##################################################

# Load arguments (digit, row and colum to print to)
# into erasable memory locations and hand over
# control to the print function.
# Normally, the arguments would be loaded into
# ROW, COLUMN, and DIGIT by the calling function.
START	CA	CONSTDIG
		TS 	DIGIT
		CA	CONSTROW
		TS	ROW
		CA	CONSTCOL
		TS	COLUMN
		TCR	PRINTDIG
		TCF	START

# Print the user-specified digit to the right position of the position pair containing
# the user-specified position.
# The index of the position pair is obtained according to (with m representing the row
# and n the column; both zero-indexed): idx = floor((m*5+n+1)/2)
PRINTDIG	CA	ROW
			EXTEND
			MP	FIVE
			CA	L
			AD	COLUMN
			INCR	A
			TS		SR	# Transfer to SR for floor division by two
			INDEX	SR	# Indexing supposedly rewrites the SR register. This does not appear to be true.
			CA		POSPAIRS
			INDEX	DIGIT
			AD		DIGITS
			TS	DIGPAIR
			EXTEND
			RXOR	010	# XOR accumulator and I/O-channel 010 to check if we would be printing the same value again
			EXTEND
			BZF	IFSAME	# If we would be printing the same value again, skip.
			CA	DIGPAIR
			EXTEND
			WRITE	010
IFSAME		RETURN

# The memory addresses of the different registers we are using
A	=	00
L	=	01
SR	=	021
Q	=	02

# The variables that store the arguments with which the function is invoked
# In use, the arguments would be loaded into the variables by the calling
# function and we wouldn't need the constants.
DIGIT	=	061
ROW		=	062
COLUMN	=	063

CONSTDIG	DEC	4
CONSTROW	DEC	2
CONSTCOL	DEC	4

# Local variable of the print function that stores the 15-bit pattern that selects
# a display position pair and specifies its left and right digit when written to
# I/O-channel 010
DIGPAIR	=	064

# The prefixes to address the different display position pairs
POSPAIRS	DEC	16384	# Prefix of first display position pair: (0,0) (no true pair)
			DEC	14336	# Prefix of second display position pair: (0,1)-(0,2) (first true pair)
			DEC	12288
			DEC	10240
			DEC	8192
			DEC	6144
			DEC	4096
			DEC	2048	# Prefix of last display position pair: (2,3)-(2,4)

# Bit representation of the digits in the right position of the position pair.
# To place them in the left position, shift five bits left.
DIGITS		DEC	21	# Bit representation of (right position) 0
			DEC	3
			DEC	25
			DEC	27
			DEC	15
			DEC	30
			DEC	28
			DEC	19
			DEC	29
			DEC	31	# Bit representation of (right position) 9
			DEC	0	# Bit representation of (right position) blank

FIVE	DEC	5