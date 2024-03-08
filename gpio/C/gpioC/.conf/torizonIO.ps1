# suppress warnings that we need to use
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidUsingWriteHost', ""
)]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseApprovedVerbs', ""
)]
param()

# FIXME: ONLY CHANGE THIS WHEN UPDATING THE https://www.powershellgallery.com/packages/TorizonPlatformAPI
$_VERSION = "0.1.0"

$ErrorActionPreference = "Stop"

# fail fast
if ($null -eq $env:PLATFORM_CLIENT_ID) {
    Write-Host -ForegroundColor Red "PLATFORM_CLIENT_ID not set"
    throw "PLATFORM_CLIENT_ID not set"
}

if ($null -eq $env:PLATFORM_CLIENT_SECRET) {
    Write-Host -ForegroundColor Red "PLATFORM_CLIENT_SECRET not set"
    throw "PLATFORM_CLIENT_SECRET not set"
}

# check if the TorizonPlatformAPI module is installed
$_mod = Get-Module -ListAvailable -Name "TorizonPlatformAPI"

if (
    -not ($_mod) -or
    ($_mod.Version[0].ToString().Contains($_VERSION) -eq $false)
) {
    Install-Module `
        -Name "TorizonPlatformAPI" `
        -RequiredVersion $_VERSION `
        -Confirm:$false `
        -Force | Out-Null
}

Import-Module -Name "TorizonPlatformAPI" -RequiredVersion $_VERSION  | Out-Null
#Write-Host -ForegroundColor DarkGreen "✅ TorizonPlatformAPI loaded"

# get the bearer token
function _getJonOsterToken () {
    $_headers = @{
        "Content-Type" = "application/x-www-form-urlencoded"
    }

    $_payload = @{
        "grant_type" = "client_credentials"
        "client_id" = "$env:PLATFORM_CLIENT_ID"
        "client_secret" = "$env:PLATFORM_CLIENT_SECRET"
    }

    $_ret = Invoke-RestMethod `
        -Method Post `
        -Uri "https://kc.torizon.io/auth/realms/ota-users/protocol/openid-connect/token" `
        -Headers $_headers `
        -Body $_payload `
        -ContentType "application/x-www-form-urlencoded" `
        -ErrorAction Stop

    # and we have the AWESOME JonOster Token 🦪
    return $_ret.access_token
}

# configure the API client
$_token = _getJonOsterToken
Set-TorizonPlatformAPIConfiguration `
    -BaseUrl "https://app.torizon.io/api/v2beta" `
    -DefaultHeaders @{ "Authorization" = "Bearer $_token" } `
    -ErrorAction Stop

function _getTargetByHash ([string] $_hash) {
    $_packages = `
        Get-TorizonPlatformAPIPackages -Limit ([System.Int64]::MaxValue)

    foreach ($_package in $_packages.values) {
        if ($_hash -eq $_package.hashes.sha256) {
            return $_package
        }
    }

    return $null
}

function _getFleetDevices ($_fleetName) {
    $_fleets = Get-TorizonPlatformAPIFleets -Limit ([System.Int64]::MaxValue)

    $_fleetId = (
        $_fleets.values |
            Where-Object { $_.name -eq "$_fleetName" }
    ).id

    if ($null -eq $_fleetId) {
        throw "Fleet '$_fleetName' not found"
    }

    $_devices =
        Get-TorizonPlatformAPIFleetsFleetidDevices `
            -Limit ([System.Int64]::MaxValue) `
            -FleetId $_fleetId

    if ($_devices.total -eq 0) {
        throw "Fleet '$_fleetName' has no devices"
    }

    return $_devices.values
}

function _getFleetId ($_fleetName) {
    $_fleets = Get-TorizonPlatformAPIFleets -Limit ([System.Int64]::MaxValue)

    $_fleetId = (
        $_fleets.values |
            Where-Object { $_.name -eq "$_fleetName" }
    ).id

    if ($null -eq $_fleetId) {
        throw "Fleet '$_fleetName' not found"
    }

    return $_fleetId
}

function _resolvePlatformMetadata ([object] $targets, [string] $targetName) {
    $_packages = $targets
    $_packageName = $targetName
    $_latestV = 0
    $_hash = $null

    $_ret = [PSCustomObject]@{
        "hash" = $null
        "version" = $null
    }

    foreach ($_package in $_packages.values) {
        if ($_package.name -eq $_packageName) {
            $_actualV = $_package.version

            if (([int]$_latestV) -lt ([int]$_actualV)) {
                $_latestV = $_actualV
                $_hash = $_package.hashes.sha256
            }
        }
    }

    $_ret.hash = $_hash
    $_ret.version = $_latestV

    return $_ret
}

function package-latest-hash ([string] $packageName) {
    $_targetName = $packageName
    $_targets = `
        Get-TorizonPlatformAPIPackages -Limit ([System.Int64]::MaxValue)
    $_hash = $null

    $_ret = _resolvePlatformMetadata $_targets $_targetName
    $_hash = $_ret.hash

    if ($null -eq $_hash) {
        Write-Host -ForegroundColor Red "package not found"
        exit 404
    }

    return $_hash
}

function package-latest-version ([string] $packageName) {
    $_packageName = $packageName
    $_packages = `
        Get-TorizonPlatformAPIPackages -Limit ([System.Int64]::MaxValue)

    $_ret = _resolvePlatformMetadata $_packages $_packageName

    # it's return 0 if not found (we can publish the version 1)
    return $_ret.version
}

function update-fleet-latest ([string] $targetName, [string] $fleetName) {
    $_targetName = $targetName
    $_fleetName = $fleetName

    $_targetHash = package-latest-hash $_targetName
    $_target = _getTargetByHash($_targetHash)

    if ($null -eq $_target) {
        throw "package $_targetName not found"
    }

    $_targetId = $_target.packageId
    $_fleetId = _getFleetId($_fleetName)

    $_updateRequest = Initialize-TorizonPlatformAPIUpdateRequest `
        -PackageIds @($_targetId) `
        -Fleets @($_fleetId)

    $Result =
        Submit-TorizonPlatformAPIUpdates `
            -UpdateRequest $_updateRequest

    return $Result
}

# check if the command exists
$_cmd = $args[0]
$_sub = $args[1]
$_third = $args[2]

try {
    # is duple
    if (Get-Command "$_cmd-$_sub" -ErrorAction SilentlyContinue) {
        $_args = '"' + ($args[3..$args.Length] -join '" "') + '"'

        (Invoke-Expression "$_cmd-$_sub $_args")
    # is triple
    } elseif (
        Get-Command "$_cmd-$_sub-$_third" -ErrorAction SilentlyContinue
    ) {
        $_args = "`"" + ($args[3..$args.Length] -join "`" `"") + "`""

        (Invoke-Expression "$_cmd-$_sub-$_third $_args")
    } else {
        Write-Host ""
        Write-Host "usage:"
        Write-Host ""
        Write-Host "    Get the latest hash pushed by package name:"
        Write-Host "        package latest hash <package name>"
        Write-Host "    Get the latest version pushed by package name:"
        Write-Host "        package latest version <package name>"
        Write-Host ""
        Write-Host "    Update a fleet with a defined package:"
        Write-Host "        update fleet latest <package name> <fleet name>"
        Write-Host ""

        exit 69
    }
} catch {
    Write-Host $_.Exception.Message -Foreground "Red"
    Write-Host ""
    $lines = $_.ScriptStackTrace.Split("`n")

    foreach ($line in $lines) {
        Write-Host "`t$line" -Foreground "DarkGray"
    }

    Write-Host ""
    exit 500
}
