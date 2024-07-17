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
                XCH     ARUPT   # Back up A register
                TCF     BUTTON
                NOOP
                NOOP

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

                CAF     NOLIGHTS        # Disable restart light (io channel 0163)
		EXTEND
		WRITE   0163
		TCR     ERASEFUNC       # Clear the board.
                CA      PLAYEROB
                TS      BOARD7
#                CA      PLAYERO
#                TS      BOARD8
#                CA      PLAYERX
#                TS      BOARD9
#                CA      PLAYERO
#                TS      BOARD4
#                CA      PLAYERX
#                TS      BOARD5
#                CA      PLAYERO
#                TS      BOARD6
#                CA      PLAYERX
#                TS      BOARD1
#                CA      PLAYERO
#                TS      BOARD2
#                CA      PLAYERX
#                TS      BOARD3
                TCR     DRAWFUNC        # coment out to clears screen on reset

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


ERASEFUNC       CA      NINE            # Set the board to all zeros.
                TS      L
ERASELOOP       CA      L
                EXTEND
                BZF     ERASEDONE
                CA      ZEROREG	        # Clear and add 0 into 'A' register.
                INDEX   L
                TS      BOARD
                EXTEND
                DIM     L
                TCF     ERASELOOP
ERASEDONE       RETURN


DRAWFUNC                                # Draw the board on the DSKY.
                # Pair 8 has digit 11 (board position 7).
                CCS     BOARD7
                TCF     DRAW7X          # +2 (X) or +1 if blinking.
                TCF     DRAW7-          # +0 ( )
                TCF     DRAW7O          # -2 (O) or -1 if blinking.
                TCF     DRAW7-          # -0 (N/A)
DRAW7X          EXTEND
                BZF     DRAW7-          # Blinking, draw blank.
                CA      DISPLAYX
                TCF     DRAW7           # Draw X ('1')
DRAW7O          EXTEND
                BZF     DRAW7-          # Blinking, draw blank.
                CA      DISPLAYO
                TCF     DRAW7           # Draw O ('0')
DRAW7-          CA      DISPLAY-        # Draw blank.
                TCF     DRAW7
DRAW7           AD      PAIR8
                EXTEND
                WRITE   010

                # Pair 7 has digit 13 (board position 8).

                # Pair 6 has digit 15 (board position 9).

                # Pair 5 has digit 21 (board position 4).

                # Pair 4 has digit 23 (board position 5).

                # Pair 3 has digit 25 and 31 (board positions 6 and 1).

                # Pair 2 has digit 33 (board position 2).

                # Pair 1 has digit 35 (board position 3).

                RETURN


BUTTON
                CA      PLAYERO
                TS      BOARD7
                TCF     DRAWFUNC
		RESUME

# System values
A               =       00      # A register.
L               =       01      # L register.
Q		=	02	# Q register.
ZEROREG		=	07      # Zero register.
NEWJOB          =       067     # Night watchman.
ARUPT           =       10
TIME3           =       26
T3-100MS        OCT     37766

DISPLAYX        DEC     3       # DSKY code for '1'
DISPLAYO        DEC     21      # DSKY code for '0'
DISPLAY-        DEC     0       # DSKY code for ' '

NOLIGHTS        DEC     0
PAIR8           OCT     40000   # DSKY digit pair addresses.
PAIR7           OCT     34000
PAIR6           OCT     30000
PAIR5           OCT     24000
PAIR4           OCT     20000
PAIR3           OCT     14000
PAIR2           OCT     10000
PAIR1           OCT     04000
DIGIT-C-0       OCT     1240
DIGIT-C-1       OCT     140
DIGIT-D-0       OCT     21
DIGIT-D-1       OCT     03

NINE            DEC     9       # Number of squares.
RAND9           =       061     # Address for random number.
TURN            =       062     # Whose turn is it? (Positive= X, Negative = O)
BOARD           =       062     # Address for start of board (0 is not used).
BOARD1          =       063
BOARD2          =       064
BOARD3          =       065
BOARD4          =       066
BOARD5          =       067
BOARD6          =       068
BOARD7          =       069
BOARD8          =       070
BOARD9          =       071

                                # Values for Board:
PLAYERX         DEC     2       # X
PLAYERXB        DEC     1       # X (blinking)
PLAYERO         DEC     -2      # O
PLAYEROB        DEC     -1      # O (blinking)
