
# TEST: ADD

	CA	NUM1		# 1 + 2 = 3
	TCR	PUSH
	CA	NUM2
	TCR	PUSH
	TCR	MA-AD
	# Diminish three times, checking each time it's not zero.
	EXTEND
	BZF	TSMA-F
	EXTEND
	DIM	A
	EXTEND
	BZF	TSMA-F
	EXTEND
	DIM	A
	EXTEND
	BZF	TSMA-F
	EXTEND
	DIM	A
	EXTEND			# Make sure it's now zero.
	BZF	TSMA-AD1
	TCF	TSMA-F
TSMA-AD1	NOOP

	CA	NUM3		# -3 + 3 = 0
	COM
	TCR	PUSH
	CA	NUM3
	TCR	PUSH
	TCR	MA-AD
	EXTEND			# Make sure it's now zero.
	BZF	TSMA-AD2
	TCF	TSMA-F
TSMA-AD2	NOOP


# TEST: SUBTRACT

	CA	NUM5		# 5 - 3 = 2
	TCR	PUSH
	CA	NUM3
	TCR	PUSH
	TCR	MA-SU
	# Diminish twice, checking each time it's not zero.
	EXTEND
	BZF	TSMA-F
	EXTEND
	DIM	A
	EXTEND
	BZF	TSMA-F
	EXTEND
	DIM	A
	EXTEND			# Make sure it's now zero.
	BZF	TSMA-SU1
	TCF	TSMA-F
TSMA-SU1	NOOP


# TEST: MULTIPLY

	CA	NUM2		# 2 * 3 = 6
	TCR	PUSH
	CA	NUM3
	TCR	PUSH
	TCR	MA-MP
	TCR	PUSH
	CA	NUM6
	TCR	PUSH
	TCR	MA-SU
	EXTEND			# Make sure it's now zero.
	BZF	TSMA-MP1
	TCF	TSMA-F
TSMA-MP1	NOOP


	TCF	TSMA-END	# Skip execution past the private functions.

TSMA-F	TCF	TSMA-F		# Test failed.  Trigger TC Trap.


TSMA-END NOOP
