# Unit tests for the Print function.

# Prints the following test pattern on the DSKY:
#   0 3 6 9 1
#   1 4 7   2
#   2 5 8 0 3

	# Print '0' at column 0 (left), row 0 (top).
	CA	NUM0
	TCR	PUSH
	CA	NUM0
	TCR	PUSH
	CA	NUM0
	TCR	PUSH
	TCR	PRNTDIG

	# Print '3' at column 1, row 0 (top).
	CA	NUM3
	TCR	PUSH
	CA	NUM1
	TCR	PUSH
	CA	NUM0
	TCR	PUSH
	TCR	PRNTDIG

	# Print '6' at column 2, row 0 (top).
	CA	NUM6
	TCR	PUSH
	CA	NUM2
	TCR	PUSH
	CA	NUM0
	TCR	PUSH
	TCR	PRNTDIG

	# Print '9' at column 3, row 0 (top).
	CA	NUM9
	TCR	PUSH
	CA	NUM3
	TCR	PUSH
	CA	NUM0
	TCR	PUSH
	TCR	PRNTDIG

	# Print '1' at column 4 (right) row 0 (top).
	CA	NUM1
	TCR	PUSH
	CA	NUM4
	TCR	PUSH
	CA	NUM0
	TCR	PUSH
	TCR	PRNTDIG


	# Print '1' at column 0 (left), row 1 (middle).
	CA	NUM1
	TCR	PUSH
	CA	NUM0
	TCR	PUSH
	CA	NUM1
	TCR	PUSH
	TCR	PRNTDIG

	# Print '4' at column 1, row 1 (middle).
	CA	NUM4
	TCR	PUSH
	CA	NUM1
	TCR	PUSH
	CA	NUM1
	TCR	PUSH
	TCR	PRNTDIG

	# Print '7' at column 2, row 1 (middle).
	CA	NUM7
	TCR	PUSH
	CA	NUM2
	TCR	PUSH
	CA	NUM1
	TCR	PUSH
	TCR	PRNTDIG

	# Print ' ' at column 3, row 1 (middle).
	CA	NUM10
	TCR	PUSH
	CA	NUM3
	TCR	PUSH
	CA	NUM1
	TCR	PUSH
	TCR	PRNTDIG

	# Print '2' at column 4 (right), row 1 (middle).
	CA	NUM2
	TCR	PUSH
	CA	NUM4
	TCR	PUSH
	CA	NUM1
	TCR	PUSH
	TCR	PRNTDIG


	# Print '2' at column 0 (left), row 2 (bottom).
	CA	NUM2
	TCR	PUSH
	CA	NUM0
	TCR	PUSH
	CA	NUM2
	TCR	PUSH
	TCR	PRNTDIG

	# Print '5' at column 1, row 2 (bottom).
	CA	NUM5
	TCR	PUSH
	CA	NUM1
	TCR	PUSH
	CA	NUM2
	TCR	PUSH
	TCR	PRNTDIG

	# Print '8' at column 2, row 2 (bottom).
	CA	NUM8
	TCR	PUSH
	CA	NUM2
	TCR	PUSH
	CA	NUM2
	TCR	PUSH
	TCR	PRNTDIG

	# Print '0' at column 3, row 2 (bottom).
	CA	NUM0
	TCR	PUSH
	CA	NUM3
	TCR	PUSH
	CA	NUM2
	TCR	PUSH
	TCR	PRNTDIG

	# Print '3' at column 4 (right), row 2 (bottom).
	CA	NUM3
	TCR	PUSH
	CA	NUM4
	TCR	PUSH
	CA	NUM2
	TCR	PUSH
	TCR	PRNTDIG
