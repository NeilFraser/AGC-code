		SETLOC	4000
		INHINT

				# BZMF jumps if 'A' is zero or negative.

START		CAF FIVE	# Load 5 into 'A' register.
		EXTEND
		BZMF START	# This branch does not happen. 

		CAF -FIVE	# Load -5 into 'A' register.
		EXTEND
		BZMF START	# This branch does happen.

		NOOP		# Never executed.

FIVE		DEC	5
-FIVE		DEC	-5
