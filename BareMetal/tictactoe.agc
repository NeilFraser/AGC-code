		SETLOC	4000

                TCF     START   # Power up
                NOOP
                NOOP
                NOOP

                                # T6 (interrupt #1)
                DXCH    ARUPT   # Back up A,L register
                EXTEND
                QXCH    QRUPT
                TCF     T6RUPT

                RESUME          # T5 (interrupt #2)
                NOOP
                NOOP
                NOOP

                                # T3 (interrupt #3)
                XCH     ARUPT   # Back up A register
                TCF     T3RUPT
                NOOP
                NOOP

                RESUME          # T4 (interrupt #4)
                NOOP
                NOOP
                NOOP

                                # DSKY1 (interrupt #5)
                DXCH    ARUPT   # Back up A,L register
                EXTEND
                QXCH    QRUPT
                TCF     FBUTTON

                RESUME          # DSKY2 (interrupt #6)
                NOOP
                NOOP
                NOOP

                RESUME          # Uplink (interrupt #7)
                NOOP
                NOOP
                NOOP

                RESUME          # Downlink (interrupt #8)
                NOOP
                NOOP
                NOOP

                RESUME          # Radar (interrupt #9)
                NOOP
                NOOP
                NOOP

                RESUME          # Hand controller (interrupt #10)
                NOOP
                NOOP
                NOOP

# T3RUPT every 100 ms.
T3RUPT          CAF     T3-100MS        # Schedule another T3RUPT in 100 ms.
                TS      TIME3

                CAE     NEWJOB          # Tickle NEWJOB to keep Night Watchman GOJAMs from happening

                XCH     ARUPT           # Restore A, and exit the interrupt
                RESUME

# T6RUPT every second, except OP-ERR.
T6RUPT          CA      OPR-ERR         # Turn off OPR-ERR lamp (even if its not on...)
                COM
                EXTEND
                WAND    LAMP163
                CA      TURN            # Check if Game Over
                EXTEND
                BZF     T6WIN           # Game Over, blink
                RESUME

T6WIN           TCR     FDRAW           # Not drawing right after THINK, so draw here

                CA      CALC            # Check if need to rest values
                EXTEND
                BZF     T6UNDO          # Change win val back to 2
                TCR     THINK
                RESUME

T6UNDO          EXTEND
                AUG     CALC            # Set CALC to 1
                CAF     T6-1SEC         # Schedule next T6RUPT to blink wins
                TS      TIME6
                CA      T6START
		EXTEND
		WOR     IO-13

                CA      NINE            # Change win val back to 2
                TS      L
T6LOOP          INDEX   L
                CA      BOARD
                EXTEND
                BZF     T6NEXT
                EXTEND
                DIM     A               # Not DIM BOARD, cuz that changes BOARD val
                EXTEND
                BZF     T6AUG
                TCF     T6NEXT
T6AUG           EXTEND
                INDEX   L
                AUG     BOARD           # Increment value
T6NEXT          EXTEND
                DIM     L
                CA      L
                EXTEND
                BZF     T6DONE
                TC      T6LOOP
T6DONE          RESUME

# Start, Idle place
START           CA      T3-100MS        # T3RUPT in 100 ms to tickle night watchman
                TS      TIME3

                CAE     ZEROREG         # Disable all lamps (io channel 0163)
		EXTEND
		WRITE   LAMP163 ################################
		TCR     GAMEINI         # Clear board values


		CA      ZEROREG         # Initialize RAND9 to zero.
		TS      RAND9

LOOP            CCS     RAND9           # CCS instead of BZF, less steps
                TCF     STEP            # RAND9 > 0 (A = RAND9-1)
                CAF     EIGHT           # RAND9 = 0, make it 8 again
STEP            TS      RAND9
                TCF     LOOP            # Loop again (wrapping around to 8 after 0)

# Initialize new game
GAMEINI	        CA      Q               # Save return pointer, cuz of TCs
                TS      QPOINT1         # Q1 used in FDRAW
                CA      PLAYERO
		TS      TURN
		TCR     FCLEAR          # Clear board values
                TCR     FDRAW
                CA      QPOINT1         # Restore Q
                TS      Q
                RETURN

# Set all boards to 0   # Using loop takes 2 more instructions
FCLEAR          CA      ZEROREG
                TS      BOARD1
                TS      BOARD2
                TS      BOARD3
                TS      BOARD4
                TS      BOARD5
                TS      BOARD6
                TS      BOARD7
                TS      BOARD8
                TS      BOARD9
                RETURN


# Check if cell is X/O/-
FCELLVAL        CCS     A
                TCF     CELLX          # +2 (X) or +1 if blinking
                TCF     CELL-          # +0 ( )
                TCF     CELLO          # -2 (O) or -1 if blinking
                TCF     CELL-          # -0 (N/A)
CELLX           EXTEND
                BZF     CELL-          # Blinking, draw blank
                CA      DISPLAYX
                RETURN                 # Draw X ('1')
CELLO           EXTEND
                BZF     CELL-          # Blinking, draw blank
                CA      DISPLAYO
                RETURN                 # Draw O ('0')
CELL-           CA      DISPLAY-       # Draw blank
                RETURN


# Draw board on to the DSKY
FDRAW           CA      Q              # Save return pointer, cuz of TCs
                TS      QPOINT2
                # Pair 8 has digit 11 (board position 7)
                CA      BOARD7
                TCR     FCELLVAL
                AD      PAIR8
                TCR     FSEND

                # Pair 7 has digit 13 (board position 8)
                CA      BOARD8
                TCR     FCELLVAL
                AD      PAIR7
                TCR     FSEND
                # Pair 6 has digit 15 (board position 9)
                CA      BOARD9
                TCR     FCELLVAL
                AD      PAIR6
                TCR     FSEND
                # Pair 5 has digit 21 (board position 4)
                CA      BOARD4
                TCR     FCELLVAL
                EXTEND
                MP      CSHIFT          # Shift for CCCCC Position (*32)
                XCH     L               # MP Val gets stored in L
                AD      PAIR5
                TCR     FSEND
                # Pair 4 has digit 23 (board position 5)
                CA      BOARD5
                TCR     FCELLVAL
                EXTEND
                MP      CSHIFT          # Shift for CCCCC Position (*32)
                XCH     L               # MP Val gets stored in L
                AD      PAIR4
                TCR     FSEND

                # Pair 3 has digit 25 and 31 (board positions 6 and 1)
                CA      BOARD6
                TCR     FCELLVAL
                EXTEND                  # Shift for CCCCC Position (*32)
                MP      CSHIFT          # MP Val gets stored in L
                CA      BOARD1
                TCR     FCELLVAL
                AD      L
                AD      PAIR3
                TCR     FSEND

                # Pair 2 has digit 33 (board positioBOARDn 2)
                CA      BOARD2
                TCR     FCELLVAL
                AD      PAIR2
                TCR     FSEND

                # Pair 1 has digit 35 (board position 3)
                CA      BOARD3
                TCR     FCELLVAL
                AD      PAIR1
                TCR     FSEND

                CA      QPOINT2         # Restore Q
                TS      Q
                RETURN


# Write A to DSKY
FSEND           EXTEND
                WRITE   DSPL10
                RETURN

# Btn pressed, compute input
FBUTTON         CA      NINE
                TS      Q
                EXTEND
                READ    KEY15           # Read DSKY keystrokes (io channel 015)
                TS      L
                EXTEND
                SU      Q               # Check if btn is 1-9
                EXTEND
                BZMF    BTN1-9
                EXTEND
                SU      Q               # Check if is 18 (RSET btn)
                EXTEND
                BZF     TRANS
                TCF     B-ERROR
TRANS           TCR     GAMEINI
                TC      B-END

BTN1-9          INDEX   L
                CA      BOARD
                EXTEND
                BZF     BTN-FREE        # Check if btn is available (free cell)
                TC      B-ERROR

BTN-FREE        CA      TURN
                EXTEND
                BZF     B-ERROR         # Game Over
                INDEX   L
                TS      BOARD
                TCR     FDRAW
                TCR     THINK           # Analize board & check win (not AI)
                CA      TURN
                EXTEND
                BZF     GOVER           # Check if Game Over
                COM                     # Flip TURN value (+ <-> -)
                TS      TURN

B-END           DXCH    ARUPT           # Restore registers
                EXTEND
                QXCH    QRUPT
		RESUME

GOVER           CAF     T6-1SEC         # Schedule T6RUPT to blink wins
                TS      TIME6
                CA      T6START
		EXTEND
		WOR     IO-13
		TC      B-END

B-ERROR         CA      OPR-ERR         # Turn on OPR-ERR lamp
                EXTEND
                WOR     LAMP163

                CAF     T6-1SEC         # Schedule T6RUPT in 1 second to turn off OPR-ERR
                TS      TIME6
                CA      T6START
		EXTEND
		WOR     IO-13

                TC      B-END

# Computer Brain, check win, ###next move
THINK           CA      EIGHT
                TS      L
T-LOOP          EXTEND
                DIM     L
                INDEX   L               # Add up the values of each line on the board
                CA      CHECK1
                INDEX   A
                CA      BOARD
                TS      CALC

                INDEX   L
                CA      CHECK2
                INDEX   A
                CA      BOARD
                AD      CALC
                TS      CALC

                INDEX   L
                CA      CHECK3
                INDEX   A
                CA      BOARD
                AD      CALC

                EXTEND                  # Take absolute value
                BZMF    T-NEG
                COM
T-NEG           AD      FIVE            # 5 bc T-WIN changes BOARD to blink Nr (-1/1), on next check it will only be 5
                EXTEND
                BZMF    T-WIN           # Found a win
T-NEXT          CA      L
                EXTEND
                BZF     T-DONE          # Checked all options
                TCF     T-LOOP

T-DONE          CA      ZEROREG
                TS      CALC
                RETURN

T-WIN           CA      Q              # Save return pointer, cuz of TCs
                TS      QPOINT2
                CA      ZEROREG
                TS      TURN            # Set TURN for Game Over

                INDEX   L
                CA      CHECK1
                TCR     T-MOD
                INDEX   L
                CA      CHECK2
                TCR     T-MOD
                INDEX   L
                CA      CHECK3
                TCR     T-MOD

                CAF     T6-1SEC         # Schedule next T6RUPT to blink wins
                TS      TIME6
                CA      T6START
		EXTEND
		WOR     IO-13

                CA      QPOINT2         # Restore Q
                TS      Q
                TCF     T-NEXT

T-MOD           TS      CALC
                CA      CALC
                INDEX   A
                CA      BOARD
                EXTEND
                DIM     A
                EXTEND
                BZF     T-MODEND
                INDEX   CALC
                TS      BOARD           # Set BOARD to blink (-1/1)
T-MODEND        RETURN

# Values:
T3-100MS        OCT     37766
T6-1SEC         OCT     1600
T6START         DEC     16384
FIVE            DEC     5
EIGHT           DEC     8
NINE            DEC     9
CSHIFT          DEC     32
OPR-ERR         DEC     64
# Values for Board:
PLAYERX         DEC     2       # X
PLAYERXB        DEC     1       # X (blinking)
PLAYERO         DEC     -2      # O
PLAYEROB        DEC     -1      # O (blinking)
# IO Values for X/O/-
DISPLAYX        DEC     3       # DSKY code for '1'
DISPLAYO        DEC     21      # DSKY code for '0'
DISPLAY-        DEC     0       # DSKY code for ' '
# IO Values for Pair
PAIR8           OCT     40000   # DSKY digit pair addresses.
PAIR7           OCT     34000
PAIR6           OCT     30000
PAIR5           OCT     24000
PAIR4           OCT     20000
PAIR3           OCT     14000
PAIR2           OCT     10000
PAIR1           OCT     04000   # Number of squares.
# Values for check
CHECK1          DEC     7
                DEC     4
                DEC     1
                DEC     7
                DEC     8
                DEC     9
                DEC     7
                DEC     9

CHECK2          DEC     8
                DEC     5
                DEC     2
                DEC     4
                DEC     5
                DEC     6
                DEC     5
                DEC     5

CHECK3          DEC     9
                DEC     6
                DEC     3
                DEC     1
                DEC     2
                DEC     3
                DEC     3
                DEC     1


# System Address Locations
A               =       00      # A register.
ARUPT           =       10
L               =       01      # L register.
Q		=	02	# Q register.
QRUPT           =       12
ZEROREG		=	07      # Zero register.
NEWJOB          =       067     # Night watchman.
TIME3           =       26
TIME6           =       31
# IO Channels
DSPL10          =       010
LAMP163         =       0163
KEY15           =       015
IO-13           =       013
# Address Locations
RAND9           =       061     # Address for random number.
TURN            =       062     # Whose turn is it? (2 = X, -2 = O, 0 = END)
BOARD           =       062
BOARD1          =       063     # Address for start of board.
BOARD2          =       064
BOARD3          =       065
BOARD4          =       066
BOARD5          =       067
BOARD6          =       070
BOARD7          =       071
BOARD8          =       072
BOARD9          =       073
QPOINT1         =       074
QPOINT2         =       075
CALC            =       076

