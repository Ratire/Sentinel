# Senti – Privacy-First Smart Home AI System

A local, FPGA-accelerated smart home platform combining voice recognition and radar motion detection on the AMD Kria KV260. All processing happens on-device with zero cloud dependency.

## Overview

With usage of AI at home, privacy has become an issue with regard to what companies can and cannot detect and record. Senti solves this issue by being an at-home AI which can be programmed to complete specific functions that are preprogrammed into it (like turning on and off lights, running specific programs, etc.), along with detecting visitors or things that move within its vicinity (a function to be upgraded later with a better device later).

## Key Features

- 🎙️ Real-time voice command recognition using I2S MEMS microphone array
- 📡 HB100 Doppler radar for motion sensing and micro-Doppler classification  
- 🧠 Custom 16×16 systolic array CNN accelerator for on-device AI inference
- ⚡ Parallel 8-channel 512-point FFT engines for audio and radar DSP
- 🏠 MQTT/REST API for smart home integration
- 🔒 Complete privacy: zero cloud services, all processing local

## Hardware Architecture

- **Compute:** AMD Kria KV260 Vision AI Starter Kit (Zynq UltraScale+ MPSoC)
- **Audio Input:** Adafruit SPH0645LM4H I2S MEMS microphone breakout
- **Motion Sensor:** HB100 10.5 GHz Doppler radar module + MCP3008 SPI ADC
- **Audio Output:** USB powered speaker (USB audio device)
- **Memory:** 4 GB on-module DDR4, microSD boot storage
- **Networking:** 1 GbE Ethernet for smart home control

## FPGA Accelerators (PL)

- **Multi-Channel FFT Core:** 8-channel 512-point pipeline for audio and radar signal processing
- **Systolic Array AI Engine:** 16×16 processing element array for CNN matrix operations
- **Radar DSP Chain:** Pulse compression, MTD, and CFAR for target detection
- **AXI DMA Controllers:** High-throughput data movement between DDR and PL

## System Integration Flow

Microphone → I2S Receiver → Audio FFT → Feature Extraction → Systolic Array → ARM Decision → Smart Home Actions  
Radar → ADC → Radar FFT → MTD → CFAR → Systolic Array → Target ID → ARM Alert Generation

## Project Status

Week 1-4: Multi-Channel Parallel FFT implementation (in progress)

## Documentation

See `/docs` folder for weekly progress reports, design decisions, and technical deep-dives.

## License

MIT License
