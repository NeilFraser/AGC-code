		SETLOC	4000

                TCF START       # Power up
                NOOP
                NOOP
                NOOP

                RESUME # T6 (interrupt #1)
                NOOP
                NOOP
                NOOP

                RESUME # T5 (interrupt #2)
                NOOP
                NOOP
                NOOP

                # T3 (interrupt #3)
                XCH     ARUPT  # Back up A register
                TCF     T3RUPT
                NOOP
                NOOP

                RESUME  # T4 (interrupt #4)
                NOOP
                NOOP
                NOOP

                # DSKY1 (interrupt #5)
                XCH     ARUPT  # Back up A register
                TCF     BUTTON
                NOOP
                NOOP

                RESUME # DSKY2 (interrupt #6)
                NOOP
                NOOP
                NOOP

                RESUME # Uplink (interrupt #7)
                NOOP
                NOOP
                NOOP

                RESUME # Downlink (interrupt #8)
                NOOP
                NOOP
                NOOP

                RESUME # Radar (interrupt #9)
                NOOP
                NOOP
                NOOP

                RESUME # Hand controller (interrupt #10)
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
                CAE      NEWJOB

                XCH    ARUPT       # Restore A, and exit the interrupt
                RESUME

START
                # Set up the TIME3 interrupt, T3RUPT.  TIME3 is a 15-bit
                # register at address 026, which automatically increments every
                # 10 ms, and a T3RUPT interrupt occurs when the timer
                # overflows.  Thus if it is initially loaded with 037766,
                # and overflows when it hits 040000, then it will
                # interrupt after 100 ms.
                CA        T3-100MS
                TS        TIME3

                CAF NOLIGHTS
		EXTEND
		WRITE 0163      # disable restart light (io channel 0163)
                CAF NUMBLANK
		EXTEND
		WRITE 010       # write to display (io channel oct 10) !weird bin for numbers! check developer.html

		CA 07           # Set A to Zero
		TS RAND6        # Set Rand6 to Zero(A)


END             CAE RAND6       # Get Rand6 Data
                EXTEND
                BZF WRAP        # if A is Zero, make it 6 again
STEP            EXTEND
                DIM 0           # Decrease A by 1
                TS RAND6        # Safe new num to Rand6
                TCF END         # Loop again (to contantly get new num)

WRAP            CAF SIX         # A = 6, because it was at 0 (restart num from 6)
                TCF STEP        # Go save new A to Rand6


BUTTON          INDEX RAND6         # get correct display num for what is in Rand6
                CAF NUMDATA0
		EXTEND
		WRITE 010       # write to display (io channel oct 10) !weird bin for numbers! check developer.html
		XCH ARUPT
		RESUME          # resume last program (in this case no other interupts; so to START)


NUMDATA0        DEC    12291    # display 1
                DEC    12313    # display 2
                DEC    12315    # display 3
                DEC    12303    # display 4
                DEC    12318    # display 5
                DEC    12316    # display 6
                DEC    12307    # display 7; not used
                DEC    12317    # display 8; not used
                DEC    12319    # display 9; not used
                DEC    12309    # display 0; not used
NUMBLANK        DEC    12288    # display _

NOLIGHTS        DEC     0
NEWJOB          EQUALS  67
SIX             DEC     6
RAND6           =       1234    # some EB location
ARUPT           EQUALS  10
TIME3           EQUALS  26
T3-100MS        OCT     37766
