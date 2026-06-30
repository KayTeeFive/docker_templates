#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════════════════════
#  llama.cpp — run ALL backends sequentially and produce a combined report
#
#  Usage:
#    cp env-file.template .env    # first time only
#    $EDITOR .env                 # at minimum: BENCH_MODELS_DIR, BENCH_MODEL_FILE
#    ./bench-all.sh               # benchmark ROCm → Intel → Vulkan, then compare
#    ./bench-all.sh rocm vulkan   # benchmark only specific backends
#    ./bench-all.sh --no-cache    # pull fresh images first (applies to all)
#
#  Backends: rocm  intel  vulkan
# ══════════════════════════════════════════════════════════════════════════════
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/.env"

# ── helpers ───────────────────────────────────────────────────────────────────
log()  { echo "[bench-all] $*"; }
die()  { echo "[bench-all] ERROR: $*" >&2; exit 1; }
sep()  { echo "══════════════════════════════════════════════════════════════════"; }

# ── load .env (auto-init from template if missing) ───────────────────────────
if [[ ! -f "$ENV_FILE" ]]; then
    cp -v "${SCRIPT_DIR}/env-file.template" "$ENV_FILE"
    sed -i "s|/home/dockeruser|${HOME}|g" "$ENV_FILE"
    log ".env created from template — review ${ENV_FILE}, then re-run."
fi
# shellcheck disable=SC1090
set -a; source "$ENV_FILE"; set +a

BENCH_RESULTS_DIR="${BENCH_RESULTS_DIR:-${SCRIPT_DIR}/results}"
BENCH_OUTPUT_FORMAT="${BENCH_OUTPUT_FORMAT:-md}"

mkdir -p "$BENCH_RESULTS_DIR"

# ── parse CLI args ────────────────────────────────────────────────────────────
PULL_FLAG=""
BACKENDS=()

for arg in "$@"; do
    case "$arg" in
        --no-cache) PULL_FLAG="--no-cache" ;;
        rocm|intel|vulkan) BACKENDS+=("$arg") ;;
        *) die "Unknown argument: $arg  (valid: rocm intel vulkan --no-cache)" ;;
    esac
done

# Default: run all three backends
if [[ ${#BACKENDS[@]} -eq 0 ]]; then
    BACKENDS=(rocm intel vulkan)
fi

# ── run selected backends ─────────────────────────────────────────────────────
FAILED=()
PASSED=()

for backend in "${BACKENDS[@]}"; do
    sep
    log "▶ Starting backend: ${backend^^}"
    sep
    script="${SCRIPT_DIR}/bench-${backend}.sh"
    [[ -x "$script" ]] || die "Script not found or not executable: $script"

    if bash "$script" $PULL_FLAG; then
        PASSED+=("$backend")
    else
        log "⚠  Backend '${backend}' failed — continuing with remaining backends."
        FAILED+=("$backend")
    fi
done

# ── combined summary ──────────────────────────────────────────────────────────
sep
log "All requested backends finished."
sep

TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
COMBINED_FILE="${BENCH_RESULTS_DIR}/bench_combined_${TIMESTAMP}.${BENCH_OUTPUT_FORMAT}"

log "Combining result files into: ${COMBINED_FILE}"

{
    echo "# llama-bench combined results — $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
    echo "Model: ${BENCH_MODEL_FILE:-<unknown>}"
    echo "KV cache: K=${BENCH_KV_TYPE_K:-q8_0}  V=${BENCH_KV_TYPE_V:-q8_0}"
    echo "Batch: ${BENCH_BATCH_SIZE:-2048} / ubatch: ${BENCH_UBATCH_SIZE:-512}"
    echo "Repetitions: ${BENCH_REPETITIONS:-3}"
    echo ""
} > "$COMBINED_FILE"

for backend in "${PASSED[@]}"; do
    # Find the most recent result file for this backend
    latest=$(ls -t "${BENCH_RESULTS_DIR}/bench_${backend}_"*.${BENCH_OUTPUT_FORMAT} 2>/dev/null | head -1 || true)
    if [[ -n "$latest" ]]; then
        {
            echo ""
            echo "## Backend: ${backend^^}"
            echo ""
            cat "$latest"
            echo ""
        } >> "$COMBINED_FILE"
    fi
done

echo "" >> "$COMBINED_FILE"
echo "---" >> "$COMBINED_FILE"
echo "Passed: ${PASSED[*]:-none}" >> "$COMBINED_FILE"
echo "Failed: ${FAILED[*]:-none}" >> "$COMBINED_FILE"

sep
log "Combined report → ${COMBINED_FILE}"

if [[ ${#FAILED[@]} -gt 0 ]]; then
    log "⚠  Some backends failed: ${FAILED[*]}"
    exit 1
fi

log "✓ Done."

