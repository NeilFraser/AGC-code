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


START	CA ONE
	TS DIGIT1
	CA TWO
	TS DIGIT2
	CA D14-15
	TS DSKYPAIR
	TCR DISPLAY
	TCF START

DISPLAY INDEX DIGIT1
	CA DSKYDIG
	EXTEND
	MP DSKYC2D	# Stored in L
	CA L
	INDEX DIGIT2
	AD DSKYDIG
	AD D14-15  # TODO: USE DKSYPAIR
	EXTEND
	WRITE 010
        RETURN

# Variables
DIGIT1 = 061
DIGIT2 = 062
DSKYPAIR = 063

# Constants.
ZERO	= 7
ONE DEC 1
TWO DEC 2
THREE DEC 3
# TODO ADD OTHER DIGITS

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

NEWJOB	= 67
T5	= 30
100MS	OCT	37766
ARUPT	= 10
A	= 00
L	= 01
Q	= 02
