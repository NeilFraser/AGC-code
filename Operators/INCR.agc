# Minimal demo of the INCR operator.

		SETLOC	4000
		INHINT

				# DIM decreases the absolute value.
				# Positive numbers increment.
				# Negative numbers increment.

		CAF FIVE	# Load 5 into 'A' register.
		INCR A		# Diminish the 'A' register.
		NOOP		# 'A' register now contains 6.

		CAF -TEN	# Load -10 into 'A' register (65525).
		INCR A		# Diminish the 'A' register.
		NOOP		# 'A' register now contains -9 (65526).

		COM		# Negate to see 9.

END		TCF END

A		=	0
FIVE		DEC	5
-TEN		DEC	-10
