
		SETLOC	4000

                TCF START       # Power up
                NOOP
                NOOP
                NOOP

                RESUME # T6
                NOOP
                NOOP
                NOOP

                RESUME # T5
                NOOP
                NOOP
                NOOP

                RESUME # T3
                NOOP
                NOOP
                NOOP

                RESUME # T4
                NOOP
                NOOP
                NOOP

                TCF BUTTON # KEY1
                NOOP
                NOOP
                NOOP

                RESUME # KEY2
                NOOP
                NOOP
                NOOP

                RESUME # UP
                NOOP
                NOOP
                NOOP

                RESUME # DOWN
                NOOP
                NOOP
                NOOP

                RESUME # RADAR
                NOOP
                NOOP
                NOOP

                RESUME # 10
                NOOP
                NOOP
                NOOP


START		CAF NOLIGHTS
		EXTEND
		WRITE 0163

END             CS NEWJOB
                TCF END

BUTTON  	EXTEND
                READ 15
                EXTEND
                DIM 0
                EXTEND
                DIM 0
                EXTEND
                BZF DONE
                CAF DATA2
		EXTEND
		WRITE 010
DONE            RESUME

DATA1           DEC     10361 # 12
DATA2           DEC     11043 # 21
NOLIGHTS        DEC     0
NEWJOB          =       67
