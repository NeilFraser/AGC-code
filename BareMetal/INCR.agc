		SETLOC	4000
		INHINT

				# INCR increments a value in memory.

		CAF TEN		# Load 10 into 'A' register.
		TS 1234		# Store 10 into memory location 1234.
		INCR 1234	# Increment memory location 1234.
		CAE 1234	# 'A' register now contains 11.

END		TCF END

TEN		DEC	10
