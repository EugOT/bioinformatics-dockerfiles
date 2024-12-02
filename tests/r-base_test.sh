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
# Test R installation
echo "Testing R installation"
docker run --rm "$IMAGE_NAME" R --version | grep -q "R version 4.4.2" || {
    echo "❌ R version 4.4.2 not installed"
    exit 1
}
echo "✅ R version 4.4.2 installed"
# Test R packages
r_packages=(
    "BiocManager"
    "Biobase"
    "ClassDiscovery"
    "easystats"
    "PCDimension"
    "apcluster"
    "arrow"
    "boot"
    "Cairo"
    "class"
    "cluster"
    "codetools"
    "data.table"
    "devtools"
    "doFuture"
    "DT"
    "extrafont"
    "fpc"
    "future"
    "future.apply"
    "ggstatsplot"
    "git2r"
    "gridExtra"
    "irlba"
    "IRkernel"
    "KernSmooth"
    "knitr"
    "lattice"
    "magick"
    "Matrix"
    "mclust"
    "mgcv"
    "NbClust"
    "nlme"
    "nmslibR"
    "odbc"
    "plyr"
    "processx"
    "purrrlyr"
    "pvclust"
    "rARPACK"
    "RcppAnnoy"
    "RCurl"
    "RColorBrewer"
    "remotes"
    "reticulate"
    "rmarkdown"
    "robustbase"
    "RobustRankAggreg"
    "roxygen2"
    "rpart"
    "RWeka"
    "sp"
    "svglite"
    "survival"
    "tidymodels"
    "tidyverse"
    "viridis"
    "workflowr"
    "yaml"
)
for package in "${r_packages[@]}"; do
    echo "Testing R package: $package"
    docker run --rm "$IMAGE_NAME" R -e "if (!requireNamespace('$package', quietly = TRUE)) { stop('Package $package not installed') }" || {
        echo "❌ R package '$package' not installed"
        exit 1
    }
    echo "✅ R package '$package' installed"
done
# Test symlinks for R and Rscript
echo "Testing symlinks for R and Rscript"
docker run --rm "$IMAGE_NAME" bash -c '[[ $(readlink -f /usr/local/bin/R) == "/opt/R/4.4.2/bin/R" ]]' || {
    echo "❌ Symlink for R not set correctly"
    exit 1
}
docker run --rm "$IMAGE_NAME" bash -c '[[ $(readlink -f /usr/local/bin/Rscript) == "/opt/R/4.4.2/bin/Rscript" ]]' || {
    echo "❌ Symlink for Rscript not set correctly"
    exit 1
}
echo "✅ Symlinks for R and Rscript set correctly"
# Test environment variables
echo "Testing environment variables"
docker run --rm "$IMAGE_NAME" bash -c '[[ $R_HOME == "/opt/R/4.4.2/lib/R" ]]' || {
    echo "❌ R_HOME environment variable not set correctly"
    exit 1
}
docker run --rm "$IMAGE_NAME" bash -c 'echo $PATH | grep -q "/opt/R/4.4.2/bin"' || {
    echo "❌ PATH environment variable not set correctly"
    exit 1
}
echo "✅ Environment variables set correctly"
echo "All tests passed successfully!"
