# Full system profiling script
$ErrorActionPreference = "Stop"

# Activate virtual environment
$venvPath = "..\SPADE-Schedule\venv\Scripts\Activate.ps1"
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

# Get the absolute path to the SPADE-Schedule directory
$projectPath = Resolve-Path "..\SPADE-Schedule"

# Set PYTHONPATH to include src directory
$env:PYTHONPATH = "$projectPath\src"

# Run Scalene with full system profiling configuration
try {
    Write-Host "Starting full system profiling..."
    Write-Host "Using PYTHONPATH: $env:PYTHONPATH"
    
    # Change to project directory before running
    Push-Location $projectPath
    
    python -m scalene `
        --html `
        --reduced-profile `
        --profile-all `
        --profile-interval 60 `
        --cpu-sampling-rate 0.001 `
        --cpu-percent-threshold 0.5 `
        --malloc-threshold 50 `
        --outfile "$outputDir\full_system_profile.html" `
        main.py

    Write-Host "Profiling completed. Results saved to $outputDir\full_system_profile.html"
} catch {
    Write-Error "Error during profiling: $_"
} finally {
    # Restore original directory
    Pop-Location
    # Deactivate virtual environment
    deactivate
}