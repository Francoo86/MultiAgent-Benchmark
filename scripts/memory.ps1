# Memory-focused profiling script
$ErrorActionPreference = "Stop"

# Activate virtual environment
$venvPath = "..\..\SPADE-Timetabling\venv\Scripts\Activate.ps1"
if (Test-Path $venvPath) {
    & $venvPath
} else {
    Write-Error "Virtual environment not found at $venvPath"
    exit 1
}

# Create output directory if it doesn't exist
$outputDir = "profiling_results"
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir
}

# Run Scalene with memory-focused configuration
try {
    Write-Host "Starting memory profiling..."
    python -m scalene `
        --html `
        --reduced-profile `
        --malloc-threshold 10 `
        --cpu-percent-threshold 0 `
        --profile-interval 30 `
        --outfile "$outputDir\memory_analysis.html" `
        ..\..\SPADE-Timetabling\main.py

    Write-Host "Memory profiling completed. Results saved to $outputDir\memory_analysis.html"
} catch {
    Write-Error "Error during profiling: $_"
} finally {
    # Deactivate virtual environment
    deactivate
}