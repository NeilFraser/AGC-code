# Minimal demo of the AD operator.

		SETLOC	4000
		INHINT

				# AD adds a number to the 'A' register.

		CAF FIVE	# Load 5 into 'A' register.
		AD SIX		# Add 6 to 'A' register.
		NOOP		# 'A' register now contains 11.

END		TCF END

FIVE		DEC	5
SIX		DEC	6
