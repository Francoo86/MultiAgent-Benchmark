# CPU-focused profiling script
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

# Run Scalene with CPU-focused configuration
try {
    Write-Host "Starting CPU profiling..."
    python -m scalene `
        --html `
        --cpu-only `
        --reduced-profile `
        --cpu-sampling-rate 0.0001 `
        --profile-interval 30 `
        --outfile "$outputDir\cpu_analysis.html" `
        ..\..\SPADE-Timetabling\main.py

    Write-Host "CPU profiling completed. Results saved to $outputDir\cpu_analysis.html"
} catch {
    Write-Error "Error during profiling: $_"
} finally {
    # Deactivate virtual environment
    deactivate
}