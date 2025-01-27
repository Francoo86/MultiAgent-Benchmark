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

# Get the absolute path to the SPADE-Schedule directory
$projectPath = Resolve-Path "..\SPADE-Schedule"

# Create output directory within the project directory
$outputDir = Join-Path $projectPath "profiling_results"
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir
    Write-Host "Created output directory: $outputDir"
}

# Set PYTHONPATH to include src directory
$env:PYTHONPATH = "$projectPath\src"

# Set environment variables to increase number of professors and interactions
$env:SPADE_NUM_PROFESSORS = "5"  # Increase number of professors
$env:SPADE_MIN_INTERACTIONS = "50"  # Minimum interactions per professor
$env:SPADE_TIMEOUT = "300"  # 5 minutes timeout

# Run Scalene with full system profiling configuration
try {
    Write-Host "Starting full system profiling..."
    Write-Host "Using PYTHONPATH: $env:PYTHONPATH"
    Write-Host "Output directory: $outputDir"
    
    # Change to project directory before running
    Push-Location $projectPath
    
    python -m scalene `
        --html `
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
    # Clear environment variables
    Remove-Item Env:\SPADE_NUM_PROFESSORS
    Remove-Item Env:\SPADE_MIN_INTERACTIONS
    Remove-Item Env:\SPADE_TIMEOUT
    # Deactivate virtual environment
    deactivate
}