# Use Ubuntu 22.04 as base
FROM ubuntu:22.04

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Update system packages and install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    wget \
    unzip \
    git \
    && rm -rf /var/lib/apt/lists/*

# Set LibTorch version or download link as needed
# For illustration, we're using version 2.0.0 for CPU (cxx11 ABI) in this example.
ARG LIBTORCH_VERSION="2.0.0"
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

# By default, Ubuntu 22.04’s gcc supports C++20 (via -std=c++20).
# You can override or confirm via a CMake configuration in your own build.

# Optionally define a working directory for your C++ project
WORKDIR /workspace

# Copy your project files here (if you like) and build
# COPY . /workspace
# RUN mkdir -p build && cd build && cmake -DCMAKE_CXX_STANDARD=20 .. && make -j$(nproc)

# Default command
CMD ["/bin/bash"]

