# suppress warnings that we need to use
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidOverwritingBuiltInCmdlets', ""
)]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidUsingWriteHost', ""
)]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidUsingInvokeExpression', ""
)]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidUsingPositionalParameters', ""
)]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidGlobalVars', ""
)]
param()

$TORIZON_ARCH = $args[0]

if ($TORIZON_ARCH -eq "aarch64") {
    $TORIZON_ARCH = "arm64"
}

if ($TORIZON_ARCH -eq "armv7l") {
    $TORIZON_ARCH = "armhf"
}

if ($TORIZON_ARCH -eq "x86_64") {
    $TORIZON_ARCH = "amd64"
}

# get the files content
function _getFileLines ($file) {
    [string[]] $lines = Get-Content -Path $file

    return $lines
}

# replace the dev and prod sections
function _ReplaceSection ([string[]]$fileLines, [string]$section) {
    $_startIx = $null
    $_endIx = $null
    $_ix = 0
    $_newFileContent = New-Object System.Collections.Generic.List[string]

    foreach ($line in $fileLines) {
        if ($line.Contains("__${section}_start__")) {
            $_startIx = $_ix
        }

        if ($line.Contains("__${section}_end__")) {
            $_endIx = $_ix
        }

        $_ix++
    }

    $_ix = 0;
    $_stopAdd = $false

    foreach ($line in $fileLines) {
        if ($_ix -eq $_startIx) {
            $_newFileContent.Add($line)
            $_stopAdd = $true

            $_json = Get-Content -Path "torizonPackages.json" | ConvertFrom-Json
            $_devPacks = $_json.devDeps
            $_prodPacks = $_json.deps

            if ($section.Contains("dev")) {
                foreach ($pack in $_devPacks) {
                    $_newFileContent.Add("`t${pack}:${TORIZON_ARCH} \")
                }
            } elseif ($section.Contains("prod")) {
                foreach ($pack in $_prodPacks) {
                    $_newFileContent.Add("`t${pack}:${TORIZON_ARCH} \")
                }
            }
        }

        if ($_ix -eq $_endIx) {
            $_stopAdd = $false
        }

        if (-not $_stopAdd) {
            $_newFileContent.Add($line)
        }

        $_ix++
    }

    return $_newFileContent
}

Write-Host "Applying torizonPackages.json ..."

# Dockerfile.debug
# The generic project doesn't have a Dockerfile.debug, so check if it exists
# before applying it
if (Test-Path -Path "Dockerfile.debug") {
    Write-Host "Applying to Dockerfile.debug ..."
    $debugDockerfile = _getFileLines "Dockerfile.debug"

    _ReplaceSection $debugDockerfile "torizon_packages_dev" `
        | Out-File -FilePath "Dockerfile.debug"

    Write-Host -ForegroundColor DarkGreen "✅ Dockerfile.debug"
}
# Dockerfile.sdk
# is not all templates that's need the Dockerfile.sdk
if (Test-Path -Path "Dockerfile.sdk") {
    Write-Host "Applying to Dockerfile.sdk ..."
    $debugDockerfileSDK = _getFileLines "Dockerfile.sdk"
    $debugDockerfileSDK = `
        _ReplaceSection $debugDockerfileSDK "torizon_packages_prod"
    _ReplaceSection $debugDockerfileSDK "torizon_packages_dev" `
        | Out-File -FilePath "Dockerfile.sdk"
    Write-Host -ForegroundColor DarkGreen "✅ Dockerfile.sdk"
}

# Dockerfile
Write-Host "Applying to Dockerfile ..."
$Dockerfile = _getFileLines "Dockerfile"
$Dockerfile = _ReplaceSection $Dockerfile "torizon_packages_prod"
_ReplaceSection $Dockerfile "torizon_packages_dev" `
    | Out-File -FilePath "Dockerfile"
Write-Host -ForegroundColor DarkGreen "✅ Dockerfile"

Write-Host "torizonPackages.json applied"
