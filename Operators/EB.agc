		SETLOC	4000
		INHINT

				# The EB register sets which erasable memory bank is active.

		CAF	E0	# Switch to E0 and load 10.
		TS	EB
		CAF	TEN
		TS	MEM-67

		CAF	E1	# Switch to E1 and load 11.
		TS	EB
		CAF	ELEVEN
		TS	MEM-67

		CAF	E2	# Switch to E2 and load 12.
		TS	EB
		CAF	TWELVE
		TS	MEM-67

		CAF	E3	# Switch to E3 and load 13.
		TS	EB
		CAF	THIRTEEN
		TS	MEM-67

		CAF	E4	# Switch to E4 and load 14.
		TS	EB
		CAF	FOURTEEN
		TS	MEM-67

		CAF	E5	# Switch to E5 and load 15.
		TS	EB
		CAF	FIFTEEN
		TS	MEM-67

		CAF	E6	# Switch to E6 and load 16.
		TS	EB
		CAF	SIXTEEN
		TS	MEM-67

		CAF	E7	# Switch to E7 and load 17.
		TS	EB
		CAF	SEVENTEEN
		TS	MEM-67

		CAF	E0	# Switch back to E0.
		TS	EB
		CAE	MEM-67	# 'A' register now contains 10.
		CAE	E0-67	# 'A' register now contains 10.

		CAF	E1	# Switch back to E1.
		TS	EB
		CAE	MEM-67	# 'A' register now contains 11.
		CAE	E1-67	# 'A' register now contains 11.

		CAF	E2	# Switch back to E2.
		TS	EB
		CAE	MEM-67	# 'A' register now contains 12.
		CAE	E2-67	# 'A' register now contains 12.

		CAF	E3	# Switch back to E3.
		TS	EB
		CAE	MEM-67	# 'A' register now contains 13.

		CAF	E4	# Switch back to E4.
		TS	EB
		CAE	MEM-67	# 'A' register now contains 14.

		CAF	E5	# Switch back to E5.
		TS	EB
		CAE	MEM-67	# 'A' register now contains 15.

		CAF	E6	# Switch back to E6.
		TS	EB
		CAE	MEM-67	# 'A' register now contains 16.

		CAF	E7	# Switch back to E7.
		TS	EB
		CAE	MEM-67	# 'A' register now contains 17.

END		TCF END

# Eight unique numbers to test the banks.
TEN		DEC	10
ELEVEN		DEC	11
TWELVE		DEC	12
THIRTEEN	DEC	13
FOURTEEN	DEC	14
FIFTEEN		DEC	15
SIXTEEN		DEC	16
SEVENTEEN	DEC	17

# Addresses for switching EB between different banks.
E0		OCT	0
E1		OCT	400
E2		OCT	1000
E3		OCT	1400
E4		OCT	2000
E5		OCT	2400
E6		OCT	3000
E7		OCT	3400

# The register that switches banks.
EB		=	03
# Switchable address to test.
MEM-67		=	1467
# Overlapped address locations.
E0-67		=	67
E1-67		=	467
E2-67		=	1067
