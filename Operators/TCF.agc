# Minimal demo of the TCF operator.

		SETLOC	4000
		INHINT

				# TCF is a jump to a label.

START		EXTEND
		AUG 0		# Increment the 'A' register (address 0).
		TCF START		# Infinite loop.

