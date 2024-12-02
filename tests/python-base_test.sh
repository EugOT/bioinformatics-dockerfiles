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
# Test Miniforge installation
echo "Testing Miniforge installation"
docker run --rm "$IMAGE_NAME" conda --version | grep -q "conda" || {
    echo "❌ Miniforge not installed"
    exit 1
}
echo "✅ Miniforge installed"
# Test conda environment and packages
conda_packages=(
    "rapids=24.10"
    "python=3.12"
    "mamba"
    "scvi-tools"
    "snakemake"
    "pytorch"
    "torchvision"
    "torchaudio"
    "graphistry"
    "networkx"
    "nx-cugraph=24.10"
    "dvc"
    "jax"
    "jaxlib"
    "numba-scipy"
    "numba"
    "scikit-image"
    "statsmodels"
    "gensim"
    "nmslib"
    "trimap"
    "imbalanced-learn"
    "metric-learn"
    "sinfo"
    "pyarrow"
    "pynndescent"
    "fbpca"
    "fitter"
    "hdbscan"
    "umap-learn"
    "pytables"
    "h5py"
    "hdf5"
    "pybind11"
    "scikit-plot"
    "pacmap"
)
for package in "${conda_packages[@]}"; do
    echo "Testing conda package: $package"
    docker run --rm "$IMAGE_NAME" conda list | grep -q "$package" || {
        echo "❌ Conda package '$package' not installed"
        exit 1
    }
    echo "✅ Conda package '$package' installed"
done
# Test Python packages installed via pip
pip_packages=(
    "ampligraph==2.0.0"
    "category_encoders==2.6.4"
    "dabest==0.2.5"
    "denmune==1.17.1"
    "featexp==0.0.7"
    "MCML==0.0.1"
    "nancorrmp==0.23"
    "numba>=0.60.0"
    "numpy>=1.26.4"
    "pandas>=2.2.2"
    "skglm==0.3.1"
    "skope-rules==1.0.1"
    "truncated_normal==0.4"
)
for package in "${pip_packages[@]}"; do
    echo "Testing pip package: $package"
    docker run --rm "$IMAGE_NAME" pip list | grep -q "$package" || {
        echo "❌ Pip package '$package' not installed"
        exit 1
    }
    echo "✅ Pip package '$package' installed"
done
# Test environment variables
echo "Testing environment variables"
docker run --rm "$IMAGE_NAME" bash -c '[[ $CONDA_DIR == "/opt/conda" ]]' || {
    echo "❌ CONDA_DIR environment variable not set correctly"
    exit 1
}
docker run --rm "$IMAGE_NAME" bash -c 'echo $PATH | grep -q "/opt/conda/bin"' || {
    echo "❌ PATH environment variable not set correctly"
    exit 1
}
echo "✅ Environment variables set correctly"
echo "All tests passed successfully!"
