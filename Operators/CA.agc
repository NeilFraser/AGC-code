# Minimal demo of the CA operator.

		SETLOC	4000
		INHINT

				# CA sets the 'A' register to a register value.

		CAF FIVE		# Load 5 into 'A' register.
		CA ZERO		# Clear and add 0 into 'A' register.
		NOOP		# 'A' regsiter now contains 0.

END		TCF END


FIVE		DEC	5
ZERO		=	7
