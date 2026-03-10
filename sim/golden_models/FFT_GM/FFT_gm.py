"""
This python golden model starts with a 18-bit input of the form signed Q1.17 (same as how it would be for any input into the 512-point 
FFT). It then goes on to create the 27-bit output of the form signed Q10.17 (once again same as the 512-point FFT output). We
accomplish this behavior by converting the initial value to a floating point value, then computing the FFT in floating point - by
following the same procedure as the RTL code for the FFT - and quantizing the result back to 27‑bit Q10.17.
"""
import numpy as np
import re
from pathlib import Path

#Constants for Readability
sign_bit = 1 << 17
total_range = 1 << 18


def expanded_sectioned_file_reader(filename):
    #Use regex to initialize a pattern to be used for expanding certain operated-on lines
    pattern = re.compile(r"(\d+)\s*\*\s*(\d+)")

    with open(filename, 'r') as inp:
        for line in inp:
            line = line.strip()
            match = pattern.match(line)

            if not line: continue

            elif line.startswith("# **"):
                _, sep, after = line.partition("# ")
                yield ("SECTION_START", line)

            elif line == "END_SECTION":
                yield ("SECTION_END", line)

            elif match:
                count, value = int(match.group(1)), int(match.group(2))
                
                for _ in range(count):  #Yield the unexpanded value as many times (count) it takes to expand it
                    yield ("DATA", value)
            
            else: #If it is a regular line and not an unexpanded line, just proceed like normal
                yield ("DATA", int(line))


DATA_INP   = 18      # Q1.17
DATA_INT   = 27      # internal real/imag width
FRAC_TW    = 17      # fractional bits in twiddles
N_FFT      = 512
LOG2_N     = 9

MAX_VAL = (1 << (DATA_INT - 1)) - 1
MIN_VAL = -(1 << (DATA_INT - 1))

# stages 7,8,9 have SHIFT_*_EN = 1 in RTL
#SHIFTED_STAGES = {7, 8, 9}

# no stages have SHIFT_*_EN = 1 in RTL
SHIFTED_STAGES = set()

def sign_extend_18_to_27(x):
    x &= (1 << DATA_INP) - 1
    if x & (1 << (DATA_INP - 1)):
        x -= (1 << DATA_INP)
    return x

def round_shift1(x):
    # this is literally what my Butterfly does:
    # add/subtract 1 then >> 1
    if x >= 0:
        return (x + 1) >> 1
    else:
        return (x - 1) >> 1

def saturate_add_27(x):
    if x > MAX_VAL:
        return MAX_VAL
    if x < MIN_VAL:
        return MIN_VAL
    return int(x)

def saturate_mul(acc):
    # same idea as saturate_mul in FFT_pkg.sv:
    # round, then chop off FRAC_TW bits, then saturate
    if acc >= 0:
        tmp = acc + (1 << (FRAC_TW - 1))
    else:
        tmp = acc - (1 << (FRAC_TW - 1))
    shifted = tmp >> FRAC_TW
    return saturate_add_27(shifted)

def twiddle_q1_17(exp_idx, N=N_FFT):
    # e^{-j 2π*k/N} quantized to the same Q1.17 as twiddle_unified.mem
    angle = -2.0 * np.pi * exp_idx / N
    wr_f = np.cos(angle)
    wi_f = np.sin(angle)
    scale = 1 << FRAC_TW
    wr = int(round(wr_f * scale))
    wi = int(round(wi_f * scale))
    # clamp into signed 18-bit just in case
    hi = (1 << (DATA_INP - 1)) - 1
    lo = -(1 << (DATA_INP - 1))
    return max(min(wr, hi), lo), max(min(wi, hi), lo)

def bit_reverse(i, n_bits):
    b = format(i, f"0{n_bits}b")
    return int(b[::-1], 2)

def fft512_fixed_q1_17_block(int_block):
    if len(int_block) != N_FFT:
        raise ValueError(f"Need {N_FFT} samples, got {len(int_block)}")

    xr = [sign_extend_18_to_27(int(v)) for v in int_block]
    xi = [0 for _ in range(N_FFT)]

    for stage in range(LOG2_N, 0, -1):    # 9,8,...,1
        m  = 1 << stage                   # 512,256,...,2
        m2 = m >> 1                       # 256,128,...,1
        step = N_FFT // m                 # = 1 << (LOG2_N - stage)
        do_shift = stage in SHIFTED_STAGES

        for k0 in range(0, N_FFT, m):
            for j in range(m2):
                i0 = k0 + j
                i1 = i0 + m2

                ar, ai = xr[i0], xi[i0]
                br, bi = xr[i1], xi[i1]

                # sum path
                sum_r = ar + br
                sum_i = ai + bi
                if do_shift:
                    sum_r = round_shift1(sum_r)
                    sum_i = round_shift1(sum_i)
                xr[i0] = saturate_add_27(sum_r)
                xi[i0] = saturate_add_27(sum_i)

                # diff path
                diff_r = ar - br
                diff_i = ai - bi
                if do_shift:
                    diff_r = round_shift1(diff_r)
                    diff_i = round_shift1(diff_i)

                exp_idx = j * step         # DIF: W_N^(j * N/m)
                wr, wi = twiddle_q1_17(exp_idx)

                acc_r = diff_r * wr - diff_i * wi
                acc_i = diff_r * wi + diff_i * wr

                xr[i1] = saturate_mul(acc_r)
                xi[i1] = saturate_mul(acc_i)

    # DIF gives bit-reversed order; hardware reorder buffer fixes that.
    xr_nat = [0] * N_FFT
    xi_nat = [0] * N_FFT
    for i in range(N_FFT):
        br_idx = bit_reverse(i, LOG2_N)
        xr_nat[br_idx] = xr[i]
        xi_nat[br_idx] = xi[i]

    return xr_nat, xi_nat

def generating_output_data_file_for_sv(input_path, output_path):
    data_gen = expanded_sectioned_file_reader(input_path)
    current_block = []
    section_idx = 0

    with open(output_path, "w") as out:
        for tag, val in data_gen:
            match tag:
                case "SECTION_START":
                    current_block = []
                    section_idx += 1

                case "DATA":
                    current_block.append(val)

                case "SECTION_END":
                    out.write(f"// OUTPUTS: {section_idx}\n")

                    if len(current_block) != N_FFT:
                        raise ValueError(
                            f"Expected {N_FFT} samples per section, got {len(current_block)}"
                        )

                    re_arr, im_arr = fft512_fixed_q1_17_block(current_block)

                    mask = (1 << DATA_INT) - 1
                    for k in range(N_FFT):
                        re_int = re_arr[k] & mask
                        im_int = im_arr[k] & mask
                        out.write(f"{re_int:027b} {im_int:027b}\n")

                    out.write("\n")
                    current_block = []


def generating_input_data_file_for_sv(input_path, output_path):
    data_gen = expanded_sectioned_file_reader(input_path)
    section_idx = 0
    with open(output_path, "w") as out:
        for tag, val in data_gen:
            if tag == "SECTION_START":
                section_idx += 1
                out.write(f"// INPUTS {section_idx}\n")
            elif tag == "DATA":
                out.write(f"{val:018b}\n")
            elif tag == "SECTION_END":
                out.write("\n")

def main():
    here = Path(__file__).resolve().parent
    inp  = here / "input.txt"
    sv_in  = here / "fft_input_sv.mem"
    sv_out = here / "fft_output_sv.mem"

    generating_input_data_file_for_sv(inp, sv_in)
    generating_output_data_file_for_sv(inp, sv_out)

if __name__ == "__main__":
    main()
