# List functions.

# Set.
# Stack arguments:
#       Value.
#       Index.
# Uses L register.
LS-SET		EXTEND
		QXCH	QPOP
		TCR	POP	# Pop the index.
		TS	L
		TCR	POP	# Pop the value.
		TS	Q
		CAF	LIST-EB	# Switch to list memory bank.
		TS	EB
		CA	Q
		INDEX	L
		TS	LIST
		CAF	MAIN-EB	# Switch back to main memory bank.
		TS	EB
		EXTEND
		QXCH	QPOP
		RETURN

# Get.
# Stack argument:
#       Index.
# Returns (on A):
#	Value.
LS-GET		EXTEND
		QXCH	QPOP
		TCR	POP	# Pop the index.
		TS	Q
		CAF	LIST-EB	# Switch to list memory bank.
		TS	EB
		INDEX	Q
		CA	LIST
		TS	Q
		CAF	MAIN-EB	# Switch back to main memory bank.
		TS	EB
		CA	Q
		EXTEND
		QXCH	QPOP
		RETURN


LIST-EB		OCT	2000	# E4 erasable memory bank used by list.
LIST		=	1400	# Address at start of bank.
