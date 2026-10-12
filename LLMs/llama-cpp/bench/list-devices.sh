#!/bin/sh

case "$1" in
    rocm|-r|--rocm)
        docker run -it --rm --device /dev/dri:/dev/dri ghcr.io/ggml-org/llama.cpp:server-rocm --list-devices
        ;;
    cuda|-c|--cuda)
        docker run -it --rm --gpus all ghcr.io/ggml-org/llama.cpp:server-cuda --list-devices
        ;;
    ""|--vlk|--vulkan)
        docker run -it --rm --device /dev/dri:/dev/dri ghcr.io/ggml-org/llama.cpp:server-vulkan --list-devices
        ;;
    *)
        echo "Usage: $0 [rocm|-r|--rocm | cuda|-c|--cuda | --vlk|--vulkan]"
        echo ""
        echo "  (no args) / --vlk / --vulkan   List Vulkan devices"
        echo "  rocm / -r / --rocm             List ROCm devices"
        echo "  cuda / -c / --cuda             List CUDA (NVIDIA) devices"
        exit 1
        ;;
esac

