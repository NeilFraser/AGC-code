		SETLOC	4000
		INHINT

				# DIM decreases the absolute value.
				# Positive numbers decrement.
				# Negative numbers increment.

		CAF FIVE	# Load 5 into 'A' register.
		EXTEND
		DIM A		# Diminish the 'A' register.
		NOOP		# 'A' register now contains 4.

		CAF -TEN	# Load -10 into 'A' register.
		EXTEND
		DIM A		# Diminish the 'A' register.
		NOOP		# 'A' register now contains -11.

		COM		# Negate to see 11.

END		TCF END

A		=	0
FIVE		DEC	5
-TEN		DEC	-10
