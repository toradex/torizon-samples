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
param(
    [string] $ContainerRuntime,
    [string] $RunArguments,
    [string] $ContainerName
)

$env:DOCKER_HOST = ""

if ($Env:GITLAB_CI -eq $true) {
    Write-Host "ℹ️ :: GITLAB_CI :: ℹ️"
    $Env:DOCKER_HOST = "tcp://docker:2375"
}

$_containerRuntime = $ContainerRuntime
$_runArguments = $RunArguments.Trim("'").Trim('"');
$_containerName = $ContainerName

# debug
Write-Host "Container Runtime: $_containerRuntime"
Write-Host "Run Arguments: $_runArguments"
Write-Host "Container Name: $_containerName"

$_containerInfo = 
    Invoke-Expression "$_containerRuntime container inspect $_containerName" | `
    ConvertFrom-Json

if ($null -ne $_containerInfo) {
    $_containerInfo = $_containerInfo[0]
}

if ($null -ne $_containerInfo) {
    Write-Host "Container Exists"

    if ($_containerInfo.State.Running -eq $false) {
        Invoke-Expression "$_containerRuntime start $_containerName"
    } else {
        Write-Host "Container is running"
    }
} else {
    Write-Host "Container does not exist. Starting ..."
    Invoke-Expression "$_containerRuntime run --name $_containerName $_runArguments"
}
