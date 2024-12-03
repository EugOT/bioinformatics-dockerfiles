#!/usr/bin/env bash
set -e
IMAGE_NAME="$1"
echo "Testing image: $IMAGE_NAME"
# Function to test command existence
test_command() {
    local cmd="$1"
    echo "Testing command: $cmd"
    docker run --rm "$IMAGE_NAME" which "$cmd" > /dev/null 2>&1 || {
        echo "❌ Command '$cmd' not found"
        return 1
    }
    echo "✅ Command '$cmd' found"
}
# Test Conda installation
echo "Testing Conda installation"
docker run --rm "$IMAGE_NAME" conda --version | grep -q "conda" || {
    echo "❌ Conda not installed"
    exit 1
}
echo "✅ Conda installed"
# Test reticulate package
echo "Testing reticulate package"
docker run --rm "$IMAGE_NAME" R -e "if (!requireNamespace('reticulate', quietly = TRUE)) { stop('Package reticulate not installed') }" || {
    echo "❌ R package 'reticulate' not installed"
    exit 1
}
echo "✅ R package 'reticulate' installed"
# Test environment variables
echo "Testing environment variables"
docker run --rm "$IMAGE_NAME" bash -c '[[ $RETICULATE_PYTHON == "/opt/conda/bin/python" ]]' || {
    echo "❌ RETICULATE_PYTHON environment variable not set correctly"
    exit 1
}
docker run --rm "$IMAGE_NAME" bash -c '[[ $QUARTO_R == "/opt/R/4.4.2/bin/R" ]]' || {
    echo "❌ QUARTO_R environment variable not set correctly"
    exit 1
}
echo "✅ Environment variables set correctly"
# Test Quarto installation using quarto check
echo "Testing Quarto installation"
docker run --rm "$IMAGE_NAME" quarto check | tee quarto_check_output.txt
# Validate Quarto check output for Python, R, and Conda versions
echo "Validating Quarto check output"
docker run --rm "$IMAGE_NAME" bash -c '
    quarto check | tee /tmp/quarto_check_output.txt &&
    grep -q "Python 3 installation....OK" /tmp/quarto_check_output.txt &&
    grep -q "Version: 3.12" /tmp/quarto_check_output.txt &&
    grep -q "R installation...........OK" /tmp/quarto_check_output.txt &&
    grep -q "Version: 4.4.2" /tmp/quarto_check_output.txt &&
    grep -q "Conda" /tmp/quarto_check_output.txt
' || {
    echo "❌ Quarto check validation failed"
    exit 1
}
echo "✅ Quarto installation and environment validated with quarto check"

echo "All tests passed successfully!"
