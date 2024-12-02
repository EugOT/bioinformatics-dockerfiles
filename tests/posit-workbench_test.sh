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

# Test Posit Workbench installation
echo "Testing Posit Workbench installation"
docker run --rm "$IMAGE_NAME" rstudio-server version | grep -q "2024.04.2+764.pro1" || {
    echo "❌ Posit Workbench not installed"
    exit 1
}
echo "✅ Posit Workbench installed"

# Test R packages
r_packages=(
    "colorRamps"
    "colourpicker"
    "dichromat"
    "explor"
    "ggrastr"
    "Gviz"
    "hyperdraw"
    "plot3D"
    "plotly"
    "quarto"
    "questionr"
    "randomcoloR"
    "rgl"
    "shinyAce"
    "shinyBS"
    "shinydashboard"
    "shinyjqui"
    "shinythemes"
    "sjPlot"
    "sphereplot"
    "tableHTML"
    "txtplot"
)
for package in "${r_packages[@]}"; do
    echo "Testing R package: $package"
    docker run --rm "$IMAGE_NAME" R -e "if (!requireNamespace('$package', quietly = TRUE)) { stop('Package $package not installed') }" || {
        echo "❌ R package '$package' not installed"
        exit 1
    }
    echo "✅ R package '$package' installed"
done

# Test Jupyter installation using quarto check
echo "Testing Jupyter installation"
docker run --rm "$IMAGE_NAME" quarto check | grep -q "Checking Jupyter engine render....OK" || {
    echo "❌ Jupyter not installed or not functioning"
    exit 1
}
echo "✅ Jupyter installation verified with quarto check"

# Test port exposure
echo "Testing port exposure"
docker run --rm -p 8788:8788 "$IMAGE_NAME" bash -c 'netstat -tuln | grep -q ":8788"' || {
    echo "❌ Port 8788 not exposed"
    exit 1
}
echo "✅ Port 8788 exposed"

echo "All tests passed successfully!"
