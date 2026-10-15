################################################################################
#
# Lua Virtualizer WebApi interface usage example.
#
# In this example we will obfuscate sample source with default options.
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
# source code in Lua format
#
$scriptSourceCode = @'
local function greet(name)
  print("Hello, " .. name)
end
greet("Lua")
'@

#
# by default all obfuscation options are enabled, so we can just simply call
#
$result = $myLuaVirtualizer.ObfuscateScriptSource($scriptSourceCode)

#
# it's also possible to pass a Lua script file path instead of a string with the source e.g.
#
# $result = $myLuaVirtualizer.ObfuscateScriptFile('/path/to/project/script.lua')

#
# $result holds the obfuscation results as well as other information
#
# $result.error              - error code
# $result.output             - obfuscated code
# $result.demo               - demo mode (missing or invalid key); limited to 1000 bytes; the server applies only flat code virtualization (code_virtualization=flat), ignoring every other strategy field
# $result.license_expiration - license end date (Y-m-d), empty if none
# $result.usages_total       - total obfuscations for this activation code
#
if ($result -and $null -ne $result.PSObject.Properties['error']) {

    # display obfuscated code
    if ($result.error -eq [LuaVirtualizer]::ERROR_SUCCESS) {

        Write-Host $result.output

    }
    else {
        Write-Host ("An error occurred, error code: {0}" -f $result.error)
    }

}
else {
    Write-Host 'Something unexpected happen while trying to obfuscate the code.'
}
