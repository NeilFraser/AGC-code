# Initialize the stack on boot-up.
STACKINI	CAF	STACK-EB	# Switch to stack memory bank.
		TS	EB
		CA	NUM0
		TS	STACKPTR
		CAF	MAIN-EB		# Switch to main memory bank.
		TS	EB
		RETURN


# Push the contents of the 'A' register onto the stack.
PUSH		TS	STACKTMP
		CAF	STACK-EB	# Switch to stack memory bank.
		TS	EB
		CAE	STACKTMP
		INCR	STACKPTR
		INDEX	STACKPTR
		TS	STACK
		CAF	MAIN-EB		# Switch back to main memory bank.
		TS	EB
		RETURN


# POP: Pop the last value on the stack into the 'A' register.
POP		CAF	STACK-EB	# Switch to stack memory bank.
		TS	EB
		INDEX	STACKPTR
		CAE	STACK
		TS	STACKTMP
		EXTEND
		DIM	STACKPTR
		CAF	MAIN-EB		# Switch back to main memory bank.
		TS	EB
		CAE	STACKTMP
		RETURN


# PEEK: Read the last value on the stack into the 'A' register.
PEEK		CAF	STACK-EB	# Switch to stack memory bank.
		TS	EB
		INDEX	STACKPTR
		CAE	STACK
		TS	STACKTMP
		CAF	MAIN-EB		# Switch back to main memory bank.
		TS	EB
		CAE	STACKTMP
		RETURN


QPOP		=	063	# Temporary spot for Q.
STACKTMP	=	064	# Temp value for stack operations.

STACKPTR	=	1400	# Stack pointer, starts at 0.
STACK		=	1400	# Start address of stack (minus one).

STACK-EB	OCT	2000	# E4 erasable memory bank used by stack.
