# AMD Radeon Instinct MI25 (Pro WX 9100) / Vulkan API / Tensor Split Mode

This document collects llama.cpp benchmark results for a dual **AMD Radeon Instinct MI25
(Pro WX 9100)** setup running in tensor split mode via the Vulkan backend. The goal is to
show how the PCIe bus link of the second GPU (CPU-connected x16 vs. chipset-connected x4)
affects throughput on two different host platforms.

## Test Conditions

- **Backend:** Vulkan API
- **Mode:** Tensor split (model layers distributed across both GPUs)
- **OS:** Debian Testing (7.2.8+deb14-amd64)
- **llama.cpp build:** `f2918cabb (11541)`

## Hardware Configurations

### PC1
 - CPU: Ryzen 7 9700X
 - RAM: DDR5 6000MHz 32Gb
 - Chipset: X870E
 - GPU1: AMD Radeon Instinct MI25 (Pro WX 9100) - PCIe Gen3 x16 bus link (CPU connected)
 - GPU2: AMD Radeon Instinct MI25 (Pro WX 9100) - PCIe Gen3 x4 bus link (chipset connected)

### PC2
 - CPU: Ryzen 7 3800XT
 - RAM: DDR4 2133MHz 16Gb
 - Chipset: B550M
 - GPU1: AMD Radeon Instinct MI25 (Pro WX 9100) - PCIe Gen3 x16 bus link (CPU connected)
 - GPU2: AMD Radeon Instinct MI25 (Pro WX 9100) - PCIe Gen3 x4 bus link (chipset connected)

## Benchmark Results

Columns legend: `pp*` — prompt processing throughput, `tg*` — token generation
throughput (both in tokens/s). The number is the batch/context size used for the run.
The `Degradation vs ref, %` column shows the relative throughput drop against the
reference run — positive means slower than the reference, a negative value means the
chipset-attached setup was actually faster.

> **Reference baseline:** the reference (ideal) numbers were measured with **both GPUs
> wired directly to the CPU PCIe lanes** (no chipset in the data path). The `PC1 Chipset`
> and `PC2 Chipset` tables, by contrast, have the second GPU attached through the chipset
> (PCIe Gen3 x4), which is the main variable this comparison highlights.

## gpt-oss-20b-mxfp4.gguf

Reference (ideal) results — both GPUs on direct CPU PCIe lanes:

| MODEL   | Processing type | SM: tensor, t/s |   
|---------|-----------------|-----------------|
| GPT-OSS | pp128           | 580             |
| GPT-OSS | pp512           | 835             |
| GPT-OSS | pp2048          | 792             |
| GPT-OSS | tg128           | 72              |
| GPT-OSS | tg512           | 72              |

### PC1 Chipset
| MODEL   | Processing type | SM: tensor, t/s | Degradation vs ref, % |
|---------|-----------------|-----------------|-----------------------|
| GPT-OSS | pp128           | 447             | 22.9                  |
| GPT-OSS | pp512           | 592             | 29.1                  |
| GPT-OSS | pp2048          | 576             | 27.3                  |
| GPT-OSS | tg128           | 60              | 16.7                  |
| GPT-OSS | tg512           | 60              | 16.7                  |

### PC2 Chipset
| MODEL   | Processing type | SM: tensor, t/s | Degradation vs ref, %    |
|---------|-----------------|-----------------|--------------------------|
| GPT-OSS | pp128           | 377             | 35.0                     |
| GPT-OSS | pp512           | 721             | 13.7                     |
| GPT-OSS | pp2048          | 980             | -23.7 (anomaly increase) |
| GPT-OSS | tg128           | 29              | 59.7                     |
| GPT-OSS | tg512           | 29              | 59.7                     |


## Qwen3-Coder-30B-A3B-Instruct-Q6_K.gguf

Reference (ideal) results — both GPUs on direct CPU PCIe lanes:

| MODEL                 | Processing type | SM: tensor, t/s |  
|-----------------------|-----------------|-----------------|
| qwen3moe 30B.A3B Q6_K | pp128           | 301             |
| qwen3moe 30B.A3B Q6_K | pp512           | 337             |
| qwen3moe 30B.A3B Q6_K | pp2048          | 355             |
| qwen3moe 30B.A3B Q6_K | tg128           | 39              |
| qwen3moe 30B.A3B Q6_K | tg512           | 39              |

### PC1 Chipset
| MODEL                 | Processing type | SM: tensor, t/s | Degradation vs ref, % |
|-----------------------|-----------------|-----------------|-----------------------|
| qwen3moe 30B.A3B Q6_K | pp128           | 219             | 27.2                  |
| qwen3moe 30B.A3B Q6_K | pp512           | 311             | 7.7                   |
| qwen3moe 30B.A3B Q6_K | pp2048          | 299             | 15.8                  |
| qwen3moe 30B.A3B Q6_K | tg128           | 35              | 10.3                  |
| qwen3moe 30B.A3B Q6_K | tg512           | 35              | 10.3                  |

### PC2 Chipset
| MODEL                 | Processing type | SM: tensor, t/s | Degradation vs ref, % |
|-----------------------|-----------------|-----------------|-----------------------|
| qwen3moe 30B.A3B Q6_K | pp128           | 59              | 80.4                  |
| qwen3moe 30B.A3B Q6_K | pp512           | 125             | 62.9                  |
| qwen3moe 30B.A3B Q6_K | pp2048          | 289             | 18.6                  |
| qwen3moe 30B.A3B Q6_K | tg128           | 17              | 56.4                  |
| qwen3moe 30B.A3B Q6_K | tg512           | 17              | 56.4                  |
