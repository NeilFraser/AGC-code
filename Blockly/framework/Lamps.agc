# Lamp functions.

# Turn off all lamps.
# Also initializes the status variable for channel 010.
LAMPINIT	# Set I/O channel 011 to zero.
		CA		NUM0
		EXTEND
		WRITE	011
		# Set I/O channel 0163 to zero.
		EXTEND
		WRITE	0163
		# Set 1100 prefix of I/O channel 010 to zero.
		CA		NUM24576
		TS		LAMP1100
		EXTEND
		WRITE	010
		RETURN


# Turn on or off a single lamp.
# Stack arguments:
#       Address of lamp (-256 to 256).
#       On (1) or off (0).
LAMP		EXTEND
		QXCH		QPOP
		TCR		POP	# Lamp address.
		EXTEND
		BZMF		LAMP-NEG
		# I/O 10: 3 VEL, 4 NO ATT, 5 ALT, 6 GIMBAL LOCK, 8 TRACKER, 9 PROG
		TS		TEMP-VAR
		TCR		POP	# State
		EXTEND
		BZF		LAMP10X
		CA		TEMP-VAR
		# Turn on the lamp.  Unfortunately there is no 'OR' operator.
		# Instead, we'll verify the lamp is off, then add the bit.
		MASK		LAMP1100
		EXTEND
		BZF		LAMP10Y
		TCF		LAMPEND	# Lamp already on.

LAMP10Y	# Turn on the lamp.
		CA		TEMP-VAR
		ADS		LAMP1100
		TCF		LAMP10W
LAMP10X	# Turn off the lamp.
		CA		TEMP-VAR
		COM
		MASK		LAMP1100
		TS		LAMP1100	# Fall through.
LAMP10W	# Write the new value to chanel 010.
		EXTEND
		WRITE	010
		TCF		LAMPEND

LAMP-NEG	# Negative lamp addresses go to I/O 163 or 11.
		COM
		# Boolean: lamp '>=' 2^8
		TS		TEMP-VAR
		CA		NUM128
		TS		Q
		CA		TEMP-VAR
		EXTEND
		SU		Q
		EXTEND
		BZMF		LAMP11
		# I/O 163: -8 RESTART, -9 STBY
		TCR		POP	# state
		EXTEND
		BZF		LAMP163X
		# Turn on the lamp.
		CA		TEMP-VAR
		EXTEND
		WOR		0163
		TCF		LAMPEND
LAMP163X	# Turn off the lamp.
		CA		TEMP-VAR
		COM
		EXTEND
		WAND		0163
		#TCF		LAMPEND

LAMP11	# I/O 11: -2 COMP ACTY, -3 COMP ACTY, -4 TEMP, -5 KEY REL, -7 OPR ERR
		TCR		POP	# state
		EXTEND
		BZF		LAMP11X
		# Turn on the lamp.
		CA		TEMP-VAR
		EXTEND
		WOR		011
		TCF		LAMPEND
LAMP11X	# Turn off the lamp.
		CA		TEMP-VAR
		COM
		EXTEND
		WAND		011
		TCF		LAMPEND

LAMPEND	EXTEND
		QXCH		QPOP
		RETURN

NUM24576	DEC	24576	# 1100 0 00000 00000b
LAMP1100	=	715
