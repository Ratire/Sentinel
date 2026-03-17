import numpy as np
from pathlib import Path
from FFT_gm import (
    fft512_fixed_q1_17_block,
    expanded_sectioned_file_reader,
    N_FFT,
    DATA_INT
)

def generate_c_header(input_txt_path, output_h_path, num_vectors=3):
    """
    Reads input.txt and exports multiple test vectors to golden_vectors.h
    """
    data_gen = expanded_sectioned_file_reader(input_txt_path)

    # Collect num_vectors sections
    sections = []
    current_section = []

    for tag, val in data_gen:
        if tag == "DATA":
            current_section.append(val)
            if len(current_section) == N_FFT:
                sections.append(current_section)
                current_section = []
                if len(sections) == num_vectors:
                    break

    if len(sections) < num_vectors:
        raise ValueError(f"Expected {num_vectors} sections, got {len(sections)}")

    # Write C header with multiple vectors
    with open(output_h_path, 'w') as f:
        f.write("// Auto-generated from FFT_gm.py - DO NOT EDIT\n")
        f.write("#include <stdint.h>\n\n")
        f.write(f"#define N_SAMPLES {N_FFT}\n")
        f.write(f"#define NUM_TEST_VECTORS {num_vectors}\n\n")

        # Export each vector
        for vec_idx, samples in enumerate(sections):
            # Compute golden output
            re_arr, im_arr = fft512_fixed_q1_17_block(samples)

            # Pack to 54-bit: [53:27] Real, [26:0] Imag (matches hardware)
            packed = []
            for r, i in zip(re_arr, im_arr):
                r_u = r & ((1 << DATA_INT) - 1)
                i_u = i & ((1 << DATA_INT) - 1)
                packed.append((r_u << 27) | i_u)

            # Write input array
            f.write(f"const int32_t input_q17_vec{vec_idx}[N_SAMPLES] = {{\n    ")
            f.write(",\n    ".join(str(s) for s in samples))
            f.write("\n};\n\n")

            # Write expected output array
            f.write(f"const uint64_t golden_packed_vec{vec_idx}[N_SAMPLES] = {{\n    ")
            f.write(",\n    ".join(f"0x{p:016x}ULL" for p in packed))
            f.write("\n};\n\n")

            print(f"Vector {vec_idx}: Input range {min(samples)} to {max(samples)}")

    print(f"\nSuccessfully generated {output_h_path} with {num_vectors} test vectors")

if __name__ == "__main__":
    here = Path(__file__).resolve().parent
    input_file = here / "input.txt"
    output_file = here / "golden_vectors.h"

    generate_c_header(input_file, output_file, num_vectors=6)
