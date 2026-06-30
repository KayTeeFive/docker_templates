# llama.cpp — Inference Benchmarks

Benchmark suite for measuring **prompt-processing (PP)** and
**token-generation (TG)** throughput across the three llama.cpp GPU backends:

| Script | Backend | Docker image |
|---|---|---|
| `bench-rocm.sh` | AMD ROCm | `ghcr.io/ggml-org/llama.cpp:full-rocm` |
| `bench-intel.sh` | Intel SYCL (Arc / Xe) | `ghcr.io/ggml-org/llama.cpp:full-intel` |
| `bench-vulkan.sh` | Vulkan (AMD / Intel / NVIDIA) | `ghcr.io/ggml-org/llama.cpp:full-vulkan` |
| `bench-all.sh` | all of the above | — |

---

## Quick start

```bash
# .env is created automatically from the template on the first run.
# Just set the two required variables and go:
./bench-vulkan.sh       # creates .env, then fails with "BENCH_MODEL_FILE not set"

# Edit the generated .env:
$EDITOR .env
# BENCH_MODELS_DIR=/home/user/.llama_models
# BENCH_MODEL_FILE=gpt-oss-20b-mxfp4.gguf

# Re-run
./bench-rocm.sh         # AMD ROCm
./bench-intel.sh        # Intel SYCL
./bench-vulkan.sh       # Vulkan

# All backends sequentially + combined report
./bench-all.sh

# Pull fresh Docker images before benchmarking
./bench-all.sh --no-cache

# Only specific backends
./bench-all.sh rocm vulkan
```

Results are written to `results/` as Markdown tables (configurable via
`BENCH_OUTPUT_FORMAT` in `.env`).

---

## Configuration (`env-file.template` → `.env`)

### Model

| Variable | Default | Description |
|---|---|---|
| `BENCH_MODELS_DIR` | `/home/<user>/.llama_models` | Host directory containing `.gguf` files |
| `BENCH_MODEL_FILE` | *(required)* | File name of the model to benchmark |
| `BENCH_CACHE_DIR` | `/home/<user>/.llama_cache` | Model weight cache (speeds up re-runs) |

### Performance

| Variable | Default | Description |
|---|---|---|
| `BENCH_GPU_LAYERS` | `99` | GPU layers to offload (99 = all) |
| `BENCH_KV_TYPE_K` | `q8_0` | KV-cache quantization for K |
| `BENCH_KV_TYPE_V` | `q8_0` | KV-cache quantization for V |
| `BENCH_CPU_THREADS` | `8` | CPU threads for non-GPU layers |
| `BENCH_BATCH_SIZE` | `2048` | Logical batch size |
| `BENCH_UBATCH_SIZE` | `512` | Physical micro-batch size |

### Multi-GPU split

| Variable | Default | Description |
|---|---|---|
| `BENCH_SPLIT_MODE` | `none` | `none` = single GPU · `layer` = split layers+KV · `row` = split rows |
| `BENCH_TENSOR_SPLIT` | `1,1` | Fraction per GPU — equal split `1,1`, asymmetric e.g. `3,1` |
| `BENCH_MAIN_GPU` | `0` | Primary GPU index (KV + intermediate results) |

### Benchmark scenarios

| Variable | Default | Description |
|---|---|---|
| `BENCH_PP_TOKENS` | `128,512,2048` | Prompt token counts for PP tests (comma-separated) |
| `BENCH_TG_TOKENS` | `128,512` | Generation token counts for TG tests (comma-separated) |
| `BENCH_REPETITIONS` | `3` | Repetitions per scenario |
| `BENCH_OUTPUT_FORMAT` | `md` | Output format: `md`, `json`, `csv`, `sql` |
| `BENCH_RESULTS_DIR` | `./results` | Where result files are written |

### Backend-specific

| Variable | Default | Description |
|---|---|---|
| `ROCM_GFX_VERSION` | `9.0.0` | HSA GFX override — see table below |
| `ROCM_VISIBLE_DEVICES` | `0` | AMD GPU indices: `0` or `0,1` for dual |
| `SYCL_DEVICE_FILTER` | `level_zero:gpu:0` | SYCL device filter |
| `BENCH_SYCL_DEVICE` | `SYCL0` | SYCL device passed to `--device` |
| `BENCH_VULKAN_DEVICE` | `Vulkan0` | Vulkan device(s): `Vulkan0` or `Vulkan0,Vulkan1` |
| `AMD_VULKAN_ICD` | `RADV` | Vulkan driver: `RADV` (Mesa) or `AMDVLK` (proprietary) |

#### `ROCM_GFX_VERSION` reference

| GPU | Architecture | Value |
|---|---|---|
| MI25 / WX9100 | Vega 10 | `9.0.0` |
| RX 5700 XT | RDNA1 | `10.1.0` |
| RX 6800 / 6900 | RDNA2 | `10.3.0` |
| RX 7900 XT | RDNA3 | `11.0.0` |
| RX 9070 XT | RDNA4 | `12.0.1` |

---

## What is measured

`llama-bench` runs two types of tests per scenario:

| Test | Flag | Measures |
|---|---|---|
| **PP** (prompt processing) | `-p N` | Tokens/s while ingesting the prompt (prefill speed) |
| **TG** (token generation) | `-n N` | Tokens/s during autoregressive generation |

The scenarios are all combinations of `BENCH_PP_TOKENS × BENCH_TG_TOKENS`.  
Example with `128,512,2048 × 128,512` → 6 scenarios × 3 reps = 18 runs.

> **Rule of thumb:** PP speed >> TG speed (PP is parallel, TG is sequential).  
> TG is the metric that matters most for real-world chat latency.

### Recommended values for large contexts

| ctx-size | BENCH_PP_TOKENS | BENCH_TG_TOKENS |
|---|---|---|
| 8 192 | `128,512,2048` | `128,512` |
| 32 768 | `512,2048,8192` | `128,512` |
| 131 072 | `512,4096,16384,65536` | `128,512` |

---

## Dual-GPU setup

```dotenv
# ROCm — two GPUs (e.g. dual MI25 / WX9100)
ROCM_VISIBLE_DEVICES=0,1
BENCH_SPLIT_MODE=layer
BENCH_TENSOR_SPLIT=1,1    # equal split; use 3,1 if GPUs differ in VRAM

# Vulkan — two GPUs
BENCH_VULKAN_DEVICE=Vulkan0,Vulkan1
BENCH_SPLIT_MODE=layer
BENCH_TENSOR_SPLIT=1,1
```

---

## Result files

```
results/
  bench_rocm_20260630_143012.md
  bench_intel_20260630_143842.md
  bench_vulkan_20260630_144501.md
  bench_combined_20260630_144502.md   # created by bench-all.sh
```

Example Markdown output:

```
| model        | size     | params | backend | ngl | sm    | ts  | fa | test    | t/s             |
|--------------|----------|--------|---------|-----|-------|-----|----|---------|-----------------|
| gpt-oss-20b  | 12.0 GiB | 20.0 B | Vulkan  | 99  | none  | 0   | 1  | pp512   | 1234.56 ± 12.34 |
| gpt-oss-20b  | 12.0 GiB | 20.0 B | Vulkan  | 99  | none  | 0   | 1  | tg128   |   45.67 ± 0.23  |
```

---

## List available GPU devices

```bash
# ROCm
docker run --rm --device /dev/kfd --device /dev/dri \
  --group-add video --group-add render \
  ghcr.io/ggml-org/llama.cpp:full-rocm --bench --list-devices

# Intel SYCL
docker run --rm --device /dev/dri \
  ghcr.io/ggml-org/llama.cpp:full-intel --bench --list-devices

# Vulkan
docker run --rm --device /dev/dri \
  ghcr.io/ggml-org/llama.cpp:full-vulkan --bench --list-devices
```

---

## Tips

- **Auto `.env`**: scripts create `.env` from template automatically on the first run —
  no manual `cp` needed.
- **Entrypoint**: `full-*` images use a wrapper; the benchmark subcommand is `--bench`
  (not `llama-bench` directly).
- **Flash Attention**: always enabled (`-fa 1`) — significant throughput gain on all backends.
- **KV-cache trade-off**: try `BENCH_KV_TYPE_K=f16 BENCH_KV_TYPE_V=f16` vs `q8_0/q8_0`
  to see VRAM vs speed differences at your context length.
- **Asymmetric split**: if two GPUs have different VRAM (e.g. 16 GiB + 8 GiB),
  set `BENCH_TENSOR_SPLIT=2,1` instead of `1,1`.
