		SETLOC	4000
		INHINT

				# DOUBLE multiplies the 'A' register by 2.

		CAF FIVE	# Load 5 into 'A' register.
		DOUBLE		# Add 'A' register to itself.
		NOOP		# 'A' register now contains 10.

END		TCF END

FIVE		DEC	5
A		=	0	# "DOUBLE" actually compiles to "AD A", so "A" is needed.
