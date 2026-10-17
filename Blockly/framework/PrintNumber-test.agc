# Unit tests for the Print number function.

# Prints the following test pattern on the DSKY:
#       1 2 3
#     1 2 3 4
#   1 2 3 4 5

		CA	NUM123
		TCR	PUSH
		CA	NUM0
		TCR	PUSH
		TCR	PN

		CA	NUM1234
		TCR	PUSH
		CA	NUM1
		TCR	PUSH
		TCR	PN

		CA	NUM12345
		TCR	PUSH
		CA	NUM2
		TCR	PUSH
		TCR	PN

		TCF TSPN-END

NUM123	DEC	123
NUM1234	DEC	1234
NUM12345	DEC	12345

TSPN-END	NOOP
