# Unit test framework.

# Execute the tests.
$Stack-test.agc
$Boolean-test.agc
$List-test.agc
$Math-test.agc
$Random-test.agc
$Lamps-test.agc

TS-LOOP	NOOP
$PrintDigit-test.agc

		CA	NUM100
		TCR	PUSH
		TCR	SLEEP

$PrintNumber-test.agc
		CA	NUM100
		TCR	PUSH
		TCR	SLEEP
		TCF	TS-LOOP

# To execute the tests, compile with yaYUL, then 'run' with yaAGC.
# If the screen fills up with alarms, then a test failed.
# Break the execution with ^C.
# If the current line is not TS-FAIL, then 'run' again and break again.
# Use 'info stack' to find the line of the failed test.  It will be the first
# entry in the list that's in a *-test.agc file.



# This assertion function verifies that two values are equal.
# If they aren't, trigger a TC Trap.
# Stack arguments:
#       First value.
#       Second value.
TS-EQUAL	EXTEND
		QXCH	TS-TEMP	# Temporarily save the Q value.
		# The arguments for TS-EQUAL are the same as for MA-SU.
	 	# So there's no need to touch the stack.
		TCR	MA-SU
		TCR	BL-NOT
		EXTEND
		BZF	TS-FAIL
		EXTEND
		QXCH	TS-TEMP
		RETURN

TS-FAIL		TCR	TS-FAIL	# Test failed.  Trigger TC Trap.


TS-TEMP		=	1400
