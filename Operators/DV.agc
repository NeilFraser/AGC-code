# Minimal demo of the DV operator.

		SETLOC	4000
		INHINT

				# DV divides a value in memory by the 'A' register.
				# Number in memory has to be bigger than A! (output only -1 to 1)

		CAF TEN		# Load 10 into 'A' register.
		TS 1234		# Store 10 into memory location 1234.
		CAF FIVE	# Load 5 into 'A' register.
		EXTEND
		DV 1234		# Divide 5 by 10.
		NOOP		# 'A' register now contains 0.5 (8192).

END		TCF END

FIVE		DEC	5
TEN		DEC	10
