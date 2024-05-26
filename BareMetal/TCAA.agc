		SETLOC	4000
		INHINT

				# TCAA jumps to the address in the 'A' register.

                NOOP            # 2049
                NOOP            # 2050 <- Jump point.
                NOOP            # 2051

		CAF ADDR	# Load 5 into 'A' register.
		TCAA		# Add 6 to 'A' register.

ADDR		DEC	2050
Z               =	05	# "TCAA" actually compiles to "TS Z", so "Z" is needed.
