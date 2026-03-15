# Minimal demo of the CA operator.

		SETLOC	4000
		INHINT

				# The 'CYR' register rotates a value right by one bit.
				# The 'CYL' register rotates a value left by one bit.
				# The 'SR' register shifts a value right by one bit.

		CAF NUM32		# Load 32 into 'A' register.
		TS CYR		# Rotate 32 right: 'CYR' now contains 16.
		CA CYR		# 'A' register now contains 16, 'CYR' is now 8.
		TS CYL		# Rotate 16 left: 'CYL' now contains 32.
		CA CYL		# 'A' register now contains 32, 'CYL' is now 64.
		TS SR		# Divide 32 by 2: 'SR' now contains 16.
		CA SR		# 'A' register now contains 16, 'SR' is now 8.

END		TCF END


NUM32	DEC	32
CYR	=	20
SR	=	21
CYL	=	22
