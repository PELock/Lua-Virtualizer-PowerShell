@{
    RootModule        = 'LuaVirtualizer.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = '7c4e1a92-0b56-4d3f-9a18-6e2f8c0d4b71'
    Author            = 'Bartosz Wójcik'
    CompanyName       = 'PELock'
    Copyright         = '(c) 2026 Bartosz Wójcik / PELock. All rights reserved.'
    Description       = 'PowerShell Gallery Web API client for Lua Virtualizer. Obfuscate, virtualize and protect Lua .lua source code via the PELock remote API.'
    PowerShellVersion = '5.1'
    FunctionsToExport = @(
        'New-LuaVirtualizer'
    )
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()
    PrivateData       = @{
        PSData = @{
            Tags         = @(
                'Lua',
                'Obfuscator',
                'Obfuscation',
                'Virtualizer',
                'VM',
                'PELock',
                'API',
                'Security',
                'SelfDefending'
            )
            LicenseUri   = 'https://www.apache.org/licenses/LICENSE-2.0'
            ProjectUri   = 'https://www.pelock.com/products/lua-virtualizer'
            ReleaseNotes = @'
## 1.0.0

- Initial PowerShell Gallery release
- LuaVirtualizer class — Web API client mirroring the Python SDK
- New-LuaVirtualizer — factory for the client
- Full strategy flag set including self-defending, protection linker, and anti-analysis options
'@
        }
    }
}
