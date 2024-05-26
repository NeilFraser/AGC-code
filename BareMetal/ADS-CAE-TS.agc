		SETLOC	4000
		INHINT

				# TS stores the 'A' register to memory.
				# ADS adds the 'A' register to memory.
				# CAE loads memory to the 'A' register.

		CAF FIVE	# Load 5 into 'A' register.
		TS MEMORY 	# Store 5 into a memory location.

		CAF SIX 	# Load 6 into 'A' register.
		ADS MEMORY 	# Add 6 into the memory location.

		CAE MEMORY	# Load memory the memory location back into 'A' register.
		NOOP		# 'A' regsiter now contains 11.

END		TCF END

FIVE		DEC	5
SIX             DEC     6
MEMORY          =       1234    # Some erasable memory location.
