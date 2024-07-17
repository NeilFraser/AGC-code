		SETLOC	4000
		INHINT

				# MP multiplies the 'A' register with another number.

		CAF SIX	        # Load 5 into 'A' register.
		EXTEND
		MP SEVEN	# Multiply 6 * 7.
		NOOP		# 'L' register now contains 42.

END		TCF END

SIX		DEC	6
SEVEN		DEC	7
