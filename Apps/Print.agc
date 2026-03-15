# Copyright:	Public domain.
# Filename:	Print.agc
# Purpose:	Demonstrating a minimal AGC program that
#		counts in memory.  Handles all the alarms
#		which cause reboots.
# Assembler:	yaYUL
# Contact:	Lena Ku <lenaku@163.com>
# Contact:	Neil Fraser <agc@neil.fraser.name>

# Interrupts, must have 4 lines per interrupt
				SETLOC	4000

# Power up
				CA		100MS	# Schedule T5 soon.
				TS		T5
				TC		START
				NOOP

# T6 (interrupt #1)
				RESUME
				NOOP
				NOOP
				NOOP

# T5 (interrupt #2)
				XCH		ARUPT
				CAF		100MS	# Reschedule T5 soon.
				TS		T5
				TC		T5RUPT

# T3 (interrupt #3)
				RESUME
				NOOP
				NOOP
				NOOP

# T4 (interrupt #4)
				RESUME
				NOOP
				NOOP
				NOOP

# DSKY1 (interrupt #5)
				RESUME
				NOOP
				NOOP
				NOOP

# DSKY2 (interrupt #6)
				RESUME
				NOOP
				NOOP
				NOOP

# Uplink (interrupt #7)
				RESUME
				NOOP
				NOOP
				NOOP

# Downlink (interrupt #8)
				RESUME
				NOOP
				NOOP
				NOOP

# Radar (interrupt #9)
				RESUME
				NOOP
				NOOP
				NOOP

# Hand controller (interrupt #10)
				RESUME
				NOOP
				NOOP
				NOOP

T5RUPT			CA		NEWJOB	# Tickle the night watchman.
				XCH		ARUPT
				RESUME

NEWJOB			=		67
T5				=		30
100MS			OCT		37766
ARUPT			=		10

# #################################################
# Function that allows users to specify a digit
# (0-9 or blank) and the position on the 3 x 5
# display (rows x columns) to print it to.

# Final version: Print user-specified digit in the
# user-specified position while retaining the digit
# in the other position of the position pair.
#
# Still needs to be debugged.
# #################################################

CONSTDIG		DEC		8
CONSTROW		DEC		1
CONSTCOL		DEC		4

# Load arguments (digit, row and colum to print to)
# into erasable memory locations and hand over
# control to the print function.
# Normally, the arguments would be loaded into
# ROW, COLUMN, and DIGIT by the calling function.
START			CA		CONSTDIG
				TS 		DIGIT
				CA		CONSTROW
				TS		ROW
				CA		CONSTCOL
				TS		COLUMN
				TCR		PRINTDIG
				TCF		START


GPOSIDX			CA		ROW
				EXTEND
				MP		FIVE
				CA		L
				AD		COLUMN
				INCR	A
				TS		POSIDX
				RETURN


# The index of the position pair is obtained according to (with m representing the row
# and n the column; both zero-indexed): idx = floor((m*5+n+1)/2)
GPAIRIDX		CA		Q	# store return address
				TS		GPRIDXR
				TCR		GPOSIDX
				CA		POSIDX
				TS		SR
				CA		SR
				TS		PAIRIDX
				CA		GPRIDXR	# restore return address
				TS		Q
				RETURN

GPREF			CA		Q	# store return address
				TS		GPREFR
				TCR		GPAIRIDX
				INDEX	PAIRIDX
				CA		POSPAIRS
				TS		PREFIX
				CA		GPREFR	# restore return address
				TS		Q
				RETURN

GCURRDIG		CA		Q	# store return address
				TS		GCRRDIGR
				TCR		GPAIRIDX
				CA		MSKR
				INDEX	PAIRIDX
				MASK 	DISPSTAT
				TS		CURRDIG
				CA		GCRRDIGR	# restore return address
				TS		Q
				RETURN

GCURLDIG		CA		Q	# store return address
				TS		GCRLDIGR
				TCR		GPAIRIDX
				CA		MSKL
				INDEX	PAIRIDX
				MASK	DISPSTAT
				TS		CURLDIG
				CA		GCRLDIGR	# restore return address
				TS		Q
				RETURN

GDIGS			CA		Q	# store return address
				TS		GDIGSR
				TCR		GPOSIDX
				CA		POSIDX
				#TS		CYR	# do this either with a MASK or by shift right then left
				#CA		CYR
				TS		SR	# check if POSIDX even or odd; if odd branch
				CA		SR
				EXTEND
				MP		TWO
				CA		L
				EXTEND
				SU		POSIDX
				INCR	A
				EXTEND
				BZF		LABEL2
				INDEX	DIGIT	# even=left
				CA		DIGITS
				EXTEND
				MP		SHFTDIGL
				CA		L
				TS		LDIG
				TCR		GCURRDIG	# retrieve right digit currently displayed
				CA		CURRDIG
				TS		RDIG
				TCF		LABEL3	# or should i use BZ(M)F????
LABEL2			INDEX	DIGIT	# odd=right
				CA		DIGITS
				TS		RDIG
				TCR		GCURLDIG	# retrieve left digit currently displayed
				CA		CURLDIG
				TS		LDIG
LABEL3			CA		GDIGSR	# restore return address
				TS		Q
				RETURN

PRINTDIG		CA		Q	# store return address to afterwards restore it
				TS		PRNTDIGR
				TCR		GPREF
				TCR		GDIGS
				CA		PREFIX	# construct the digit pair representation (prefix, left digit and right digit)
				AD		LDIG
				AD		RDIG
				TS		DIGPAIR
				TCR		GPAIRIDX
				CA		DIGPAIR	#----added this line to debug
				EXTEND
				INDEX 	PAIRIDX	# indexing does not reset the extracode flag (EXTEND should apply to SU)
				SU		DISPSTAT
				EXTEND
				BZF		LABEL1
				#CA		DIGPAIR	# moved two lines down
				TCR		GPAIRIDX	# we already call it in this function; do we have to do it again here???
				CA		DIGPAIR
				INDEX	PAIRIDX	# write the DIGPAIR to the state DISPSTAT
				TS		DISPSTAT
				EXTEND
				WRITE	010
				CA		PRNTDIGR	# restore return address
				TS		Q
LABEL1			RETURN

# The prefixes to address the different display position pairs
POSPAIRS		DEC		16384	# Prefix of first display position pair: (0,0) (no true pair)
				DEC		14336	# Prefix of second display position pair: (0,1)-(0,2) (first true pair)
				DEC		12288
				DEC		10240
				DEC		8192
				DEC		6144
				DEC		4096
				DEC		2048	# Prefix of last display position pair: (2,3)-(2,4)

# Bit representation of the digits in the right position of the position pair.
# To place them in the left position, shift five bits left.
DIGITS			DEC		21	# Bit representation of (right position) 0
				DEC		3
				DEC		25
				DEC		27
				DEC		15
				DEC		30
				DEC		28
				DEC		19
				DEC		29
				DEC		31	# Bit representation of (right position) 9
				DEC		0	# Bit representation of (right position) blank

TWO				DEC		2
FIVE			DEC		5

SHFTDIGL		DEC		32

MSKR			DEC		31
MSKL			DEC		992



DIGIT			=		061
ROW				=		062
COLUMN			=		063

POSIDX			=		064
PAIRIDX			=		065
PREFIX			=		066

CURLDIG			=		070
CURRDIG			=		071

LDIG			=		072
RDIG			=		073
DIGPAIR			=		074

GPRIDXR			=		075
GPREFR			=		076
GCRRDIGR		=		077
GCRLDIGR		=		0100
GDIGSR			=		0101
PRNTDIGR		=		0102

DISPSTAT		=		0103
PRFX1			=		0104
PRFX2			=		0105
PRFX3			=		0106
PRFX4			=		0107
PRFX5			=		0110
PRFX6			=		0111
PRFX7			=		0112

# The memory addresses of the different registers we are using
A				=		00
L				=		01
Q				=		02
CYR				=		020
SR				=		021

#				BANK	0
#				SETLOC	0

#DISPSTAT		ERASE	8
