# suppress warnings that we need to use
param()

$env:DOCKER_HOST = ""

if ($Env:GITLAB_CI -eq $true) {
    Write-Host "ℹ️ :: GITLAB_CI :: ℹ️"
    $Env:DOCKER_HOST = "tcp://docker:2375"
}

$_envVarsSettings = @(
    "TORIZON_PSSWD",
    "TORIZON_LOGIN",
    "HOST_IP",
    "TORIZON_IP",
    "TORIZON_ARCH"
)

Write-Host -ForegroundColor DarkYellow `
    "`n⚠️ VALIDATING ENVIRONMENT`n"

$_missingEnvVarSettings = $false

# validate the environment variables
foreach ($var in $_envVarsSettings) {
    if ((Test-Path "Env:$var") -eq $false -or (Get-Item "Env:$var").Value -eq "") {
        # let's maintain this here to debug purposes
        # but show to users will make more confusing
        # the message must be that the default device is not set
        # Write-Host -ForegroundColor DarkRed `
        #     "❌ $var is not set"
        $_missingEnvVarSettings = $true
    }
}

if ($_missingEnvVarSettings) {
    Write-Host -ForegroundColor DarkRed `
        "❌ Missing settings.json properties, aborting`n"
    Write-Host -ForegroundColor DarkYellow `
        "⚠️  Did you forget to set default device?"
    Write-Host -ForegroundColor DarkYellow `
        "If you are facing issues even after setting default device, please remove the registered device and connect it again.`n"

    exit 69
}

# check if docker is running
docker info 2> $null | Out-Null
if (-not $?) {
    Write-Host -ForegroundColor DarkRed `
        "❌ Docker is not running!`n"
    Write-Host -ForegroundColor DarkRed `
        "⚠️  Please start Docker"
    Write-Host -ForegroundColor DarkRed `
        "⚠️  Please make sure to reload the VS Code window after starting Docker"

    exit 69
}

# check if the docker container with name registry is running
if ($null -eq (docker ps -q -f name=registry)) {
    Write-Host -ForegroundColor DarkRed `
        "❌ Docker container registry is not running!`n"
    Write-Host -ForegroundColor DarkRed `
        "⚠️  Please make sure to reload the VS Code Window if you had initialization errors"

    exit 69
}

Write-Host -ForegroundColor DarkGreen `
    "`n✅ Environment is valid!`n"
