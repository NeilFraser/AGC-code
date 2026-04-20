# Copyright:	Public domain.
# Filename:	Random-Number-Generator-test.agc
# Purpose:	An simple test program to initialize and run the pseudo-random
#		number generator (PRNG) defined in "Random-Number-Generator.agc"
#		and write its internal random state and generated random
#		number sequences to different yaAGC IO-channels for easy
#		inspection and statistical analysis (e.g., using the
#		"piPeripheral.py" script).
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



# ##############################################################################
# Setup and random number generation loop:
#
# Initializes the pseudo-random number generator (PRNG) state to CSEED using
# the INITGEN function.
# Then continuously generates new random integers in the range [0, CUPRBND-1]
# (GRNDNUM) and writes them, and the generator's corresponding internal states,
# to yaAGC IO-channels 10 (octal; normally used to drive DSKY 7-segment
# displays) and 11, respectively.
#
# The generator's random states and emitted numbers can then be captured by
# connecting to a yaAGC server port on localhost, e.g., using the
# "piPeripheral.py" script provided on the Virtual AGC Project's GitHub
# repository (https://github.com/virtualagc/virtualagc/tree/master/piPeripheral)
# ##############################################################################



# Import PRNG (INITGEN and GRNDNUM functions)
$Random-Number-Generator.agc

# Just a random number greater than 0 and less than MODULUS (see "Random-Number-
# Generator.agc" for the PRNG coefficients, including MODULUS).
CSEED		DEC	9601

# Upper bound (exclusive) of random numbers generated; i.e., random numbers are
# integers in [0, CUPRBND-1].
CUPRBND		DEC	7

START		CA	CSEED
		TS	SEED
		TCR	INITGEN
		CA	CUPRBND
		TS	UPRBND
LOOP		TCR	GRNDNUM
		CA	RNDNUM
		EXTEND
		WRITE	10
		CA	RNDSTATE
		EXTEND
		WRITE	11
		TCF	LOOP