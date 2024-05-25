		SETLOC	4000
		INHINT

				# ADS stores the 'A' register to memory.
				# CAE loads memory to the 'A' register.

		CAF FIVE	# Load 5 into 'A' register.
		ADS 1234	# Store 5 into memory location 1234.
		CA ZERO		# Zero out the 'A' register.
		CAE 1234	# Load memory location 1234 back into 'A' register.
		NOOP		# 'A' regsiter now contains 5.

END		TCF END

FIVE		DEC	5
ZERO		=	7
