# Sentinel – Privacy-First Smart Home Robot

A local, FPGA-accelerated smart home robot combining voice command recognition and FMCW radar motion detection on the AMD Kria KV260. All DSP, AI inference, and control run entirely on-device with zero cloud dependency.

## Overview

Sentinel addresses the privacy concerns of cloud-connected home AI by processing all sensor data locally. The system recognizes eight spoken commands to control a robot base ("forward, back, left, right, stop, come here, follow, stay") while simultaneously detecting human motion using a 24GHz radar. All processing utilizes custom FPGA accelerators with no external computational dependencies.

## Key Features

- Real-time voice command recognition using I2S MEMS microphone with custom 8-command CNN
- 24GHz FMCW radar (Infineon Distance2GoL) for motion sensing and Doppler detection  
- Custom 16×16 systolic array accelerator for quantized CNN matrix operations (int16×int16 → int32 MAC)
- Shared 512-point FFT engine with natural-order output for both audio and radar DSP pipelines
- Local AI inference with no cloud connectivity required
- Complete privacy: Raw audio and radar data never leaves the device

## Hardware Architecture

- **Compute:** AMD Kria KV260 Vision AI Starter Kit (Zynq UltraScale+ MPSoC, XCZU5EV)
- **Memory:** 4 GB on-module DDR4, microSD boot storage
- **Audio Input:** I2S MEMS microphone (16kHz mono)
- **Radar Frontend:** Infineon Distance2GoL 24GHz FMCW module (BGT24LTR11)
- **ADC:** Dual-channel PMOD ADC for radar I/Q digitization
- **Audio Output:** USB powered speaker or LED indicators
- **Robot Base:** 2-wheel differential chassis with DC motors + TB6612FNG H-bridge driver
- **Servo:** Pan servo for radar scanning capability
- **Networking:** 1 GbE Ethernet (for development)

## FPGA Accelerators (PL)

### FFT512ReorderIP (Complete, Verified)

- **Type:** Custom 512-point radix-2 Single-Path Delay Feedback (SDF) FFT
- **Language:** SystemVerilog with fixed-point arithmetic
- **Features:**
  - 18-bit signed input (Q1.17), 54-bit complex output (27b real + 27b imag)
  - Per-stage scaling with saturating arithmetic
  - Hardware bit-reversal buffer for natural-order output
  - Twiddle factors in ROM initialized from Python-generated .mem files
- **Status:** Architecturally frozen, verified against Python fixed-point golden model, packaged as Vivado IP
- **Latency:** ~512 cycles + pipeline stages

### SystolicArray16x16 (In Development)

- **Architecture:** 16×16 grid of Processing Elements (PEs)
- **Dataflow:** Output-stationary (accumulator stays in PE)
- **Precision:** Signed 16-bit inputs/weights, 32-bit saturating accumulator
- **Operation:** Int16 × Int16 → Int32 MAC every cycle
- **Purpose:** CNN inference engine for voice command classification and radar target detection
- **Verification Plan:** 2×2 → 4×4 → 16×16 scaling against Python integer matmul golden

## System Integration Flow

### Audio/Voice Pipeline

I2S Microphone → PS Buffer (512-sample windows) → FFT512ReorderIP → Mel Feature Extraction (ARM) → SystolicArray CNN → 8-class Command ID → Robot Motor Control/LEDs

### Radar/Motion Pipeline  

Distance2GoL I/Q → PMOD ADC → PS Buffer → FFT512ReorderIP → Doppler Magnitude (ARM) → Motion Energy Threshold → MOTION LED / Occupancy Grid (post-NSBE)

## Project Status and Roadmap

**Current Status (March 2026):**

- FFT512ReorderIP: Complete, verified, packaged in `src/ip/fft_ip/`
- Vivado Block Design: PS + AXI DMA + FFT IP instantiated
- Systolic Array: PE microarchitecture defined, RTL implementation pending
- AXI-Stream Shim: Required between DMA and FFT (64-bit to 18-bit conversion)
- Voice CNN: Architecture defined (128-dim FC → 8 outputs), training pending
- Radar Integration: Distance2GoL hardware received, PMOD ADC interface design pending
- Robot Base: Parts ordered/assembling

**NSBE 2026 Demo Goals (March 18-22):**

1. **Minimum Viable Demo:** Voice command recognition (stored PCM → FFT HW → CNN HW/SW → Robot/LEDs)
2. **Stretch Goal:** Live microphone input with real-time classification
3. **Radar Demo:** Motion detection via Distance2GoL → ADC → FFT HW → Doppler energy threshold → MOTION LED

**Post-NSBE Roadmap:**

- Servo-scanning radar for 2D occupancy grid mapping
- Full CNN layers on systolic array (not just FC)
- Path planning algorithms (A*/greedy) on ARM
- Multi-modal fusion (voice + radar for "come here" navigation)


## Repository Structure
'''
Senti/
├── build/                      # Vivado/Vitis build outputs (gitignored)
│   ├── bitstreams/
│   ├── vitis_workspace/
│   └── vivado_project/
├── docs/                       # Documentation and reports
│   ├── design_decisions.md
│   ├── module_sketches/
│   ├── resource_utilization/
│   ├── sketches/
│   ├── timing_reports/
│   └── weekly_reports/
├── scripts/                    # Python utility scripts
│   └── generating_twiddles/
│       ├── generating_twiddles.py
│       └── twiddle_unified.mem
├── sim/                        # Simulation and verification
│   ├── golden_models/          # Python fixed-point reference models
│   │   ├── FFT_BF_GM/          # Butterfly golden model
│   │   └── FFT_GM/             # Full FFT golden model
│   ├── testbenches/            # SystemVerilog testbenches
│   └── waveforms/              # Vivado waveform configs
├── src/                        # RTL source and constraints
│   ├── constraints/
│   │   └── kv260.xdc
│   ├── ip/                     # Packaged Vivado IPs
│   │   ├── fft_ip/             # FFT512ReorderIP (frozen)
│   │   └── systolic_ip/        # Systolic array (in dev)
│   └── rtl/                    # SystemVerilog source code
│       ├── axi_interfaces/     # AXI-Stream shim (to be implemented)
│       ├── fft_core/           # SDF FFT implementation
│       ├── i2s_receiver/       # Microphone interface
│       ├── radar_dsp/          # Radar processing blocks
│       ├── systolic_array/     # 16x16 MAC array
│       └── top.sv              # Top-level wrapper
├── sw/                         # Software applications
│   ├── baremetal/              # Vitis bare-metal apps
│   ├── drivers/                # Custom IP drivers
│   └── linux_apps/             # Linux applications (if needed)
├── LICENSE
└── README.md
'''

## Technical Specifications

**FFT512ReorderIP:**

- Input: 18-bit signed fixed-point (Q1.17)
- Output: 54-bit complex (Q10.17 real, Q10.17 imag)
- Scaling: Divide-by-2 per stage (9 stages total)
- Reordering: Dual-port BRAM ping-pong buffer
- Interface: Streaming handshake (valin/datain, valout/dataout)

**Systolic Array:**

- Grid: 16×16 PEs
- PE Microarchitecture: 16-bit multiplier, 32-bit saturating accumulator
- Dataflow: Weight-stationary or output-stationary (TBD per layer)
- Tiling: Support for matrix dimensions > 16 via blocking

## License

MIT License
