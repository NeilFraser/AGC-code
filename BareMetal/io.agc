
		SETLOC	4000

                TCF START       # Power up
                NOOP
                NOOP
                NOOP

                RESUME # T6 (interrupt #1) (Disable all interuptions except keystroke)
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

END             CS NEWJOB
                TCF END

BUTTON  	EXTEND
                READ 15         # read dsky keystrokes (io channel oct 15)
                EXTEND
                DIM 0           # diminish twice (only 1&2 will show 12, 0 comes as dec 16)
                EXTEND
                DIM 0
                EXTEND
                BZF D1          # if is zero display 12 (jump to D1)
                CAF DATA2       # not zero so display 21
                TC CONT         # jump so don't load 12 as data
D1              CAF DATA1

CONT		EXTEND
		WRITE 010       # write to display (io channel oct 10) !weird bin for numbers! check developer.html
		RESUME


DATA1           DEC     10361 # 12 (weird bin num made up of display location & display data)
DATA2           DEC     11043 # 21
NOLIGHTS        DEC     0
NEWJOB          =       67
