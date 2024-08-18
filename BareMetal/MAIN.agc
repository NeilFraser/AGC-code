# Interrupts, must have 4 lines per interrupt
	SETLOC	4000

	# Power up
	TCF	START
	NOOP
	NOOP
	NOOP

	# T6 (interrupt #1)
	DXCH	ARUPT	# Back up A,L register
	EXTEND
	QXCH	QRUPT
	TCF	T6RUPT

	# T5 (interrupt #2)
	RESUME
	NOOP
	NOOP
	NOOP

	# T3 (interrupt #3)
	XCH	ARUPT	# Back up A register
	TCF	T3RUPT
	NOOP
	NOOP

	# T4 (interrupt #4)
	RESUME
	NOOP
	NOOP
	NOOP

	# DSKY1 (interrupt #5)
	DXCH	ARUPT	# Back up A,L register
	EXTEND
	QXCH	QRUPT
	TCF	KEYRUPT1

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


# Time3 interrupt every 100 ms.
# No inputs or outputs.
T3RUPT	CAF	T3-100MS	# Schedule another T3RUPT in 100 ms
	TS	TIME3

	CAE	NEWJOB	# Tickle NEWJOB to keep Night Watchman GOJAMs from happening

	XCH	ARUPT	# Restore A, and exit the interrupt
	RESUME


# Time6 interrupt.  Every second when blinking a winner.  One second single call on OPP-ERR.
# No inputs or outputs.
T6RUPT	CA	OPR-ERR	# Turn off OPR-ERR lamp (even if its not on...)
	COM
	EXTEND
	WAND	LAMP163
	CA	TURN	# Check if Game Over
	EXTEND
	BZF	T6WIN	# Game Over, blink
	RESUME

T6WIN	TCR	DRAW	# Not drawing right after THINK, so draw here
	CA	DOBLINK	# Check if need to reset +/- 1s to +/- 2s
	EXTEND
	BZF	T6UNDO	# Change win val back to 2
	TCR	THINK
	RESUME

T6UNDO	EXTEND
	AUG	DOBLINK	# Set DOBLINK to 1
	CAF	T6-1SEC	# Schedule T6RUPT in 1 second to restore the blinked win cells
	TS	TIME6
	CA	T6START
	EXTEND
	WOR	IO-13
	CA	NINE	# Change win val back to 2
	TS	L

T6LOOP	INDEX	L
	CA	BOARD
	EXTEND
	BZF	T6NEXT
	EXTEND
	DIM	A	# Not DIM BOARD, cuz that changes BOARD val
	EXTEND
	BZF	T6AUG
	TCF	T6NEXT

T6AUG	EXTEND
	INDEX	L
	AUG	BOARD	# Increment value
T6NEXT	EXTEND
	DIM	L
	CA	L
	EXTEND
	BZF	T6DONE
	TCF	T6LOOP

T6DONE	RESUME


# Main program start.  Initializes, then idle loops.
START	CA	T3-100MS	# T3RUPT in 100 ms to tickle night watchman
	TS	TIME3
	CAE	ZEROREG	# Disable all lamps (io channel 0163)
	EXTEND
	WRITE	LAMP163	################################ #TODO# WOR or so
	TCR	GAMEINI	# Clear BOARD values
	CA	ZEROREG	# Initialize RAND9 to zero
	TS	RAND9
LOOP	CCS	RAND9	# CCS instead of BZF, fewer steps
	TCF	STEP	# RAND9 > 0 (A = RAND9-1)
	CAF	EIGHT	# RAND9 = 0, make it 8 again
STEP	TS	RAND9
	TCF	LOOP	# Loop again (wrapping around to 8 after 0)


# Function to initialize a new game.
# No inputs or outputs.
GAMEINI	CA	Q	# Save return pointer, cuz of TCRs
	TS	QGAMEINI
	CA	PLAYERX	# Starting Player, can change to PLAYERO
	TS	TURN
	TCR	CLEAR	# Clear board values
	TCR	DRAW
	CA	QGAMEINI	# Restore Q
	TS	Q
	RETURN


# Function to set all cells to 0.
# No inputs or outputs.
CLEAR	CA	ZEROREG	# Using loop takes 2 more instructions
	TS	BOARD1
	TS	BOARD2
	TS	BOARD3
	TS	BOARD4
	TS	BOARD5
	TS	BOARD6
	TS	BOARD7
	TS	BOARD8
	TS	BOARD9
	RETURN


# Function to convert cell value (2,1,0,-1,-2) into DSKY code for '1', '0', or ' '.
# Input: A is cell value.  Output: A is DSKY code.
CELLVAL	CCS	A
	TCF	CELLX	# +2 (X) or +1 if blinking
	TCF	CELL-	# +0 ( )
	TCF	CELLO	# -2 (O) or -1 if blinking
	TCF	CELL-	# -0 (N/A)

CELLX	EXTEND
	BZF	CELL-	# Blinking, draw blank
	CA	DISPLAYX
	RETURN		# Draw X ('1')

CELLO	EXTEND
	BZF	CELL-	# Blinking, draw blank
	CA	DISPLAYO
	RETURN		# Draw O ('0')

CELL-	CA	DISPLAY-	# Draw blank
	RETURN


# Function to draw the entire board on the DSKY, including the player number as the Verb.
# No inputs or outputs.
DRAW	CA	Q	# Save return pointer, cuz of TCRs
	TS	QDRAW
	# Pair 10 VERB to indicate whos turn it is #TODO# COMP ACTY if computers turn
	CA	TURN
	TCR	CELLVAL
	AD	PAIR10
	EXTEND
	WRITE	DSPL10
	# Pair 8 has digit 11 (board position 7)
	CA	BOARD7
	TCR	CELLVAL
	AD	PAIR8
	EXTEND
	WRITE	DSPL10
	# Pair 7 has digit 13 (board position 8)
	CA	BOARD8
	TCR	CELLVAL
	AD	PAIR7
	EXTEND
	WRITE	DSPL10
	# Pair 6 has digit 15 (board position 9)
	CA	BOARD9
	TCR	CELLVAL
	AD	PAIR6
	EXTEND
	WRITE	DSPL10
	# Pair 5 has digit 21 (board position 4)
	CA	BOARD4
	TCR	CELLVAL
	EXTEND
	MP	CSHIFT	# Shift for CCCCC Position (*32)
	XCH	L	# MP Val gets stored in L
	AD	PAIR5
	EXTEND
	WRITE	DSPL10
	# Pair 4 has digit 23 (board position 5)
	CA	BOARD5
	TCR	CELLVAL
	EXTEND
	MP	CSHIFT	# Shift for CCCCC Position (*32)
	XCH	L	# MP Val gets stored in L
	AD	PAIR4
	EXTEND
	WRITE	DSPL10
	# Pair 3 has digit 25 and 31 (board positions 6 and 1)
	CA	BOARD6
	TCR	CELLVAL
	EXTEND		# Shift for CCCCC Position (*32)
	MP	CSHIFT	# MP Val gets stored in L
	CA	BOARD1
	TCR	CELLVAL
	AD	L
	AD	PAIR3
	EXTEND
	WRITE	DSPL10
	# Pair 2 has digit 33 (board positioBOARDn 2)
	CA	BOARD2
	TCR	CELLVAL
	AD	PAIR2
	EXTEND
	WRITE	DSPL10
	# Pair 1 has digit 35 (board position 3)
	CA	BOARD3
	TCR	CELLVAL
	AD	PAIR1
	EXTEND
	WRITE	DSPL10
	CA	QDRAW	# Restore Q
	TS	Q
	RETURN


# Interrupt called when button pushed.  Handle the keystroke.
# No inputs or outputs.
KEYRUPT1	CA	NINE
	TS	Q
	EXTEND
	READ	KEY15	# Read DSKY keystrokes (io channel 015)
	TS	L
	EXTEND
	SU	Q	# Check if btn is 1-9
	EXTEND
	BZMF	BTN1-9
	EXTEND
	SU	Q	# Check if is 18 (RSET btn)
	EXTEND
	BZF	RSET
	TCF	B-ERROR

RSET	TCR	GAMEINI
	TCF	B-END

BTN1-9	INDEX	L
	CA	BOARD
	EXTEND
	BZF	BTN-FREE	# Check if btn is available (free cell)
	TCF	B-ERROR

BTN-FREE	CA	TURN
	EXTEND
	BZF	B-ERROR	# Game Over
	INDEX	L
	TS	BOARD
	COM		# Flip TURN value (+ <-> -), here bc after updating BOARD val &
	TS	TURN	# before drawing board so VERB can show whos turn it is
	TCR	DRAW
	TCR	THINK	# Analize board & check win (not AI)

B-END	DXCH	ARUPT	# Restore registers
	EXTEND
	QXCH	QRUPT
	RESUME

B-ERROR	CA	OPR-ERR	# Turn on OPR-ERR lamp
	EXTEND
	WOR	LAMP163
	CAF	T6-1SEC	# Schedule T6RUPT in 1 second to turn off OPR-ERR
	TS	TIME6
	CA	T6START
	EXTEND
	WOR	IO-13
	TCF	B-END


# Function to check for winning condition.  Ends game if needed.
# No inputs or outputs.
THINK			# For each of the eight possible lines,
			# add up the values of the three cells on thah line.
			# If the sum is 6, then X has three in that line.
			#  2 +  2 +  2 =  6
			# If the sum is -6, then O has three in that line.
			# -2 + -2 + -2 = -6
	CA	EIGHT
	TS	L	# L is the line counter (7 -> 0).
T-LOOP	EXTEND
	DIM	L
	INDEX	L	# Add up the values of each line on the board
	CA	CHECK1
	INDEX	A
	CA	BOARD
	TS	CALC	# CALC is a local summing location
	INDEX	L
	CA	CHECK2
	INDEX	A
	CA	BOARD
	AD	CALC
	TS	CALC
	INDEX	L
	CA	CHECK3
	INDEX	A
	CA	BOARD
	AD	CALC
	EXTEND		# Take absolute negative value
	BZMF	T-NEG
	COM
T-NEG	AD	FIVE	# Compare with 5 (not 6) since one cell might intersect with another winning line.
	EXTEND
	BZMF	T-WIN	# Found a win
T-NEXT	CA	L
	EXTEND
	BZF	T-DONE	# Checked all options
	TCF	T-LOOP

T-DONE	CA	ZEROREG
	TS	DOBLINK
	RETURN

T-WIN	CA	Q	# Save return pointer, cuz of TCRs
	TS	QTHINK
	CA	ZEROREG
	TS	TURN	# Set TURN for Game Over
	INDEX	L
	CA	CHECK1
	TCR	T-MOD
	INDEX	L
	CA	CHECK2
	TCR	T-MOD
	INDEX	L
	CA	CHECK3
	TCR	T-MOD
	CAF	T6-1SEC	# Schedule T6RUPT in 1 second to blink off win cells
	TS	TIME6
	CA	T6START
	EXTEND
	WOR	IO-13
	CA	QTHINK	# Restore Q
	TS	Q
	TCF	T-NEXT


# Function to modify a cell to blink if not blank.
# Input: A is cell index.  No outputs.
T-MOD	TS	CALC	# For the cell specified in A, signal it to blink if not blank.
			# Thus change 2 -> 1, -2 -> -1, but leave 0 alone.
	INDEX	A
	CA	BOARD
	EXTEND
	DIM	A
	EXTEND
	BZF	T-MODEND
	INDEX	CALC
	TS	BOARD	# Set BOARD to blink (-1/1)
T-MODEND	RETURN


# Values:
T3-100MS	OCT	37766
T6-1SEC	OCT	1600
T6START	DEC	16384
FIVE	DEC	5
EIGHT	DEC	8
NINE	DEC	9
CSHIFT	DEC	32
OPR-ERR	DEC	64
# Values for Board:
PLAYERX	DEC	2	# X
PLAYERXB	DEC	1	# X (blinking)
PLAYERO	DEC	-2	# O
PLAYEROB	DEC	-1	# O (blinking)
# IO Values for X/O/-
DISPLAYX	DEC	3	# DSKY code for '1'
DISPLAYO	DEC	21	# DSKY code for '0'
DISPLAY-	DEC	0	# DSKY code for ' '
# IO Values for Pair
PAIR10	OCT	50000	# Verb pair
PAIR8	OCT	40000	# DSKY digit pair address
PAIR7	OCT	34000
PAIR6	OCT	30000
PAIR5	OCT	24000
PAIR4	OCT	20000
PAIR3	OCT	14000
PAIR2	OCT	10000
PAIR1	OCT	04000
# Cell indicies for every possible line (7/8/9, 4/5/6, etc)
CHECK1	DEC	7
	DEC	4
	DEC	1
	DEC	7
	DEC	8
	DEC	9
	DEC	7
	DEC	9

CHECK2	DEC	8
	DEC	5
	DEC	2
	DEC	4
	DEC	5
	DEC	6
	DEC	5
	DEC	5

CHECK3	DEC	9
	DEC	6
	DEC	3
	DEC	1
	DEC	2
	DEC	3
	DEC	3
	DEC	1


# System Address Locations
A	=	00	# A register
ARUPT	=	10
L	=	01	# L register
Q	=	02	# Q register
QRUPT	=	12
ZEROREG	=	07	# Zero register
NEWJOB	=	067	# Night watchman
TIME3	=	26
TIME6	=	31
# IO Channels
DSPL10	=	010
LAMP163	=	0163
KEY15	=	015
IO-13	=	013
# Address Locations
RAND9	=	061	# Address for random number
TURN	=	062	# Whose turn is it? (2 = X, -2 = O, 0 = END)
BOARD	=	062
BOARD1	=	063	# Address for start of board
BOARD2	=	064
BOARD3	=	065
BOARD4	=	066
BOARD5	=	067
BOARD6	=	070
BOARD7	=	071
BOARD8	=	072
BOARD9	=	073
QGAMEINI	=	074
QDRAW	=	075
QTHINK	=	076
CALC	=	077	# Local scratchpad (ran out of free registers)
DOBLINK	=	100	# Global flag indicating that a blink out is needed (1=blink, 0=undo blink)
