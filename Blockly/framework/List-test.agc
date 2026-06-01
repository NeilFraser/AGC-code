# Unit tests for the List functions.

# TEST: SET

	CA	NUM4		# list[0] -> 4
	TCR	PUSH
	CA	NUM0
	TCR	PUSH
	TCR	LS-SET
	CA	NUM2		# list[1] -> 2
	TCR	PUSH
	CA	NUM1
	TCR	PUSH
	TCR	LS-SET

	CA	NUM4		# Test that list[0] == 4
	TCR	PUSH
	CA	NUM0
	TCR	PUSH
	TCR	LS-GET
	TCR	PUSH
	TCR	TS-EQUAL

	CA	NUM2		# Test that list[1] == 2
	TCR	PUSH
	CA	NUM1
	TCR	PUSH
	TCR	LS-GET
	TCR	PUSH
	TCR	TS-EQUAL
