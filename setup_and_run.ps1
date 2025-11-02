# EaseMyTrip AI Planner - Quick Setup and Run Script
# This script loads environment variables from .env.local and runs the app

Write-Host "🚀 EaseMyTrip AI Planner - Quick Start" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# Check if .env.local exists
if (-not (Test-Path ".env.local")) {
    Write-Host "⚠️  .env.local file not found!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To create it:" -ForegroundColor Cyan
    Write-Host "1. Copy .env.example to .env.local: " -NoNewline
    Write-Host "Copy-Item .env.example .env.local" -ForegroundColor Green
    Write-Host "2. Edit .env.local and add your API keys" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Or run in MOCK MODE (no API keys needed):" -ForegroundColor Cyan
    Write-Host "   .\run_dev.ps1" -ForegroundColor Green
    Write-Host ""
    exit 1
}

Write-Host "📄 Loading environment variables from .env.local..." -ForegroundColor Yellow

# Load .env.local
Get-Content .env.local | ForEach-Object {
    $line = $_.Trim()
    # Skip empty lines and comments
    if ($line -and !$line.StartsWith('#')) {
        $key, $value = $line -split '=', 2
        $key = $key.Trim()
        $value = $value.Trim()
        [Environment]::SetEnvironmentVariable($key, $value, 'Process')
        Write-Host "  ✅ Loaded: $key" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "🎯 Running application with loaded environment..." -ForegroundColor Cyan
Write-Host ""

# Run the development script
& .\run_dev.ps1
