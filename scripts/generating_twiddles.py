import numpy as np

def generate_unified_twiddle_rom(N):
    """
    Generate a single ROM containing W_N^0 through W_N^(N/2-1).
    All stages can index into this with stride addressing.
    """
    num_twiddles = N // 2  # For 512-point: 256 twiddles

    # Generate W_N^k for k = 0 to N/2-1
    exponents = np.arange(num_twiddles)
    twiddles = [np.exp(-1j * 2 * np.pi * e / N) for e in exponents]

    return twiddles


def complex_to_q1_17(c):
    """Convert complex to Q1.17 (18-bit signed)."""
    FRAC_BITS = 17
    TOTAL_BITS = 18
    scale = 2**FRAC_BITS

    real_fixed = int(np.round(c.real * scale))
    imag_fixed = int(np.round(c.imag * scale))

    max_val = 2**(TOTAL_BITS - 1) - 1
    min_val = -2**(TOTAL_BITS - 1)

    real_fixed = np.clip(real_fixed, min_val, max_val)
    imag_fixed = np.clip(imag_fixed, min_val, max_val)

    return (real_fixed, imag_fixed)


def signed_to_hex(value, num_bits=18):
    """Two's complement hex."""
    if value < 0:
        value = (1 << num_bits) + value
    return f"{value:0{(num_bits + 3) // 4}x}"


def write_unified_rom(N, filename_base='twiddle_unified'):
    """Write single unified ROM to .mem files."""
    twiddles = generate_unified_twiddle_rom(N)

    # Separate real/imag files
    with open(f"{filename_base}_real.mem", 'w') as f_real, \
         open(f"{filename_base}_imag.mem", 'w') as f_imag:

        for tw in twiddles:
            real_int, imag_int = complex_to_q1_17(tw)
            f_real.write(f"{signed_to_hex(real_int, 18)}\n")
            f_imag.write(f"{signed_to_hex(imag_int, 18)}\n")

    print(f"Generated unified ROM: {len(twiddles)} twiddles (W_{{N}}^0 to W_{{N}}^{len(twiddles)-1})")
    return twiddles


def print_stage_addressing(N):
    """Show how each stage indexes the unified ROM."""
    L = int(np.log2(N))
    print("\n=== Stage Addressing into Unified ROM ===")
    print(f"ROM size: {N//2} entries (addresses 0 to {N//2 - 1})\n")

    for s in range(1, L + 1):
        stride = 2**(s - 1)
        counter_max = 2**(L - s) - 1
        num_unique = 2**(L - s)

        # Example addresses for this stage
        example_addrs = [j * stride for j in range(min(4, num_unique))]

        print(f"Stage {s}:")
        print(f"  Stride: {stride}")
        print(f"  Local counter n: 0..{counter_max}")
        print(f"  ROM_addr = n * {stride}")
        print(f"  Accesses {num_unique} unique twiddles")
        print(f"  Example addresses: {example_addrs}{'...' if num_unique > 4 else ''}")
        print()


# Generate for 512-point
N = 512
twiddles = write_unified_rom(N)
print_stage_addressing(N)
