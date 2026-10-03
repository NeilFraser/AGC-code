# Lamp functions.

# Turn on or off a single lamp.
# Stack arguments:
#       Address of lamp (-9 to 9).
#       On (1) or off (0).
# Uses L register.
LAMP	EXTEND
		QXCH	QPOP
		TCR	POP	# Lamp address.
		# Set A to the IO number, L to the lamp address.
		TS L
		EXTEND
		BZMF LAMP-NEG
		CA 010	# 3 VEL, 4 NO ATT, 5 ALT, 6 GIMBAL LOCK, 8 TRACKER, 9 PROG
		TCF LAMPSET

# Negative lamp addresses go to IO 163 or 11.
LAMP-NEG	COM
		TCR PUSH
		CA NUM8
		TCR PUSH
		# Boolean: lamp '>=' 8
		TCR	MA-SU
		TCR	BL-GTE
		EXTEND
		BZF LAMP-11
		CA 0163	# -8 RESTART, -9 STBY
		TCF LAMPSET

LAMP-11
		CA 011	# -2 COMP ACTY, -3 COMP ACTY, -4 TEMP, -5 KEY REL, -7 OPR ERR
		TCF LAMPSET


# A = io, L = lamp nr
# Sets the DSKY lamp using state & nr
LAMPSET	TS TEMP-VAR
		TCR	POP	# state
		EXTEND
		BZF LAMPOFF
		CA L
		EXTEND
		WOR	TEMP-VAR
		TCF LAMPEND

LAMPOFF	CA L
		COM
		EXTEND
		WAND	TEMP-VAR

LAMPEND	EXTEND
		QXCH	QPOP
		RETURN

