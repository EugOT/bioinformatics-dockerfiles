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

# Function to test package installation
test_package() {
    local package="$1"
    echo "Testing package: $package"
    docker run --rm "$IMAGE_NAME" dpkg -l | grep -q "$package" || {
        echo "❌ Package '$package' not installed"
        return 1
    }
    echo "✅ Package '$package' installed"
}

# Test system locale
echo "Testing locale settings"
docker run --rm "$IMAGE_NAME" locale | grep -q "LANG=en_US.UTF-8" || {
    echo "❌ Locale not properly set"
    exit 1
}
echo "✅ Locale correctly set"

# Test essential system utilities
essential_packages=(
    "apt-transport-https"
    "apt-utils"
    "build-essential"
    "bwidget"
    "bzip2"
    "ca-certificates"
    "cloc"
    "cmake"
    "curl"
    "default-jdk"
    "default-jre"
    "dnsutils"
    "duf"
    "fd-find"
    "freeglut3-dev"
    "fzf"
    "g++"
    "gcc"
    "gdal-bin"
    "gdebi-core"
    "gettext"
    "gfortran"
    "git"
    "glpk-utils"
    "gnupg"
    "gnupg2"
    "graphicsmagick"
    "graphviz"
    "gsfonts"
    "hdf5-tools"
    "imagemagick"
    "jags"
    "jq"
    "krb5-user"
    "libarchive-dev"
    "libasound2"
    "libblas3"
    "libboost-all-dev"
    "libbz2-dev"
    "libc6-dev"
    "libcairo2-dev"
    "libcurl4-gnutls-dev"
    "libeigen3-dev"
    "libffi-dev"
    "libfftw3-dev"
    "libfontconfig1-dev"
    "libfreetype6-dev"
    "libfribidi-dev"
    "libgconf-2-4"
    "libgdal-dev"
    "libgeos-dev"
    "libgit2-dev"
    "libglib2.0-dev"
    "libglpk-dev"
    "libglu1-mesa-dev"
    "libgmp3-dev"
    "libgnutls28-dev"
    "libgomp1"
    "libgraphviz-dev"
    "libgtk2.0-dev"
    "libharfbuzz-dev"
    "libhdf5-dev"
    "libimage-exiftool-perl"
    "libjpeg-dev"
    "libjpeg-turbo8"
    "libjpeg-turbo8-dev"
    "liblapack3"
    "libleptonica-dev"
    "liblzma-dev"
    "libmagick++-dev"
    "libmagickwand-dev"
    "libmpfr-dev"
    "libmysqlclient-dev"
    "libncurses-dev"
    "libncurses5-dev"
    "libnetcdf-dev"
    "libnlopt-dev"
    "libnss3"
    "libopenmpi-dev"
    "libpcre3-dev"
    "libpng-dev"
    "libpoppler-cpp-dev"
    "libpq-dev"
    "libproj-dev"
    "libprotobuf-dev"
    "libreadline-dev"
    "libsecret-1-dev"
    "libsm6"
    "libssh2-1-dev"
    "libssl-dev"
    "libtbb-dev"
    "libtesseract-dev"
    "libtiff-dev"
    "libtiff5-dev"
    "libudunits2-dev"
    "libuser"
    "libuser1-dev"
    "libwebp-dev"
    "libxcb-render0-dev"
    "libxcb-shape0-dev"
    "libxcb-xfixes0-dev"
    "libxcb1-dev"
    "libxext-dev"
    "libxext6"
    "libxft-dev"
    "libxml2-dev"
    "libxrender-dev"
    "libxrender1"
    "libxss1"
    "libxt-dev"
    "libxtst-dev"
    "libzmq3-dev"
    "locales"
    "lsb-release"
    "mesa-common-dev"
    "nfs-common"
    "nvidia-cuda-dev"
    "openmpi-bin"
    "openssh-client"
    "pandoc"
    "pandoc-citeproc"
    "pdf2svg"
    "pigz"
    "pkg-config"
    "protobuf-compiler"
    "python3-dev"
    "python3-pip"
    "rrdtool"
    "rustc"
    "saga"
    "software-properties-common"
    "subversion"
    "tcl"
    "tesseract-ocr-eng"
    "tk-dev"
    "tk-table"
    "unixodbc"
    "unixodbc-dev"
    "unzip"
    "vim"
    "wget"
    "x11vnc"
    "xauth"
    "xfonts-base"
    "xvfb"
    "zlib1g-dev"
)
for package in "${essential_packages[@]}"; do
    test_package "$package"
done

# Test Rust-based installations
rust_commands=(
    "bat"
    "broot"
    "btm"  # bottom
    "http" # httpie
    "hyperfine"
    "xh"
    "zoxide"
    "choose"
    "dust"
    "eza"
    "delta"
    "gping"
    "lsd"
    "procs"
    "rg"  # ripgrep
    "sd"
    "tldr"
)
for cmd in "${rust_commands[@]}"; do
    test_command "$cmd"
done

# Test Go-based installations
go_commands=(
    "curlie"
    "doggo"
    "lazygit"
)
for cmd in "${go_commands[@]}"; do
    test_command "$cmd"
done

# Test shell configurations
echo "Testing shell configurations"
docker run --rm "$IMAGE_NAME" bash -c 'source ~/.bashrc && type fzf && type mcfly && type zoxide' || {
    echo "❌ Shell configurations not properly set"
    exit 1
}
echo "✅ Shell configurations correctly set"

echo "✅ All tests passed for $IMAGE_NAME"
