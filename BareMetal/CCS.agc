		SETLOC	4000
		INHINT

				# CCS jumps based on sign.

		CAF TWO         # Load 2 into 'A' register.
		TS L

LOOPDOWN        CCS L
                TCF DIMDOWN     # Positive
                NOOP            # +0 (Never reached)
                NOOP            # Negative
                TCF ENDDOWN     # -0 (End of loop)
DIMDOWN         EXTEND
                DIM L
                TCF LOOPDOWN
ENDDOWN         NOOP

		CAF -TWO        # Load -2 into 'A' register (65533).
		TS L

LOOPUP          CCS L
                NOOP            # Positive
                NOOP            # +0 (Never reached)
                TCF DIMUP       # Negative
                TCF ENDUP       # -0 (End of loop)
DIMUP           EXTEND
                DIM L
                TCF LOOPUP
ENDUP           NOOP

END		TCF END

-TWO		DEC	-2
TWO		DEC	2
L               =       01
