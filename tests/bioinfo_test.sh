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

# Test bioinformatics tools
bioinfo_tools=(
    "pyscenic"
    "STAR"
    "seqtk"
    "samtools"
    "bbmap/stats.sh"
    "rsem-calculate-expression"
)
for tool in "${bioinfo_tools[@]}"; do
    test_command "$tool"
done

# Test R packages
r_packages=(
    "SoupX"
    "anndata"
    "annotation"
    "AnnotationHub"
    "AUCell"
    "bacon"
    "batchelor"
    "Biostrings"
    "BSgenome.Hsapiens.NCBI.GRCh38"
    "BSgenome.Hsapiens.UCSC.hg19.masked"
    "BSgenome.Hsapiens.UCSC.hg19"
    "BSgenome.Hsapiens.UCSC.hg38.masked"
    "BSgenome.Hsapiens.UCSC.hg38"
    "BSgenome.Mmusculus.UCSC.mm10.masked"
    "BSgenome.Mmusculus.UCSC.mm10"
    "BSgenome.Rnorvegicus.UCSC.rn5"
    "BSgenome"
    "CARNIVAL"
    "celldex"
    "CellNOptR"
    "chromVAR"
    "CNORdt"
    "CNORfeeder"
    "CNORfuzzy"
    "CNORode"
    "CoGAPS"
    "cosmosR"
    "decoupleR"
    "DESeq2"
    "DropletUtils"
    "edgeR"
    "eisaR"
    "EnhancedVolcano"
    "enrichplot"
    "EnsDb.Hsapiens.v86"
    "EnsDb.Mmusculus.v79"
    "fishpond"
    "generegulation"
    "GENIE3"
    "GenomicAlignments"
    "GenomicFeatures"
    "GenomicRanges"
    "glmGamPoi"
    "harmony"
    "Homo.sapiens"
    "infercnv"
    "IRanges"
    "iSEE"
    "iSEEu"
    "JASPAR2020"
    "kebabs"
    "liftOver"
    "limma"
    "maftools"
    "MAST"
    "mistyR"
    "MitoHEAR"
    "MOFA2"
    "MotifDb"
    "motifmatchr"
    "Nebulosa"
    "nempi"
    "OmnipathR"
    "Organism.dplyr"
    "pandaR"
    "podkat"
    "ReactomePA"
    "rliger"
    "rnaseqGene"
    "Rsubread"
    "rtracklayer"
    "scAlign"
    "scater"
    "scBubbletree"
    "schex"
    "scone"
    "SCpubr"
    "scran"
    "scry"
    "Seurat"
    "SingleR"
    "slalom"
    "slingshot"
    "SomaticSignatures"
    "SparseSignatures"
    "SpatialFeatureExperiment"
    "STRINGdb"
    "sva"
    "TFBSTools"
    "TxDb.Hsapiens.UCSC.hg19.knownGene"
    "TxDb.Hsapiens.UCSC.hg38.knownGene"
    "TxDb.Mmusculus.UCSC.mm10.knownGene"
    "tximport"
    "veloviz"
    "workflowr"
)
for package in "${r_packages[@]}"; do
    echo "Testing R package: $package"
    docker run --rm "$IMAGE_NAME" R -e "if (!requireNamespace('$package', quietly = TRUE)) { stop('Package $package not installed') }" || {
        echo "❌ R package '$package' not installed"
        exit 1
    }
    echo "✅ R package '$package' installed"
done

# Test Conda installation
echo "Testing Conda installation"
docker run --rm "$IMAGE_NAME" conda --version | grep -q "conda" || {
    echo "❌ Conda not installed"
    exit 1
}
echo "✅ Conda installed"

# Test Python packages installed via pip
pip_packages=(
    "Cell-BLAST"
    "cello-classify"
    "ciara_python"
    "constclust"
    "gemmapy"
    "hidef"
    "liana"
    "louvain"
    "pypath-omnipath"
    "pyscenic"
    "scplot"
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
docker run --rm "$IMAGE_NAME" bash -c 'echo $PATH | grep -q "/opt/STAR-2.7.11b/source:/opt/seqtk:/opt/bbmap:/opt/RSEM-1.3.3"' || {
    echo "❌ PATH environment variable not set correctly"
    exit 1
}
echo "✅ Environment variables set correctly"

echo "All tests passed successfully!"
