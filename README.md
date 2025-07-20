# Detector Simulator

## Introduction

Welcome! **"Detector Simulator"** is a hardware design project that simulates a system which generates, processes, and serializes pixel data from multiple sources. It’s useful for applications such as image processing, display systems, or systems requiring synchronized serial data transmission.

In this project, there are only **two inputs**:
- **`rst`** — Reset signal to initialize the system.
- **`clk`** — Main clock signal that drives all operations.

All other signals are **outputs**, which include:

- Serial data streams (`serial1` to `serial5`),
- Various internal control and data signals processed within the system.

---

## Overview of the Process

The **Detector Simulator** operates using a structured pipeline composed of several key processes:

### 1. **Control & Timing Management**
- Coordinates overall operation.
- Manages states, counters, and synchronization signals.
- Triggers pixel data generation based on timing.

### 2. **Pixel Data Generation (for B1 to B5)**
- Each of the five pixel sources produces **parallel pixel signals**.
- These signals are internally generated based on the current control state.
- Pixel data can represent any pixel information like color intensity, brightness, etc.

### 3. **Parallel-to-Serial Conversion**
- Converts the parallel pixel data into serial bit streams.
- Shifts pixel bits out sequentially on each clock cycle.
- Synchronizes data transmission with system clock.

### 4. **Serial Data Output**
- Output five separate serial streams (`serial1` to `serial5`).
- These streams convey pixel data sequentially for each source.
- Used for display, communication, or further processing.

---

## How the System Works: Step-by-Step Explanation

### Step 1: Initialization
- When `rst` is asserted, all internal registers, counters, and states are reset.
- The system waits for the `clk` signal to start normal operation.

### Step 2: Control & Timing Management
- The control module uses `clk` to increment counters and switch states.
- It determines when pixel data should be generated and serialized.
- Keeps everything synchronized, ensuring timing accuracy.

### Step 3: Pixel Data Generation
- Based on the current control state, each pixel source (B1–B5) produces **parallel pixel data** (`bX_ocnt`, `bX_ecnt`).
- These signals represent the pixel information in a parallel format.
- The generation logic can simulate real pixel data or be based on predefined patterns.

### Step 4: Parallel-to-Serial Conversion
- Each pixel source's parallel data is fed into a serializer.
- The serializer shifts out bits one-by-one for each clock cycle.
- Maintains synchronization to ensure that data aligns correctly with the system clock.

### Step 5: Serial Data Transmission
- The serialized bits are sent out through `serial1` to `serial5`.
- The outputs can be connected to other hardware modules for display, communication, or testing.

---

## Summary of Core Modules & Signals

| Module/Process                   | Description                                                          |
|----------------------------------|----------------------------------------------------------------------|
| **Control Module**               | Manages system operation, states, and synchronization signals.     |
| **Pixel Data Modules (B1–B5)**    | Generate parallel pixel data signals based on internal logic.       |
| **Parallel-to-Serial Modules**   | Convert parallel pixel data into serial bit streams.                |
| **Serial Outputs (`serial1`–`serial5`)** | Transmit the serialized pixel data streams.                       |

### **Main Inputs:**
- `rst` — Reset signal
- `clk` — Clock signal

### **Main Outputs:**
- `serial1`, `serial2`, `serial3`, `serial4`, `serial5` — Serial data streams for each pixel source

---

## How to Use or Simulate

- Use hardware synthesis tool **Libero** synthesis tool **Questa-Sim**.
- Provide a clock signal (`clk`) that drives the system.
- Toggle `rst` to reset the system.
- Observe the serial output streams to verify data correctness.
- Connect the outputs to display modules or communication interfaces for real-world applications.
