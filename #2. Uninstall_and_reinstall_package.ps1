# Uninstall and reinstall LuaVirtualizer from the PowerShell Gallery.

[CmdletBinding()]
param(
    [string]$Name = 'LuaVirtualizer',
    [string]$Scope = 'CurrentUser'
)

$ErrorActionPreference = 'Continue'

if (Get-Command Uninstall-PSResource -ErrorAction SilentlyContinue) {
    Uninstall-PSResource -Name $Name -ErrorAction SilentlyContinue
    Install-PSResource -Name $Name -Scope $Scope -Reinstall -ErrorAction SilentlyContinue
    if (-not (Get-PSResource -Name $Name -ErrorAction SilentlyContinue)) {
        Install-PSResource -Name $Name -Scope $Scope
    }
}
else {
    Uninstall-Module -Name $Name -AllVersions -Force -ErrorAction SilentlyContinue
    Install-Module -Name $Name -Scope $Scope -Force -AllowClobber
}

Get-Module -ListAvailable -Name $Name | Format-Table Name, Version, Path -AutoSize
