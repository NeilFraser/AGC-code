# Minimal demo of the TCAA operator.

		SETLOC	4000
		INHINT

				# TCAA jumps to the address in the 'A' register.

		NOOP		# 2049
		NOOP		# 2050 <- Jump point.
		NOOP		# 2051

		CAF ADDR		# Load 2050 into 'A' register.
		TCAA		# Transfer control to 'A' register address.

ADDR		DEC	2050
Z		=	05	# "TCAA" actually compiles to "TS Z", so "Z" is needed.
