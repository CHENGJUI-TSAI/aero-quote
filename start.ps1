$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath $PSScriptRoot
$pythonCandidates = @(
    (Join-Path $PSScriptRoot '.venv\Scripts\python.exe'),
    (Join-Path $env:USERPROFILE '.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe')
)
$pythonRunner = $pythonCandidates | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
if (-not $pythonRunner) {
    $found = Get-Command py -ErrorAction SilentlyContinue
    if (-not $found) { $found = Get-Command python -ErrorAction SilentlyContinue }
    if (-not $found) { throw 'Python 3.11+ is required. Install Python, then run this launcher again.' }
    $pythonRunner = $found.Source
}
try {
    $existing = Invoke-WebRequest -Uri 'http://127.0.0.1:8765/' -UseBasicParsing -TimeoutSec 2
    if ($existing.Content -match 'AEROSPACE INTELLIGENCE') {
        Start-Process 'http://127.0.0.1:8765/'
        exit 0
    }
} catch { }
& $pythonRunner -c 'import flask, ezdxf, fitz, matplotlib' 2>$null
if ($LASTEXITCODE -ne 0) {
    & $pythonRunner -m pip install -r requirements.txt
    if ($LASTEXITCODE -ne 0) { throw 'Dependency installation failed. Check the internet connection and retry.' }
}
Write-Host 'AeroQuote is starting at http://127.0.0.1:8765/'
Write-Host 'Keep this window open. Press Ctrl+C to stop.'
Start-Process 'http://127.0.0.1:8765/'
& $pythonRunner app.py
