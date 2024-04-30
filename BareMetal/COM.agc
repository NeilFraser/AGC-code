		SETLOC	4000
		INHINT

				# COM negates the 'A' register.

		CAF FIVE	# Load 5 into 'A' register.
		COM		# Negate
		NOOP		# 'A' register now contains -5 (32762).
		COM		# Negate
		NOOP		# 'A' register now contains 5.

END		TCF END

FIVE		DEC	5
A		=	0	# "COM" actually compiles to "CS A", so "A" is needed.
