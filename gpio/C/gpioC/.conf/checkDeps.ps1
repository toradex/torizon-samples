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

$env:DOCKER_HOST = ""

if ($Env:GITLAB_CI -eq $true) {
    Write-Host "ℹ️ :: GITLAB_CI :: ℹ️"
    $Env:DOCKER_HOST = "tcp://docker:2375"
}

# tested on Ubuntu 22.04
$_packages = Get-Content .conf/deps.json | ConvertFrom-Json

# docker and docker-compose are special cases
# TODO: check also for podman or other runtime
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host -ForegroundColor DarkRed "❌ you need docker installed"
    exit 69
}

$_dockerComposeV = (docker compose version)

if ($? -eq $false || [string]::IsNullOrEmpty($_dockerComposeV)) {
    Write-Host -ForegroundColor DarkRed "❌ you need docker compose plugin installed"
    exit 69
}

# ok docker and docker-compose exist so let's check the packages
$_packagesToInstall = New-Object Collections.Generic.List[string]

Write-Host -ForegroundColor Yellow "Checking dependencies ..."

foreach ($package in $_packages.packages) {
    dpkg -s $package > /dev/null 2>&1
    
    if ($? -eq $false) {
        $_packagesToInstall.Add($package)
        Write-Host -ForegroundColor DarkRed "😵 $package not installed"
    } else {
        Write-Host -ForegroundColor DarkGreen "👍 $package installed"
    }
}

# ask if the user want to install the packages that are not installed
if ($_packagesToInstall.Count -gt 0) {
    $_installConfirm = Read-Host `
        "Do you want to try to install the dependencies? <y/N>"

    if ($_installConfirm -eq 'y') {
        # make sure to update the list first
        sudo apt-get update

        foreach ($item in $_packagesToInstall) {
            sudo apt-get install -y $item
            
            if ($? -eq $false) {
                Write-Host -ForegroundColor DarkRed "❌ error trying to install package $item"
                exit 69
            }
        }

        Write-Host -ForegroundColor DarkGreen "✅ All packages installed successfully"

        # all packages installed then dep ok
        New-Item -Path .conf/ -Name .depok -ItemType File 2>&1 | out-null
    }
} else {
    Write-Host -ForegroundColor DarkGreen "✅ All packages already installed"

    # we need to ran the check deps only if it's not ran yet
    New-Item -Path .conf/ -Name .depok -ItemType File 2>&1 | out-null
}
