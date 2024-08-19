# Copyright:	Public domain.
# Filename:	Random-Die.agc
# Purpose:	Demonstrating a minimal AGC program that
#		prints a random 1-6 digit every time any
#		button is pressed.
# Assembler:	yaYUL
# Contact:	Lena Ku <lenaku@163.com>
# Contact:	Neil Fraser <agc@neil.fraser.name>

# Interrupts, must have 4 lines per interrupt
	SETLOC	4000

	# Power up
	TCF	START
	NOOP
	NOOP
	NOOP

	# T6 (interrupt #1)
	RESUME
	NOOP
	NOOP
	NOOP

	# T5 (interrupt #2)
	RESUME
	NOOP
	NOOP
	NOOP

	# T3 (interrupt #3)
	XCH	ARUPT	# Back up A register
	TCF	T3RUPT
	NOOP
	NOOP

	# T4 (interrupt #4)
	RESUME
	NOOP
	NOOP
	NOOP

	# DSKY1 (interrupt #5)
	XCH	ARUPT	# Back up A register
	TCF	BUTTON
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

# The interrupt-service routine for the TIME3 interrupt every 100 ms.
T3RUPT	CAF	T3-100MS	# Schedule another TIME3 interrupt in 100 ms.
	TS	TIME3

	# Tickle NEWJOB to keep Night Watchman GOJAMs from happening.
	# You normally would NOT do this kind of thing in an interrupt-service
	# routine, because it would actually prevent you from detecting
	# true misbehavior in the main program.  If you're concerned about
	# that, just comment out the next instruction and instead sprinkle
	# your main code with "CS NEWJOB" instructions at strategic points.
	CAE	NEWJOB

	XCH	ARUPT		# Restore A, and exit the interrupt
	RESUME

START
	# Set up the TIME3 interrupt, T3RUPT.  TIME3 is a 15-bit
	# register at address 026, which automatically increments every
	# 10 ms, and a T3RUPT interrupt occurs when the timer
	# overflows.  Thus if it is initially loaded with 037766,
	# and overflows when it hits 040000, then it will
	# interrupt after 100 ms.
	CA	T3-100MS
	TS	TIME3

	CAF	NOLIGHTS
	EXTEND
	WRITE	0163	# disable restart light (io channel 0163)
	CAF	NUMBLANK
	EXTEND
	WRITE	010	# write to display (io channel oct 10) !weird bin for numbers! check developer.html

	CA	ZEROREG	# Set A to Zero
	TS	RAND6	# Set Rand6 to Zero(A)


LOOP	CCS	RAND6
	TCF	STEP	# RAND6 > 0 (A = RAND6-1)
	CAF	FIVE	# RAND6 = 0, make it 5 again
STEP	TS	RAND6	# Safe new num to Rand6
	TCF	LOOP	# Loop again (to contantly get new num)


BUTTON	INDEX	RAND6	# get correct display num for what is in Rand6
	CAF	NUMDATA0
	EXTEND
	WRITE	010	# write to display (io channel oct 10) !weird bin for numbers! check developer.html
	XCH	ARUPT
	RESUME		# resume last program (in this case no other interupts; so to START)


NUMDATA0	DEC	12291	# display 1
	DEC	12313	# display 2
	DEC	12315	# display 3
	DEC	12303	# display 4
	DEC	12318	# display 5
	DEC	12316	# display 6
	DEC	12307	# display 7; not used
	DEC	12317	# display 8; not used
	DEC	12319	# display 9; not used
	DEC	12309	# display 0; not used
NUMBLANK	DEC	12288	# display _

NOLIGHTS	DEC	0
NEWJOB	EQUALS	67
FIVE	DEC	5
RAND6	=	1234	# some EB location
ARUPT	EQUALS	10
TIME3	EQUALS	26
T3-100MS	OCT	37766
ZEROREG	=	07	# Zero register.
A	=	0	# A register.
