# <u>Module</u>

## FFT Module
Size: 512-point FFT  
Channels: 2 channels for now, later will be scaled to 8 (for filtering certain inputs)  
Throughput: 1 sample per clock (fully pipelined)  
Clock Domain: 100 MHz PL clock  
Latency: ~512–1024 cycles through the FFT  

Input format: Each initial input representing some x(j) sample for 0 ≤ j ≤ 511 (512 samples) will have 18 bits (Q1.17) for representing that sample. This is because an MCP3008 ADC will be used later that outputs 10 bits and an I2S stream will be output from the Adafruit microphone, 18 bits of which will be used to represent the audio samples. Therefore, we require at most 18 bits to represent the initial inputs.

Because a 512-point FFT can produce outputs up to 512 times larger than the inputs in the worst case (log₂(512) = 9 bits of potential growth), we use a 27-bit internal format (Q10.17) to provide sufficient headroom while keeping external I/O at 18-bit Q1.17. Internally, all 18-bit inputs are sign-extended to 27 bits before entering the FFT pipeline. The FFT outputs are also provided in Q10.17 format.

Input format of microphone: The I2S receiver outputs an 18-bit two’s-complement value, interpreted as Q1.17, which is sign-extended to 27 bits internally for the FFT.

Input format of radar: The 10-bit ADC will be used for the radar’s output; the ADC’s 10-bit value (0–1023) will be decremented by 512 to re-center around zero, then left-shifted by 8 to align it into an 18-bit Q1.17 value, which is then sign-extended to 27 bits internally.

*Complex Data Convention:*
The FFT core operates on complex samples $x(n) = \mathrm{Re}(x(n)) + j\,\mathrm{Im}(x(n))$. For real-valued inputs such as the microphone (I2S) and radar (ADC), the imaginary part is initialized to zero at the first stage: $\mathrm{Re}(x(n))$ is the 18-bit Q1.17 sample, and $\mathrm{Im}(x(n)) = 0$. As the samples propagate through the radix-2 butterfly stages, the complex additions and twiddle-factor multiplications generate non-zero imaginary components, producing a full complex spectrum at the FFT output. This follows the standard treatment of real signals as complex inputs with zero imaginary part in FFT implementations.
