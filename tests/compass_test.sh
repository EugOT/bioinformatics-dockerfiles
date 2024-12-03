#!/bin/bash
set -e

IMAGE_NAME="$1"

echo "Testing image: $IMAGE_NAME"

# Run commands to test the image
docker run --rm "$IMAGE_NAME" R --version
docker run --rm "$IMAGE_NAME" python --version

echo "All tests passed for $IMAGE_NAME"
