#!/bin/bash

# Set variables
IMAGE_NAME="ai-video-editor"
DIRECTORY_TO_MOUNT="AIVideoGenerator"
CONTAINER_WORKDIR="/workspace"

win2lin () { f="${1/C://c}"; printf '%s\n' "${f//\\//}"; }

# Check if the script is running on a Windows system
IS_WINDOWS=false
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
    IS_WINDOWS=true
fi

# Check if the image exists
if ! docker images | grep -q "$IMAGE_NAME"; then
    echo "Image $IMAGE_NAME not found. Building the image..."
    docker build -t $IMAGE_NAME .
else
    echo "Image $IMAGE_NAME already exists."
fi

# Ensure the directory to mount exists
if [ ! -d "$DIRECTORY_TO_MOUNT" ]; then
    echo "Error: Directory $DIRECTORY_TO_MOUNT does not exist."
    exit 1
fi

# Convert path for Windows if necessary
HOST_PATH="$(pwd)"
if $IS_WINDOWS; then
    # Convert Windows path to Unix-style
    HOST_PATH="$(win2lin "$(pwd)")"
fi

# Determine the Docker run command
echo $HOST_PATH
DOCKER_CMD="docker run -it -v /$HOST_PATH/$DIRECTORY_TO_MOUNT:$CONTAINER_WORKDIR/$DIRECTORY_TO_MOUNT $IMAGE_NAME"

# Prepend with winpty if on Windows
if $IS_WINDOWS; then
    DOCKER_CMD="winpty $DOCKER_CMD"
fi

# Run the container
echo "Running $IMAGE_NAME interactively with $DIRECTORY_TO_MOUNT mounted..."
eval $DOCKER_CMD