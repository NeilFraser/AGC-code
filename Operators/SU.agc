# Minimal demo of the SU operator.

		SETLOC	4000
		INHINT

				# SU subtracts a number from the 'A' register, must be in EraseableMem(0ct 0-1777)

		CAF TWO		# Load 2 into 'A' register.
		ADS 1234	# Store 2 into memory location 1234.
		CAF FIVE	# Load 5 into 'A' register.
		EXTEND
		SU 1234		# Subtract 2 from 'A' register.
		NOOP		# 'A' register now contains 3.

END		TCF END

FIVE		DEC	5
TWO		DEC	2
