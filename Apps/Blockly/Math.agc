
# Addition.
# Stack arguments:
#       First value.
#       Second value.
# Returns (on A):
#	Both values added.
MA-AD		EXTEND
		QXCH	QPOP
		TCR	POP	# Pop the second value.
		# Add the first value on the stack to the second value.
		INDEX	STACKPTR
		AD	STACK
		TCR	DROP	# Throw away the first value.
		EXTEND
		QXCH	QPOP
		RETURN

# Subtraction.
# Stack arguments:
#       First value.
#       Second value.
# Returns (on A):
#	First value minus second value.
MA-SU		EXTEND
		QXCH	QPOP
		TCR	POP	# Pop the second value.
		# Subtract the first value on the stack from the second value.
		EXTEND
		INDEX	STACKPTR
		SU	STACK
		TCR	DROP	# Throw away the first value.
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
		# Multiply the first value on the stack with the second value.
		EXTEND
		INDEX	STACKPTR
		MP	STACK
		CA	L
		TCR	DROP	# Throw away the first value.
		EXTEND
		QXCH	QPOP
		RETURN
