# Minimal demo of the BZF operator.

		SETLOC	4000
		INHINT

				# BZF jumps if 'A' is zero.

START		CAF FIVE	# Load 5 into 'A' register.
		EXTEND
		BZF START	# This branch does not happen.

		CA ZERO		# Load 0 into 'A' register.
		EXTEND
		BZF START	# This branch does happen.

		NOOP		# Never executed.

FIVE	DEC	5
ZERO	=	7
