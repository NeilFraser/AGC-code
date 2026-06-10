# Copyright:	Public domain.
# Filename:	Random.agc
# Purpose:	Implementation of a multiplicative linear
#		congruential generator (MLCG), a pseudo-
#		random number generator (PRNG).
#		Generates uniformly distributed random integers
#		in the range [0, UPRBND-1] with a sequence period
#		length of approximately 16k.
#		The algorithm and coefficients used are taken
#		from "Tables of Linear Congruential Generators
#		of Different Sizes and Good Lattice Structure"
#		by L'Ecuyer.
# Assembler:	yaYUL
# Contact:	Luca Rosenberg <luca.rosenberg@gmail.com>
# Contact:	Neil Fraser <agc@neil.fraser.name>



# ##############################################################################
# GRNDNUM pseudo-random number generator (PRNG):
#
# Implements a multiplicative linear congruential generator (MLCG) that
# generates uniformly distributed random integers in the range [0, UPRBND-1].
#
# Relies on INITGEN to initialize its random state (RNDSTATE) to a random value
# (SEED) greater than 0 and less than MODULUS and to load the algorithm
# coefficients into their corresponding addresses in erasable memory.
#
# The algorithm and coefficients used are taken from "Tables of Linear
# Congruential Generators of Different Sizes and Good Lattice Structure"
# by L'Ecuyer.
# With the chosen coefficient pair (MLTIPLR = 12957 and MODULUS = 16381),
# the yaAGC's AL double-register will not overflow, guaranteeing a random
# number sequence period length of p = MODULUS-1 = 16380.
# ##############################################################################



# RNDINIT ('Initialize Generator') function:
#
# Inputs: None
#
# Returns: None
#
# Initializes the PRNG by setting its initial random state and
# loading the algorithm coefficient pair into the corresponding addresses in
# erasable memory.
# This function must be called before generating the first random number.
# Executed on boot-up.
RNDINIT		CA	CMODULUS
		TS	MODULUS
		CA	NUM9601
		TS	RNDSTATE
		RETURN


# RNDSEED ('Seed Generator') function:
#
# Inputs: None
#
# Returns: None
#
# Initializes the PRNG by setting its initial random state to the clock.
# The seed must be an integer greater than 0 and less than MODULUS.
# If this constrain isn't met, don't change the seed.
# Executed on DSKY keypress.
RNDSEED		CA	T1		# Read the low (fast) half of the clock.
		EXTEND
		BZMF	RNDSEEDX	# Skip seed if zero or minus.
		EXTEND
		SU	MODULUS
		EXTEND
		BZMF	RNDSEEDY	# Only seed if less than MODULUS.
RNDSEEDX	RETURN
RNDSEEDY	AD	CMODULUS
		TS	RNDSTATE
		RETURN


# ##############################################################################

# GRNDNUM ('Get Random Number') function:
#
# Inputs:
# UPRBND: integer specifying the upper bound (exclusive).
#
# Returns:
# RNDNUM: uniformly distributed random integer in the range [0, UPRBND-1]
#
# The function relies on INITGEN to initialize its random state (RNDSTATE) to
# a value (SEED) greater than 0 and less than MODULUS.
# Each time it is called, it returns a uniformly distributed random integer
# in the range [0, UPRBND-1].
# It uses a two-step approach to achieve this:
# 1) Update the random state according to:
# RNDSTATE_n = mod(RNDSTATE_{n-1}*MLTIPLR, MODULUS)
# 2) Map the new random state to a number in the range [0, UPRBND-1]
# according to: RNDNUM_n = mod(RNDSTATE_n, UPRBND)
GRNDNUM		EXTEND
		QXCH	QPOP
		TCR	POP
		EXTEND
		QXCH	A		# Use Q as temporary local var
		CA	RNDSTATE
		EXTEND
# RNDSTATE_{n-1}*MLTIPLR in AL
		MP	MLTIPLR
		EXTEND
# floor(AL/MODULUS) in A and mod(AL, MODULUS) = RNDSTATE_n in L
		DV	MODULUS
		CA	L
		TS	RNDSTATE
# RNDSTATE_n in AL
		CA	NUM0
		EXTEND
# floor(AL/UPRBND) in A and mod(AL, UPRBND) = RNDNUM_n in L
		DV	Q		# Q holds the upper bound
		CA	L		# Return on A
		EXTEND
		QXCH	QPOP
		RETURN

# ##############################################################################

# The following coefficient pair was taken from "Tables of Linear Congruential
# Generators of Different Sizes and Good Lattice Structure" by L'Ecuyer.
# They are chosen to be of such a size as to ensure that the AL double-register
# doesn't overflow.
# This guarantees a random state/number sequence period length of
# p = CMODULUS-1 = 16380
MLTIPLR		DEC	12957		# Primitive root modulo CMODULUS
CMODULUS	DEC	16381		# Prime number
NUM9601		DEC	9601		# Random number seed.

RNDSTATE	=	66
MODULUS		=	67
