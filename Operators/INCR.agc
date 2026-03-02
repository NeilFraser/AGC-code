# Minimal demo of the INCR operator.

		SETLOC	4000
		INHINT

				# INCR increases the value by +1.
				# Positive numbers increment.
				# Negative numbers increment.

		CAF FIVE		# Load 5 into 'A' register.
		INCR A		# Increment the 'A' register.
		NOOP		# 'A' register now contains 6.

		CAF -TEN		# Load -10 into 'A' register (65525).
		INCR A		# Increment the 'A' register.
		NOOP		# 'A' register now contains -9 (65526).

		COM		# Negate to see 9.

END		TCF END

A		=	0
FIVE		DEC	5
-TEN		DEC	-10
