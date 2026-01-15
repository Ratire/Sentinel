"""
This python golden model starts with a 18-bit input of the form signed Q1.17 (same as how it would be for any input into the 512-point 
FFT). It then goes on to create the 27-bit output of the form signed Q10.17 (once again same as the 512-point FFT output). We
accomplish this behavior by converting the initial value to a floating point value, then computing the FFT in floating point and 
quantizing the result back to 27‑bit Q10.17.
"""
import numpy as np
import re
from pathlib import Path

#Constants for Readability
sign_bit = 1 << 17
total_range = 1 << 18


def expanded_sectioned_file_reader(filename):
    #Use regex to initialize a pattern to be used for expanding certain operated-on lines
    pattern = re.compile(r"(\d+)\s*\*\s(\d+)")

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


def fft_block_q1_17_to_q10_17(int_block):   #Converts array of Q1.17 ints to the complex array after 512-point fft is done and Q10.17 ints        
    raw_ints = np.array(int_block, dtype=np.int32)
    
    if np.any((raw_ints < 0) | (raw_ints >= (1 << 18))):    #Check to see if any value is outside the 18-bit range
        raise ValueError("Input contains values outside 18-bit unsigned range")
    
    raw_ints = np.where(raw_ints & sign_bit, raw_ints - total_range, raw_ints)  #Makes sure every element is signed
    float_data = raw_ints / (2**17) #Converts values to floating point

    fft_res = np.fft.fft(float_data)    #Does the 512-point FFT operation

    scaled_fft = fft_res * (2**17)  #Returns the result closer to int format
    fft_res_rr = np.round(scaled_fft.real).astype(np.int32) #FFT result real rounded int
    fft_res_ir = np.round(scaled_fft.imag).astype(np.int32) #FFT result imaginary rounded int

    OUT_MIN = -(1 << 26)
    OUT_MAX = (1 << 26) - 1
    fft_res_rr = np.clip(fft_res_rr, OUT_MIN, OUT_MAX) ##Make sure 
    fft_res_ir = np.clip(fft_res_ir, OUT_MIN, OUT_MAX)

    return fft_res, fft_res_rr, fft_res_ir


def main():
    script_dir = Path(__file__).resolve().parent  # directory containing this .py file
    input_path = script_dir / "input.md"
    output_path = script_dir / "output.md"

    data_gen = expanded_sectioned_file_reader(input_path)
    current_block = []

    with open(output_path, 'w') as out:
        inp_i = 0
        out_i = 0

        for tag, val in data_gen:
            match tag:
                case "SECTION_START":
                    inp_i = 0
                    out_i = 0
                    out.write(f"{val}\n*INPUTS:*\n")

                case "DATA":
                    inp_i += 1
                    out.write(f"Index({inp_i:d})\t{val:022_b}\n")
                    current_block.append(val)

                case "SECTION_END":
                    out.write(f"*OUTPUTS:*\n")

                    if len(current_block) != 512:
                        raise ValueError(f"Expected 512 samples per section, got {len(current_block)}")
                    
                    if current_block:
                        fft_res, fft_res_rr, fft_res_ir = fft_block_q1_17_to_q10_17(current_block)

                        N = 27
                        mask = (1 << N) - 1

                        for i in range(len(fft_res)):
                            f_res = fft_res[i]
                            re_int = fft_res_rr[i] & mask  #Keep low 27 bits
                            im_int = fft_res_ir[i] & mask  #Keep low 27 bits

                            out_i += 1
                            out.write(
                                f"Index({out_i:<3d})  "                      # left-align index in 3-char field
                                f"{f_res.real:>10.6f}, {f_res.imag:>10.6f}j  "  # right-align floats in 10-char fields
                                f"|  "
                                f"{re_int:033_b}, {im_int:033_b}\n"
                            )
                        
                        current_block = [] # Clear for next section


if __name__ == "__main__":
    main()