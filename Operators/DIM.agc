# Minimal demo of the DIM operator.

		SETLOC	4000
		INHINT

				# DIM decreases the absolute value.
				# Positive numbers decrement.
				# Negative numbers increment.

		CAF FIVE	# Load 5 into 'A' register.
		EXTEND
		DIM A		# Diminish the 'A' register.
		NOOP		# 'A' register now contains 4.

		CAF -TEN	# Load -10 into 'A' register (65525).
		EXTEND
		DIM A		# Diminish the 'A' register.
		NOOP		# 'A' register now contains -9 (65526).

		COM		# Negate to see 9.

END		TCF END

A		=	0
FIVE		DEC	5
-TEN		DEC	-10
