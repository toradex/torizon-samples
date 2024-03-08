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

function _usage ($_fdp = 1) {
    Write-Host "usage:"
    Write-Host "    list                    : list the tasks.json labels defined"
    Write-Host "    desc <task_label>       : describe the task <task_label>"
    Write-Host "    desc <task_index>       : describe the task <task_index>"
    Write-Host "    run <task_label>        : run the task <task_label>"
    Write-Host "    run <task_index>        : run the task <task_index>"
    Write-Host "    run-nodeps <task_label> : run the tasks without dependencies <task_label>"

    if ($_fdp -eq 0) {
        Write-Host -ForegroundColor Yellow ""
        Write-Host -ForegroundColor Yellow "⚠️ :: WARNING :: ⚠️"
        Write-Host -ForegroundColor Yellow "This script depends on tasks.json and settings.json"
        Write-Host -ForegroundColor Yellow "These files need to be in the same directory as this script."
        Write-Host -ForegroundColor Yellow ""
    }

    exit 0
}

# settings
$_overrideEnv = $true;
$_debug = $false;
$_gitlab_ci = $false

if ($Env:GITLAB_CI -eq $true) {
    Write-Host "ℹ️ :: GITLAB_CI :: ℹ️"
    # for gitlab-ci we need to set the docker host
    $Env:DOCKER_HOST = "tcp://docker:2375"
    $_gitlab_ci = $true
}

if ($env:TASKS_DEBUG -eq $true) {
    $_debug = $true;
}

if ($env:TASKS_OVERRIDE_ENV -eq $false) {
    $_overrideEnv = $false;
}

if ($env:TASKS_USE_PWSH_INSTEAD_BASH -eq $true) {
    $_usePwshInsteadBash = $true;
} else {
    $_usePwshInsteadBash = $false;
}

try {
    $tasksFileContent = Get-Content $PSScriptRoot/tasks.json
    $settingsFileContent = Get-Content $PSScriptRoot/settings.json
    $json = $tasksFileContent | ConvertFrom-Json
    $settings = $settingsFileContent | ConvertFrom-Json
    $inputs = $json.inputs
    $inputValues = @{}
    $cliInputs = [System.Collections.ArrayList]@()
    $runDeps = $true;
} catch {
    _usage 0
}

function settingsToGlobal () {
    foreach ($set in $settings | Get-Member -MemberType Properties) {
        if (-not (Test-Path "variable:Global:$($set.Name)")) {
            New-Variable `
                -Scope Global `
                -Name "config:$($set.Name)" -Value $settings.($set.Name)
        } else {
            Set-Variable `
                -Scope Global `
                -Name "config:$($set.Name)" -Value $settings.($set.Name)
        }
    }
}

function write-error () {
    Write-Host -ForegroundColor Red `
        $args[0]
    exit $args[1]
}

function getTasksLabels () {
    $labels = [System.Collections.ArrayList]@()

    for ($i = 0; $i -le $json.tasks.length; $i++) {
        [void]$labels.Add($json.tasks[$i].label)
    }

    return $labels
}

function listTasksLabel () {
    $_noIndex = $false

    if ($null -ne $args[0]) {
        if ($args[0] -eq "--no-index") {
            $_noIndex = $true
        }
    }

    for ($i = 0; $i -le $json.tasks.length; $i++) {
        if ($null -ne $json.tasks[$i].label) {
            if ($_noIndex -eq $false) {
                Write-Host -NoNewline "$($i + 1).`t"
            }
            Write-Host $json.tasks[$i].label
        }
    }
}

function checkInput () {
    $ret = [System.Collections.ArrayList]@()

    foreach ($arg in $args[0]) {
        if (-not $arg.Contains("`${input:")) {
            [void]$ret.Add($arg)
        } else {
            $maches = ($arg |
                            Select-String `
                                -Pattern "(?<=\`${input:).*?(?=\s*})" `
                                -AllMatches
                        ).Matches

            foreach ($matchValue in $maches) {
                $inputObj = $null

                foreach ($inp in $inputs) {
                    if ($inp.id -eq $matchValue.Value) {
                        $inputObj = $inp
                    }
                }

                $fromUser = $null
                if ($inputValues.ContainsKey($matchValue.Value)) {
                    $fromUser = $inputValues[$matchValue.Value]
                } else {
                    $desc = $inputObj.description
                    $default = $inputObj.default

                    if ($cliInputs.Count -gt 0) {
                        $fromUser = $cliInputs[0]
                        $cliInputs.RemoveAt(0)
                    }

                    # cli input is nothing
                    if ($null -eq $fromUser) {
                        if ($inputObj.password -eq $true) {
                            $fromUser = Read-Host `
                                        -AsSecureString `
                                        -Prompt "$desc [***]"

                            # TODO: so much security wow
                            $fromUser = ConvertFrom-SecureString `
                                -SecureString $fromUser `
                                -AsPlainText
                        } else {
                            $fromUser = Read-Host `
                                        -Prompt "$desc [$default]"
                        }
                    }

                    if ($fromUser -eq [String]::Empty) {
                        $fromUser = $default
                    }

                    $inputValues.Add($matchValue.Value, $fromUser)
                }

                $matchValue = $matchValue.Value
                $arg = $arg.Replace("`${input:${matchValue}}", $fromUser)
            }

            [void]$ret.Add($arg)
        }
    }

    return $ret
}

# TODO: refactor to be an generic prefix check
function checkTorizonInputs ([System.Collections.ArrayList] $list) {
    $ret = [System.Collections.ArrayList]@()

    foreach ($item in $list) {
        if ($item.Contains("`${command:torizon_")) {

            $maches = ($item |
                        Select-String `
                            -Pattern "(?<=\`${command:torizon_).*?(?=\s*})" `
                            -AllMatches
                    ).Matches

            foreach ($matchValue in $maches) {
                $matchValue = $matchValue.Value
                $item = $item.Replace(
                    "`${command:torizon_${matchValue}}", 
                    "`${config:torizon_${matchValue}}"
                )
            }
        }

        [void]$ret.Add($item)
    }

    return $ret
}

function checkDockerInputs ([System.Collections.ArrayList] $list) {
    $ret = [System.Collections.ArrayList]@()

    foreach ($item in $list) {
        if ($item.Contains("`${command:docker_")) {

            $maches = ($item |
                        Select-String `
                            -Pattern "(?<=\`${command:docker_).*?(?=\s*})" `
                            -AllMatches
                    ).Matches

            foreach ($matchValue in $maches) {
                $matchValue = $matchValue.Value
                $item = $item.Replace(
                    "`${command:docker_${matchValue}}", 
                    "`${config:docker_${matchValue}}"
                )
            }
        }

        [void]$ret.Add($item)
    }

    return $ret
}

function checkTCBInputs ([System.Collections.ArrayList] $list) {
    $ret = [System.Collections.ArrayList]@()

    foreach ($item in $list) {
        if ($item.Contains("`${command:tcb")) {

            if ($item.Contains("tcb.getNextPackageVersion")) {
                $_ret =  (
                    ./.conf/torizonIO.ps1 `
                        package latest version ${global:config:tcb.packageName}
                )
                $_next = [System.Int32]::Parse($_ret) +1

                if ($_debug) {
                    Write-Host -ForegroundColor Green `
                        "Next package version: $_next"
                }

                $item = $item.Replace(
                    "`${command:tcb.getNextPackageVersion}", 
                    "$_next"
                )
            }

            $maches = ($item |
                        Select-String `
                            -Pattern "(?<=\`${command:tcb.).*?(?=\s*})" `
                            -AllMatches
                    ).Matches

            foreach ($matchValue in $maches) {
                $matchValue = $matchValue.Value
                $item = $item.Replace(
                    "`${command:tcb.${matchValue}}", 
                    "`${config:tcb.${matchValue}}"
                )
            }
        }

        [void]$ret.Add($item)
    }

    return $ret
}

# check if the string contains special characters
function _containsSpecialChars ([String] $str) {
    $ret = $false

    if (
        $str -match "[^a-zA-Z0-9\.\-_]"
    ) {
        $ret = $true
    }

    return $ret
}

function scapeArgs ([System.Collections.ArrayList] $list) {
    $ret = [System.Collections.ArrayList]@()

    # for now only scaping double quotes
    foreach ($item in $list) {
        if ($item.Contains("`"")) {
            $item = $item.Replace("`"", "```"")
        }

        [void]$ret.Add($item)
    }

    return $ret
}

function checkConfig ([System.Collections.ArrayList] $list) {
    $ret = [System.Collections.ArrayList]@()

    foreach ($item in $list) {
        # TODO: Add variable expand recursive
        if ($item.Contains("config:")) {
            $item = $item.Replace("config:", "global:config:")

            $value = Invoke-Expression "echo `"$item`""

            if ($null -ne $value -and $value.Contains("`${workspaceFolder")) {
                $item = $value
            }
        }

        [void]$ret.Add($item)
    }

    return $ret
}

function checkLongArgs ([System.Collections.ArrayList] $list) {
    $ret = [System.Collections.ArrayList]@()

    foreach ($item in $list) {
        if ($item.Contains(" ")) {
            $item = "'$item'"
        }

        [void]$ret.Add($item)
    }

    return $ret
}

##
# If the user is using bash as default shell, we need to scape the $ special
# characters, because powershell will try to expand the variables before it
# reach the bash shell
##
function bashVariables ([System.Collections.ArrayList] $list) {
    $ret = [System.Collections.ArrayList]@()

    foreach ($item in $list) {
        if ($item.Contains("$")) {

            # if $env
            # if ${}
            # if $global
            # then we continue because these are meant to be expanded
            if (
                $item.Contains("`$global:") -or
                $item.Contains("`$env:") -or 
                $item.Contains("`${")
            ) {
                [void]$ret.Add($item)
                continue
            }

            # ok, we can scape it
            $item = $item.Replace("`$", "``$")
            [void]$ret.Add($item)
        } else {
            [void]$ret.Add($item)
        }
    }

    return $ret
}

function quotingSpecialChars ([System.Collections.ArrayList] $list) {
    $ret = [System.Collections.ArrayList]@()

    foreach ($item in $list) {
        $_specialChar = _containsSpecialChars($item)
        $_space = $item.Contains(" ")

        if ($_specialChar -and -not $_space) {
            $item = "'$item'"
        }

        [void]$ret.Add($item)
    }

    return $ret
}

function checkWorkspaceFolder ([System.Collections.ArrayList] $list) {
    $ret = [System.Collections.ArrayList]@()

    foreach ($item in $list) {
        # TODO: Add variable expand recursive
        if ($item.Contains("workspaceFolder")) {
            $item = $item.Replace("workspaceFolder", "global:workspaceFolder")

            $value = Invoke-Expression "echo $item"

            if ($value.Contains("`${workspaceFolder")) {
                $item = $value
            }
        }

        [void]$ret.Add($item)
    }

    return $ret
}

function taskArgumentExecute ($label, [ScriptBlock]$fnExec, $message) {
    if ($null -eq $label -or $label -eq [String]::Empty) {
        write-error $message 10
    } else {
        $taskLabel = $label

        if ($taskLabel -match "^\d+$") {
            Invoke-Command -ScriptBlock $fnExec `
                -ArgumentList $json.tasks[[int]::Parse($taskLabel) -1].label
        } elseif ((getTasksLabels).Contains($taskLabel)) {
            Invoke-Command -ScriptBlock $fnExec `
                -ArgumentList $taskLabel
        } else {
            write-error "Undefined task <$taskLabel>" 10
        }
    }
}

function descTask () {
    for ($i = 0; $i -le $json.tasks.length; $i++) {
        if ($json.tasks[$i].label -eq $args[0]) {
            $task = $json.tasks[$i]
            $task | ConvertTo-Json
        }
    }
}

function _parseEnvs () {
    $env = $args[0]
    $task = $args[1]

    $value = $task.options.env
                | Select-Object -ExpandProperty $env

    $expValue = checkWorkspaceFolder($value)
    $expValue = checkTorizonInputs($expValue)
    $expValue = checkDockerInputs($expValue)
    $expValue = checkTCBInputs($expValue)
    $expValue = checkInput($expValue)
    $expValue = checkConfig($expValue)
    $expValue = bashVariables($expValue)
    $expValue = $expValue.ToString()
    $_env = Invoke-Expression "echo `"$expValue`""

    if ($_debug -eq $true) {
        Write-Host -ForegroundColor Yellow `
            "Env: $env=$expValue"
        Write-Host -ForegroundColor Yellow `
            "Parsed Env: $env=$_env"
    }

    return $_env
}

function _replaceDockerHost () {
    $value = $args[0]

    if ($value -match "DOCKER_HOST=") {
        $value = $value.Replace("DOCKER_HOST=", "DOCKER_HOST=tcp://docker:2375")
    }

    return $value
}

function runTask () {
    for ($i = 0; $i -le $json.tasks.length; $i++) {
        if ($json.tasks[$i].label -eq $args[0]) {
            $task = $json.tasks[$i]
            $taskCmd = $task.command
            $taskArgs = scapeArgs($task.args)
            $taskArgs = checkWorkspaceFolder($taskArgs)
            $taskArgs = checkTorizonInputs($taskArgs)
            $taskArgs = checkDockerInputs($taskArgs)
            $taskArgs = checkTCBInputs($taskArgs)
            $taskArgs = checkInput($taskArgs)
            $taskArgs = checkConfig($taskArgs)
            $taskArgs = checkLongArgs($taskArgs)
            $taskArgs = bashVariables($taskArgs)
            $taskArgs = quotingSpecialChars($taskArgs)
            $taskDepends = $task.dependsOn
            $taskEnv = $task.options.env
            $taskCwd = $task.options.cwd

            $isBackground = ""
            if ($task.isBackground -eq $true) {
                $isBackground = " &"
            }

            # FIXME: if using powershell instead bash the background will start
            # a new job, this is was not been well tested
            # is gitlab ci
            if ($_gitlab_ci -eq $true) {
                $taskCmd = _replaceDockerHost($taskCmd)
            }

            # inject env
            if ($null -ne $taskEnv) {
                $envs = $taskEnv
                    | get-member -MemberType NoteProperty
                    | Select-Object -ExpandProperty Name

                foreach ($env in $envs) {
                    if ($_overrideEnv) {
                        $_env = _parseEnvs $env $task
                        [System.Environment]::SetEnvironmentVariable(
                            $env, $_env
                        )
                    } else {
                        if (
                            $null -eq 
                            [System.Environment]::GetEnvironmentVariable($env)
                        ) {
                            $_env = _parseEnvs $env $task
                            [System.Environment]::SetEnvironmentVariable(
                                $env, $_env
                            )
                        }
                    }
                }
            }

            # run dependencies
            if ($runDeps -eq $true) {
                for ($j = 0; $j -lt $taskDepends.Count; $j++) {
                    runTask $taskDepends[$j]
                }
            }

            Write-Host -ForegroundColor Green `
                "> Executing task: $($json.tasks[$i].label) <"

            # we need to change dir if we are setting cwd
            if ($null -ne $taskCwd) {
                # store the current location
                $_cwd = Get-Location

                # we use invoke-expression because this way it expand the
                # variables automatically
                Invoke-Expression "Set-Location $taskCwd"
            }

            # parse the variables
            $_cmd = Invoke-Expression "echo `"$taskCmd $taskArgs $isBackground`""

            if ($env:TASKS_DEBUG -eq $true) {
                Write-Host -ForegroundColor Yellow `
                    "Command: $taskCmd"
                Write-Host -ForegroundColor Yellow `
                    "Args: $taskArgs"
                Write-Host -ForegroundColor Yellow `
                    "Parsed Command: $_cmd"
            }

            # all to global
            # we are spawning a new process, so we need to set all the envs
            # as global, so the new process can see it
            # this is useful when the user set bash variables
            $_ALLENV = $(Get-ChildItem env:)
            foreach ($_env in $_ALLENV) {
                try {
                # set it as a $Global:
                Set-Variable `
                    -Scope Global `
                    -Name $_env.Name -Value $_env.Value
                } catch {
                    # ignore
                    # some variables are not overwrite
                }
            }

            # execute the task
            if ($task.type -eq "shell") {
                if ($_usePwshInsteadBash -eq $false) {
                    # use bash as default
                    # TODO: be explicit about bash as default on documentation
                    Invoke-Expression "bash -c `"$_cmd`""
                } else {
                    Invoke-Expression "pwsh -nop -c `"$_cmd`""
                }
            } else {
                Invoke-Expression $_cmd
            }

            $exitCode = $LASTEXITCODE

            # go back to the origin location
            if ($null -ne $taskCwd) {
                # restore the current location
                Set-Location $_cwd
            }

            # abort we had an error
            if ($exitCode -ne 0) {
                Write-Host -ForegroundColor Red `
                    "> TASK $($json.tasks[$i].label) exited with error code $($exitCode) <"
                exit $exitCode
            }
        }
    }
}

function getCliInputs () {
    $argsS = $args[0]
    # args[0] command / args[1] task name
    for ($i = 2; $i -lt $argsS.Length; $i++) {
        # inputs
        [void]$cliInputs.Add($argsS[$i])
    }
}

# main()
# set the relative workspaceFolder (following the pattern that VS Code expects)
if (
    ($null -eq $env:APOLLOX_WORKSPACE) -and 
    ($env:APOLLOX_CONTAINER -ne 1)
) {
    $Global:workspaceFolder = Join-Path $PSScriptRoot ..
} else {
    $Global:workspaceFolder = $env:APOLLOX_WORKSPACE
}

settingsToGlobal

try {
    switch ($args[0]) {
        "list" {
            listTasksLabel $args[1]
        }
        "desc" {
            taskArgumentExecute `
                $args[1] ${function:descTask} "Argument expected desc <task_label>"
        }
        "run" {
            getCliInputs $args
            taskArgumentExecute `
                $args[1] ${function:runTask} "Argument expected run <task_label>"
        }
        "run-nodeps" {
            $runDeps = $false;
            getCliInputs $args
            taskArgumentExecute `
                $args[1] ${function:runTask} "Argument expected run <task_label>"
        }
        Default {
            _usage
        }
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
