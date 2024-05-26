		SETLOC	4000

                TCF START       # Power up
                NOOP
                NOOP
                NOOP

                # Ignore all interupts except keystroke.
                RESUME # T6 (interrupt #1)
                NOOP
                NOOP
                NOOP

                RESUME # T5 (interrupt #2)
                NOOP
                NOOP
                NOOP

                RESUME # T3 (interrupt #3)
                NOOP
                NOOP
                NOOP

                RESUME # T4 (interrupt #4)
                NOOP
                NOOP
                NOOP

                TCF BUTTON # DSKY1 (interrupt #5) (dsky1 interrupt, jump to programm)
                NOOP
                NOOP
                NOOP

                RESUME # DSKY2 (interrupt #6)
                NOOP
                NOOP
                NOOP

                RESUME # UP (interrupt #7)
                NOOP
                NOOP
                NOOP

                RESUME # DOWN (interrupt #8)
                NOOP
                NOOP
                NOOP

                RESUME # RADAR (interrupt #9)
                NOOP
                NOOP
                NOOP

                RESUME # 10 (interrupt #10)
                NOOP
                NOOP
                NOOP


START		CAF NOLIGHTS    # Disable restart light (io channel 0163)
		EXTEND
		WRITE 0163
		TCR ERASEFUNC   # Clear the board.
		CA ZEROREG      # Initialize RAND9 to zero.
		TS RAND9

END             CA NEWJOB       # Tickle the night watchman.
TICK            CAE RAND9       # Step RAND9 by -1 (wrapping around to 9 after 1).
                EXTEND
                BZF WRAP        # if A is Zero, make it 9 again.
STEP            EXTEND
                DIM 0           # Decrease A by 1.
                TS RAND9        # Save new num to Rand9
                TCF END         # Loop again (to contantly get new num)
WRAP            CAF NINE        # A = 9, because it was at 0 (restart num from 9)
                TCF STEP        # Go save new A to Rand9


ERASEFUNC       CA NINE         # Set the board to all zeros.
                TS L
ERASELOOP       CA L
                EXTEND
                BZF ERASEDONE
                CA ZEROREG		# Clear and add 0 into 'A' register.
                INDEX L
                TS BOARD
                EXTEND
                DIM L
                TCF ERASELOOP
ERASEDONE       RETURN


DRAWFUNC                        # Draw the board on the DSKY.
                                # Line 8 has digit 11 (board position 7).
                CCS BOARD7
                TCF DIMDOWN     # 1 (X)
                NOOP            # +0 ( )
                NOOP            # -1 (O)
                TCF ENDDOWN     # -0 (N/A)
                CAF LINE8

                EXTEND
                WRITE 010
                                # Line 7 has digit 13 (board position 8).
                                # Line 6 has digit 15 (board position 9).
                                # Line 5 has digit 21 (board position 4).
                                # Line 4 has digit 23 (board position 5).
                                # Line 3 has digit 25 and 31 (board positions 6 and 1).
                                # Line 2 has digit 33 (board position 2).
                                # Line 1 has digit 35 (board position 3).


BUTTON  	CAE RAND9       # on keyRupt get current Rand6 number
                INDEX A         # get correct display num for what is in Rand6
                CAF NUMDATA0

		EXTEND
		WRITE 010       # write to display (io channel oct 10) !weird bin for numbers! check developer.html
		RESUME          # resume last program (in this case no other interupts; so to START)


NUMDATA0        DEC    12291    # display 1
                DEC    12313    # display 2
                DEC    12315    # display 3
                DEC    12303    # display 4
                DEC    12318    # display 5
                DEC    12316    # display 6
                DEC    12307    # display 7
                DEC    12317    # display 8
                DEC    12319    # display 9
                DEC    12309    # display 0; not used

NOLIGHTS        DEC     0
NEWJOB          =       67
NINE            DEC     9
LINE8           OCT     40000   # DSKY digit pair addresses.
LINE7           OCT     34000
LINE6           OCT     30000
LINE5           OCT     24000
LINE4           OCT     20000
LINE3           OCT     14000
LINE2           OCT     10000
LINE1           OCT     04000
DIGIT-C-0       OCT     1240
DIGIT-C-1       OCT     140
DIGIT-D-0       OCT     21
DIGIT-D-1       OCT     03
A               =       00      # A register.
L               =       01      # L register.
Q		=	02	# Q register.
ZEROREG		=	07
RAND9           =       061     # Address for random number.
TURN            =       062     # Whose turn is it?
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
