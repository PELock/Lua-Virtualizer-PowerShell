################################################################################
#
# Lua Virtualizer WebApi interface usage example.
#
# In this example we will verify our activation key status.
#
# Version        : v1.0.0
# Language       : PowerShell
# Author         : Bartosz Wójcik
# Web page       : https://www.pelock.com
#
################################################################################

#
# include Lua Virtualizer module
#
# After Install-Module / Install-PSResource:
# using module LuaVirtualizer
#
using module '..\luavirtualizer\LuaVirtualizer.psd1'

#
# create Lua Virtualizer class instance (we are using our activation key)
#
$myLuaVirtualizer = [LuaVirtualizer]::new('ABCD-ABCD-ABCD-ABCD')

#
# login to the service
#
$result = $myLuaVirtualizer.Login()

#
# $result holds the information about the license
#
# $result.demo               - demo mode (missing or invalid key); limited to 1000 bytes; the server applies only flat code virtualization (code_virtualization=flat), ignoring every other strategy field
# $result.license_expiration - license end date (Y-m-d), empty if none
# $result.usages_total       - total obfuscations for this activation code
# $result.string_limit       - max. source code size allowed (it's 1000 bytes for demo mode)
#
if ($result) {

    $demoStatus = if ($result.demo) { 'True' } else { 'False' }
    Write-Host ("Demo version status - {0}" -f $demoStatus)
    Write-Host ("License expiration - {0}" -f $result.license_expiration)
    Write-Host ("Total obfuscations - {0}" -f $result.usages_total)
    Write-Host ("Max. source code size - {0}" -f $result.string_limit)

}
else {
    Write-Host 'Something unexpected happen while trying to login to the service.'
}
