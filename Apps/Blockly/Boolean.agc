# The six equality operators start by pushing two values on the stack then
# calling MA-SU followed by various chained calls are made depending on which
# operator is needed.
# In all cases, if 0 is returned on the A register, then the operator is false.
# The true value may be any non-zero number.
# Calls for '==':
# 	TCR	MA-SU
# 	TCR	BL-NOT
# Calls for '!=':
# 	TCR	MA-SU
# Calls for '<':
# 	TCR	MA-SU
# 	TCR	BL-LT
# Calls for '>':
# 	TCR	MA-SU
# 	TCR	BL-GT
# Calls for '<=':
# 	TCR	MA-SU
# 	TCR	BL-GT
# 	TCR	BL-NOT
# Calls for '>=':
# 	TCR	MA-SU
# 	TCR	BL-LT
# 	TCR	BL-NOT


# Suffix functions to MA-SU.
# BL-GT returns 1 if first '>' second.
# BL-LT returns 1 if first '<' second.
BL-GT		COM
BL-LT		EXTEND
		BZMF	BL-1	# Return with 1.
		TCF	BL-0	# Return with 0.

# Reverses zero and non-zero.
BL-NOT		EXTEND
		BZF	BL-1
BL-0		CA	NUM0
		RETURN
BL-1		CA	NUM1
		RETURN


# OR operator.
# Stack arguments:
#       First value.
#       Second value.
# Returns (on A):
#	Second value if it is non-zero, otherwise first value.
BL-OR		EXTEND
		QXCH	QPOP
		TCR	POP	# Pop the second value.
		EXTEND
		BZF	BL-OR2
		# Second value was non-zero.  Return it.
		TCR	DROP	# Throw away the first value.
		TCF	BL-ORX
		# Second value was a zero.  Return the first value.
BL-OR2		TCR	POP
BL-ORX		EXTEND
		QXCH	QPOP
		RETURN


# AND operator.
# Stack arguments:
#       First value.
#       Second value.
# Returns (on A):
#	Second value if it is non-zero, otherwise first value.
BL-AND		EXTEND
		QXCH	QPOP
		TCR	POP	# Pop the second value.
		EXTEND
		BZF	BL-AND0
		# Second value was non-zero.  Return first value.
		TCR	POP
		TCF	BL-ANDX
		# Second value was a zero.  Return it.
BL-AND0		TCR	DROP	# Throw away the first value.
BL-ANDX		EXTEND
		QXCH	QPOP
		RETURN


# Inline conditional operator (a ? b : c).
# Stack arguments:
#       If-false value (c).
#       If-true value (b).
#	Conditional value (a).
# Returns (on A):
#	If-false value if conditional value is zero, otherwise if-true value.
BL-COND		EXTEND
		QXCH	QPOP
		TCR	POP	# Pop the conditional value.
		EXTEND
		BZF	BL-COND0
		# Conditional value was non-zero.  Return if-true value.
		TCR	POP	# Pop the if-true value.
		TCR	DROP	# Throw away the if-false value.
		TCF	BL-CONDX
		# Conditional value was a zero.  Return if-false value.
BL-COND0	TCR	DROP	# Throw away the if-true value.
		TCR	POP	# Pop the if-false value.
BL-CONDX	EXTEND
		QXCH	QPOP
		RETURN
