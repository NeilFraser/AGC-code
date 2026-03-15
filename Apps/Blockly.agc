# Copyright:	Public domain.
# Filename:	Blockly.agc
# Purpose:	Framework to enable Blockly-based programming using higher-level
#               blocks.
# Assembler:	yaYUL
# Contact:	Neil Fraser <agc@neil.fraser.name>
# Contact:

# Interrupts, must have 4 lines per interrupt
		SETLOC	4000

		# Power up
		CA		100MS	# Schedule T5 soon.
		TS		T5
		TCF		START
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
		TCF		T5RUPT

		# T3 (interrupt #3)
		RESUME
		NOOP
		NOOP
		NOOP

		# T4 (interrupt #4)
		XCH		ARUPT
		CA		NUM0		# Clear SLEEPING flag.
		TS		SLEEPING
		TCF		WAKEUP

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

START		# Display a 88.
		CA	NUM8
		TS	DIGIT1
		CA	NUM8
		TS	DIGIT2
		CA	D14-15
		TS	DSKYPAIR
		TCR	DISPLAY
		# Wait a second.
		CA	NUM100
		TS	SLEEPCS
		TCR	SLEEP
		# Display a 11.
		CA	NUM1
		TS	DIGIT1
		CA	NUM1
		TS	DIGIT2
		CA	D14-15
		TS	DSKYPAIR
		TCR	DISPLAY
		# Wait a second.
		CA	NUM100
		TS	SLEEPCS
		TCR	SLEEP
		TCF	START


T5RUPT		CA	NEWJOB	# Tickle the night watchman.
		XCH	ARUPT
		RESUME


WAKEUP		XCH	ARUPT
		RESUME


# Function that sleeps for the duration of SLEEPCS.
# SLEEPCS is in 100ths of a second, thus 100 is 1 second.
SLEEP		CA	10MS
		EXTEND
		SU	SLEEPCS
		INCR	A
		TS	T4

		# Set SLEEPING to any non-zero value as a flag.
		# 'A' happens to be a non-zero number, so use that.
		TS	SLEEPING

SLEEPBZF	CA	SLEEPING
		EXTEND
		BZF	SLEEPEND	# Loop until SLEEPING flag is zero.
		TCF	SLEEPBZF
SLEEPEND	RETURN


# Function that displays a pair of digits on the DSKY.
# DIGIT1 and DIGIT2 are the two digits.
DISPLAY 	INDEX	DIGIT1
		CA	DSKYDIG
		EXTEND
		MP	DSKYC2D	# Stored in L
		CA	L
		INDEX	DIGIT2
		AD	DSKYDIG
		AD	D14-15  # TODO: USE DKSYPAIR
		EXTEND
		WRITE	010
        	RETURN


# Variables in memory.
SLEEPING	=	061
SLEEPCS		=	062
DIGIT1		=	063
DIGIT2		=	064
DSKYPAIR	=	065

# Constants.
10MS		OCT	37777	# 2^14, the overflow of T4
100MS		OCT	37766	# 2^14-10, 100 ms

NUM1	DEC	1
NUM2	DEC	2
NUM3	DEC	3
NUM4	DEC	4
NUM5	DEC	5
NUM6	DEC	6
NUM7	DEC	7
NUM8	DEC	8
NUM9	DEC	9
NUM100	DEC	100

D14-15 DEC 12288
# TODO ADD OTHER PAIRS

DSKYDIG DEC 21
	DEC 3
	DEC 25
	DEC 27
	DEC 15
	DEC 30
	DEC 28
	DEC 19
	DEC 29
	DEC 31
DSKYC2D DEC 32

# System Address Locations
A	=	00
L	=	01
Q	=	02
NUM0	=	07
ARUPT	=	10
T4	=	27
T5	=	30
NEWJOB	=	67
