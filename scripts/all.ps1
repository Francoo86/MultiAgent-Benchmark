# Full system profiling script
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

# Run Scalene with full system profiling configuration
try {
    Write-Host "Starting full system profiling..."
    python -m scalene `
        --html `
        --reduced-profile `
        --profile-all `
        --profile-interval 60 `
        --cpu-sampling-rate 0.001 `
        --cpu-percent-threshold 0.5 `
        --malloc-threshold 50 `
        --outfile "$outputDir\full_system_profile.html" `
        ..\..\SPADE-Timetabling\main.py

    Write-Host "Profiling completed. Results saved to $outputDir\full_system_profile.html"
} catch {
    Write-Error "Error during profiling: $_"
} finally {
    # Deactivate virtual environment
    deactivate
}