# Minimal demo of the AUG operator.

		SETLOC	4000
		INHINT

				# AUG increases the absolute value.
				# Positive numbers increment.
				# Negative numbers decrement.

		CAF FIVE	# Load 5 into 'A' register.
		EXTEND
		AUG A		# Augment the 'A' register.
		NOOP		# 'A' register now contains 6.

		CAF -TEN	# Load -10 into 'A' register.
		EXTEND
		AUG A		# Augment the 'A' register.
		NOOP		# 'A' register now contains -11.

END		TCF END

A		=	0
FIVE		DEC	5
-TEN		DEC	-10
