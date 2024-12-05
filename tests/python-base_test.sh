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
docker run --rm "$IMAGE_NAME" conda --version | rg "conda" || {
    echo "❌ Miniforge not installed"
    exit 1
}
echo "✅ Miniforge installed"
# Test conda environment and packages
conda_packages=(
    "rapids                    24.10.00"
    "python                    3.12"
    "mamba                     2.0.4"
    "scvi-tools"
    "snakemake                 8.25.5"
    "pytorch                   2.4.0           py3.12_cuda12.4_cudnn9.1.0_0"
    "graphistry"
    "networkx"
    "nx-cugraph                24.10.00"
    "dvc                       3.58.0"
    "jax                       0.4.34"
    "jaxlib                    0.4.34          cuda120py312"
    "numba-scipy               0.2.0                      py_0    numba"
    "numba                     0.60.0"
    "scikit-image              0.24.0"
    "statsmodels               0.14.4"
    "gensim                    4.3.2"
    "nmslib                    2.1.1"
    "trimap                    1.0.15"
    "imbalanced-learn          0.12.4"
    "metric-learn              0.7.0"
    "sinfo                     0.3.1"
    "pyarrow                   17.0.0"
    "pynndescent               0.5.13"
    "fbpca                     1.0"
    "fitter                    1.4.1"
    "hdbscan                   0.8.39"
    "umap-learn                0.5.7"
    "pytables                  3.10.1 "
    "h5py                      3.12.1"
    "hdf5                      1.14.3"
    "pybind11                  2.13.6"
    "scikit-plot               0.3.7"
    "pacmap                    0.7.6"
)
for package in "${conda_packages[@]}"; do
    echo "Testing conda package: $package"
    docker run --rm "$IMAGE_NAME" conda list | rg "$package" || {
        echo "❌ Conda package '$package' not installed"
        exit 1
    }
    echo "✅ Conda package '$package' installed"
done
# Test Python packages installed via pip
pip_packages=(
    "ampligraph                           2.0.0"
    "category-encoders                    2.6.4"
    "dabest                               0.2.5"
    "denmune                              1.17.1"
    "featexp"
    "MCML"
    "nancorrmp"
    "numba"
    "numpy"
    "pandas"
    "skglm"
    "skope-rules"
    "truncated_normal"
)
for package in "${pip_packages[@]}"; do
    echo "Testing pip package: $package"
    docker run --rm "$IMAGE_NAME" pip list | rg "$package" || {
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
