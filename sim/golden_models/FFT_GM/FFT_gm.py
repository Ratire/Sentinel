"""
This python golden model starts with a 18-bit input of the form signed Q1.17 (same as how it would be for any input into the 512-point 
FFT). It then goes on to create the 27-bit output of the form signed Q10.17 (once again same as the 512-point FFT output). We
accomplish this behavior by converting the initial value to a floating point value, completing
"""
import numpy as np
import re

def expanded_file_reader (filename):
    #Use regex to initialize a pattern to be used for expanding certain operated-on lines
    pattern = re.compile(r"(\d+)\s*\*\s(-?\d+)")

    with open(filename, 'r') as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith('#'): #skip the empty/comment lines
                continue

            match = pattern.match(line)
            if match:
                count = int(match.group(1))
                unexpanded_int = int(match.group(2))

                #yield the unexpanded value as many times (count) it takes to expand it
                for _ in range(count):
                    yield str(value)
            
            else: #if it is a regular line and not an unexpanded line, just proceed like normal
                yield line

#Constants for Readability
sign_bit = 1 << 17
total_range = 1 << 18

#Creating initial raw int array
raw_ints = np.loadtxt('input.txt', dtype=np.int32)

# Apply sign extension to the whole array at once
raw_ints = np.where(raw_ints & sign_bit, raw_ints - total_range, raw_ints)

#Convert entire array to floating point
float_data = raw_ints / (2**17)

#