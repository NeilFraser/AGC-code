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


START		CAF NOLIGHTS
		EXTEND
		WRITE 0163      # disable restart light (io channel 0163)
		CA 07           # Set A to Zero
		TS RAND6        # Set Rand6 to Zero(A)

END             CS NEWJOB
TICK            CAE RAND6       # Get Rand6 Data
                EXTEND
                BZF WRAP        # if A is Zero, make it 6 again
STEP            EXTEND
                DIM 0           # Decrease A by 1
                TS RAND6        # Safe new num to Rand6
                TCF END         # Loop again (to contantly get new num)

WRAP            CAF SIX         # A = 6, because it was at 0 (restart num from 6)
                TC STEP         # Go save new A to Rand6


BUTTON  	CAE RAND6       # on keyRupt get current Rand6 number
                INDEX 0         # get correct display num for what is in Rand6
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
                DEC    12307    # display 7; not used
                DEC    12317    # display 8; not used
                DEC    12319    # display 9; not used
                DEC    12309    # display 0; not used

NOLIGHTS        DEC     0
NEWJOB          =       67
SIX             DEC     6
RAND6           =       1234    # some EB location
