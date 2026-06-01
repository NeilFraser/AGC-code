# Math functions.

# Addition.
# Stack arguments:
#       First value.
#       Second value.
# Returns (on A):
#	Both values added.
# Uses L register.
MA-AD		EXTEND
		QXCH	QPOP
		TCR	POP	# Pop the second value.
		TS	L
		TCR	POP	# Pop the first value.
		AD	L	# Add both values together.
		EXTEND
		QXCH	QPOP
		RETURN

# Subtraction.
# Stack arguments:
#       First value.
#       Second value.
# Returns (on A):
#	Second value minus first value.
# Uses L register.
MA-SU		EXTEND
		QXCH	QPOP
		TCR	POP	# Pop the second value.
		TS	L
		TCR	POP	# Pop the first value.
		TS	Q
		# Subtract the first value on the stack from the second value.
		CA	L
		EXTEND
		SU	Q
		EXTEND
		QXCH	QPOP
		RETURN


# Multiplication
# Stack arguments:
#       First value.
#       Second value.
# Returns (on A):
#	Both values multiplied together.
# Uses L register.
MA-MP		EXTEND
		QXCH	QPOP
		TCR	POP	# Pop the second value.
		TS	L
		TCR	POP	# Pop the first value.
		# Multiply the first value on the stack with the second value.
		EXTEND
		MP	L
		CA	L
		EXTEND
		QXCH	QPOP
		RETURN
