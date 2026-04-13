# Copyright:	Public domain.
# Filename:	Random-Number-Generator.agc
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
# Contact:	Neil Fraser <agc@neil.fraser.name>
# Contact:	Luca Rosenberg <luca.rosenberg@gmail.com>



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



# INITGEN ('Initialize Generator') function:
#
# Inputs:
# SEED: random integer greater than 0 and less than MODULUS
#
# Returns: None
#
# Initializes the PRNG by setting its initial random state to SEED and loading
# the algorithm coefficient pair into the corresponding addresses in erasable
# memory.
# This function must be called exactly once before generating the first random
# number. If it is called again with the same SEED, the same random number
# sequences are generated (for the respective UPRBNDs).
INITGEN		CA	SEED
		TS	RNDSTATE
		CA	CMLTIPLR
		TS	MLTIPLR
		CA	CMODULUS
		TS	MODULUS
		RETURN

# ##############################################################################

# GRNDNUM ('Get Random Number') function:
#
# Inputs:
# UPRBND: integer specifying the upper bound (exclusive) of the random integer
# to be generated
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
GRNDNUM		CA	RNDSTATE
		EXTEND
# RNDSTATE_{n-1}*MLTIPLR in AL
		MP	MLTIPLR
		EXTEND
# floor(AL/MODULUS) in A and mod(AL, MODULUS) = RNDSTATE_n in L
		DV	MODULUS
		CA	L
		TS	RNDSTATE
# RNDSTATE_n in AL
		CA	ZERO
		EXTEND
# floor(AL/UPRBND) in A and mod(AL, UPRBND) = RNDNUM_n in L
		DV	UPRBND
		CA	L
		TS	RNDNUM
		RETURN

# ##############################################################################

# The following coefficient pair was taken from "Tables of Linear Congruential
# Generators of Different Sizes and Good Lattice Structure" by L'Ecuyer.
# They are chosen to be of such a size as to ensure that the AL double-register
# doesn't overflow.
# This guarantees a random state/number sequence period length of
# p = CMODULUS-1 = 16380
CMLTIPLR	DEC	12957		# Primitive root modulo CMODULUS
CMODULUS	DEC	16381		# Prime number

ZERO		=	7



SEED		=	1000

RNDSTATE	=	1001
MLTIPLR		=	1002
MODULUS		=	1003
UPRBND		=	1004
RNDNUM		=	1005