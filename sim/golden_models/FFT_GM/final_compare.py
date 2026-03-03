import numpy as np
from pathlib import Path

MEM_BITS = 27  # fft_output_sv.mem uses 27-bit signed for each component


def read_fft_output_sv(mem_path, points=512, section=1):
    """Read first 'points' complex outputs for the given section from fft_output_sv.mem."""
    re_list = []
    im_list = []
    current_section = 0

    with open(mem_path, "r") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            if line.startswith("// OUTPUTS"):
                current_section += 1
                continue
            if current_section != section:
                continue

            parts = line.split()
            if len(parts) != 2:
                continue  # skip any weird lines

            re_bits, im_bits = parts
            re_val = int(re_bits, 2)
            im_val = int(im_bits, 2)

            # convert 27-bit two's complement to signed int
            if re_val & (1 << (MEM_BITS - 1)):
                re_val -= 1 << MEM_BITS
            if im_val & (1 << (MEM_BITS - 1)):
                im_val -= 1 << MEM_BITS

            re_list.append(re_val)
            im_list.append(im_val)

            if len(re_list) == points:
                break

    if len(re_list) != points:
        raise ValueError(f"Expected {points} outputs, got {len(re_list)}")

    return np.array(re_list, dtype=np.int32), np.array(im_list, dtype=np.int32)


def read_stage9_hw(path, points=512):
    """Read first 'points' complex samples from stage9_hw.txt (decimal re im)."""
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


def best_shift_error(gm_re, gm_im, hw_re, hw_im, max_shift=32):
    """Try circular shifts of hardware sequence and return shift with smallest max error."""
    N = len(gm_re)
    best = None

    for s in range(max_shift + 1):
        # rotate hardware by s
        hw_re_shift = np.roll(hw_re, -s)
        hw_im_shift = np.roll(hw_im, -s)

        diff_re = hw_re_shift - gm_re
        diff_im = hw_im_shift - gm_im

        max_re = int(np.abs(diff_re).max())
        max_im = int(np.abs(diff_im).max())

        if best is None or max(max_re, max_im) < max(best["max_re"], best["max_im"]):
            best = {"shift": s, "max_re": max_re, "max_im": max_im}

    return best


def compare_sorted_magnitudes(gm_re, gm_im, hw_re, hw_im):
    """Rough check if sets of magnitudes match (ignoring order)."""
    gm_mag = np.sqrt(gm_re.astype(np.float64) ** 2 + gm_im.astype(np.float64) ** 2)
    hw_mag = np.sqrt(hw_re.astype(np.float64) ** 2 + hw_im.astype(np.float64) ** 2)

    gm_sorted = np.sort(gm_mag)
    hw_sorted = np.sort(hw_mag)

    # Compare a subset (to avoid being too strict)
    k = min(512, len(gm_sorted))
    diff = np.abs(gm_sorted[:k] - hw_sorted[:k])
    return float(diff.max()), float(diff.mean())


def main():
    script_dir = Path(__file__).resolve().parent
    mem_path = script_dir / "fft_output_sv.mem"
    hw_path = script_dir / "stage9_hw.txt"

    gm_re, gm_im = read_fft_output_sv(mem_path, points=512, section=1)
    hw_re, hw_im = read_stage9_hw(hw_path, points=512)

    best = best_shift_error(gm_re, gm_im, hw_re, hw_im, max_shift=32)
    print("Best circular shift of hardware:", best)

    max_mag_diff, mean_mag_diff = compare_sorted_magnitudes(gm_re, gm_im, hw_re, hw_im)
    print("Max diff of sorted magnitudes:", max_mag_diff)
    print("Mean diff of sorted magnitudes:", mean_mag_diff)


if __name__ == "__main__":
    main()
