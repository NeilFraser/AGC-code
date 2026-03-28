# Unit test framework.

# Execute the tests.
$Boolean-test.agc
$Math-test.agc

# To execute the tests, compile with yaYUL, then 'run' with yaAGC.
# If the screen fills up with alarms, then a test failed.
# Break the execution with ^C.
# If the current line is not TS-FAIL, then 'run' again and break again.
# Use 'info stack' to find the line of the failed test.  It will be the first
# entry in the list that's in a *-test.agc file.

		TCF	TS-END	# Skip execution past the private functions.

# This assertion function verifies that two values are equal.
# If they aren't, trigger a TC Trap.
# Stack arguments:
#       First value.
#       Second value.
TS-EQUAL	EXTEND
		QXCH	L	# Temporarily save the Q value into L
		# The arguments for TS-EQUAL are the same as for MA-SU.
	 	# So there's no need to touch the stack.
		TCR	MA-SU
		TCR	BL-NOT
		EXTEND
		BZF	TS-FAIL
		EXTEND
		QXCH	L
		RETURN

TS-FAIL		TCR	TS-FAIL	# Test failed.  Trigger TC Trap.

TS-END		NOOP
