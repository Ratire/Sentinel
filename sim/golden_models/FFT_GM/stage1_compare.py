import numpy as np
from pathlib import Path

# reuse your existing reader so we interpret input.txt the same way as FFT_gm.py
from FFT_gm import expanded_sectioned_file_reader, sign_bit, total_range


def read_first_block_from_input(input_path, points=512):
    """Read first 512-sample section from input.txt as Q1.17 ints."""
    data_gen = expanded_sectioned_file_reader(input_path)
    block = []

    for tag, val in data_gen:
        if tag == "DATA":
            block.append(val)
            if len(block) == points:
                break
        elif tag == "SECTION_END":
            # stop at end of first section even if somehow shorter
            break

    if len(block) != points:
        raise ValueError(f"Expected {points} samples, got {len(block)}")

    return block


def stage1_block_q1_17_to_q10_17(int_block):
    """
    Model S=1 DIF stage in float, then quantize to 27-bit Q10.17
    (same sign handling as FFT_gm).
    """
    raw_ints = np.array(int_block, dtype=np.int32)

    # interpret 18-bit Q1.17 as signed
    if np.any((raw_ints < 0) | (raw_ints >= (1 << 18))):
        raise ValueError("Input contains values outside 18-bit unsigned range")

    raw_ints = np.where(raw_ints & sign_bit, raw_ints - total_range, raw_ints)
    float_data = raw_ints / (2**17)

    # treat as complex with zero imaginary part
    x = float_data.astype(np.complex64)
    N = x.shape[0]
    y = np.zeros_like(x)

    # radix‑2 DIF stage 1: pairs (2k, 2k+1), no twiddles, no scaling
    half = N // 2
    for k in range(half):
        a = x[2 * k]
        b = x[2 * k + 1]
        y[2 * k]     = a + b
        y[2 * k + 1] = a - b


    # quantize to 27-bit Q10.17 like your RTL: *2^17, round, clip to [-2^26, 2^26-1]
    scaled = y * (2**17)
    re = np.round(scaled.real).astype(np.int32)
    im = np.round(scaled.imag).astype(np.int32)

    OUT_MIN = -(1 << 26)
    OUT_MAX = (1 << 26) - 1
    re = np.clip(re, OUT_MIN, OUT_MAX)
    im = np.clip(im, OUT_MIN, OUT_MAX)

    return y, re, im


def load_stage1_hw(path, points=512):
    """Load first 512 lines of stage1_hw.txt as signed ints."""
    re_hw = []
    im_hw = []
    with open(path, "r") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            parts = line.split()
            if len(parts) < 2:
                continue
            r, i = int(parts[0]), int(parts[1])
            re_hw.append(r)
            im_hw.append(i)
            if len(re_hw) == points:
                break

    if len(re_hw) != points:
        raise ValueError(f"Expected {points} hardware samples, got {len(re_hw)}")

    return np.array(re_hw, dtype=np.int32), np.array(im_hw, dtype=np.int32)


def main():
    script_dir = Path(__file__).resolve().parent
    input_path = script_dir / "input.txt"
    stage1_hw_path = script_dir / "stage1_hw.txt"

    # 1) load first 512-sample frame from input.txt
    int_block = read_first_block_from_input(input_path, points=512)

    # 2) run Python model of S=1 stage
    _, stg1_re, stg1_im = stage1_block_q1_17_to_q10_17(int_block)

    # 3) load RTL stage‑1 dump
    hw_re, hw_im = load_stage1_hw(stage1_hw_path, points=512)

    # 4) compare
    diff_re = hw_re - stg1_re
    diff_im = hw_im - stg1_im

    abs_diff_re = np.abs(diff_re)
    abs_diff_im = np.abs(diff_im)

    print("Stage 1 comparison vs RTL")
    print("-------------------------")
    print("max |re_error|:", int(abs_diff_re.max()))
    print("max |im_error|:", int(abs_diff_im.max()))

    # print first few mismatches with indices
    print("\nFirst 10 mismatches (idx, hw_re, gm_re, hw_im, gm_im):")
    mismatches = np.where((diff_re != 0) | (diff_im != 0))[0]
    for idx in mismatches[:10]:
        print(
            idx,
            int(hw_re[idx]),
            int(stg1_re[idx]),
            int(hw_im[idx]),
            int(stg1_im[idx]),
        )


if __name__ == "__main__":
    main()
