################################################################################
#
# Lua Virtualizer WebApi interface usage example.
#
# In this example we will obfuscate sample source with every public option
# set, so you can see the full client surface and turn flags on or off.
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
# should the source code be compressed (both input & compressed)
#
$myLuaVirtualizer.enable_compression = $false

#
# globals
#
# fixed random seed for reproducible obfuscation output (optional)
#
$myLuaVirtualizer.seed = $null

#
# randomization density / intensity (0-100)
#
$myLuaVirtualizer.randomization_density = $null

#
# identifier renaming style: [RenameStyle]::il, o0, hex, or mangled
#
$myLuaVirtualizer.rename_style = [RenameStyle]::il

#
# Lua dialect. "auto" (default) omits the POST field.
# Explicit values: 5.1, 5.2, 5.3, 5.4, 5.5, luajit, luau.
#
$myLuaVirtualizer.target = 'auto'

#
# code virtualization (exactly one): vm, fsa, or flat
# set to $null to skip virtualization
#
$myLuaVirtualizer.code_virtualization = [CodeVirtualization]::vm

#
# protection (opt-in on the service for --all; shown enabled here so every flag is visible)
#
# protection against tampering with protected code (integrity verification)
#
$myLuaVirtualizer.self_defending = $true

#
# protection linker (decoy call graph; requires self_defending)
#
$myLuaVirtualizer.protection_linker = $true

#
# insert anti-debugging detections
#
$myLuaVirtualizer.detect_debugger = $true

#
# insert virtual machine (anti-VM) detections
#
$myLuaVirtualizer.anti_vm = $true

#
# insert anti-sandbox detections
#
$myLuaVirtualizer.anti_sandbox = $true

#
# insert anti-emulators (CPU) detections
#
$myLuaVirtualizer.anti_emulator = $true

#
# renaming
#
# rename variable names to random string values
#
$myLuaVirtualizer.rename_variables = $true

#
# rename parameter names to random string values
#
$myLuaVirtualizer.rename_parameters = $true

#
# rename function names to random string values
#
$myLuaVirtualizer.rename_functions = $true

#
# rename function call references consistently with renamed functions
#
$myLuaVirtualizer.rename_function_calls = $true

#
# shuffle function order in the output source
#
$myLuaVirtualizer.shuffle_functions = $true

#
# fold/resolve constant expressions at obfuscation time
#
$myLuaVirtualizer.resolve_constants = $true

#
# strings
#
# split strings into concatenated chunks
#
$myLuaVirtualizer.split_strings = $true

#
# apply light transformations/mutations to string literals
#
$myLuaVirtualizer.modify_strings = $true

#
# encrypt strings using randomly generated polymorphic encryption algorithms
#
$myLuaVirtualizer.encrypt_strings = $true

#
# store string fragments in char-code array vaults
#
$myLuaVirtualizer.string_char_array_vault = $true

#
# numeric
#
# encrypt integers
#
$myLuaVirtualizer.encrypt_integers = $true

#
# encrypt floating point numbers
#
$myLuaVirtualizer.encrypt_floating = $true

#
# replace binary operators with mixed boolean-arithmetic (MBA) equivalents
#
$myLuaVirtualizer.mba_binops = $true

#
# represent integers via floating-point math
#
$myLuaVirtualizer.integers_to_floating = $true

#
# move integers to arrays
#
$myLuaVirtualizer.integers_to_arrays = $true

#
# move floats to arrays
#
$myLuaVirtualizer.floats_to_arrays = $true

#
# apply redundant xor / affine integer masks
#
$myLuaVirtualizer.affine_integer_mask = $true

#
# encrypted array literals
#
# encrypt integer array literals
#
$myLuaVirtualizer.array_int_crypt = $true

#
# encrypt character array literals
#
$myLuaVirtualizer.array_char_crypt = $true

#
# encrypt floating-point array literals
#
$myLuaVirtualizer.array_double_crypt = $true

#
# encrypt string array literals
#
$myLuaVirtualizer.array_string_crypt = $true

#
# decoy value pools
#
# insert a shared bucket of random noise values used by other strategies
#
$myLuaVirtualizer.insert_random_value_bucket = $true

#
# populate the random value bucket with decoy integers
#
$myLuaVirtualizer.random_bucket_integers = $true

#
# populate the random value bucket with decoy arrays
#
$myLuaVirtualizer.random_bucket_arrays = $true

#
# populate the random value bucket with decoy functions
#
$myLuaVirtualizer.random_bucket_functions = $true

#
# populate the random value bucket with decoy characters
#
$myLuaVirtualizer.random_bucket_characters = $true

#
# populate the random value bucket with anti-regex decoy noise
#
$myLuaVirtualizer.random_bucket_anti_regex = $true

#
# populate the random value bucket with autostart decoy stubs
#
$myLuaVirtualizer.random_bucket_autostart = $true

#
# opaque predicates & noise
#
# rewrite selected statements using ternary operators
#
$myLuaVirtualizer.insert_ternary_operators = $true

#
# replace boolean conditions with equivalent complex expressions
#
$myLuaVirtualizer.complexify_booleans = $true

#
# insert opaque predicate branches
#
$myLuaVirtualizer.opaque_branches = $true

#
# insert opaque mixer chains into control flow
#
$myLuaVirtualizer.opaque_mixer_chain = $true

#
# insert dead code
#
$myLuaVirtualizer.insert_dead_code = $true

#
# wrap code in try/finally blocks with dead noise
#
$myLuaVirtualizer.try_finally_noise = $true

#
# decoys
#
# insert decoy functions
#
$myLuaVirtualizer.decoy_functions = $true

#
# insert decoy lambda expressions
#
$myLuaVirtualizer.lambda_decoys = $true

#
# insert literal padding noise
#
$myLuaVirtualizer.literal_padding = $true

#
# insert fake import statement markers
#
$myLuaVirtualizer.fake_import_markers = $true

#
# use dynamic getattr()-based indirect calls
#
$myLuaVirtualizer.dynamic_getattr_calls = $true

#
# rewrite absolute imports into __import__ / getattr
#
$myLuaVirtualizer.obfuscate_imports = $true

#
# insert dead callback/event registration stubs
#
$myLuaVirtualizer.callback_registration_stubs = $true

#
# other
#
# strip comments from the output source
#
$myLuaVirtualizer.remove_comments = $true

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

#
# Per-function marker (source syntax, not a library import). The marker is the
# first statement of a function. The engine reads it and strips it.
#
# local function f()
#   LUAVIRTUALIZER(VM(FSA), OBFUSCATION(encrypt_strings, NUMBERS))
#   return 1
# end
#
# VM(VM|FSA|FLAT|NONE) selects the dispatcher; NONE stays native Lua.
# OBFUSCATION(...) is a blacklist: NONE, ALL, group names NAMES, STRINGS,
# NUMBERS, BOOLEANS, SHAPE, BUCKET, CALLS, COMMENTS, PROTECT, or a specific
# snake_case strategy flag.
