# LLM Performance Benchmark (llama.cpp)

> **Focus:** Real-world LLM inference performance across GPUs using **Vulkan** and **ROCm** backends

This repository documents practical benchmarking results of running modern Large Language Models (LLMs) locally with **llama.cpp** via **LM Studio**. The goal is to provide reproducible, hardware-focused insights rather than synthetic benchmarks.

---

## Contents

- [Test Setup](#test-setup)
- [Hardware Configurations](#hardware-configurations)
- [Models Tested](#models-tested)
- [Benchmark Results](#benchmark-results)
- [Key Findings](#key-findings)
- [Conclusion](#conclusion)

---

## Test Setup

- **LM Studio:** 0.4.2
- **llama.cpp (Linux, Vulkan):** v2.1.0
- **llama.cpp (Linux, ROCm):** v2.1.0

### LM Studio definitions
- System prompt:
    ```
    You are a helpful, knowledgeable AI assistant.
    Answer questions concisely and factually.
    Always cite sources when available.
    Use retrieved documents if necessary.
    
    Always respond in the same language as the user's latest message.
    Do not change the response language unless the user explicitly asks to.
    
    Never respond in Russian.
    If the user's message is in Russian, respond in Ukrainian or English instead.
    ```
- Temperature: `0`
- Asked question:
    ```
    I need an Arduino sketch for Arduino UNO.
    It is required to measure temperature and, using PWM, change the voltage so that a fan connected to the PWM pin changes its speed.
    The fan is a 4-pin computer fan.
    The pin responsible for speed control accepts 0–5 V.
    The sensor is an NTC 10K 3435.
    The sensor voltage, temperature, and the desired PWM percentage must be displayed in Serial for debugging.
    In case of overheating, or if the sensor is open-circuit or short-circuited, the fan speed must be set to maximum.
    During controller initialization, perform a visual test:
    - increase speed to 100% for 2 seconds
    - decrease to 20% for 2 seconds
    - increase speed to 100% for 2 seconds
    - decrease to 20% for 2 seconds
    - then switch to the main temperature-based fan control loop
    ```

### Metrics

- **tok/sec** – sustained generation throughput
- **tokens** – total generated tokens
- **TTFT** – Time To First Token (latency)

All tests were performed with identical prompts and settings per model.

---

## Hardware Configurations

### HW #1 – High-End Desktop

- **GPU:** AMD RX 9070 XT (16 GB)
- **CPU:** AMD Ryzen 7 9700X
- **RAM:** 64 GB DDR5-6400 CL32 (EXPO)
- **Motherboard:** ASUS TUF GAMING B850-PLUS WIFI
- **PSU:** Be Quiet! Pure Power 12 M 850W

### HW #2 – Small Form Factor / Low-Power

- **System:** Lenovo M720q (ReBAR enabled, patched BIOS)
- **CPU:** Intel Core i5-9600T
- **RAM:** 32 GB DDR4-3200 (2×16 GB)
- **PSU:** 135 W external

---

## Models Tested

All models use **Q4_K_M** or equivalent low-precision formats.

- **Google Gemma 3:** 4B, 12B
- **Meta LLaMA 3.1:** 8B Instruct
- **Qwen3:** 14B (thinking enabled / disabled)
- **GPT-OSS:** 20B MXFP4 (low-reasoning)

---

## Benchmark Results

### Google Gemma 3 – 4B (Q4_K_M)

| GPU | HW | API | Performance |
|-----|----|-----|-------------|
| AMD RX 560 4GB | HW2 | Vulkan | 11.90 tok/sec · 1299 tokens · 3.90 s TTFT |
| AMD RX 6300 4GB (mod) | HW2 | Vulkan | 13.10 tok/sec · 1023 tokens · 3.51 s TTFT |
| **AMD RX 9070 XT 16GB** | HW1 | **Vulkan** | **122.27 tok/sec · 1389 tokens · 0.31 s TTFT** |
| AMD RX 9070 XT 16GB | HW1 | ROCm | 101.07 tok/sec · 1615 tokens · 0.15 s TTFT |
| Intel Arc A310 4GB | HW2 | Vulkan | 8.38 tok/sec · 1237 tokens · 6.56 s TTFT |
| Intel Arc A380 6GB | HW2 | Vulkan | 13.58 tok/sec · 1270 tokens · 3.45 s TTFT |
| Intel Arc Pro B50 16GB | HW2 | Vulkan | 22.09 tok/sec · 1224 tokens · 0.52 s TTFT |

---

### Meta LLaMA 3.1 – 8B Instruct (Q4_K_M, from lmstudio-community)

| GPU | HW | API | Performance |
|-----|----|-----|-------------|
| **AMD RX 9070 XT 16GB** | HW1 | Vulkan | **99.08 tok/sec · 689 tokens · 0.53 s TTFT** |
| AMD RX 9070 XT 16GB | HW1 | ROCm | 80.10 tok/sec · 780 tokens · 0.23 s TTFT |
| Intel Arc A380 6GB | HW2 | Vulkan | 6.77 tok/sec · 539 tokens · 7.36 s TTFT |
| Intel Arc Pro B50 16GB | HW2 | Vulkan | 14.55 tok/sec · 542 tokens · 0.97 s TTFT |

---

### Google Gemma 3 – 12B (Q4_K_M)

| GPU | HW | API | Performance |
|-----|----|-----|-------------|
| **AMD RX 9070 XT 16GB** | HW1 | Vulkan | **59.22 tok/sec · 1384 tokens · 0.75 s TTFT** |
| AMD RX 9070 XT 16GB | HW1 | ROCm | 47.37 tok/sec · 1735 tokens · 0.21 s TTFT |
| Intel Arc Pro B50 16GB | HW2 | Vulkan | 9.99 tok/sec · 1541 tokens · 1.55 s TTFT |

---

### Qwen3 – 14B (Q4_K_M)

#### Thinking Enabled

| GPU | HW | API | Performance |
|-----|----|-----|-------------|
| **AMD RX 9070 XT 16GB** | HW1 | Vulkan | **55.18 tok/sec · 3079 tokens · 0.88 s TTFT** (thinking ~40 s) |
| AMD RX 9070 XT 16GB | HW1 | ROCm | 49.95 tok/sec · 3145 tokens · 1.36 s TTFT |
| Intel Arc Pro B50 16GB | HW2 | Vulkan | 6.96 tok/sec · 6383 tokens · 2.08 s TTFT (thinking ~13.5 min) |

#### Thinking Disabled

| GPU | HW | API | Performance |
|-----|----|-----|-------------|
| **AMD RX 9070 XT 16GB** | HW1 | Vulkan | **57.60 tok/sec · 1094 tokens · 0.83 s TTFT** |
| AMD RX 9070 XT 16GB | HW1 | ROCm | 49.66 tok/sec · 930 tokens · 0.38 s TTFT |
| Intel Arc Pro B50 16GB | HW2 | Vulkan | 8.06 tok/sec · 952 tokens · 1.80 s TTFT |

---

### GPT-OSS – 20B (MXFP4, Low Reasoning)

| GPU | HW | API | Performance |
|-----|----|-----|-------------|
| **AMD RX 9070 XT 16GB** | HW1 | Vulkan | **82.05 tok/sec · 1383 tokens · 0.66 s TTFT** |
| AMD RX 9070 XT 16GB | HW1 | ROCm | 70.60 tok/sec · 1305 tokens · 0.30 s TTFT |
| Intel Arc Pro B50 16GB | HW2 | Vulkan | 14.35 tok/sec · 1582 tokens · 1.17 s TTFT |

---

## Key Findings

- **Vulkan** delivers higher sustained throughput across all tested GPUs
- **ROCm** consistently provides lower TTFT and better interactivity
- **AMD RX 9070 XT** scales efficiently from 4B to 20B models
- Intel **Arc Pro B50** is usable for mid-size models but struggles with reasoning workloads
- Reasoning / thinking modes massively increase wall-clock time on weaker GPUs

---

## Conclusion

These benchmarks show that modern consumer GPUs are fully capable of local LLM inference when paired with the right backend and quantization strategy.

- Choose **Vulkan** for maximum throughput
- Choose **ROCm** for interactive latency-sensitive workloads
- For serious local LLM work, **16 GB VRAM is the practical minimum**

This README is intended to be a living document and will be updated as new GPUs, models, and backends are tested.
