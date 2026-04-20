# Copyright:    Public domain.
# Filename:     random_number_generator_algorithm_testing.py
# Purpose:      Implementation of the pseudo-random number generator (PRNG)
#               algorithm described in "Tables of Linear Congruential Generators
#               of Different Sizes and Good Lattice Structure" by L'Ecuyer and
#               used in "Random-Number-Generator.agc".
#               Serves to verify that the described algorithm generates random
#               numbers with good characteristics.
# Contact:      Neil Fraser <agc@neil.fraser.name>
# Contact:      Luca Rosenberg <luca.rosenberg@gmail.com>

from typing import Tuple, Dict
from statistics import mean, stdev

rand_state = None
initialized = False

def get_rand_num_and_state(uppr_bound: int) -> Tuple[int, int]:
    SEED = 9601
    MULTIPLIER = 12957
    MODULUS = 16381

    global rand_state
    global initialized
    if not rand_state:
          rand_state = SEED
          initialized = True

    _, rand_state = divmod(rand_state * MULTIPLIER, MODULUS)
    _, rand_num = divmod(rand_state, uppr_bound)

    return rand_num, rand_state
    
def get_num_and_transition_counts(uppr_bound: int, num_samples: int) -> Tuple[Dict, Dict]:
    num_counts = {i: 0 for i in range(uppr_bound)}
    transition_counts = {(i, j): 0 for i in range(uppr_bound) for j in range(uppr_bound)}
    
    for i in range(num_samples):
        sample, _ = get_rand_num_and_state(uppr_bound)
        num_counts[sample] += 1
        if i > 0:
            transition_counts[(prev_sample, sample)] += 1
        prev_sample = sample
    
    return num_counts, transition_counts



if __name__ == "__main__":
    UPPR_BOUND = 7
    NUM_SAMPLES = 10000

    num_counts, transition_counts = get_num_and_transition_counts(UPPR_BOUND, NUM_SAMPLES)
    
    counts = num_counts.values()
    transitions = transition_counts.values()
    minmax = lambda x: f"[{min(x)}, {max(x)}]"

    print(f"Total samples: {sum(counts)}")
    print(f"Mean number frequency: {mean(counts):.2f} (mean), {stdev(counts):.2f} (stdev), {minmax(counts)} (range)")
    print(f"Mean transition frequency: {mean(transitions):.2f} (mean), {stdev(transitions):.2f} (stdev), {minmax(transitions)} (range)")