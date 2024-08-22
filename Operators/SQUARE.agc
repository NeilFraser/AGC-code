# Minimal demo of the SQUARE operator.

		SETLOC	4000
		INHINT

				# SQUARE multiplies the 'A' register by itself.

		CAF FIVE		# Load 5 into 'A' register.
		EXTEND
		SQUARE		# Square 'A' register.
		NOOP		# 'A' is 0, 'L' is 25.

END		TCF END

FIVE		DEC	5
A		=	0	# "SQUARE" actually compiles to "MP A", so "A" is needed.
