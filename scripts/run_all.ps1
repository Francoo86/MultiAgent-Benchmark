# Master script to run all profiling configurations
$ErrorActionPreference = "Stop"

# Function to run a script and handle errors
function Run-ProfilingScript {
    param (
        [string]$ScriptName,
        [string]$Description
    )
    
    Write-Host "`n=== Starting $Description ===" -ForegroundColor Green
    try {
        & ".\$ScriptName.ps1"
        Write-Host "$Description completed successfully" -ForegroundColor Green
    } catch {
        Write-Host "Error in $Description : $_" -ForegroundColor Red
    }
    Write-Host "=== Finished $Description ===`n" -ForegroundColor Green
}

# Create timestamp for this run
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm"
$logFile = "profiling_results\profiling_run_$timestamp.log"

# Start logging
Start-Transcript -Path $logFile

Write-Host "Starting profiling suite run at $timestamp" -ForegroundColor Cyan

# Run each profiling script
Run-ProfilingScript -ScriptName "full-profile" -Description "Full System Profile"
Start-Sleep -Seconds 5  # Brief pause between runs

Run-ProfilingScript -ScriptName "memory-profile" -Description "Memory Analysis"
Start-Sleep -Seconds 5  # Brief pause between runs

Run-ProfilingScript -ScriptName "cpu-profile" -Description "CPU Analysis"

Write-Host "`nAll profiling runs completed. Results available in profiling_results directory" -ForegroundColor Cyan
Write-Host "Log file saved to: $logFile" -ForegroundColor Cyan

Stop-Transcript