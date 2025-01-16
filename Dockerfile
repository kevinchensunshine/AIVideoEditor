# Use Ubuntu 22.04 as base
FROM ubuntu:22.04

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Update and install Python, gdb, and essential tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.10 \
    python3.10-venv \
    python3-pip \
    build-essential \
    cmake \
    wget \
    unzip \
    git \
    tini \
    gdb && \
    rm -rf /var/lib/apt/lists/*

# Set LibTorch version or download link as needed
ARG LIBTORCH_VERSION="2.5.1"
ARG TORCHVISION_VERSION="0.20.1"
ARG LIBTORCH_VARIANT="cpu"
ARG LIBTORCH_BASE_URL="https://download.pytorch.org/libtorch"

# If you want a different variant (e.g. cu117 for CUDA 11.7), update the link accordingly.
# For CPU-only with cxx11 ABI:
ARG LIBTORCH_PACKAGE="libtorch-cxx11-abi-shared-with-deps-${LIBTORCH_VERSION}%2B${LIBTORCH_VARIANT}.zip"

# Download and install LibTorch
RUN wget "${LIBTORCH_BASE_URL}/${LIBTORCH_VARIANT}/${LIBTORCH_PACKAGE}" --no-check-certificate -O /tmp/libtorch.zip \
    && unzip /tmp/libtorch.zip -d /usr/local \
    && rm /tmp/libtorch.zip

# Set environment variables to help find LibTorch from CMake
ENV CMAKE_PREFIX_PATH="/usr/local/libtorch"
ENV LD_LIBRARY_PATH="/usr/local/libtorch/lib:${LD_LIBRARY_PATH}"

# Default working directory
WORKDIR /workspace/AIVideoGenerator

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir torch==${LIBTORCH_VERSION} torchvision==${TORCHVISION_VERSION} torchaudio && \
    pip install --no-cache-dir -r requirements.txt

# Set tini as the entry point for signal handling
ENTRYPOINT ["tini", "--"]

# Default command
CMD ["/bin/bash"]
