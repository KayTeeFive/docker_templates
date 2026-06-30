#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════════════════════
#  llama.cpp — Vulkan (AMD / Intel / NVIDIA) inference benchmark
#  Uses:  ghcr.io/ggml-org/llama.cpp:full-vulkan  (contains llama-bench)
#
#  Usage:
#    cp env-file.template .env       # first time only
#    $EDITOR .env                    # set BENCH_MODELS_DIR, BENCH_MODEL_FILE, etc.
#    ./bench-vulkan.sh               # run benchmark
#    ./bench-vulkan.sh --no-cache    # pull fresh image before running
# ══════════════════════════════════════════════════════════════════════════════
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/.env"
BACKEND="vulkan"
IMAGE="ghcr.io/ggml-org/llama.cpp:full-vulkan"

# ── helpers ───────────────────────────────────────────────────────────────────
log()  { echo "[bench-vulkan] $*"; }
die()  { echo "[bench-vulkan] ERROR: $*" >&2; exit 1; }

# ── load .env (auto-init from template if missing) ───────────────────────────
if [[ ! -f "$ENV_FILE" ]]; then
    cp -v "${SCRIPT_DIR}/env-file.template" "$ENV_FILE"
    sed -i "s|/home/dockeruser|${HOME}|g" "$ENV_FILE"
    log ".env created from template — review ${ENV_FILE}, then re-run."
fi
# shellcheck disable=SC1090
set -a; source "$ENV_FILE"; set +a

# ── defaults ─────────────────────────────────────────────────────────────────
BENCH_MODELS_DIR="${BENCH_MODELS_DIR:-/home/dockeruser/.llama_models}"
BENCH_MODEL_FILE="${BENCH_MODEL_FILE:-}"
BENCH_CACHE_DIR="${BENCH_CACHE_DIR:-/home/dockeruser/.llama_cache}"
BENCH_GPU_LAYERS="${BENCH_GPU_LAYERS:-99}"
BENCH_KV_TYPE_K="${BENCH_KV_TYPE_K:-q8_0}"
BENCH_KV_TYPE_V="${BENCH_KV_TYPE_V:-q8_0}"
BENCH_CPU_THREADS="${BENCH_CPU_THREADS:-8}"
BENCH_BATCH_SIZE="${BENCH_BATCH_SIZE:-2048}"
BENCH_UBATCH_SIZE="${BENCH_UBATCH_SIZE:-512}"
BENCH_PP_TOKENS="${BENCH_PP_TOKENS:-128,512,2048}"
BENCH_TG_TOKENS="${BENCH_TG_TOKENS:-128,512}"
BENCH_REPETITIONS="${BENCH_REPETITIONS:-3}"
BENCH_OUTPUT_FORMAT="${BENCH_OUTPUT_FORMAT:-md}"
BENCH_RESULTS_DIR="${BENCH_RESULTS_DIR:-${SCRIPT_DIR}/results}"
BENCH_VULKAN_DEVICE="${BENCH_VULKAN_DEVICE:-Vulkan0}"
AMD_VULKAN_ICD="${AMD_VULKAN_ICD:-RADV}"

# ── validate ──────────────────────────────────────────────────────────────────
[[ -n "$BENCH_MODEL_FILE" ]] || die "BENCH_MODEL_FILE is not set in .env"
[[ -d "$BENCH_MODELS_DIR" ]] || die "BENCH_MODELS_DIR does not exist: $BENCH_MODELS_DIR"
[[ -f "${BENCH_MODELS_DIR}/${BENCH_MODEL_FILE}" ]] || \
    die "Model not found: ${BENCH_MODELS_DIR}/${BENCH_MODEL_FILE}"

# ── prepare results dir ───────────────────────────────────────────────────────
mkdir -p "$BENCH_RESULTS_DIR"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
RESULT_FILE="${BENCH_RESULTS_DIR}/bench_${BACKEND}_${TIMESTAMP}.${BENCH_OUTPUT_FORMAT}"

# ── optional image pull ───────────────────────────────────────────────────────
if [[ "${1:-}" == "--no-cache" ]]; then
    log "Pulling latest image: $IMAGE"
    docker pull "$IMAGE"
fi

# ── run llama-bench ───────────────────────────────────────────────────────────
log "Backend  : Vulkan"
log "Image    : $IMAGE"
log "Device   : ${BENCH_VULKAN_DEVICE}  (AMD_VULKAN_ICD=${AMD_VULKAN_ICD})"
log "Model    : ${BENCH_MODEL_FILE}"
log "PP tokens: ${BENCH_PP_TOKENS}"
log "TG tokens: ${BENCH_TG_TOKENS}"
log "KV cache : K=${BENCH_KV_TYPE_K}  V=${BENCH_KV_TYPE_V}"
log "Reps     : ${BENCH_REPETITIONS}"
log "Output   : ${RESULT_FILE}"
log "──────────────────────────────────────────────────────"

docker run --rm \
    --device /dev/dri \
    -e AMD_VULKAN_ICD="${AMD_VULKAN_ICD}" \
    -v "${BENCH_MODELS_DIR}:/models:ro" \
    -v "${BENCH_CACHE_DIR}:/root/.cache" \
    "$IMAGE" \
    --bench \
        -m "/models/${BENCH_MODEL_FILE}" \
        --device "${BENCH_VULKAN_DEVICE}" \
        -ngl "${BENCH_GPU_LAYERS}" \
        -t "${BENCH_CPU_THREADS}" \
        -b "${BENCH_BATCH_SIZE}" \
        -ub "${BENCH_UBATCH_SIZE}" \
        -ctk "${BENCH_KV_TYPE_K}" \
        -ctv "${BENCH_KV_TYPE_V}" \
        -fa 1 \
        -p "${BENCH_PP_TOKENS}" \
        -n "${BENCH_TG_TOKENS}" \
        -r "${BENCH_REPETITIONS}" \
        -o "${BENCH_OUTPUT_FORMAT}" \
    | tee "$RESULT_FILE"

log "──────────────────────────────────────────────────────"
log "Results saved → ${RESULT_FILE}"

