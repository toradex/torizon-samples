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

$ErrorActionPreference = "Stop"
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', "Internal PS variable"
)]
$PSNativeCommandUseErrorActionPreference = $true

$env:DOCKER_HOST = ""

if ($Env:GITLAB_CI -eq $true) {
    Write-Host "ℹ️ :: GITLAB_CI :: ℹ️"
    $Env:DOCKER_HOST = "tcp://docker:2375"
}

# args are needed
$compoFilePath  = $args[0]
$dockerLogin    = $args[1]
$tag            = $args[2]
$registry       = $args[3]
$imageName      = $args[4]

# can be null
$gpu            = $args[5]

$_iterative = $true

if ($null -eq $gpu) {
    $gpu = ""
} else {
    $env:GPU = $gpu
}

if ($null -eq $env:DOCKER_PSSWD) {
    throw "❌ DOCKER_PSSWD not set"
} else {
    $psswd = $env:DOCKER_PSSWD
}

if ($null -eq $env:TORIZON_ARCH) {
    throw "❌ TORIZON_ARCH not set"
} else {
    $imageArch = $env:TORIZON_ARCH
}

if ($null -eq $env:APP_ROOT) {
    throw "❌ APP_ROOT not set"
} else {
    $appRoot = $env:APP_ROOT
}

if ($env:TASKS_ITERATIVE -eq $False) {
    $_iterative = $False
}

if ([string]::IsNullOrEmpty($compoFilePath)) {
    if ($_iterative) {
        $compoFilePath = Read-Host "docker-compose.yml root file path"
    }

    if ([string]::IsNullOrEmpty($compoFilePath)) {
        throw "❌ docker-compose.yml root file path cannot be empty"
    }
}

if ([string]::IsNullOrEmpty($dockerLogin)) {
    if ($_iterative) {
        $dockerLogin = Read-Host "Image repository"
    }

    if ([string]::IsNullOrEmpty($dockerLogin)) {
        throw "❌ Docker image repository cannot be empty"
    }
}

if ([string]::IsNullOrEmpty($psswd)) {
    if ($_iterative) {
        $psswd = Read-Host -MaskInput "Docker registry password"
    }

    if ([string]::IsNullOrEmpty($psswd)) {
        throw "❌ Docker registry password cannot be empty"
    }
}

if ([string]::IsNullOrEmpty($imageName)) {
    if ($_iterative) {
        $imageName = Read-Host "Image name"
    }

    if ([string]::IsNullOrEmpty($imageName)) {
        throw "❌ Docker image name cannot be empty"
    }
}

if ([string]::IsNullOrEmpty($tag)) {
    if ($_iterative) {
        $tag = Read-Host "Image tag"
    }

    if ([string]::IsNullOrEmpty($tag)) {
        throw "❌ Docker image tag cannot be empty"
    }
}

$objSettings = Get-Content ("$compoFilePath/.vscode/settings.json") | `
    Out-String | ConvertFrom-Json
$localRegistry = $objSettings.host_ip

$env:LOCAL_REGISTRY="$($localRegistry):5002"
$env:TAG="$tag"
if ([string]::IsNullOrEmpty($registry)) {
    $env:DOCKER_LOGIN="$dockerLogin"
} else {
    $env:DOCKER_LOGIN="$registry/$dockerLogin"
}
Set-Location $compoFilePath

# rebuild and tag
Write-Host "Rebuilding $env:DOCKER_LOGIN/${imageName}:$tag ..."

docker compose build `
    --build-arg APP_ROOT=$appRoot `
    --build-arg IMAGE_ARCH=$imageArch `
    --build-arg GPU=$gpu `
    $imageName

Set-Location -

Write-Host -ForegroundColor DarkGreen "✅ Image rebuild and tagged"

# push it
Write-Host "Pushing it $env:DOCKER_LOGIN/${imageName}:$tag ..."

Write-Output "$psswd" | docker login $registry -u $dockerLogin --password-stdin
docker push $env:DOCKER_LOGIN/${imageName}:$tag

Write-Host -ForegroundColor DarkGreen "✅ Image push OK"

# check if the yaml module is installed
Write-Host "Importing powershell-yaml ..."
if (-not (Get-Module -ListAvailable -Name "powershell-yaml")) {
    Write-Host -ForegroundColor Yellow "Installing powershell-yaml ..."
    Install-Module -Name "powershell-yaml" -Confirm:$false -Force
}

Import-Module -Name "powershell-yaml"
Write-Host -ForegroundColor DarkGreen "✅ powershell-yaml loaded"

# read the yaml file
Write-Host "Reading docker-compose.yml file ..."
$composeContent = Get-Content ("$compoFilePath/docker-compose.yml") | Out-String
$composeLoad = ConvertFrom-Yaml $composeContent -AllDocuments
$composeServices = $composeLoad.Services
$removeKeys = New-Object Collections.Generic.List[String]
$prodKeys = New-Object Collections.Generic.List[String]

Write-Host -ForegroundColor DarkGreen "✅ docker-compose.yml loaded"


# get the keys that need to be removed
Write-Host "Cleaning services ..."

foreach ($key in $composeServices.Keys) {
    if ($key.toString().contains("debug")) {
        $removeKeys.Add($key)
    } else {
        $prodKeys.Add($key)
    }
}

# remove it
foreach ($key in $removeKeys) {
    $composeServices.Remove($key)
}

Write-Host -ForegroundColor DarkGreen "✅ services cleaned"

# replace all the env variables
Write-Host "Replacing variables ..."

foreach ($key in $prodKeys) {
    $composeServices[$key].Remove("build")
    $composeServices[$key].image = `
        $composeServices[$key].image.replace("`${DOCKER_LOGIN}", $env:DOCKER_LOGIN)
    $composeServices[$key].image = `
        $composeServices[$key].image.replace("`${TAG}", $tag)
    $composeServices[$key].image = `
        $composeServices[$key].image.replace("`${GPU}", $gpu)
}

Write-Host -ForegroundColor DarkGreen "✅ variables replaced"

# write the torizon.io ready docker-compose
ConvertTo-Yaml $composeLoad `
    -OutFile "$compoFilePath/docker-compose.prod.yml" -Force

Write-Host -ForegroundColor DarkGreen "✅ docker-compose.prod.yml created"
