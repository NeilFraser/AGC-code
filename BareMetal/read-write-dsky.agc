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

END             CS NEWJOB       # Continually tickle the newjob register to prevent system restart.
                TCF END

BUTTON  	EXTEND
                READ 15         # Read DSKY keystrokes (io channel octal 15)
                INDEX 0         # Get num from A that is from io channel
                CAF NUMDATA0

		EXTEND
		WRITE 010       # write to display (io channel oct 10) !weird bin for numbers! check developer.html
		RESUME


NUMDATA0        DEC    0        # Not used cuz seystroke 0 gives back 16 into A
                DEC    12291    # display 1
                DEC    12313    # display 2
                DEC    12315    # display 3
                DEC    12303    # display 4
                DEC    12318    # display 5
                DEC    12316    # display 6
                DEC    12307    # display 7
                DEC    12317    # display 8
                DEC    12319    # display 9
                DEC    0
                DEC    0
                DEC    0
                DEC    0
                DEC    0
                DEC    0
                DEC    12309    # display 0

NOLIGHTS        DEC     0
NEWJOB          =       67
