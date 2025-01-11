# Copyright:	Public domain.
# Filename:	Minimal.agc
# Purpose:	Demonstrating a minimal AGC program that
#		counts in memory.  Handles all the alarms
#		which cause reboots.
# Assembler:	yaYUL
# Contact:	Lena Ku <lenaku@163.com>
# Contact:	Neil Fraser <agc@neil.fraser.name>

# Interrupts, must have 4 lines per interrupt
	SETLOC	4000

	# Power up
	CA		100MS
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
	CAF		100MS
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

T5RUPT	XCH ARUPT
		CA NEWJOB
		RESUME


START	CA ZERO
		TS 1234
LOOP	EXTEND
		AUG 1234
		TC LOOP

ZERO	= 7
NEWJOB	= 67
T5		= 30
100MS	OCT	37766
ARUPT	= 10
