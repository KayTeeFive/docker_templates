#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════════════════════
#  llama.cpp — ROCm (AMD GPU) inference benchmark
#  Uses:  ghcr.io/ggml-org/llama.cpp:full-rocm  (contains llama-bench)
#
#  Usage:
#    ./bench-rocm.sh               # run benchmark (auto-creates .env on first run)
#    ./bench-rocm.sh --no-cache    # pull fresh image before running
# ══════════════════════════════════════════════════════════════════════════════
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/.env"
BACKEND="rocm"
IMAGE="ghcr.io/ggml-org/llama.cpp:full-rocm"

# ── helpers ───────────────────────────────────────────────────────────────────
log()  { echo "[bench-rocm] $*"; }
die()  { echo "[bench-rocm] ERROR: $*" >&2; exit 1; }

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
ROCM_GFX_VERSION="${ROCM_GFX_VERSION:-12.0.1}"
ROCM_VISIBLE_DEVICES="${ROCM_VISIBLE_DEVICES:-0}"
BENCH_SPLIT_MODE="${BENCH_SPLIT_MODE:-none}"
BENCH_TENSOR_SPLIT="${BENCH_TENSOR_SPLIT:-1/1}"
BENCH_MAIN_GPU="${BENCH_MAIN_GPU:-0}"

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
PULL=0; VERBOSE=0
for _arg in "$@"; do
    case "$_arg" in
        --no-cache)   PULL=1 ;;
        --verbose|-v) VERBOSE=1 ;;
    esac
done
if (( PULL )); then
    log "Pulling latest image: $IMAGE"
    docker pull "$IMAGE"
fi

# ── build split flags (-ts separator must be '/', comma triggers separate runs) ─
SPLIT_FLAGS=(-sm "${BENCH_SPLIT_MODE}")
if [[ "${BENCH_SPLIT_MODE}" != "none" ]]; then
    SPLIT_FLAGS+=(-ts "${BENCH_TENSOR_SPLIT}" -mg "${BENCH_MAIN_GPU}")
fi

# ── verbose/progress flag ─────────────────────────────────────────────────────
PROGRESS_FLAGS=()
(( VERBOSE )) && PROGRESS_FLAGS=(--progress)

# ── run llama-bench ───────────────────────────────────────────────────────────
log "Backend  : ROCm (AMD GPU)"
log "Image    : $IMAGE"
log "Model    : ${BENCH_MODEL_FILE}"
log "Visible  : ${ROCM_VISIBLE_DEVICES}  (GFX VERSION: ${ROCM_GFX_VERSION})"
log "Split    : mode=${BENCH_SPLIT_MODE}  tensor=${BENCH_TENSOR_SPLIT}  main-gpu=${BENCH_MAIN_GPU}"
log "PP tokens: ${BENCH_PP_TOKENS}"
log "TG tokens: ${BENCH_TG_TOKENS}"
log "KV cache : K=${BENCH_KV_TYPE_K}  V=${BENCH_KV_TYPE_V}"
log "Reps     : ${BENCH_REPETITIONS}"
log "Output   : ${RESULT_FILE}"
log "──────────────────────────────────────────────────────"

docker run --rm \
    --device /dev/kfd \
    --device /dev/dri \
    --group-add video \
    --group-add render \
    -e HSA_OVERRIDE_GFX_VERSION="${ROCM_GFX_VERSION}" \
    -e ROCR_VISIBLE_DEVICES="${ROCM_VISIBLE_DEVICES}" \
    -e GPU_MAX_HW_QUEUES=8 \
    -v "${BENCH_MODELS_DIR}:/models:ro" \
    -v "${BENCH_CACHE_DIR}:/root/.cache" \
    "$IMAGE" \
    --bench \
        -m "/models/${BENCH_MODEL_FILE}" \
        -ngl "${BENCH_GPU_LAYERS}" \
        "${SPLIT_FLAGS[@]}" \
        -t "${BENCH_CPU_THREADS}" \
        --batch-size "${BENCH_BATCH_SIZE}" \
        -ub "${BENCH_UBATCH_SIZE}" \
        -ctk "${BENCH_KV_TYPE_K}" \
        -ctv "${BENCH_KV_TYPE_V}" \
        -fa on \
        "${PROGRESS_FLAGS[@]}" \
        -p "${BENCH_PP_TOKENS}" \
        -n "${BENCH_TG_TOKENS}" \
        -r "${BENCH_REPETITIONS}" \
        -o "${BENCH_OUTPUT_FORMAT}" \
    | tee "$RESULT_FILE"

log "──────────────────────────────────────────────────────"
log "Results saved → ${RESULT_FILE}"
