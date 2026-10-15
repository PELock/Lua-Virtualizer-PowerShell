@echo off
REM Prefer 64-bit Windows PowerShell. The x86 host ships inbox PowerShellGet 1.0
REM which cannot create a TLS 1.2 channel to the PowerShell Gallery.

set "PS64=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
if exist "%PS64%" (
    "%PS64%" -NoProfile -ExecutionPolicy Bypass -File "%~dp0#1. Publish_to_gallery.ps1"
) else (
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0#1. Publish_to_gallery.ps1"
)
pause
cls
