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

## `llama-bench` CLI reference

```
usage: ./llama-bench [options]

options:
  -h, --help
  --numa <distribute|isolate|numactl>         numa mode (default: disabled)
  -r, --repetitions <n>                       number of times to repeat each test (default: 5)
  --prio <-1|0|1|2|3>                         process/thread priority (default: 0)
  --delay <0...N> (seconds)                   delay between each test (default: 0)
  -o, --output <csv|json|jsonl|md|sql>        output format printed to stdout (default: md)
  -oe, --output-err <csv|json|jsonl|md|sql>   output format printed to stderr (default: none)
  --list-devices                              list available devices and exit
  -v, --verbose                               verbose output
  --progress                                  print test progress indicators
  --no-warmup                                 skip warmup runs before benchmarking
  -fitt, --fit-target <MiB>                   fit model to device memory with this margin per device in MiB (default: off)
  -fitc, --fit-ctx <n>                        minimum ctx size for --fit-target (default: 4096)

test parameters:
  -m, --model <filename>                            (default: models/7B/ggml-model-q4_0.gguf)
  -hf, -hfr, --hf-repo <user>/<model>[:quant]       Hugging Face model repository; quant is optional, case-insensitive
                                                    default to Q4_K_M, or falls back to the first file in the repo if Q4_K_M doesn't exist.
                                                    example: ggml-org/GLM-4.7-Flash-GGUF:Q4_K_M
                                                    (default: unused)
  -hff, --hf-file <file>                            Hugging Face model file. If specified, it will override the quant in --hf-repo
                                                    (default: unused)
  -hft, --hf-token <token>                          Hugging Face access token
                                                    (default: value from HF_TOKEN environment variable)
  --offline                                         Offline mode: forces use of cache, prevents network access
                                                    (default: disabled)
  -p, --n-prompt <n>                                (default: 512)
  -n, --n-gen <n>                                   (default: 128)
  -pg <pp,tg>                                       (default: )
  -d, --n-depth <n>                                 (default: 0)
  -b, --batch-size <n>                              (default: 2048)
  -ub, --ubatch-size <n>                            (default: 512)
  -ctk, --cache-type-k <t>                          (default: f16)
  -ctv, --cache-type-v <t>                          (default: f16)
  -t, --threads <n>                                 (default: 8)
  -C, --cpu-mask <hex,hex>                          (default: 0x0)
  --cpu-strict <0|1>                                (default: 0)
  --poll <0...100>                                  (default: 50)
  -ngl, --n-gpu-layers <n>                          (default: -1)
  -ncmoe, --n-cpu-moe <n>                           (default: 0)
  -sm, --split-mode <none|layer|row|tensor>         (default: layer)
  -mg, --main-gpu <i>                               (default: 0)
  -nkvo, --no-kv-offload <0|1>                      (default: 0)
  -fa, --flash-attn <on|off|auto>                   (default: auto)
  -dev, --device <dev0/dev1/...>                    (default: auto)
  -lm, --load-mode <auto|none|mmap|mlock|mmap+mlock|dio> (default: auto)
  -mmp, --mmap <0|1>                                (DEPRECATED IN FAVOUR OF --load-mode)
  -dio, --direct-io <0|1>                           (DEPRECATED IN FAVOUR OF --load-mode)
  -embd, --embeddings <0|1>                         (default: 0)
  -ts, --tensor-split <ts0/ts1/..>                  (default: 0)
  -ot --override-tensor <tensor name pattern>=<buffer type>;...
                                                    (default: disabled)
  -nopo, --no-op-offload <0|1>                      (default: 0)
  --no-host <0|1>                                   (default: 0)

Multiple values can be given for each parameter by separating them with ','
or by specifying the parameter multiple times. Ranges can be given as
'first-last' or 'first-last+step' or 'first-last*mult'.
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
