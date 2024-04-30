		SETLOC	4000
		INHINT

				# CS sets 'A' register to contain the negative of a value.

		CS TWO		# Load -2 into 'A' register.
		AD FIVE		# Add 5 to 'A' register.
		NOOP		# 'A' regsiter now contains 3.

END		TCF END

TWO		DEC	2
FIVE		DEC	5
