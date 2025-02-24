
param()

# include
. "$env:HOME/.apollox/scripts/utils/formatJson.ps1"
. "$env:HOME/.apollox/scripts/utils/replaceTasksInput.ps1"

$errorActionPreference = "Stop"

$projectFolder = $args[0]
$projectName = $args[1]
$acceptAll = $args[2]
$_secondRun = $args[3]

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

function _openMergeWindow ($_updatedFile, $_currentFile) {
    if ($acceptAll -eq $true) {
        # If the source doesn't exist anymore on the .apollox repo of the
        # template, remove it from the project being updated
        if (-not (Test-Path -Path $_updatedFile )) {
            Remove-Item -Path $_currentFile
        } else {
            Copy-Item $_updatedFile $_currentFile
        }
        return
    }

    # If one of the files doesn't exist create an empty one
    if (-not (Test-Path -Path $_updatedFile )) {
        New-Item -Path $_updatedFile -ItemType File
    } elseif (-not (Test-Path -Path $_currentFile )) {
        New-Item -Path $_currentFile -ItemType File
    }

    if (
        -not (_checkIfFileContentIsEqual $_updatedFile $_currentFile)
    ) {
        code --wait --diff $_updatedFile $_currentFile
        # If after the code diff the file is still empty, that means that
        # this file should not be added to the project, so let's remove this
        # empty file that we have just created above
        if ($null -eq (Get-Content $_currentFile)) {
            Remove-Item -Path $_currentFile
        }
    }
}

# this check if not needed if this is the second run
if ($_secondRun -ne $true) {
    # Don't allow the update of the project if there is no git repository initiated, to avoid losing track of the changes applied in the update
    $cmdOutput = git status 2>&1 | Out-String

    if ($cmdOutput.Contains("fatal: not a git repository")) {
        Write-Host -ForegroundColor DarkRed "❌ fatal: this workspace is not a git repository."
        Write-Host -ForegroundColor DarkYellow "It is highly recommended that you create a repo and commit the current state of the project before updating it, to keep track of the changes that will be applied on the update."
        Write-Host -ForegroundColor DarkYellow "If the project is not versioned there is no way back!"
        $_sure = Read-Host -Prompt "Do you really want to proceed? [y/n]"
        if ($_sure -ne "y") {
            exit 0
        }
    }
}

# check if the args passed are not empty
_checkArg $projectFolder
_checkArg $projectName

# the accept all is optional
if ([string]::IsNullOrEmpty($acceptAll)) {
    $acceptAll = $false
} else {
    if ($acceptAll -eq "1" -and $_secondRun -ne $true) {
        # ask for confirmation
        Write-Host -ForegroundColor DarkYellow "You are about to accept all incoming changes from the updated template"
        Write-Host -ForegroundColor DarkYellow "If the project is not versioned there is no way back!"
        $_sure = Read-Host -Prompt "Accept all changes? [y/n]"

        if ($_sure -ne "y") {
            exit 0
        }

        $acceptAll = $true
    } elseif ($_secondRun -ne $true) {
        $acceptAll = $false
    }
}

# PROJECT UPDATER - The first thing is to update it
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
        $projectName `
        $acceptAll `
        $true

    exit $LASTEXITCODE
}

# get the metadata of templates.json
$_templatesJson = Get-Content "$Env:HOME/.apollox/templates.json" | ConvertFrom-Json

# Replace the the .template and .container with metadata.json
if ((Test-Path "$projectFolder/.conf/.template") -and (Test-Path "$projectFolder/.conf/.container")) {
    $templateName = Get-Content $projectFolder/.conf/.template
    $containerName = Get-Content $projectFolder/.conf/.container

    $_metadataJson = New-Object PSObject
    $_metadataJson | Add-Member -MemberType NoteProperty -Name "templateName" -Value $templateName
    $_metadataJson | Add-Member -MemberType NoteProperty -Name "containerName" -Value $containerName
    # If this property doesn't exist, then we are on Torizon 6
    if ($null -eq $_templatesJson.TorizonOSMajor) {
        $_torizonOSMajor = "6"
    } else {
        $_torizonOSMajor = $_templatesJson.TorizonOSMajor
    }
    $_metadataJson | Add-Member -MemberType NoteProperty -Name "torizonOSMajor" -Value $_torizonOSMajor

    # Save the modified JSON object to a file
    Set-Content -Path "$projectFolder/.conf/metadata.json" -Value ($_metadataJson | ConvertTo-Json) -Encoding UTF8

    Remove-Item -Path $projectFolder/.conf/.template -Force
    Remove-Item -Path $projectFolder/.conf/.container -Force
}

# get the metadata of the project
$_metadataJson = Get-Content "$projectFolder/.conf/metadata.json" | ConvertFrom-Json
$templateName = $_metadataJson.templateName
$containerName = $_metadataJson.containerName

##
# FIXUP FOR THE ISSUE WITH BOOKWORM SET AS TorizonOSMajor=7 on v2.8.0
# !!!IF WE ARE USING PWSH MEANS THAT IS NOT 7 IS 6!!!
##
if ($_metadataJson.torizonOSMajor -eq "7") {
    $_metadataJson.torizonOSMajor = "6"
    # Save the modified JSON object to a file
    Set-Content -Path "$projectFolder/.conf/metadata.json" -Value ($_metadataJson | ConvertTo-Json) -Encoding UTF8
}
$_torizonOSMajor = $_metadataJson.torizonOSMajor


# If it's not the current version, it's because the person has torizon.templatesBranch setting set
if ($_templatesJson.TorizonOSMajor -ne "7") {
    Write-Host -ForegroundColor DarkYellow "The current Torizon OS version is 7. If you want to upgrade to the current version, remove the torizon.templatesBranch setting."
}

$_templatesJsonTorizonMajor = $_templatesJson.TorizonOSMajor

# Major update on the template
if ($_torizonOSMajor -ne $_templatesJsonTorizonMajor) {

    Write-Host -ForegroundColor DarkRed "Your template is on Torizon OS version ${_torizonOSMajor} and you are updating it to a template in Torizon OS version ${_templatesJsonTorizonMajor}"
    $_sure = Read-Host -Prompt "Are you sure you want to proceed with the update? [y/n]"

    if ($_sure -ne "y") {
        Write-Host -ForegroundColor DarkRed "If you want to stick to a specific Torizon OS version, set the torizon.templatesBranch on settings.json: https://developer.toradex.com/torizon/application-development/ide-extension/reference-documentation/workspace-settings#torizontemplatesbranch"
        exit 0
    }
}

# check first if the folder already exists
if (-not (Test-Path $projectFolder/.conf/tmp)) {
    mkdir $projectFolder/.conf/tmp
}

# get the metadata of deprecatedTemplates.json
$_deprecatedMetadata = Get-Content "$Env:HOME/.apollox/deprecatedTemplates.json" | ConvertFrom-Json
$_deprecatedTemplateMetadata =
    $_deprecatedMetadata.DeprecatedTemplates |
        Where-Object { $_.folder -eq $templateName }

# If the template is deprecated or broken, it cannot be updated. If it is incomplete the user should be made aware of the problem and choose to proceed or not.
if ($null -ne $_deprecatedTemplateMetadata) {
    Write-Host -ForegroundColor DarkRed "This template is deprecated in the most recent version of the Torizon IDE Extension. For details, check https://github.com/torizon/vscode-torizon-templates/blob/dev/DEPRECATED.md"
    exit 69
}

$_templateMetadata =
    $_templatesJson.Templates |
        Where-Object { $_.folder -eq $templateName }

if ($_templateMetadata.status -eq "notok") {
    Write-Host -ForegroundColor DarkRed "This template is broken in the most recent version of the Torizon IDE Extension. Reason:"
    Write-Host -ForegroundColor DarkRed $_templateMetadata.customMessage
    exit 69

} elseif ($_templateMetadata.status -eq "incomplete") {
    Write-Host -ForegroundColor DarkRed "This template is incomplete in the most recent version of the Torizon IDE Extension. Reason:"
    Write-Host -ForegroundColor DarkRed $_templateMetadata.customMessage
    $_sure = Read-Host -Prompt "Are you sure you want to proceed with the update? [y/n]"

    if ($_sure.ToLower() -ne "y") {
        exit 0
    }
}

# ----------------------------------------------------------- ALWAYS ACCEPT NEW
# UPDATE.JSON:
Copy-Item `
    $Env:HOME/.apollox/$templateName/.conf/update.json `
    $projectFolder/.conf/update.json


# TASKS.PS1:
Copy-Item `
    $Env:HOME/.apollox/scripts/tasks.ps1 `
    $projectFolder/.vscode/tasks.ps1

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

# VALIDATE DEPS RUNNING ENV:
Copy-Item `
    $Env:HOME/.apollox/scripts/validateDepsRunning.ps1 `
    $projectFolder/.conf/validateDepsRunning.ps1

# TORIZONPACKAGES.PS1:
Copy-Item `
    $Env:HOME/.apollox/scripts/torizonPackages.ps1 `
    $projectFolder/.conf/torizonPackages.ps1

Write-Host -ForegroundColor DarkGreen "✅ always accept new"
# ----------------------------------------------------------- ALWAYS ACCEPT NEW


# now that we have an updated version we ca read it
$updateTable = Get-Content $projectFolder/.conf/update.json | ConvertFrom-Json


# ----------------------------------------------------------------------- .VSCODE
# tcb does not have the launch.json
if ($templateName -ne "tcb") {
    Copy-Item $Env:HOME/.apollox/$templateName/.vscode/launch.json `
        $projectFolder/.conf/tmp/launch-next.json
}

Copy-Item $Env:HOME/.apollox/$templateName/.vscode/settings.json `
$projectFolder/.conf/tmp/settings-next.json

# check if the template has an extensions.json file
if (Test-Path -Path $Env:HOME/.apollox/$templateName/.vscode/extensions.json) {
    Copy-Item $Env:HOME/.apollox/$templateName/.vscode/extensions.json `
    $projectFolder/.conf/tmp/extensions-next.json
}

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
# ----------------------------------------------------------------------- .VSCODE

# we need to create a tmp folder to the update files
Set-Location $projectFolder/.conf/tmp

# tcb does not have the common Docker files
if ($templateName -ne "tcb") {
    # The generic template doesn't have a Dockerfile.debug
    if (Test-Path -Path $Env:HOME/.apollox/$templateName/Dockerfile.debug) {
        Copy-Item $Env:HOME/.apollox/$templateName/Dockerfile.debug .
    }
    # If there is a Dockerfile.sdk, also include it
    if (Test-Path -Path $Env:HOME/.apollox/$templateName/Dockerfile.sdk) {
        Copy-Item $Env:HOME/.apollox/$templateName/Dockerfile.sdk .
    }
    Copy-Item $Env:HOME/.apollox/$templateName/Dockerfile .
    Copy-Item $Env:HOME/.apollox/$templateName/docker-compose.yml .
    Copy-Item $Env:HOME/.apollox/assets/github/workflows/build-application.yaml .
    Copy-Item $Env:HOME/.apollox/assets/gitlab/.gitlab-ci.yml .
    # If there is a .dockerignore file, also include it
    if (Test-Path -Path $Env:HOME/.apollox/$templateName/.dockerignore) {
        Copy-Item $Env:HOME/.apollox/$templateName/.dockerignore .
    }

    # ----------------------------------------------------------------- TORIZONPACKAGES.JSON
    $_torPackagesJson = Get-Content -Path "$Env:HOME/.apollox/assets/json/torizonPackages.json" | ConvertFrom-Json

    # Check also the build part of Dockerfile, for the presence of torizon_packages_build
    $dockerfileLines = Get-Content -Path "$Env:HOME/.apollox/$templateName/Dockerfile"

    $buildDepDockerfile = $false
    foreach ($line in $dockerfileLines) {
        if ($line.Contains("torizon_packages_build")) {
            $buildDepDockerfile = $true
            break
        }
    }

    if ((Test-Path -Path "$Env:HOME/.apollox/$templateName/Dockerfile.sdk") -Or ($buildDepDockerfile)) {
        $_torPackagesJson | Add-Member -NotePropertyName buildDeps -NotePropertyValue @()
    }
    # Save the modified JSON object to a file
    Set-Content -Path "./torizonPackages.json" -Value ($_torPackagesJson | ConvertTo-Json) -Encoding UTF8
    # ----------------------------------------------------------------- TORIZONPACKAGES.JSON

}


Copy-Item $Env:HOME/.apollox/$templateName/.gitignore .

# DEPS.JSON:
Copy-Item $Env:HOME/.apollox/$templateName/.conf/deps.json .

# Check if there are scripts defined in the .conf/deps.json of the template and, if so,
# copy them to the .conf of the project
$_deps = Get-Content  ./deps.json | ConvertFrom-Json

# If there are installation scripts listed on the .conf/deps.json of the template
if (($_deps.installDepsScripts.Count -gt 0)) {
    # Create the installDepsScripts dir on the .conf dir and on the tmp/.conf dir
    if (-not (Test-Path -Path $projectFolder/.conf/installDepsScripts )){
        New-Item -ItemType Directory -Path $projectFolder/.conf/installDepsScripts
    }
    if (-not (Test-Path -Path ./installDepsScripts )){
        New-Item -ItemType Directory -Path ./installDepsScripts
    }
    # If there is no script in the .conf/installDepsScripts of the template, but there is some script defined in the
    # installDepsScripts with the .conf/installDepsScripts path, then it comes from the scripts/installDepsScripts
    # folder of the vscode-torizon-templates repo. This is useful when there are scripts that are common for many
    # templates, like the installDotnetSDK8.sh one for example.
    foreach ($script in $_deps.installDepsScripts) {

        if ((-not (Test-Path -Path $Env:HOME/.apollox/$templateName/$script )) -and
            $script -match  ".conf/installDepsScripts") {
            # Copy the script from the scripts/installDepsScripts folder to the .conf/installDepsScripts folder of the template
            $scriptSource = $script.Replace(".conf","scripts")
        } else {
            $scriptSource = "$templateName/$script"
        }

        $scriptDest = $script.Replace(".conf/","")
        Copy-Item $Env:HOME/.apollox/$scriptSource ./$scriptDest
    }
}

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
        # FIXME: we are not using key pair anymore, maintaining this for compatibility
        # id_rsa is a special case, is ascii but we do not have permissions
        if (-not $a.Contains("id_rsa")) {
            if ($_ -isnot [System.IO.DirectoryInfo]) {
                ( Get-Content $a ) |
                ForEach-Object {
                    $_ -replace "__change__",$projectName
                } | Set-Content $a

                ( Get-Content $a ) |
                ForEach-Object {
                    $_ -replace "__container__",$containerName
                } | Set-Content $a

                ( Get-Content $a ) |
                ForEach-Object {
                    $_ -replace "__home__",$env:HOME
                } | Set-Content $a

                ( Get-Content $a ) |
                ForEach-Object {
                    $_ -replace "__templateFolder__", $templateName
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

# ---------------------------------------------------------------------- .VSCODE
# open the merge window
_openMergeWindow `
    $projectFolder/.conf/tmp/tasks-next.json `
    $projectFolder/.vscode/tasks.json

Write-Host -ForegroundColor DarkGreen "✅ tasks.json"

# LAUNCH.JSON

# tcb does not have the launch.json
if ($templateName -ne "tcb") {
    _openMergeWindow `
        $projectFolder/.conf/tmp/launch-next.json `
        $projectFolder/.vscode/launch.json

    Write-Host -ForegroundColor DarkGreen "✅ launch.json"
}

# SETTINGS.JSON
_openMergeWindow `
    $projectFolder/.conf/tmp/settings-next.json `
    $projectFolder/.vscode/settings.json

Write-Host -ForegroundColor DarkGreen "✅ settings.json"

# EXTENSIONS.JSON
# check if the template has an extensions.json file
if (Test-Path -Path $Env:HOME/.apollox/$templateName/.vscode/extensions.json) {
    _openMergeWindow `
        $projectFolder/.conf/tmp/extensions-next.json `
        $projectFolder/.vscode/extensions.json

    Write-Host -ForegroundColor DarkGreen "✅ extensions.json"
}

# ---------------------------------------------------------------------- .VSCODE

# ---------------------------------------------------------------------- COMMON

# TCB does not have the common application Docker files
if ($templateName -ne "tcb") {
    # DOCKERFILE.DEBUG:
    # The generic template doesn't have a Dockerfile.debug
    if (Test-Path -Path $projectFolder/.conf/tmp/Dockerfile.debug) {
        _openMergeWindow `
            $projectFolder/.conf/tmp/Dockerfile.debug `
            $projectFolder/Dockerfile.debug
    }
    # DOCKERFILE.SDK:
    # If there is a Dockerfile.sdk, also include it
    if (Test-Path -Path $projectFolder/.conf/tmp/Dockerfile.sdk) {
        _openMergeWindow `
            $projectFolder/.conf/tmp/Dockerfile.sdk `
            $projectFolder/Dockerfile.sdk
    }
    # DOCKERFILE:
    _openMergeWindow `
        $projectFolder/.conf/tmp/Dockerfile `
        $projectFolder/Dockerfile
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

    # TEMPLATE SPECIFIC DOCUMENTATION:
    # check if the folder already exists, if not create it
    # and always accept the new one
    if (-not (Test-Path $projectFolder/.doc)) {
        mkdir $projectFolder/.doc
    }

    # DOCKERIGNORE:
    # If there is a .dockerignore file, also include it
    if (Test-Path -Path $projectFolder/.conf/tmp/.dockerignore) {
        _openMergeWindow `
            $projectFolder/.conf/tmp/.dockerignore `
            $projectFolder/.dockerignore
    }

    # TORIZONPACKAGES.JSON:
    _openMergeWindow `
        $projectFolder/.conf/tmp/torizonPackages.json `
        $projectFolder/torizonPackages.json

}

# DOCUMENTATION
Copy-Item `
    $Env:HOME/.apollox/$templateName/.doc `
    $projectFolder `
    -Recurse -Force

# GITIGNORE:
_openMergeWindow `
    $projectFolder/.conf/tmp/.gitignore `
    $projectFolder/.gitignore


# DEPS.JSON:
_openMergeWindow `
    $projectFolder/.conf/tmp/deps.json `
    $projectFolder/.conf/deps.json

# Install dependencies scripts
foreach ($script in $_deps.installDepsScripts) {
    $scriptSource = $script.Replace(".conf/","")
    _openMergeWindow `
        $projectFolder/.conf/tmp/$scriptSource `
        $projectFolder/$script
}

Write-Host -ForegroundColor DarkGreen "✅ common"
# ---------------------------------------------------------------------- COMMON



# -------------------------------------------------------------------- SPECIFIC
for ($i = 0; $i -lt $updateTable.Count; $i++) {
    $_source = Split-Path $updateTable[$i].source -Leaf
    $_target = $updateTable[$i].target
    $_target = (Invoke-Expression "echo `"$_target`"")

    # check if the file exists, if not simple copy it
    if (
        (Test-Path $projectFolder/$_target) -eq $True
    ) {
        _openMergeWindow `
            $projectFolder/.conf/tmp/$_source `
            $projectFolder/$_target
    } else {
        cp $projectFolder/.conf/tmp/$_source $projectFolder/$_target
    }
}

Write-Host -ForegroundColor DarkGreen "✅ specific"
# -------------------------------------------------------------------- SPECIFIC

# clean up tmp
Remove-Item -Recurse -Force $projectFolder/.conf/tmp

Write-Host -ForegroundColor DarkGreen "✅ Update done"
