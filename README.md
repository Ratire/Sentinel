# Sentinel – Heterogeneous SoC Robot Platform

An FPGA-accelerated rover combining voice command recognition and FMCW radar sensing on the AMD Kria KV260. Built to demonstrate heterogeneous computing architecture—custom RTL accelerators, cache-coherent DMA data movement, and ARM PS coordination—running entirely on the Zynq UltraScale+ MPSoC without external computational dependencies.

## Overview

Sentinel fuses audio and radar sensor streams through a unified hardware compute fabric. The system recognizes eight spoken commands ("forward, back, left, right, stop, come here, follow, stay") while simultaneously detecting motion via a 24GHz radar module. 

This project demonstrates:
- **Hardware/Software Co-design**: Bare-metal C drivers managing cache-coherent DMA to RTL accelerators
- **Custom RTL Architecture**: 512-point FFT and 16x16 systolic array in SystemVerilog, verified against Python fixed-point golden models
- **Real-time DSP Pipelines**: Shared acceleration infrastructure between heterogeneous sensor modalities

## Hardware Architecture

- **Compute**: AMD Kria KV260 (Zynq UltraScale+ MPSoC, XCZU5EV)
- **Memory**: 4GB DDR4, microSD boot
- **Audio**: I2S MEMS microphone (16kHz mono)
- **Radar**: Infineon Distance2GoL 24GHz FMCW module (BGT24LTR11) + PMOD ADC
- **Actuation**: 2-wheel differential chassis (TB6612FNG H-bridge), pan servo for radar scanning
- **Clocking**: 50 MHz PL fabric (timing closed)

## FPGA Accelerators (PL)

All three core accelerators are synthesized, integrated, and verified in simulation. Timing closure achieved at 50 MHz.

### FFT512ReorderIP
- **Architecture**: 512-point radix-2 Single-Path Delay Feedback (SDF) FFT
- **Interface**: 18-bit signed input, 54-bit complex output (27b real + 27b imag), AXI-Stream with DMA offload
- **Status**: Synthesized, bitstream generated, simulation verified bit-accurate against Python golden model
- **Integration**: Connected via AXI DMA (MM2S/S2MM) to Zynq HP0_FPD

### FeatureExtractor_FFT_SA
- **Function**: |Real| + |Imag| absolute-sum feature extraction from FFT output
- **Interface**: Converts 54-bit FFT output to 18-bit activations for systolic array
- **Status**: Synthesized, integrated between FFT and systolic array, simulation verified
- **Buffering**: 512-entry sample buffer with broadcast-to-rows capability

### SystolicArray16x16
- **Architecture**: 16x16 output-stationary grid (256 PEs)
- **PE Microarchitecture**: 18-bit activation x 18-bit weight -&gt; 45-bit accumulator, local weight BRAM (512x18b per PE)
- **Dataflow**: Activations broadcast horizontally, weights pre-loaded serially via addressable interface
- **Status**: Synthesized, integrated, simulation verified against integer matmul golden model
- **Compute**: 256 parallel dot products (512 MACs each) per inference

## Current Development Status

**Major Milestone: Full Hardware Synthesis Complete**

All accelerators (FFT, Feature Extractor, Systolic Array) are integrated in the unified Vivado block design. The complete data path PS -&gt; DDR -&gt; AXI DMA -&gt; FFT -&gt; Feature Extraction -&gt; Systolic Array -&gt; Result Registers is timing-closed at 50 MHz.

**Verification Status:**
- [x] FFT512: Simulation verified bit-accurate vs Python golden model
- [x] Feature Extractor: Simulation verified, data format conversion validated  
- [x] Systolic Array: 16x16 grid simulation verified, PE MAC operations validated
- [x] Integration: Full pipeline synthesized, timing closed (50 MHz)
- [ ] Hardware Validation: Pending bare-metal DMA loopback test on KV260 hardware

**NSBE 2026 (March 18-22, Baltimore)**
Attending for technical networking with semiconductor and defense employers. Demonstrating verified hardware architecture: ILA capture data, Python/RTL correlation reports, and clean SystemVerilog implementation. Robot chassis integration remains a post-conference stretch goal following hardware validation.

## System Integration Flow

### Audio/Voice Pipeline
I2S Microphone -&gt; PS Buffer (512 samples) -&gt; AXI DMA -&gt; FFT512 -&gt; Feature Extraction (|Re|+|Im|) -&gt; Systolic Array CNN -&gt; 8-class Command ID -&gt; Motor Control

### Radar/Motion Pipeline  
Distance2GoL I/Q -&gt; PMOD ADC -&gt; PS Buffer -&gt; AXI DMA -&gt; FFT512 -&gt; Doppler Magnitude -&gt; Threshold Detection -&gt; Motion Indicator

## Repository Structure
```
Senti/
├── build/
│   ├── vivado_projects/systolic_array/   # Current unified project
│   ├── hw_handoff/                       # XSA exports for Vitis
│   └── vitis_workspace/                  # Bare-metal applications
├── docs/
│   ├── module_sketches/                  # Architecture diagrams
│   └── reports/                          # Utilization/timing
├── src/
│   ├── rtl/
│   │   ├── fft_core/                     # SDF FFT implementation
│   │   ├── systolic_array/               # PE, array, feature extractor
│   │   └── axi_interfaces/               # DMA shims
│   └── ip/                               # Packaged Vivado IPs
├── sim/
│   ├── testbenches/                      # SV testbenches
│   └── golden_models/                    # Python fixed-point reference
└── sw/
└── baremetal/                        # Vitis C applications
```

## Technical Specifications

**FFT512ReorderIP**
- Latency: ~520 cycles (512-point + pipeline)
- Interface: AXI4-Stream 64-bit, valin/valout handshake
- Memory: 9 stages of dual-port BRAM with twiddle ROM

**FeatureExtractor_FFT_SA**
- Input: 54-bit complex (27b real, 27b imag)
- Output: 18-bit signed activation (Q1.17)
- Processing: |Real| + |Imag| with saturation
- Buffer: 512x18b BRAM

**SystolicArray16x16**
- Grid: 256 PEs, output-stationary
- Throughput: 256 MACs/cycle @ 50 MHz = 12.8 GMAC/s
- Weight Loading: Serial broadcast (131,072 total weights for 512x256 layer)
- Accumulator: 45-bit to prevent overflow over 512 operations

**Resource Utilization (Post-Synthesis)**
- BRAM: ~48% (FFT twiddles + weight storage + buffers)
- DSP: 256/360 (71%, systolic array multipliers)
- LUTs/FFs: <20% (headroom for control logic)

## Dependencies

- AMD Vivado 2025.2
- AMD Vitis 2025.2
- Python 3.8+ (NumPy for golden models)
- AMD Kria KV260 Starter Kit

## License

MIT License
