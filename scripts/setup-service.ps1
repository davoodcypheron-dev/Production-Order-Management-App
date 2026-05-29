# scripts/setup-service.ps1
# Automates the downloading and setup of the Windows Service wrapper for Nexus Prod.

$ErrorActionPreference = "Stop"

# Paths
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$RootDir = Split-Path -Parent $ScriptDir
$DistDir = Join-Path $RootDir "dist"
$ExePath = Join-Path $DistDir "nexus-prod.exe"
$ServiceExe = Join-Path $DistDir "nexus-prod-service.exe"
$ServiceXml = Join-Path $DistDir "nexus-prod-service.xml"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " Nexus Prod Windows Service Setup Script   " -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# 1. Verify build exists
if (-not (Test-Path $ExePath)) {
    Write-Host "[ERROR] Executable not found at $ExePath" -ForegroundColor Red
    Write-Host "Please build the project first by running: npm run build:exe" -ForegroundColor Yellow
    Exit 1
}

# 2. Download WinSW wrapper if not already downloaded
if (-not (Test-Path $ServiceExe)) {
    Write-Host "[INFO] Downloading Windows Service Wrapper (WinSW)..." -ForegroundColor Cyan
    $Url = "https://github.com/winsw/winsw/releases/download/v2.12.0/WinSW-x64.exe"
    try {
        Invoke-WebRequest -Uri $Url -OutFile $ServiceExe -UseBasicParsing
        Write-Host "[SUCCESS] Downloaded WinSW to $ServiceExe" -ForegroundColor Green
    } catch {
        Write-Host "[ERROR] Failed to download WinSW. Please check your internet connection." -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Yellow
        Exit 1
    }
} else {
    Write-Host "[INFO] WinSW service wrapper executable already exists." -ForegroundColor Gray
}

# 3. Create/Overwrite XML Configuration
Write-Host "[INFO] Writing XML service configuration..." -ForegroundColor Cyan
$XmlContent = @"
<service>
  <id>NexusProdService</id>
  <name>Nexus Prod Order Management Service</name>
  <description>Runs the Nexus Production Order Management backend and frontend application on port 5000.</description>
  <executable>%BASE%\nexus-prod.exe</executable>
  <log mode="roll"/>
  <onfailure action="restart" delay="10 sec"/>
</service>
"@

try {
    Set-Content -Path $ServiceXml -Value $XmlContent -Encoding UTF8
    Write-Host "[SUCCESS] Configured service XML at $ServiceXml" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Failed to write XML configuration: $_" -ForegroundColor Red
    Exit 1
}

# 4. Check for Administrator privileges
$Identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$Principal = New-Object Security.Principal.WindowsPrincipal($Identity)
$IsAdmin = $Principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

Write-Host "------------------------------------------" -ForegroundColor Gray

if (-not $IsAdmin) {
    Write-Host "[WARNING] Script is not running as Administrator!" -ForegroundColor Yellow
    Write-Host "To install or manage the Windows Service, you must open PowerShell as Administrator." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Next steps manual instructions:" -ForegroundColor Cyan
    Write-Host "1. Open PowerShell as Administrator." -ForegroundColor Gray
    Write-Host "2. Navigate to the dist directory:" -ForegroundColor Gray
    Write-Host "   cd '$DistDir'" -ForegroundColor White
    Write-Host "3. Install the service:" -ForegroundColor Gray
    Write-Host "   .\nexus-prod-service.exe install" -ForegroundColor White
    Write-Host "4. Start the service:" -ForegroundColor Gray
    Write-Host "   .\nexus-prod-service.exe start" -ForegroundColor White
    Write-Host ""
    Write-Host "You can also manage the service later using:" -ForegroundColor Gray
    Write-Host "   Uninstall: .\nexus-prod-service.exe uninstall" -ForegroundColor Gray
    Write-Host "   Stop:      .\nexus-prod-service.exe stop" -ForegroundColor Gray
    Write-Host "   Status:    .\nexus-prod-service.exe status" -ForegroundColor Gray
} else {
    Write-Host "[SUCCESS] Running with Administrator privileges." -ForegroundColor Green
    Write-Host "You are ready to install the service." -ForegroundColor Cyan
    
    $Choice = Read-Host "Do you want to install and start the service now? (y/n)"
    if ($Choice -eq 'y' -or $Choice -eq 'Y') {
        Write-Host "[INFO] Installing Windows Service..." -ForegroundColor Cyan
        Push-Location $DistDir
        try {
            # Check if service already exists
            $ExistingService = Get-Service -Name "NexusProdService" -ErrorAction SilentlyContinue
            if ($ExistingService) {
                Write-Host "[INFO] Service already exists. Reinstalling..." -ForegroundColor Yellow
                & .\nexus-prod-service.exe stop | Out-Null
                & .\nexus-prod-service.exe uninstall | Out-Null
            }
            
            & .\nexus-prod-service.exe install
            & .\nexus-prod-service.exe start
            Write-Host "[SUCCESS] Service installed and started successfully!" -ForegroundColor Green
            Write-Host "Check it at: http://localhost:5000" -ForegroundColor Green
        } catch {
            Write-Host "[ERROR] Failed to register service: $_" -ForegroundColor Red
        } finally {
            Pop-Location
        }
    } else {
        Write-Host "[INFO] Skipping automatic installation." -ForegroundColor Yellow
        Write-Host "You can install it manually by running these commands from the dist folder:" -ForegroundColor Cyan
        Write-Host "  .\nexus-prod-service.exe install" -ForegroundColor White
        Write-Host "  .\nexus-prod-service.exe start" -ForegroundColor White
    }
}
Write-Host "==========================================" -ForegroundColor Cyan
