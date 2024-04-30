		SETLOC	4000
		INHINT

				# LXCH swaps 'L' register with a memory location.
				# QXCH swaps 'Q' register with a memory location.

		CAF TEN		# Load 10 into 'A' register.
		TS L		# Store 10 to 'L' register.
		CAF FIVE	# Load 5 into 'A' register.
		TS Q		# Store 5 to 'Q' register.
		NOOP		# 'L' is 10, 'Q' is 5.

		LXCH Q		# Swap 'L' and 'Q' registers.
		NOOP		# 'L' is 5, 'Q' is 10.

		EXTEND
		QXCH L		# Swap 'Q' and 'L' registers.
		NOOP		# 'L' is 10, 'Q' is 5.

END		TCF END

Q		=	2
L		=	1
TEN		DEC	10
FIVE		DEC	5
