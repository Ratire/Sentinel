import numpy as np

# Testbench stimulus: fft_data_out = {27'(i << 9), 27'd0}
# This means real = i * 512, imag = 0
# Feature extractor computes |real| + |imag| = i * 512
# Then takes bits [26:9] (upper 18 bits of 27-bit value)
# Since i<<9 has binary form: [i][000000000], bits [26:9] = i

activations = np.arange(0, 512)  # i from 0 to 511
weights = np.ones(512)           # Your testbench loads weight=1 to all PEs

# Expected MAC result (each PE computes this)
expected = np.dot(activations, weights)
print(f"Expected result: {expected}")  # 130816

# Verification against your hardware output
hardware_results = [130816] * 16  # Your simulation showed all 16 PEs = 130816
assert all(r == expected for r in hardware_results), "Mismatch!"
print(f"✅ Verified: Sum of 0..511 = {expected}")
