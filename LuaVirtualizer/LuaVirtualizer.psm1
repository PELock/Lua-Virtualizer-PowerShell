################################################################################
#
# Lua Virtualizer is a source code obfuscator for the Python programming
# language. Obfuscate and protect your Lua source code and algorithms
# against analysis, reverse engineering and technology theft.
#
# Lua Virtualizer provides advanced Lua source code parsing based on
# AST trees, multiple advanced obfuscation, virtualization and protection
# strategies are available.
#
# Version      : PowerShell SDK v1.0.0
# PowerShell   : Windows PowerShell 5.1 / PowerShell 7+
# Author       : Bartosz Wójcik (support@pelock.com)
# Project      : https://www.pelock.com/products/lua-virtualizer
# Homepage     : https://www.pelock.com
#
################################################################################

Set-StrictMode -Version Latest

if ($PSVersionTable.PSVersion.Major -lt 6) {
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
}

Add-Type -AssemblyName System.IO.Compression | Out-Null

$script:PoApiUrl = 'https://www.pelock.com/api/lua-virtualizer/v1'
$script:PoUserAgent = 'PELock Lua Virtualizer'
$script:PoTimeoutSec = 3600

enum CodeVirtualization {
    vm
    fsa
    flat
}

enum RenameStyle {
    il
    o0
    hex
    mangled
}

function Get-PoApiValue {
    param($Value)

    if ($null -eq $Value) {
        return $null
    }

    if ($Value -is [Enum]) {
        return $Value.ToString()
    }

    return [string]$Value
}

function Get-PoAdler32 {
    param([Parameter(Mandatory)] [byte[]]$Data)

    $modAdler = 65521
    $a = 1
    $b = 0

    foreach ($byte in $Data) {
        $a = ($a + $byte) % $modAdler
        $b = ($b + $a) % $modAdler
    }

    return [uint32](($b -shl 16) -bor $a)
}

function Compress-PoZlib {
    param([Parameter(Mandatory)] [string]$Source)

    $bytes = [System.Text.Encoding]::UTF8.GetBytes($Source)
    $ms = New-Object System.IO.MemoryStream
    try {
        $deflate = New-Object System.IO.Compression.DeflateStream($ms, [System.IO.Compression.CompressionMode]::Compress, $true)
        try {
            $deflate.Write($bytes, 0, $bytes.Length)
        }
        finally {
            $deflate.Dispose()
        }

        $deflated = $ms.ToArray()
    }
    finally {
        $ms.Dispose()
    }

    $adler = Get-PoAdler32 -Data $bytes
    $output = New-Object byte[] ($deflated.Length + 6)
    $output[0] = 0x78
    $output[1] = 0xDA
    [Buffer]::BlockCopy($deflated, 0, $output, 2, $deflated.Length)
    $output[$output.Length - 4] = [byte](($adler -shr 24) -band 0xFF)
    $output[$output.Length - 3] = [byte](($adler -shr 16) -band 0xFF)
    $output[$output.Length - 2] = [byte](($adler -shr 8) -band 0xFF)
    $output[$output.Length - 1] = [byte]($adler -band 0xFF)

    return [Convert]::ToBase64String($output)
}

function Expand-PoZlib {
    param([Parameter(Mandatory)] [string]$CompressedBase64)

    $data = [Convert]::FromBase64String($CompressedBase64)
    if ($data.Length -lt 6) {
        throw 'Invalid zlib payload.'
    }

    $payloadLength = $data.Length - 6
    $ms = New-Object System.IO.MemoryStream($data, 2, $payloadLength)
    try {
        $deflate = New-Object System.IO.Compression.DeflateStream($ms, [System.IO.Compression.CompressionMode]::Decompress)
        try {
            $reader = New-Object System.IO.StreamReader($deflate, [System.Text.Encoding]::UTF8)
            try {
                return $reader.ReadToEnd()
            }
            finally {
                $reader.Dispose()
            }
        }
        finally {
            $deflate.Dispose()
        }
    }
    finally {
        $ms.Dispose()
    }
}

function ConvertTo-PoFormBody {
    param([Parameter(Mandatory)] [hashtable]$Fields)

    $parts = foreach ($key in $Fields.Keys) {
        $name = [uri]::EscapeDataString([string]$key)
        $value = [uri]::EscapeDataString([string]$Fields[$key])
        '{0}={1}' -f $name, $value
    }

    return ($parts -join '&')
}

function Invoke-PoApiRequest {
    param([Parameter(Mandatory)] [hashtable]$Fields)

    $body = ConvertTo-PoFormBody -Fields $Fields
    $headers = @{ 'User-Agent' = $script:PoUserAgent }

    try {
        return Invoke-RestMethod -Uri $script:PoApiUrl -Method Post -Body $body `
            -ContentType 'application/x-www-form-urlencoded' -Headers $headers `
            -TimeoutSec $script:PoTimeoutSec
    }
    catch {
        return $false
    }
}

class LuaVirtualizer {
    static [string] $API_URL = 'https://www.pelock.com/api/lua-virtualizer/v1'

    hidden [string] $_api_key = ''

    [bool] $enable_compression = $false
    [object] $seed = $null
    [object] $randomization_density = $null
    [object] $rename_style = $null
    # Lua dialect. auto or empty omits the POST field. Explicit: 5.1, 5.2, 5.3, 5.4, 5.5, luajit, luau.
    [string] $target = 'auto'
    [object] $code_virtualization = [CodeVirtualization]::vm

    [bool] $self_defending = $false
    [bool] $protection_linker = $false
    [bool] $rename_variables = $true
    [bool] $rename_parameters = $true
    [bool] $rename_functions = $true
    [bool] $rename_function_calls = $true
    [bool] $shuffle_functions = $true
    [bool] $resolve_constants = $true
    [bool] $split_strings = $true
    [bool] $modify_strings = $true
    [bool] $encrypt_strings = $true
    [bool] $string_char_array_vault = $true
    [bool] $encrypt_integers = $true
    [bool] $encrypt_floating = $true
    [bool] $mba_binops = $true
    [bool] $integers_to_floating = $true
    [bool] $integers_to_arrays = $true
    [bool] $floats_to_arrays = $true
    [bool] $affine_integer_mask = $true
    [bool] $array_int_crypt = $true
    [bool] $array_char_crypt = $true
    [bool] $array_double_crypt = $true
    [bool] $array_string_crypt = $true
    [bool] $insert_random_value_bucket = $true
    [bool] $random_bucket_integers = $true
    [bool] $random_bucket_arrays = $true
    [bool] $random_bucket_functions = $true
    [bool] $random_bucket_characters = $true
    [bool] $random_bucket_anti_regex = $true
    [bool] $random_bucket_autostart = $true
    [bool] $insert_ternary_operators = $true
    [bool] $complexify_booleans = $true
    [bool] $opaque_branches = $true
    [bool] $opaque_mixer_chain = $true
    [bool] $insert_dead_code = $true
    [bool] $try_finally_noise = $true
    [bool] $decoy_functions = $true
    [bool] $lambda_decoys = $true
    [bool] $literal_padding = $true
    [bool] $fake_import_markers = $true
    [bool] $dynamic_getattr_calls = $true
    [bool] $obfuscate_imports = $true
    [bool] $callback_registration_stubs = $true
    [bool] $detect_debugger = $false
    [bool] $anti_vm = $false
    [bool] $anti_sandbox = $false
    [bool] $anti_emulator = $false
    [bool] $remove_comments = $true

    static [int] $ERROR_SUCCESS = 0
    static [int] $ERROR_INPUT_SIZE = 1
    static [int] $ERROR_INPUT = 2
    static [int] $ERROR_PARSING = 3
    static [int] $ERROR_OBFUSCATION = 4
    static [int] $ERROR_OUTPUT = 5

    LuaVirtualizer() {
        $this.Initialize($null, $true)
    }

    LuaVirtualizer([string]$ApiKey) {
        $this.Initialize($ApiKey, $true)
    }

    LuaVirtualizer([string]$ApiKey, [bool]$EnableAllObfuscationOptions) {
        $this.Initialize($ApiKey, $EnableAllObfuscationOptions)
    }

    hidden [void] Initialize([string]$ApiKey, [bool]$EnableAllObfuscationOptions) {
        $this._api_key = $ApiKey
        $this.enable_compression = $false
        $this.seed = $null
        $this.randomization_density = $null
        $this.rename_style = $null
        $this.target = 'auto'
        $this.code_virtualization = if ($EnableAllObfuscationOptions) { [CodeVirtualization]::vm } else { $null }

        $this.rename_variables = $EnableAllObfuscationOptions
        $this.rename_parameters = $EnableAllObfuscationOptions
        $this.rename_functions = $EnableAllObfuscationOptions
        $this.rename_function_calls = $EnableAllObfuscationOptions
        $this.shuffle_functions = $EnableAllObfuscationOptions
        $this.resolve_constants = $EnableAllObfuscationOptions
        $this.split_strings = $EnableAllObfuscationOptions
        $this.modify_strings = $EnableAllObfuscationOptions
        $this.encrypt_strings = $EnableAllObfuscationOptions
        $this.string_char_array_vault = $EnableAllObfuscationOptions
        $this.encrypt_integers = $EnableAllObfuscationOptions
        $this.encrypt_floating = $EnableAllObfuscationOptions
        $this.mba_binops = $EnableAllObfuscationOptions
        $this.integers_to_floating = $EnableAllObfuscationOptions
        $this.integers_to_arrays = $EnableAllObfuscationOptions
        $this.floats_to_arrays = $EnableAllObfuscationOptions
        $this.affine_integer_mask = $EnableAllObfuscationOptions
        $this.array_int_crypt = $EnableAllObfuscationOptions
        $this.array_char_crypt = $EnableAllObfuscationOptions
        $this.array_double_crypt = $EnableAllObfuscationOptions
        $this.array_string_crypt = $EnableAllObfuscationOptions
        $this.insert_random_value_bucket = $EnableAllObfuscationOptions
        $this.random_bucket_integers = $EnableAllObfuscationOptions
        $this.random_bucket_arrays = $EnableAllObfuscationOptions
        $this.random_bucket_functions = $EnableAllObfuscationOptions
        $this.random_bucket_characters = $EnableAllObfuscationOptions
        $this.random_bucket_anti_regex = $EnableAllObfuscationOptions
        $this.random_bucket_autostart = $EnableAllObfuscationOptions
        $this.insert_ternary_operators = $EnableAllObfuscationOptions
        $this.complexify_booleans = $EnableAllObfuscationOptions
        $this.opaque_branches = $EnableAllObfuscationOptions
        $this.opaque_mixer_chain = $EnableAllObfuscationOptions
        $this.insert_dead_code = $EnableAllObfuscationOptions
        $this.try_finally_noise = $EnableAllObfuscationOptions
        $this.decoy_functions = $EnableAllObfuscationOptions
        $this.lambda_decoys = $EnableAllObfuscationOptions
        $this.literal_padding = $EnableAllObfuscationOptions
        $this.fake_import_markers = $EnableAllObfuscationOptions
        $this.dynamic_getattr_calls = $EnableAllObfuscationOptions
        $this.obfuscate_imports = $EnableAllObfuscationOptions
        $this.callback_registration_stubs = $EnableAllObfuscationOptions
        $this.remove_comments = $EnableAllObfuscationOptions

        $this.self_defending = $false
        $this.protection_linker = $false
        $this.detect_debugger = $false
        $this.anti_vm = $false
        $this.anti_sandbox = $false
        $this.anti_emulator = $false
    }

    [object] Login() {
        $params = @{ command = 'login' }
        return $this.PostRequest($params)
    }

    [object] ObfuscateScriptFile([string]$ScriptFilePath) {
        if (-not (Test-Path -LiteralPath $ScriptFilePath -PathType Leaf)) {
            return $false
        }

        try {
            $source = [System.IO.File]::ReadAllText((Resolve-Path -LiteralPath $ScriptFilePath).Path)
        }
        catch {
            return $false
        }

        if ([string]::IsNullOrEmpty($source)) {
            return $false
        }

        return $this.ObfuscateScriptSource($source)
    }

    [object] obfuscate_script_file([string]$script_file_path) {
        return $this.ObfuscateScriptFile($script_file_path)
    }

    [object] ObfuscateScriptSource([string]$ScriptSource) {
        $params = @{
            command = 'obfuscate'
            source  = $ScriptSource
        }

        return $this.PostRequest($params)
    }

    [object] obfuscate_script_source([string]$script_source) {
        return $this.ObfuscateScriptSource($script_source)
    }

    [object] PostRequest([hashtable]$ParamsArray) {
        if ($this._api_key) {
            $ParamsArray['key'] = $this._api_key
        }

        if ($null -ne $this.seed) {
            $ParamsArray['seed'] = [string]$this.seed
        }
        if ($null -ne $this.randomization_density) {
            $ParamsArray['randomization_density'] = [string]$this.randomization_density
        }
        if ($this.rename_style) {
            $ParamsArray['rename_style'] = Get-PoApiValue -Value $this.rename_style
        }
        if ($this.code_virtualization) {
            $ParamsArray['code_virtualization'] = Get-PoApiValue -Value $this.code_virtualization
        }
        if ($this.target -and $this.target -ne 'auto') {
            $ParamsArray['target'] = [string]$this.target
        }

        $flags = @(
            'self_defending',
            'protection_linker',
            'rename_variables',
            'rename_parameters',
            'rename_functions',
            'rename_function_calls',
            'shuffle_functions',
            'resolve_constants',
            'split_strings',
            'modify_strings',
            'encrypt_strings',
            'string_char_array_vault',
            'encrypt_integers',
            'encrypt_floating',
            'mba_binops',
            'integers_to_floating',
            'integers_to_arrays',
            'floats_to_arrays',
            'affine_integer_mask',
            'array_int_crypt',
            'array_char_crypt',
            'array_double_crypt',
            'array_string_crypt',
            'insert_random_value_bucket',
            'random_bucket_integers',
            'random_bucket_arrays',
            'random_bucket_functions',
            'random_bucket_characters',
            'random_bucket_anti_regex',
            'random_bucket_autostart',
            'insert_ternary_operators',
            'complexify_booleans',
            'opaque_branches',
            'opaque_mixer_chain',
            'insert_dead_code',
            'try_finally_noise',
            'decoy_functions',
            'lambda_decoys',
            'literal_padding',
            'fake_import_markers',
            'dynamic_getattr_calls',
            'obfuscate_imports',
            'callback_registration_stubs',
            'detect_debugger',
            'anti_vm',
            'anti_sandbox',
            'anti_emulator',
            'remove_comments'
        )

        foreach ($flag in $flags) {
            if ($this.$flag) {
                $ParamsArray[$flag] = '1'
            }
        }

        if ($ParamsArray.ContainsKey('source') -and $this.enable_compression -and $ParamsArray['source']) {
            $ParamsArray['source'] = Compress-PoZlib -Source ([string]$ParamsArray['source'])
            $ParamsArray['compression'] = '1'
        }

        $result = Invoke-PoApiRequest -Fields $ParamsArray
        if ($result -eq $false -or $null -eq $result) {
            return $false
        }

        $errorCode = 0
        $errorProperty = $result.PSObject.Properties['error']
        if ($null -ne $errorProperty) {
            $errorCode = [int]$errorProperty.Value
        }

        $outputProperty = $result.PSObject.Properties['output']
        if ($null -ne $outputProperty -and $this.enable_compression -and $errorCode -eq [LuaVirtualizer]::ERROR_SUCCESS) {
            $result.output = Expand-PoZlib -CompressedBase64 ([string]$outputProperty.Value)
        }

        return $result
    }

    [object] post_request([hashtable]$params_array) {
        return $this.PostRequest($params_array)
    }
}

function New-LuaVirtualizer {
    <#
    .SYNOPSIS
        Creates a Lua Virtualizer Web API client.

    .DESCRIPTION
        Factory for the LuaVirtualizer class. Empty or invalid keys run demo mode,
        A missing or invalid key is limited to 1000 bytes and the server applies only flat code virtualization (code_virtualization=flat), ignoring every other strategy field.

    .PARAMETER ApiKey
        Activation key from PELock.

    .PARAMETER EnableAllObfuscationOptions
        Enable or disable all of the obfuscation options. Protection strategies
        stay opt-in even when this is $true.

    .EXAMPLE
        $client = New-LuaVirtualizer -ApiKey 'ABCD-ABCD-ABCD-ABCD'
        $result = $client.ObfuscateScriptSource($source)
    #>
    [CmdletBinding()]
    [OutputType([LuaVirtualizer])]
    param(
        [string]$ApiKey,
        [bool]$EnableAllObfuscationOptions = $true
    )

    if ([string]::IsNullOrWhiteSpace($ApiKey)) {
        return [LuaVirtualizer]::new($null, $EnableAllObfuscationOptions)
    }

    return [LuaVirtualizer]::new($ApiKey, $EnableAllObfuscationOptions)
}

Export-ModuleMember -Function @('New-LuaVirtualizer')
