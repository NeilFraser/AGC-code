# Minimal demo of the TCR and RETURN operators.

		SETLOC	4000
		INHINT

				# TC jumps to a label, setting up a RETURN.

		TCR FUNC		# Jump
		NOOP

END		TCF END

FUNC		NOOP
		RETURN

Q		=	02	# "RETURN" actually compiles to "TC Q", so "Q" is needed.
