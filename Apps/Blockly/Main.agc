# Copyright:	Public domain.
# Filename:	Main.agc
# Purpose:	Framework to enable Blockly-based programming using higher-level
#               blocks.
# Assembler:	yaYUL
# Contact:	Neil Fraser <agc@neil.fraser.name>
# Contact:	Luca Rosenberg <luca.rosenberg@gmail.com>

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
		CA		100MS	# Reschedule T5 soon.
		TS		T5
		TCF		T5RUPT

		# T3 (interrupt #3)
		RESUME
		NOOP
		NOOP
		NOOP

		# T4 (interrupt #4)
		XCH		ARUPT
		CA		NUM0	# Clear SLEEPING flag.
		TS		SLEEPING
		TCF		T4RUPT

		# DSKY1 (interrupt #5)
		NOOP			# Fall through to DSKY2.
		NOOP
		NOOP
		NOOP

		# DSKY2 (interrupt #6)
		XCH		ARUPT
		EXTEND
		READ		KEY15
		TCF		KEYRUPT

		# Uplink (interrupt #7)
		RESUME
KEYRUPT		TS	INPUTING	# Squeeze the remaining key handler in here.
		XCH	ARUPT
		RESUME

		# Downlink (interrupt #8)
		RESUME
T5RUPT		CA	NEWJOB		# Tickle the night watchman.
T4RUPT		XCH	ARUPT
		RESUME

		# Radar (interrupt #9)
		RESUME
		NOOP
		NOOP
		NOOP

		# Hand controller (interrupt #10)
		RESUME
		#NOOP	# Save three words by allowing START to move up.
		#NOOP
		#NOOP

# Initialize the stack pointer to be 0.
# This is the offset from the starting stack position.
START		CA	NUM0
		TS	STACKPTR

# Unit tests.
$Test.agc

		# Wait a second.
		CA	NUM100
		TCR	PUSH
		TCR	SLEEP

		TCR	INPUT

		TCF	START


# Code modules.
$Boolean.agc
$Math.agc


# Function that waits for a DSKY keypress.
# Returns (on A):
#	Keycode of keypress.
INPUT		CA	NUM1		# Set INPUTTING to -1
		COM
		TS	INPUTING
		# Wait until INPUTING isn't -1.
INPUT-WT	CA	INPUTING
		INCR	A
		EXTEND
		BZF	INPUT-WT
		CA	INPUTING
		RETURN


# Function that sleeps for the specified duration.
# Stack argument:
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
		EXTEND		# Subtract the desired delay.
		SU	L
		TS	T4	# Set the interrupt timer
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


# Push the contents of the 'A' register onto the stack.
# No registers are affected.
PUSH		INCR	STACKPTR
		INDEX	STACKPTR
		TS	STACK
		RETURN


# POP: Pop the last value on the stack into the 'A' register.
# DROP: Drop the last value without returning it.
POP		INDEX	STACKPTR
		CAE	STACK
DROP		EXTEND
		DIM	STACKPTR
		RETURN


# Variables in memory.
SLEEPING	=	061	# Flag indicating if we are busy-sleeping.
INPUTING	=	062	# Waiting for a DSKY key press.
QPOP		=	063	# Temporary spot for Q.
STACKPTR	=	064	# Stack pointer, starts at 0.
STACK		=	064	# Start address of stack (minus one).

# Constants.
10MS		OCT	37777	# 2^14-1 is 10 ms to T4/T5 overflow.
100MS		OCT	37766	# 2^14-10 is 100 ms to T4/T5 overflow.

NUM1		DEC	1
NUM2		DEC	2
NUM3		DEC	3
NUM4		DEC	4
NUM5		DEC	5
NUM6		DEC	6
NUM7		DEC	7
NUM8		DEC	8
NUM9		DEC	9
NUM100		DEC	100

# System Address Locations
A		=	00
L		=	01
Q		=	02
NUM0		=	07
ARUPT		=	10
KEY15		=	15	# I/O Channel 15 (DSKY keypad)
T4		=	27
T5		=	30
NEWJOB		=	67
