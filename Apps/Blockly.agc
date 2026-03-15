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

START		CA	NUM0		# Initializations.
		TS	STACKPTR	# Stack pointer to zero.
		TS	RAND		# Current random number to zero.
		CA	NUM1		# Random number range = 0-1.
		TS	RANDMAX

		# Set RANDMAX to 9
		CA	NUM7
		TS	RANDMAX

		# Display a 00.
		CA	D14-15
		TCR	PUSH
		CA	NUM0
		TCR	PUSH
		CA	NUM0
		TCR	PUSH
		TCR	DISPLAY

		# Wait a second.
		CA	NUM100
		TCR	PUSH
		TCR	SLEEP

		# Display a 11.
		CA	D14-15
		TCR	PUSH
		# Fetch random number.
		CA	RAND
		TCR	PUSH
		# Fetch random number.
		CA	RAND
		TCR	PUSH
		TCR	DISPLAY

		# Wait a second.
		CA	NUM100
		TCR	PUSH
		TCR	SLEEP
		TCF	START


T5RUPT		CA	NEWJOB	# Tickle the night watchman.
		# Step the random number (down to zero, wrapping up).
		CCS	RAND
		TCF	T5RAND	# RAND > 0 (A = RAND-1)
		CAE	RANDMAX	# RAND = 0, make it RANDMAX again
T5RAND		TS	RAND	# Save new num to RAND
		XCH	ARUPT
		RESUME


WAKEUP		XCH	ARUPT
		RESUME


# Function that sleeps for the duration of SLEEPCS.
# Arguments:
# 	Delay in 100ths of a second, thus 100 is 1 second.
SLEEP		EXTEND
		QXCH	QPOP
		TCR	POP	# Pop the delay from the stack.
		TS	L
		# We want to load 2^14 (40,000 oct).  But doing so gets treated
		# as a negative number since it uses the 15th bit.
		# Workaround: load 2^14-1, then increment.
		CA	10MS
		INCR	A
		EXTEND
		SU	L
		TS	T4
		EXTEND
		QXCH	QPOP

		# Set SLEEPING to any non-zero value as a flag.
		# 'A' happens to be a non-zero number, so use that.
		TS	SLEEPING

SLEEPBZF	CA	SLEEPING
		EXTEND
		BZF	SLEEPEND	# Loop until SLEEPING flag is zero.
		TCF	SLEEPBZF
SLEEPEND	RETURN


# Function that displays a pair of digits on the DSKY.
# Arguments:
#	Position of pair on DSKY.
#	Second digit.
#	First digit.
DISPLAY 	EXTEND
		QXCH	QPOP
		TCR	POP	# Pop first digit from stack.
		INDEX	A
		CA	DSKYDIG
		EXTEND
		MP	DSKYC2D	# Stored in L
		TCR	POP	# Pop second digit from stack.
		INDEX	A
		CA	DSKYDIG
		ADS	L
		TCR	POP	# Pop DSKY pair position from stack.
		AD	L
		EXTEND
		WRITE	010
		EXTEND
		QXCH	QPOP
        	RETURN

# Push the contents of the 'A' register onto the stack.
PUSH		INCR	STACKPTR
		INDEX	STACKPTR
		TS	STACK
		RETURN

# Pop the last value on the stack into the 'A' register.
POP		INDEX	STACKPTR
		CAE	STACK
		EXTEND
		DIM	STACKPTR
		RETURN

# Variables in memory.
SLEEPING	=	061	# Flag indicating if we are busy-sleeping.
RAND		=	062	# Random number (0 to RANDMAX inc)
RANDMAX		=	063	# Maximum possible random number.
QPOP		=	100	# Temporary spot for Q.
STACKPTR	=	101	# Stack pointer.
STACK		=	102	# Start of the stack.

# Constants.
10MS		OCT	37777	# 2^14-1 is 10 ms to T4/T5 overflow.
100MS		OCT	37766	# 2^14-10 is 100 ms to T4/T5 overflow.

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
