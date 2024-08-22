# Minimal demo of the XCH operator.

		SETLOC	4000
		INHINT

				# XCH swaps the 'A' register and memory.

		CAF FIVE		# Load 5 into 'A' register.
		TS 1234		# Load 5 into memory.
		CAF SIX 		# Load 6 into 'A' register.

		XCH 1234
		NOOP		# 'A' register now contains 5.
		XCH 1234
		NOOP		# 'A' register now contains 6.

END		TCF END

FIVE		DEC	5
SIX		DEC	6
