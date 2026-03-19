$InnoSetupPath = "C:\Users\Alteralph\AppData\Local\Programs\Inno Setup 6\iscc.exe"
$OutputDir = "build\windows\x64\runner\Release"

if (-not (Test-Path $InnoSetupPath)) {
    Write-Host "Error: Inno Setup not found at $InnoSetupPath" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "Building Windows release..." -ForegroundColor Green
flutter build windows --release
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Flutter build failed" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

if (-not (Test-Path $OutputDir)) {
    Write-Host "Error: Build output directory not found at $OutputDir" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "Creating installer..." -ForegroundColor Green
& $InnoSetupPath /O"$OutputDir" windows\installer.iss
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Installer creation failed" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "Build complete!" -ForegroundColor Green
Write-Host "Installer: $OutputDir\ocd_logger_installer.exe" -ForegroundColor Yellow
Read-Host "Press Enter to exit"
