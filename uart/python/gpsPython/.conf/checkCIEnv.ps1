# suppress warnings that we need to use
param()

$_envVarsSettings = @(
    "DOCKER_REGISTRY",
    "DOCKER_LOGIN",
    "DOCKER_TAG",
    "TCB_CLIENTID",
    "TCB_CLIENTSECRET",
    "TCB_PACKAGE",
    "TCB_FLEET",
    "TORIZON_ARCH"
)

$_envVarsSecrets = @(
    # secrets
    "DOCKER_PSSWD",
    "PLATFORM_CLIENT_ID",
    "PLATFORM_CLIENT_SECRET",
    "PLATFORM_CREDENTIALS"
)

# List of environment variables that are allowed to be empty
$_envVarEmptyAllowed = @(
    "DOCKER_REGISTRY"
)

function _gotoError {
    Write-Host -ForegroundColor DarkYellow `
        "`n⚠️ THESE ENV VARIABLES NEED TO BE SET IN YOUR CI/CD ENVIRONMENT`n"
    exit 69
}

$_missingEnvVarSettings = $false
$_missingEnvVarSecrets  = $false

# check if we are running in a GitLab CI or GitHub Actions environment
if (
    ($Env:GITLAB_CI -eq $true) -or
    ($Env:CI -eq $true)
) {
    # validate the environment variables
    foreach ($var in $_envVarsSettings) {
        if (
            ((Test-Path "Env:$var") -eq $false) -and
            $_envVarEmptyAllowed.contains($var) -eq $false
        ) {
            Write-Host -ForegroundColor DarkRed `
                "❌ $var is not set"
            $_missingEnvVarSettings = $true
        }
    }

    if ($_missingEnvVarSettings) {
        Write-Host -ForegroundColor DarkRed `
            "Missing settings.json properties, aborting`n"
    }

    foreach ($var in $_envVarsSecrets) {
        if ((Test-Path "Env:$var") -eq $false) {
            Write-Host -ForegroundColor DarkRed `
                "❌ $var is not set"
            $_missingEnvVarSecrets = $true
        }
    }

    if ($_missingEnvVarSecrets) {
        Write-Host -ForegroundColor DarkRed `
            "Missing protected environment variables, aborting`n"
    }

    if (
        $_missingEnvVarSettings -or
        $_missingEnvVarSecrets
    ) {
        _gotoError
    }
}
