import numpy as np  # for exp, pi, arrays


def generate_unified_twiddle_rom(N):
    """
    Generate complex twiddles W_N^k for k = 0 .. N/2-1.
    These are later quantized to Q1.17 and concatenated.
    """
    num_twiddles = N // 2           # e.g. 512 -> 256 twiddles
    exponents = np.arange(num_twiddles)
    return [np.exp(-1j * 2 * np.pi * k / N) for k in exponents]


def complex_to_q1_17(c):
    """Convert complex twiddle to Q1.17 (18-bit signed integer tuple)."""
    FRAC_BITS = 17
    TOTAL_BITS = 18
    scale = 2**FRAC_BITS

    real_fixed = int(np.round(c.real * scale))
    imag_fixed = int(np.round(c.imag * scale))

    max_val = 2**(TOTAL_BITS - 1) - 1   # +131071
    min_val = -2**(TOTAL_BITS - 1)      # -131072

    real_fixed = np.clip(real_fixed, min_val, max_val)
    imag_fixed = np.clip(imag_fixed, min_val, max_val)

    return real_fixed, imag_fixed


def concat_q1_17_to_36b(real_int, imag_int):
    """
    Take signed 18-bit real/imag and produce one 36-bit unsigned word:
    [real(17:0), imag(17:0)].
    """
    real_u = real_int & ((1 << 18) - 1)
    imag_u = imag_int & ((1 << 18) - 1)
    return (real_u << 18) | imag_u


def to_hex_36b(value):
    """Format 36-bit unsigned integer as 9-hex-digit string (zero-padded)."""
    return f"{value:09x}"


def write_unified_rom(N, filename_base="twiddle_unified"):
    """
    Generate unified twiddle ROM and write one .mem file.
    Each line: concatenated 36-bit word [real(17:0), imag(17:0)] in hex.
    """
    twiddles = generate_unified_twiddle_rom(N)

    mem_filename = f"{filename_base}.mem"
    with open(mem_filename, "w") as f:
        for tw in twiddles:
            real_int, imag_int = complex_to_q1_17(tw)
            combined = concat_q1_17_to_36b(real_int, imag_int)
            f.write(to_hex_36b(combined) + "\n")

    print(f"Generated {mem_filename}: {len(twiddles)} entries (W_N^0 .. W_N^{len(twiddles)-1})")
    return twiddles


def print_stage_addressing(N):
    """Print how each DIF SDF stage indexes the unified ROM."""
    L = int(np.log2(N))
    print("\n=== Stage Addressing into Unified ROM ===")
    print(f"ROM size: {N//2} entries (addresses 0 .. {N//2 - 1})\n")

    for s in range(1, L + 1):
        stride = 2**(s - 1)
        counter_max = 2**(L - s) - 1
        num_unique = 2**(L - s)
        example_addrs = [j * stride for j in range(min(4, num_unique))]

        print(f"Stage {s}:")
        print(f"  Stride: {stride}")
        print(f"  Local counter k_s: 0..{counter_max}")
        print(f"  ROM_addr = k_s * {stride}")
        print(f"  Accesses {num_unique} unique twiddles")
        print(f"  Example addresses: {example_addrs}{'...' if num_unique > 4 else ''}\n")


if __name__ == "__main__":
    N = 512
    twiddles = write_unified_rom(N, filename_base="twiddle_unified")
    print_stage_addressing(N)
