
param()

# include
. "$env:HOME/.apollox/scripts/utils/formatJson.ps1"
. "$env:HOME/.apollox/scripts/utils/replaceTasksInput.ps1"

$errorActionPreference = "Stop"

$projectFolder = $args[0]
$projectName = $args[1]

function _checkArg ($_arg) {
    if ([string]::IsNullOrEmpty($_arg)) {
        throw "❌ arg is not defined"
    }
}

function _checkIfFileContentIsEqual ($_file1, $_file2) {
    $file1 = Get-FileHash $_file1
    $file2 = Get-FileHash $_file2

    if ($file1.Hash -eq $file2.Hash) {
        return $true
    } else {
        return $false
    }
}

function _openMergeWindow ($_path1, $_path2) {
    if (
        -not (_checkIfFileContentIsEqual $_path1 $_path2)
    ) {
        code --wait --diff $_path1 $_path2
    }
}

# check if the args passed are not empty
_checkArg $projectFolder
_checkArg $projectName

# copy the new one and make the subs
$templateName = Get-Content $projectFolder/.conf/.template
$containerName = Get-Content $projectFolder/.conf/.container

# check first if the folder already exists
if (-not (Test-Path $projectFolder/.conf/tmp)) {
    mkdir $projectFolder/.conf/tmp
}

# get the metadata
$_metadata = Get-Content "$Env:HOME/.apollox/templates.json" | ConvertFrom-Json
$_templateMetadata = 
    $_metadata.Templates |
        Where-Object { $_.folder -eq $templateName }

# ----------------------------------------------------------- ALWAYS ACCEPT NEW
# UPDATE.JSON:
Copy-Item `
    $Env:HOME/.apollox/$templateName/.conf/update.json `
    $projectFolder/.conf/update.json

# DEPS.JSON:
Copy-Item `
    $Env:HOME/.apollox/$templateName/.conf/deps.json `
    $projectFolder/.conf/deps.json

# PROJECT UPDATER:
if (
    -not (_checkIfFileContentIsEqual `
            $Env:HOME/.apollox/scripts/projectUpdater.ps1 `
            $projectFolder/.conf/projectUpdater.ps1)
) {
    # in this case we need to update the project updater
    # and then run it again
    Copy-Item `
        $Env:HOME/.apollox/scripts/projectUpdater.ps1 `
        $projectFolder/.conf/projectUpdater.ps1

    Write-Host `
        -ForegroundColor DarkYellow `
        "⚠️  project updater updated, running it again"

    # run the project updater again
    & $projectFolder/.conf/projectUpdater.ps1 `
        $projectFolder `
        $projectName

    exit $LASTEXITCODE
}

# CHECK DEPS
Copy-Item `
    $Env:HOME/.apollox/scripts/checkDeps.ps1 `
    $projectFolder/.conf/checkDeps.ps1

# RUN CONTAINER IF NOT EXISTS
Copy-Item `
    $Env:HOME/.apollox/scripts/runContainerIfNotExists.ps1 `
    $projectFolder/.conf/runContainerIfNotExists.ps1

# SHARE WSL PORTS
Copy-Item `
    $Env:HOME/.apollox/scripts/shareWSLPorts.ps1 `
    $projectFolder/.conf/shareWSLPorts.ps1

# TORIZON PACKAGES
Copy-Item `
    $Env:HOME/.apollox/scripts/torizonPackages.ps1 `
    $projectFolder/.conf/torizonPackages.ps1

# TORIZON IO:
Copy-Item `
    $Env:HOME/.apollox/scripts/torizonIO.ps1 `
    $projectFolder/.conf/torizonIO.ps1

# CREATE DOCKER COMPOSE PRODUCTION:
Copy-Item `
    $Env:HOME/.apollox/scripts/createDockerComposeProduction.ps1 `
    $projectFolder/.conf/createDockerComposeProduction.ps1

# TCB ENV SETUP:
Copy-Item `
    $Env:HOME/.apollox/scripts/bash/tcb-env-setup.sh `
    $projectFolder/.conf/tcb-env-setup.sh

# CHECK CI ENV:
Copy-Item `
    $Env:HOME/.apollox/scripts/checkCIEnv.ps1 `
    $projectFolder/.conf/checkCIEnv.ps1

Write-Host -ForegroundColor DarkGreen "✅ always accept new"
# ----------------------------------------------------------- ALWAYS ACCEPT NEW


# now that we have an updated version we ca read it
$updateTable = Get-Content $projectFolder/.conf/update.json | ConvertFrom-Json


# ----------------------------------------------------------------------- TASKS
# TASKS.JSON:
Copy-Item $Env:HOME/.apollox/$templateName/.vscode/tasks.json `
    $projectFolder/.conf/tmp/tasks-next.json

if ($_templateMetadata.mergeCommon -ne $False) {
    Write-Host -ForegroundColor Yellow "Applying common tasks ..."
    $commonTasks = 
        Get-Content "$env:HOME/.apollox/assets/tasks/common.json" | 
            ConvertFrom-Json
    $commonInputs = 
        Get-Content "$env:HOME/.apollox/assets/tasks/inputs.json" | 
            ConvertFrom-Json
    $projTasks = 
        Get-Content "$projectFolder/.conf/tmp/tasks-next.json" | 
            ConvertFrom-Json

    $projTasks.tasks += $commonTasks.tasks
    $projTasks.inputs += $commonInputs.inputs

    ConvertTo-Json -Depth 100 -InputObject $projTasks | `
        Format-Json | `
        Out-File -FilePath "$projectFolder/.conf/tmp/tasks-next.json"
}

# we need to create a tmp folder to the update files
Set-Location $projectFolder/.conf/tmp
Copy-Item $Env:HOME/.apollox/$templateName/Dockerfile .
Copy-Item $Env:HOME/.apollox/$templateName/Dockerfile.debug .
Copy-Item $Env:HOME/.apollox/$templateName/docker-compose.yml .
Copy-Item $Env:HOME/.apollox/$templateName/.gitignore .
Copy-Item $Env:HOME/.apollox/assets/github/workflows/build-application.yaml .
Copy-Item $Env:HOME/.apollox/assets/gitlab/.gitlab-ci.yml .

# read the update table:
for ($i = 0; $i -lt $updateTable.Count; $i++) {
    $_source = $updateTable[$i].source
    Copy-Item "$Env:HOME/.apollox/$templateName/$_source" .
}

# change the contents
Write-Host -ForegroundColor Yellow "Renaming file contents ..."
Get-ChildItem -Force -File -Recurse * | ForEach-Object {
    Write-Host $_
    $a = $_.fullname;

    # do not mess up with binary files
    $mimeType = file --mime-encoding $a

    if (-not $mimeType.Contains("binary")) {
        # id_rsa is a special case, is ascii but we do not have permissions
        if (-not $a.Contains("id_rsa")) {
            if ($_ -isnot [System.IO.DirectoryInfo]) {
                ( Get-Content $a ) |
                ForEach-Object {
                    $_ -replace "gpioC",$projectName
                } | Set-Content $a

                ( Get-Content $a ) |
                ForEach-Object {
                    $_ -replace "gpioc",$containerName
                } | Set-Content $a

                ( Get-Content $a ) |
                ForEach-Object {
                    $_ -replace "/home/andreriesco",$env:HOME
                } | Set-Content $a
                
                ( Get-Content $a ) |
                ForEach-Object {
                    $_ -replace "cppConsole", $templateName
                } | Set-Content $a
            }
        } elseif (-not $a.Contains("id_rsa.pub")) {
            chmod 0400 $a
        }
    }
}

# we need to also replace the inputs
Replace-Tasks-Input

# and back to the project folder
Set-Location -

# open the merge window
_openMergeWindow `
    $projectFolder/.conf/tmp/tasks-next.json `
    $projectFolder/.vscode/tasks.json

Write-Host -ForegroundColor DarkGreen "✅ tasks.json"
# ----------------------------------------------------------------------- TASKS



# ---------------------------------------------------------------------- COMMON
# DOCKERFILE:
_openMergeWindow `
    $projectFolder/.conf/tmp/Dockerfile `
    $projectFolder/Dockerfile

# DOCKERFILE.DEBUG:
_openMergeWindow `
    $projectFolder/.conf/tmp/Dockerfile.debug `
    $projectFolder/Dockerfile.debug

# DOCKER-COMPOSE:
_openMergeWindow `
    $projectFolder/.conf/tmp/docker-compose.yml `
    $projectFolder/docker-compose.yml

# GITHUB ACTIONS:
_openMergeWindow `
    $projectFolder/.conf/tmp/build-application.yaml `
    $projectFolder/.github/workflows/build-application.yaml

# GITLAB CI:
_openMergeWindow `
    $projectFolder/.conf/tmp/.gitlab-ci.yml `
    $projectFolder/.gitlab-ci.yml

# GITIGNORE:
_openMergeWindow `
    $projectFolder/.conf/tmp/.gitignore `
    $projectFolder/.gitignore

Write-Host -ForegroundColor DarkGreen "✅ common"
# ---------------------------------------------------------------------- COMMON



# -------------------------------------------------------------------- SPECIFIC
for ($i = 0; $i -lt $updateTable.Count; $i++) {
    $_source = Split-Path $updateTable[$i].source -Leaf
    $_target = $updateTable[$i].target
    $_target = (Invoke-Expression "echo `"$_target`"")

    _openMergeWindow `
        $projectFolder/.conf/tmp/$_source `
        $projectFolder/$_target
}

Write-Host -ForegroundColor DarkGreen "✅ specific"
# -------------------------------------------------------------------- SPECIFIC

# clean up tmp
Remove-Item -Recurse -Force $projectFolder/.conf/tmp

Write-Host -ForegroundColor DarkGreen "✅ Update done"
