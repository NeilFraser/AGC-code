# Minimal demo of the MASK operator.

		SETLOC	4000
		INHINT

				# MASK bitwise ANDs the 'A' register with another number.

		CAF NINE		# Load 9 into 'A' register.
		MASK TWELVE		# AND 9, 12.
		NOOP		# 'A' register now contains 8 (1000).

END		TCF END

NINE		DEC	9	# 1001
TWELVE		DEC	12	# 1100
