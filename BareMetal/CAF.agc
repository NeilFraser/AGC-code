		SETLOC	4000
		INHINT

				# CAF sets the 'A' register to a fixed memory value.

		CAF FIVE	# Load 5 into 'A' register.
		NOOP		# 'A' regsiter now contains 5.

END		TCF END

FIVE		DEC	5
