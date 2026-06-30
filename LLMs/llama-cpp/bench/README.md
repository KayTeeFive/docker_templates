# llama.cpp — Inference Benchmarks

Benchmark suite for measuring **prompt-processing (PP)** and
**token-generation (TG)** throughput across the three llama.cpp GPU backends:

| Script            | Backend                       | Docker image                             |
|-------------------|-------------------------------|------------------------------------------|
| `bench-rocm.sh`   | AMD ROCm                      | `ghcr.io/ggml-org/llama.cpp:full-rocm`   |
| `bench-intel.sh`  | Intel SYCL (Arc / Xe)         | `ghcr.io/ggml-org/llama.cpp:full-intel`  |
| `bench-vulkan.sh` | Vulkan (AMD / Intel / NVIDIA) | `ghcr.io/ggml-org/llama.cpp:full-vulkan` |
| `bench-all.sh`    | all of the above              | —                                        |

---

## Quick start

```bash
# 1. Create .env from the template
cp env-file.template .env

# 2. Fill in at minimum:
#    BENCH_MODELS_DIR — path to the directory with your .gguf files
#    BENCH_MODEL_FILE — file name of the model to benchmark
$EDITOR .env

# 3. Run one backend
./bench-rocm.sh       # AMD ROCm
./bench-intel.sh      # Intel SYCL
./bench-vulkan.sh     # Vulkan

# 4. Or run all backends sequentially and get a combined report
./bench-all.sh

# Pull fresh Docker images before benchmarking (optional)
./bench-all.sh --no-cache

# Run only specific backends
./bench-all.sh rocm vulkan
```

Results are written to `results/` as Markdown tables (configurable via
`BENCH_OUTPUT_FORMAT` in `.env`).

---

## Configuration (`env-file.template` → `.env`)

| Variable               | Default                          | Description                                               |
|------------------------|----------------------------------|-----------------------------------------------------------|
| `BENCH_MODELS_DIR`     | `/home/dockeruser/.llama_models` | Host directory containing `.gguf` files                   |
| `BENCH_MODEL_FILE`     | *(required)*                     | File name of the model to benchmark                       |
| `BENCH_CACHE_DIR`      | `/home/dockeruser/.llama_cache`  | Model weight cache (speeds up re-runs)                    |
| `BENCH_GPU_LAYERS`     | `99`                             | GPU layers to offload (99 = all)                          |
| `BENCH_KV_TYPE_K`      | `q8_0`                           | KV-cache quantization for K                               |
| `BENCH_KV_TYPE_V`      | `q8_0`                           | KV-cache quantization for V                               |
| `BENCH_CPU_THREADS`    | `8`                              | CPU threads for non-GPU layers                            |
| `BENCH_BATCH_SIZE`     | `2048`                           | Logical batch size                                        |
| `BENCH_UBATCH_SIZE`    | `512`                            | Physical micro-batch size                                 |
| `BENCH_PP_TOKENS`      | `128,512,2048`                   | Prompt token counts (PP scenarios)                        |
| `BENCH_TG_TOKENS`      | `128,512`                        | Generation token counts (TG scenarios)                    |
| `BENCH_REPETITIONS`    | `3`                              | Repetitions per scenario                                  |
| `BENCH_OUTPUT_FORMAT`  | `md`                             | Output format: `md`, `json`, `csv`, `sql`                 |
| `BENCH_RESULTS_DIR`    | `./results`                      | Where result files are written                            |
| `ROCM_GFX_VERSION`     | `12.0.1`                         | HSA GFX override for RDNA4 (RX 9070 XT)                   |
| `ROCM_VISIBLE_DEVICES` | `0`                              | AMD GPU index                                             |
| `SYCL_DEVICE_FILTER`   | `level_zero:gpu:0`               | SYCL device filter                                        |
| `BENCH_SYCL_DEVICE`    | `SYCL0`                          | SYCL device passed to `--device`                          |
| `BENCH_VULKAN_DEVICE`  | `Vulkan0`                        | Vulkan device passed to `--device`                        |
| `AMD_VULKAN_ICD`       | `RADV`                           | Vulkan ICD driver (`RADV` = Mesa, `AMDVLK` = proprietary) |

---

## What is measured

`llama-bench` runs two types of tests per scenario:

| Test                       | Flag   | Measures                                            |
|----------------------------|--------|-----------------------------------------------------|
| **PP** (prompt processing) | `-p N` | Tokens/s while ingesting the prompt (prefill speed) |
| **TG** (token generation)  | `-n N` | Tokens/s during autoregressive generation           |

The scenarios are all combinations of `BENCH_PP_TOKENS × BENCH_TG_TOKENS`, e.g.
with defaults `128,512,2048 × 128,512` → 6 scenarios × 3 reps = 18 runs.

---

## Result files

```
results/
  bench_rocm_20260630_143012.md
  bench_intel_20260630_143842.md
  bench_vulkan_20260630_144501.md
  bench_combined_20260630_144502.md   # created by bench-all.sh
```

Example Markdown output (one row per scenario):

```
| model                               | size     | params  | backend  | ngl  | fa  | mmap  | ...  | test  | t/s             |
|-------------------------------------|----------|---------|----------|------|-----|-------|------|-------|-----------------|
| Qwen3-Coder-30B-A3B-Instruct-Q4_K_M | 17.2 GiB | 30.5 B  | ROCm     | 99   | 1   | 1     | ...  | pp512 | 1234.56 ± 12.34 |
| Qwen3-Coder-30B-A3B-Instruct-Q4_K_M | 17.2 GiB | 30.5 B  | ROCm     | 99   | 1   | 1     | ...  | tg128 | 45.67 ± 0.23    |
```

---

## List available GPU devices

```bash
# ROCm
docker run --rm --device /dev/kfd --device /dev/dri \
  --group-add video --group-add render \
  ghcr.io/ggml-org/llama.cpp:full-rocm llama-bench --list-devices

# Intel SYCL
docker run --rm --device /dev/dri \
  ghcr.io/ggml-org/llama.cpp:full-intel llama-bench --list-devices

# Vulkan
docker run --rm --device /dev/dri \
  ghcr.io/ggml-org/llama.cpp:full-vulkan llama-bench --list-devices
```

---

## Tips

- **Warm-up**: llama-bench performs a warm-up run before each test by default.
- **Flash Attention**: always enabled (`--flash-attn 1`) — gives significant
  throughput improvements on all backends.
- **RDNA4 / RX 9070 XT**: set `ROCM_GFX_VERSION=12.0.1` in `.env`.  If ROCm
  still errors, try `11.0.0` (RDNA3 fallback).
- **Multiple GPUs**: to split across two GPUs with ROCm, add
  `--tensor-split 1,1 --split-mode layer` by editing `bench-rocm.sh`.
- **KV-cache impact**: try `BENCH_KV_TYPE_K=f16 BENCH_KV_TYPE_V=f16` vs
  `q8_0/q8_0` to see throughput vs accuracy trade-off at your context length.

