# Publish LuaVirtualizer to the PowerShell Gallery.
# Set $env:PSGALLERY_API_KEY or pass -NuGetApiKey.
#
# Windows PowerShell 5.1 defaults to TLS 1.0. PowerShell Gallery requires TLS 1.2.
# Inbox PowerShellGet 1.0.0.1 also cannot talk to the Gallery on modern TLS.

[CmdletBinding()]
param(
    [string]$NuGetApiKey = $env:PSGALLERY_API_KEY,
    [string]$Repository = 'PSGallery'
)

$ErrorActionPreference = 'Stop'

$tls12 = [Net.SecurityProtocolType]::Tls12
try {
    $tls12 = $tls12 -bor [Net.SecurityProtocolType]'Tls13'
}
catch {
}
[Net.ServicePointManager]::SecurityProtocol = $tls12
Write-Host ("TLS enabled: {0}" -f [Net.ServicePointManager]::SecurityProtocol)

$modulePath = Join-Path $PSScriptRoot 'LuaVirtualizer'
$manifestPath = Join-Path $modulePath 'LuaVirtualizer.psd1'

if (-not (Test-Path -LiteralPath $manifestPath)) {
    throw "Module manifest not found in $modulePath"
}

Test-ModuleManifest -Path $manifestPath | Out-Null

if ([string]::IsNullOrWhiteSpace($NuGetApiKey)) {
    $NuGetApiKey = Read-Host 'PowerShell Gallery API key'
}

function Get-PoPowerShellGetMajor {
    $module = Get-Module -ListAvailable -Name PowerShellGet |
        Sort-Object Version -Descending |
        Select-Object -First 1

    if ($null -eq $module) {
        return 0
    }

    return [int]$module.Version.Major
}

if (-not (Get-Command Publish-PSResource -ErrorAction SilentlyContinue)) {
    $psGetMajor = Get-PoPowerShellGetMajor
    if ($psGetMajor -lt 2) {
        Write-Host 'Inbox PowerShellGet 1.0 cannot publish over TLS 1.2. Installing Microsoft.PowerShell.PSResourceGet...'
        Install-Module -Name Microsoft.PowerShell.PSResourceGet -Scope CurrentUser -Force -AllowClobber
        Import-Module Microsoft.PowerShell.PSResourceGet -Force
    }
}

if (Get-Command Publish-PSResource -ErrorAction SilentlyContinue) {
    Publish-PSResource -Path $modulePath -ApiKey $NuGetApiKey -Repository $Repository -Verbose
}
elseif ((Get-PoPowerShellGetMajor) -ge 2) {
    Publish-Module -Path $modulePath -NuGetApiKey $NuGetApiKey -Repository $Repository -Verbose
}
else {
    throw @'
Cannot publish: only inbox PowerShellGet 1.0.0.1 is available.

Run this once in 64-bit Windows PowerShell, then retry:

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Install-Module -Name PowerShellGet -Scope CurrentUser -Force -AllowClobber
    Install-Module -Name Microsoft.PowerShell.PSResourceGet -Scope CurrentUser -Force -AllowClobber

Use "%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" (not the x86 host).
'@
}

Write-Host 'Published LuaVirtualizer to the PowerShell Gallery.'
