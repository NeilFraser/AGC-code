# List functions.

# Set.
# Stack arguments:
#       Value.
#       Index.
# Uses L register.
LS-SET		EXTEND
		QXCH	QPOP
		TCR	POP	# Pop the index.
		COM
		TS	L
		TCR	POP	# Pop the value.
		INDEX	L
		TS	LIST
		EXTEND
		QXCH	QPOP
		RETURN
