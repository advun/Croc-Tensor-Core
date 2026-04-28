# Tensor Core for the Croc SoC

## Overview
This is a Tensor Core, developed as a coprocesser for the [Croc SoC](https://github.com/pulp-platform/croc) developed by ETH Zurich and the University of Bologna.   It consists of 4 procesing elements performing 8 MAC operations in parallel every cycle on INT8 outputting in INT32, allowing for 640,000,000 operations per second at 80 MHz. For reference: GPT-2 Small needs an average of 248 million ops per token, so we can generate 2.58 tokens per second.  This hardware allows for a 9.58x speedup over calculation in software, a value which would increase the larger the Systolic Array at the core is.  Our size was constrained by needing to tape out with other projects on the same chip, but we have made the design to be easily expandable.  The chip was taped out during May 2026, and has yet to be recieved back from the fabrication lab.

In order to implement larger matrixes then 2x2 (the size of our systolic array), we used Matrix tiling, which allows us to break up arbitrary sized matrixes into 2x2 "tiles", and use those tiles to compute full matrixes.  A 1024x1024 matrix multiplication was demonstrated using this method in 268 million cycles (3.35 seconds).  

## Visualization


## Operation
Send 1 cycle start pulse, followed by 32 bits of A, then 32 bits of B, repeating in alternate clock cycles.
Valid goes high when full output matrix is done.

To provide data: split your matrix up into 2x2 matrixes, then put the values in each 32 bit register like below:

A11 = [31:24]
A12 = [23:16]
A21 = [15:8]
A22 = [7:0]

Supports matrixes up to 131070x131070 without risk of overflow through tiling.

If entering matrixes with odd widths/lengths: fill spaces with 0s to make it tilable by 2x2 matrixes

All matrixes must be the same length and width, this is the "size" input (may be fixed in future, but don't count on it)
(Example: A 2x2 * 2x2, or a 40x40 * 40x40)

matrix_multiplier_core_tb.sv is a test for one matrix multiplication and gives indepth info

matrix_multiplier_core_tb_multiple.sv tests multiple different sizes, and gives less info
