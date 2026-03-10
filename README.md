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

### FFT512ReorderIP (Complete, Verified, Bitstream Generated)

- **Type:** Custom 512-point radix-2 Single-Path Delay Feedback (SDF) FFT
- **Language:** SystemVerilog with fixed-point arithmetic
- **Features:**
  - 18-bit signed input (Q2.15), 54-bit complex output (27b real + 27b imag)
  - Per-stage scaling with saturating arithmetic
  - Hardware bit-reversal buffer for natural-order output
  - Twiddle factors in ROM initialized from Python-generated .mem files
  - AXI-Stream interface with DMA offload support
- **Status:** Architecturally frozen, verified against Python fixed-point golden model, packaged as Vivado IP, bitstream generated
- **Current Task:** Bare-metal DMA loopback validation (PS→DDR→DMA→FFT→DMA→DDR→PS)
- **Latency:** ~512 cycles + pipeline stages

### SystolicArray16x16 (In Development)

- **Architecture:** 16×16 grid of Processing Elements (PEs)
- **Dataflow:** Output-stationary (accumulator stays in PE)
- **Precision:** Signed 16-bit inputs/weights, 32-bit saturating accumulator
- **Operation:** Int16 × Int16 → Int32 MAC every cycle
- **Purpose:** CNN inference engine for voice command classification and radar target detection
- **Status:** PE microarchitecture defined, RTL implementation in progress
- **Verification Plan:** 2×2 → 4×4 → 16×16 scaling against Python integer matmul golden

## System Integration Flow

### Audio/Voice Pipeline

I2S Microphone → PS Buffer (512-sample windows) → AXI DMA → FFT512ReorderIP → Mel Feature Extraction (ARM) → SystolicArray CNN → 8-class Command ID → Robot Motor Control/LEDs

### Radar/Motion Pipeline  

Distance2GoL I/Q → PMOD ADC → PS Buffer → AXI DMA → FFT512ReorderIP → Doppler Magnitude (ARM) → Motion Energy Threshold → MOTION LED / Occupancy Grid

## Project Status and Roadmap

**Current Status (March 2026):**

- FFT512ReorderIP: Complete, verified, packaged in `src/ip/fft_ip/`, bitstream generated
- Vivado Block Design: PS + AXI DMA + FFT IP instantiated and routed
- AXI-Stream Shim: Implemented (converts 64-bit AXI to 18-bit FFT samples)
- Systolic Array: PE microarchitecture defined, RTL implementation pending
- Voice CNN: Architecture defined (128-dim FC → 8 outputs), training pending
- Radar Integration: Distance2GoL hardware received, PMOD ADC interface design pending
- Robot Base: Parts ordered, assembly in progress

**Current Development Priorities (March 2026):**

Rather than rushing a superficial demo for NSBE, the focus is on completing a verified, production-quality implementation of the core accelerators.

1. **FFT IP Validation (In Progress):** Complete bare-metal DMA loopback testing on KV260 hardware to verify bit-accurate operation against Python golden model. Debug AXI-Stream shim timing if needed.
2. **Systolic Array Implementation:** Complete RTL for 16×16 output-stationary array with verified PE microarchitecture. Target: Clean, documented code over rushed integration.
3. **Hardware-Software Interface:** Solidify AXI-Lite control path and DMA descriptor management for reliable data flow.

**NSBE 2026 (March 18-22):**
Attending primarily for networking and career exploration. The goal is to discuss the Sentinel architecture (verified FFT IP, systolic array design methodology) with FPGA/SoC engineers and recruiters, not to present a flashy incomplete demo. The robot chassis and radar integration remain exploratory stretch goals for post-conference development once the compute fabric is solid.

**Post-NSBE Roadmap:**
- Complete systolic array verification (2×2 → 4×4 → 16×16 scaling)
- CNN weight loading and inference validation on hardware
- Begin robot chassis integration (motor drivers, encoder feedback)
- Distance2GoL radar ADC interface design (after FFT/systolic are stable)

## Repository Structure
```
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
├── hardware/                   # Hardware platform files
│   └── block_design/           # Vivado block design and IP configs
│       ├── FFT512_Reorder_IP.bd
│       └── ip/
├── scripts/                    # Python utility scripts
│   ├── generating_twiddles/
│   │   ├── generating_twiddles.py
│   │   └── twiddle_unified.mem
│   └── golden_models/          # Python fixed-point reference models
│       ├── fft_golden.py
│       └── generate_test_vectors.py
├── sim/                        # Simulation and verification
│   ├── testbenches/            # SystemVerilog testbenches
│   │   ├── tb_Butterfly.sv
│   │   ├── tb_FFT512_Reorder.sv
│   │   └── ...
│   └── waveforms/              # Vivado waveform configs
├── src/                        # RTL source and constraints
│   ├── constraints/
│   │   └── kv260.xdc
│   ├── ip/                     # Packaged Vivado IPs
│   │   ├── fft_ip/             # FFT512ReorderIP (frozen)
│   │   │   ├── component.xml
│   │   │   ├── src/
│   │   │   └── xgui/
│   │   └── systolic_ip/        # Systolic array (in dev)
│   └── rtl/                    # SystemVerilog source code
│       ├── axi_interfaces/     # AXI-Stream shim
│       │   └── fft512_axishim.v
│       ├── fft_core/           # SDF FFT implementation
│       │   ├── Butterfly.sv
│       │   ├── FFT512.sv
│       │   ├── FFT_pkg.sv
│       │   └── ...
│       └── top.sv              # Top-level wrapper
├── sw/                         # Software applications
│   ├── baremetal/              # Vitis bare-metal apps
│   │   └── sentinel_fft_test/
│   │       └── src/
│   │           └── main.c      # DMA loopback test
│   ├── drivers/                # Custom IP drivers
│   └── linux_apps/             # Linux applications (PetaLinux)
├── LICENSE
└── README.md
```

## Technical Specifications

**FFT512ReorderIP:**

- Input: 18-bit signed fixed-point (Q2.15)
- Output: 54-bit complex (Q10.17 real, Q10.17 imag)
- Scaling: Divide-by-2 per stage (9 stages total)
- Reordering: Dual-port BRAM ping-pong buffer
- Interface: AXI4-Stream (64-bit data width) with `valin`/`valout` handshake
- DMA: Connected to Zynq HP0 via AXI DMA (MM2S/S2MM channels)

**Systolic Array:**

- Grid: 16×16 PEs
- PE Microarchitecture: 16-bit multiplier, 32-bit saturating accumulator, local weight storage
- Dataflow: Weight-stationary or output-stationary (configurable per layer)
- Tiling: Support for matrix dimensions > 16 via spatial blocking

## Dependencies

- AMD Vivado Design Suite 2025.2
- AMD Vitis Unified IDE 2025.2
- Python 3.8+ (NumPy for golden models)
- AMD Kria KV260 Starter Kit

## License

MIT License
