		SETLOC	4000

                TCF     START   # Power up
                NOOP
                NOOP
                NOOP

                RESUME          # T6 (interrupt #1)
                NOOP
                NOOP
                NOOP

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

# The interrupt-service routine for the TIME3 interrupt every 100 ms.
T3RUPT          CAF     T3-100MS      # Schedule another TIME3 interrupt in 100 ms.
                TS      TIME3

                # Tickle NEWJOB to keep Night Watchman GOJAMs from happening.
                # You normally would NOT do this kind of thing in an interrupt-service
                # routine, because it would actually prevent you from detecting
                # true misbehavior in the main program.  If you're concerned about
                # that, just comment out the next instruction and instead sprinkle
                # your main code with "CS NEWJOB" instructions at strategic points.
                CAE     NEWJOB

                XCH     ARUPT   # Restore A, and exit the interrupt
                RESUME

START
                # Set up the TIME3 interrupt, T3RUPT.  TIME3 is a 15-bit
                # register at address 026, which automatically increments every
                # 10 ms, and a T3RUPT interrupt occurs when the timer
                # overflows.  Thus if it is initially loaded with 037766,
                # and overflows when it hits 040000, then it will
                # interrupt after 100 ms.
                CA      T3-100MS
                TS      TIME3

                CAE     ZEROREG        # Disable restart light (io channel 0163)
		EXTEND
		WRITE   0163
		TCR     GAMEINI      # coment out to clears screen on reset


		CA      ZEROREG         # Initialize RAND9 to zero.
		TS      RAND9

END             CAE     RAND9           # Step RAND9 by -1 (wrapping around to 9 after 1).
                EXTEND
                BZF     WRAP            # if A is Zero, make it 9 again.
STEP            EXTEND
                DIM     0               # Decrease A by 1.
                TS      RAND9           # Save new num to Rand9
                TCF     END             # Loop again (to contantly get new num)
WRAP            CAF     NINE            # A = 9, because it was at 0 (restart num from 9)
                TCF     STEP            # Go save new A to Rand9

# Initialize new game
GAMEINI	        CA      Q               # Save return pointer, cuz of TCs
                TS      QPOINT2         # Q1 used in FDRAW
                CA      PLAYERX
		TS      TURN
		TCR     FCLEAR          # Clear board values
                TCR     FDRAW
                CA      QPOINT2         # Restore Q
                TS      Q
                RETURN

# Set the board to all zeros.   # Using loop takes 2 more instructions
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


# Check if sell is X/O/-
FCELLVAL        CCS     A
                TCF     CELLX          # +2 (X) or +1 if blinking.
                TCF     CELL-          # +0 ( )
                TCF     CELLO          # -2 (O) or -1 if blinking.
                TCF     CELL-          # -0 (N/A)
CELLX           EXTEND
                BZF     CELL-          # Blinking, draw blank.
                CA      DISPLAYX
                RETURN                 # Draw X ('1')
CELLO           EXTEND
                BZF     CELL-          # Blinking, draw blank.
                CA      DISPLAYO
                RETURN                 # Draw O ('0')
CELL-           CA      DISPLAY-       # Draw blank.
                RETURN


# Draw the board on the DSKY.
FDRAW           CA      Q               # Save return pointer, cuz of TCs
                TS      QPOINT1
                # Pair 8 has digit 11 (board position 7).
                CA      BOARD7
                TCR     FCELLVAL
                AD      PAIR8
                TCR     FSEND

                # Pair 7 has digit 13 (board position 8).
                CA      BOARD8
                TCR     FCELLVAL
                AD      PAIR7
                TCR     FSEND
                # Pair 6 has digit 15 (board position 9).
                CA      BOARD9
                TCR     FCELLVAL
                AD      PAIR6
                TCR     FSEND
                # Pair 5 has digit 21 (board position 4).
                CA      BOARD4
                TCR     FCELLVAL
                EXTEND
                MP      CSHIFT          # Shift for CCCCC Position (*32)
                XCH     L               # MP Val gets stored in L
                AD      PAIR5
                TCR     FSEND
                # Pair 4 has digit 23 (board position 5).
                CA      BOARD5
                TCR     FCELLVAL
                EXTEND
                MP      CSHIFT          # Shift for CCCCC Position (*32)
                XCH     L               # MP Val gets stored in L
                AD      PAIR4
                TCR     FSEND

                # Pair 3 has digit 25 and 31 (board positions 6 and 1).
                CA      BOARD6
                TCR     FCELLVAL
                EXTEND                  # Shift for CCCCC Position (*32)
                MP      CSHIFT          # MP Val gets stored in L
                CA      BOARD1
                TCR     FCELLVAL
                AD      L
                AD      PAIR3
                TCR     FSEND

                # Pair 2 has digit 33 (board position 2).
                CA      BOARD2
                TCR     FCELLVAL
                AD      PAIR2
                TCR     FSEND

                # Pair 1 has digit 35 (board position 3).
                CA      BOARD3
                TCR     FCELLVAL
                AD      PAIR1
                TCR     FSEND

                CA      QPOINT1         # Restore Q
                TS      Q
                RETURN


# Write A to DSKY
FSEND           EXTEND
                WRITE   IODSPL
                RETURN

# Btn pressed, compute input
FBUTTON         CA      OPR-ERR # Turn off OPR-ERR lamp
                COM
                EXTEND
                WAND    IOLAMP

                CA      NINE
                TS      Q
                EXTEND
                READ    IOKEY   # Read DSKY keystrokes (io channel octal 15)
                TS      L
                EXTEND
                SU      Q       # Check if button is 1-9
                EXTEND
                BZMF    BTN1-9
                EXTEND
                SU      Q       # Check if is 18 (RSET btn)
                EXTEND
                BZF     TRANS
                TCF     B-ERROR
TRANS           TCR     GAMEINI
                TC      B-END

BTN1-9          INDEX   L
                CA      BOARD
                EXTEND
                BZF     BTN-FREE # Check if btn is available (free cell)
                TC      B-ERROR

BTN-FREE        CA      TURN
                INDEX   L
                TS      BOARD
                TCR     FDRAW

                CA      TURN    # Flip TURN value (-2 or 2)
                EXTEND
                SU      TURN
                EXTEND
                SU      TURN
                TS      TURN

B-END           DXCH    ARUPT   # Restore registers
                EXTEND
                QXCH    QRUPT
		RESUME

B-ERROR         CA      OPR-ERR # Turn on OPR-ERR lamp
                EXTEND
                WOR     IOLAMP
                TC      B-END


# Values:
T3-100MS        OCT     37766
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

# System Address Locations
A               =       00      # A register.
ARUPT           =       10
L               =       01      # L register.
Q		=	02	# Q register.
QRUPT           =       12
ZEROREG		=	07      # Zero register.
NEWJOB          =       067     # Night watchman.
TIME3           =       26
# IO Channels
IODSPL          =       010
IOLAMP          =       0163
IOKEY           =       015
# Address Locations
RAND9           =       061     # Address for random number.
TURN            =       062     # Whose turn is it? (Positive= X, Negative = O)
BOARD           =       062     # Address for start of board (0 is not used).
BOARD1          =       063
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

