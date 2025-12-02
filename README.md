Tensor Core for the Croc SoC

Takes in 32 bits in INT8 format per cycle, outputs in INT32

To operate:
Send 1 cycle start pulse, followed by 32 bits of A, then 32 bits of B, repeating in alternate clock cycles.

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
