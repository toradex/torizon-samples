#!/usr/bin/env xonsh

# Copyright (c) 2025 Toradex
# SPDX-License-Identifier: MIT

##
# This script is used to update the project from the fetch from git
##

# use the xonsh environment to update the OS environment
$UPDATE_OS_ENVIRON = True
# Get the full log of error
$XONSH_SHOW_TRACEBACK = True
# always return if a cmd fails
$RAISE_SUBPROC_ERROR = True

import os
import sys
import json
import hashlib
import mimetypes
from torizon_templates_utils import debug
from xonsh.procs.pipelines import CommandPipeline
from torizon_templates_utils.tasks import replace_tasks_input
from torizon_templates_utils.errors import Error,Error_Out
from torizon_templates_utils.colors import Color,BgColor,print
from torizon_templates_utils.args import get_arg_not_empty,get_optional_arg


## In case of fire break glass
# debug.vscode_prepare()
# debug.breakpoint()


if len(sys.argv) < 4:
    print(
"""
Usage:
    project-updater.xsh <project_folder> <accept_all> <vscode> <second_run>

        <project_folder>    The folder path where the project that will be updated is located.

        <accept_all>        This is a bool like argument (True or False).
                            This signals if the updater should accept all the new
                            changes without open a diff window.

    Optional:

        <vscode>            This is a bool like argument (True or False).
                            This signals if the script is being used from VS Code extension.
                            The default is False.

        <second_run>        This is a bool like argument (True or False).
                            This is used internally to signal that the script updated
                            itself and is running again.
"""
    )

    Error_Out("", Error.EUSER)


project_folder = get_arg_not_empty(1)
project_name = get_arg_not_empty(2)
# Check if it's True or 1
accept_all = get_arg_not_empty(3) in ("True", "1")
vscode = get_optional_arg(4, True)
second_run = get_optional_arg(5, False)

##
# even tough the vscode arg is true, if the TORIZON_TEMPLATES_NON_VSCODE
# is set we will not use the vscode to open the diff tool
##
if "TORIZON_TEMPLATES_NON_VSCODE" in os.environ:
    vscode = False


def _check_if_file_content_is_equal(file1_path, file2_path):
    try:
        file1 = open(file1_path, "rb")
        file2 = open(file2_path, "rb")

        file1_hash = hashlib.sha256(file1.read()).hexdigest()
        file2_hash = hashlib.sha256(file2.read()).hexdigest()

        file1.close()
        file2.close()

        return file1_hash == file2_hash
    except FileNotFoundError as fex:
        if os.environ["TORIZON_TEMPLATES_UPDATER_IGNORE_MISSING_FILES"] == "True":
            # make sure that the file missing is not the one from .apollox
            if ".apollox" not in fex.filename:
                # so, we ignore the error copy the file1_path to file2_path
                # and return True
                cp -f @(file1_path) @(file2_path)
                return True

        Error_Out(
            f"❌ fatal: {fex.filename} not found when trying to diff files",
            Error.ENOFOUND
        )


def _open_merge_window(to_update, current):
    if accept_all:
        # if the source does not exists anymore on the .apollox repo
        # we can just remove it from the project being updated
        if not os.path.exists(to_update):
            rm -rf @(to_update)
        else:
            cp -f @(to_update) @(current)

        return

    # if one of the files does not exists create an empty one
    if not os.path.exists(to_update):
        open(to_update, "w").close()
    elif not os.path.exists(current):
        open(current, "w").close()

    if not _check_if_file_content_is_equal(to_update, current):
        _diff_tool = "code"

        if not vscode:
            # meld
            _diff_tool = $(which meld)

            if _diff_tool == "":
                Error_Out(
                    "❌ fatal: meld is not installed",
                    Error.ENOCONF
                )

            # open the diff tool
            @(_diff_tool) @(to_update) @(current)

        # vscode need some other arguments
        else:
            @(_diff_tool) --wait --diff @(to_update) @(current)

        # if after the merge the file is still empty
        # means that this file should bot be added to the project
        # so, let's remove it
        if os.path.getsize(to_update) == 0:
            rm -f @(to_update)
        if os.path.getsize(current) == 0:
            rm -f @(current)


# no need to update itself again
if not second_run:
    # make sure to tell user if the project is not a git repo
    $RAISE_SUBPROC_ERROR = False
    _git_status: CommandPipeline = {}
    _git_status = !(git -C @(project_folder) status)

    if _git_status.err != None and "fatal: not a git repository" in _git_status.err:
        print(
            "❌ fatal: this workspace is not a git repository.",
            color=Color.RED
        )
        print(
            "It is highly recommended that you create a repo and commit the current state of the project before updating it, to keep track of the changes that will be applied on the update.",
            color=Color.YELLOW
        )
        print(
            "If the project is not versioned there is no way back!",
            color=Color.YELLOW
        )

        _iam_sure = input("Do you really want to proceed? [y/n] ")
        if _iam_sure != "y":
            Error_Out(
                "User abort",
                Error.EABORT
            )

    $RAISE_SUBPROC_ERROR = True


if accept_all and not second_run:
    print("You are about to accept all incoming changes from the updated template", color=Color.YELLOW)
    print("If the project is not versioned there is no way back!", color=Color.YELLOW)

    _iam_sure = input("Accept all changes? [y/n] ")
    if _iam_sure != "y":
        Error_Out(
            "User abort",
            Error.EABORT
        )

# PROJECT UPDATER - update itself?
if not _check_if_file_content_is_equal(
        f"{os.environ['HOME']}/.apollox/scripts/project-updater.xsh",
        f"{project_folder}/.conf/project-updater.xsh"
    ):
    # in this case we need to update the updater itself
    # and then run it again
    print("Updater need update ...")

    cp -f \
        @(f"{os.environ['HOME']}/.apollox/scripts/project-updater.xsh") \
        @(f"{project_folder}/.conf/project-updater.xsh")

    print("⚠️  project updater updated, running it again", color=Color.YELLOW)

    # run the updater again
    xonsh \
        @(f"{project_folder}/.conf/project-updater.xsh") \
        @(project_folder) \
        @(project_name) \
        @(accept_all) \
        @(vscode) \
        True

    sys.exit(__xonsh__.last.returncode)


# get the metadata from templates.json
_templates_metadata_file = open(f"{os.environ['HOME']}/.apollox/templates.json", "r")
_templates_metadata = json.loads(_templates_metadata_file.read())
_templates_metadata_file.close()

if "TorizonOSMajor" in _templates_metadata:
    _templatesJsonTorizonMajor = _templates_metadata["TorizonOSMajor"]
else:
    _templatesJsonTorizonMajor = "6"


# get the metadata from deprecatedTemplates.json
_deprecated_metadata_file = open(f"{os.environ['HOME']}/.apollox/deprecatedTemplates.json", "r")
_deprecated_metadata = json.loads(_deprecated_metadata_file.read())
_deprecated_metadata_file.close()

# get the project metadata
_project_metadata = None

if os.path.exists(f"{project_folder}/.conf/metadata.json"):
    _project_metadata_file = open(f"{project_folder}/.conf/metadata.json", "r")
    _project_metadata = json.loads(_project_metadata_file.read())
    _project_metadata_file.close()
else:
    # update the old .template and .container to metadata.json
    _dot_template_file = open(f"{project_folder}/.conf/.template", "r")
    _dot_container_file = open(f"{project_folder}/.conf/.container", "r")
    _dot_template = _dot_template_file.read().strip()
    _dot_container = _dot_container_file.read().strip()
    _dot_template_file.close()
    _dot_container_file.close()

    _project_metadata = {
        "templateName": f"{_dot_template}",
        "containerName": f"{_dot_container}",
        "torizonOSMajor": f"{_torizonOSMajor}"
    }

    # save the metadata
    _project_metadata_file = open(f"{project_folder}/.conf/metadata.json", "w")
    _project_metadata_file.write(json.dumps(_project_metadata, indent=4))
    _project_metadata_file.close()

    # remove the old files
    rm -f @(f"{project_folder}/.conf/.template")
    rm -f @(f"{project_folder}/.conf/.container")

_torizonOSMajor = _project_metadata["torizonOSMajor"]
_template_name = _project_metadata['templateName']

# signalize if the user is under a torizonOSMajor not 7
if _torizonOSMajor != "7":
    print(
        "The latest Torizon OS major version is 7",
        color=Color.YELLOW
    )
    print(
        f"But your templates repository is using the major version {_torizonOSMajor}.",
        color=Color.YELLOW
    )
    print(
        "Check the torizon.templatesBranch property in your settings.json",
        color=Color.YELLOW
    )

# make sure to accept a major version update
if _torizonOSMajor != _templatesJsonTorizonMajor:
    print(
        f"Your template is on Torizon OS major version {_torizonOSMajor} and you are updating it to a template in Torizon OS major version {_templatesJsonTorizonMajor}",
        color=Color.RED
    )

    _iam_sure = input("Are you sure you want to proceed with the update? [y/n] ")
    if _iam_sure != "y":
        Error_Out(
            "If you want to stick to a specific Torizon OS version, set the torizon.templatesBranch on settings.json: https://developer.toradex.com/torizon/application-development/ide-extension/reference-documentation/workspace-settings#torizontemplatesbranch",
            Error.EABORT
        )

# continue
# check first if the folder already exists
if not os.path.exists(f"{project_folder}/.conf/tmp"):
    mkdir -p @(f"{project_folder}/.conf/tmp")

# check if the template was deprecated
for _template in _deprecated_metadata["DeprecatedTemplates"]:
    if _template["folder"] == _template_name:
        print(
            f"❌ The template {_template_name} is deprecated and will not be updated.\n"
            f"For details, check https://github.com/torizon/vscode-torizon-templates/blob/dev/DEPRECATED.md",
            color=Color.RED
        )

        Error_Out(
            "Impossible to update",
            Error.ETOMCRUISE
        )


# query the template in the metadata
_template_metadata = None
_template_metadata = next(
    (item for item in _templates_metadata["Templates"] if item["folder"] == _template_name),
    None
)

if _template_metadata is None:
    print(
        f"❌ The template {_template_name} was not found in the templates repository.",
        color=Color.RED
    )

    Error_Out(
        "Impossible to update",
        Error.ETOMCRUISE
    )

# continue
# check the status
# if deprecated or broken, it cannot be updated
if _template_metadata["status"] == "notok":
    print(
        f"This template is broken in the most recent version of the Torizon IDE Extension templates. Reason:"
        f"\n{_template_metadata['customMessage']}",
        color=Color.RED
    )

    Error_Out(
        "Impossible to update",
        Error.ETOMCRUISE
    )

elif _template_metadata["status"] == "incomplete":
    print(
        f"This template is incomplete in the most recent version of the Torizon IDE Extension templates reason:"
        f"\n{_template_metadata['customMessage']}",
        color=Color.RED
    )

    _iam_sure = input("Are you sure you want to proceed with the update? [y/n] ")
    if _iam_sure != "y":
        Error_Out(
            "User abort",
            Error.EABORT
        )


# continue
# ----------------------------------------------------------- ALWAYS ACCEPT NEW
# UPDATE.JSON:
cp -f \
    @(f"{os.environ['HOME']}/.apollox/{_template_name}/.conf/update.json") \
    @(f"{project_folder}/.conf/update.json")

# TASKS.XSH:
cp -f \
    @(f"{os.environ['HOME']}/.apollox/scripts/.vscode/tasks.xsh") \
    @(f"{project_folder}/.vscode/tasks.xsh")

# CHECK DEPS
cp -f \
    @(f"{os.environ['HOME']}/.apollox/scripts/check-deps.xsh") \
    @(f"{project_folder}/.conf/check-deps.xsh")

# RUN CONTAINER IF NOT EXISTS
cp -f \
    @(f"{os.environ['HOME']}/.apollox/scripts/run-container-if-not-exists.xsh") \
    @(f"{project_folder}/.conf/run-container-if-not-exists.xsh")

# SHARE WSL PORTS
cp -f \
    @(f"{os.environ['HOME']}/.apollox/scripts/share-wsl-ports.xsh") \
    @(f"{project_folder}/.conf/share-wsl-ports.xsh")

# TORIZON IO:
cp -f \
    @(f"{os.environ['HOME']}/.apollox/scripts/torizon-io.xsh") \
    @(f"{project_folder}/.conf/torizon-io.xsh")

# DOCKER LOGIN:
cp -f \
    @(f"{os.environ['HOME']}/.apollox/scripts/docker-login.xsh") \
    @(f"{project_folder}/.conf/docker-login.xsh")

# CREATE DOCKER COMPOSE PRODUCTION:
cp -f \
    @(f"{os.environ['HOME']}/.apollox/scripts/create-docker-compose-production.xsh") \
    @(f"{project_folder}/.conf/create-docker-compose-production.xsh")

# TCB ENV SETUP
cp -f \
    @(f"{os.environ['HOME']}/.apollox/scripts/bash/tcb-env-setup.sh") \
    @(f"{project_folder}/.conf/tcb-env-setup.sh")

# CHECK CI ENV:
cp -f \
    @(f"{os.environ['HOME']}/.apollox/scripts/check-ci-env.xsh") \
    @(f"{project_folder}/.conf/check-ci-env.xsh")

# VALIDATE DEPS RUNNING ENV:
cp -f \
    @(f"{os.environ['HOME']}/.apollox/scripts/validate-deps-running.xsh") \
    @(f"{project_folder}/.conf/validate-deps-running.xsh")

# APPLY CI SETTINGS FILE:
cp -f \
    @(f"{os.environ['HOME']}/.apollox/scripts/apply-ci-settings-file.xsh") \
    @(f"{project_folder}/.conf/apply-ci-settings-file.xsh")

# TORIZONPACKAGES:
cp -f \
    @(f"{os.environ['HOME']}/.apollox/scripts/torizon-packages.xsh") \
    @(f"{project_folder}/.conf/torizon-packages.xsh")

# VALIDATE JSON FILES:
cp -f \
    @(f"{os.environ['HOME']}/.apollox/scripts/validate-json.xsh") \
    @(f"{project_folder}/.conf/validate-json.xsh")

# DOCUMENTATION:
if not os.path.exists(f"{project_folder}/.doc"):
    mkdir -p @(f"{project_folder}/.doc")

cp -rf \
    @(f"{os.environ['HOME']}/.apollox/{_template_name}/.doc/.") \
    @(f"{project_folder}/.doc/")


print("✅ always accept new OK", color=Color.GREEN)
# ----------------------------------------------------------- ALWAYS ACCEPT NEW


# now that we have an updated version we can read it
_update_table_file = open(f"{project_folder}/.conf/update.json", "r")
_update_table = json.loads(_update_table_file.read())
_update_table_file.close()


# ---------------------------------------------------------------------- .VSCODE
# tcb does not have the launch.json
if _template_name != "tcb":
    cp -f \
        @(f"{os.environ['HOME']}/.apollox/{_template_name}/.vscode/launch.json") \
        @(f"{project_folder}/.conf/tmp/launch-next.json")

cp -f \
    @(f"{os.environ['HOME']}/.apollox/{_template_name}/.vscode/settings.json") \
    @(f"{project_folder}/.conf/tmp/settings-next.json")

# check if the template has an extensions.json file
if os.path.exists(f"{os.environ['HOME']}/.apollox/{_template_name}/.vscode/extensions.json"):
    cp -f \
        @(f"{os.environ['HOME']}/.apollox/{_template_name}/.vscode/extensions.json") \
        @(f"{project_folder}/.conf/tmp/extensions-next.json")


# TASKS.JSON
cp -f \
    @(f"{os.environ['HOME']}/.apollox/{_template_name}/.vscode/tasks.json") \
    @(f"{project_folder}/.conf/tmp/tasks-next.json")

# tcb also does not need to merge the common tasks
if "mergeCommon" not in _template_metadata:
    print("Applying common tasks ...", color=Color.YELLOW)

    _common_tasks_file = open(f"{os.environ['HOME']}/.apollox/assets/tasks/common.json", "r")
    _common_tasks = json.loads(_common_tasks_file.read())
    _common_tasks_file.close()

    _common_inputs_file = open(f"{os.environ['HOME']}/.apollox/assets/tasks/inputs.json", "r")
    _common_inputs = json.loads(_common_inputs_file.read())
    _common_inputs_file.close()

    _proj_tasks_file = open(f"{project_folder}/.conf/tmp/tasks-next.json", "r")
    _proj_tasks = json.loads(_proj_tasks_file.read())
    _proj_tasks_file.close()

    # merge then
    _proj_tasks["tasks"] += _common_tasks["tasks"]
    _proj_tasks["inputs"] += _common_inputs["inputs"]

    # save the new tasks
    _proj_tasks_file = open(f"{project_folder}/.conf/tmp/tasks-next.json", "w")
    _proj_tasks_file.write(json.dumps(_proj_tasks, indent=4))
    _proj_tasks_file.close()


# go to the tmp folder
_old_location = os.getcwd()
os.chdir(f"{project_folder}/.conf/tmp")

# tcb does not have the common Docker files
if _template_name != "tcb":
    # The generic template doesn't have a Dockerfile.debug
    if os.path.exists(f"{os.environ['HOME']}/.apollox/{_template_name}/Dockerfile.debug"):
        cp -f @(f"{os.environ['HOME']}/.apollox/{_template_name}/Dockerfile.debug") .

    # If there is a Dockerfile.sdk, also include it
    if os.path.exists(f"{os.environ['HOME']}/.apollox/{_template_name}/Dockerfile.sdk"):
        cp -f @(f"{os.environ['HOME']}/.apollox/{_template_name}/Dockerfile.sdk") .

    cp -f @(f"{os.environ['HOME']}/.apollox/{_template_name}/Dockerfile") .
    cp -f @(f"{os.environ['HOME']}/.apollox/{_template_name}/docker-compose.yml") .
    cp -f @(f"{os.environ['HOME']}/.apollox/assets/github/workflows/build-application.yaml") .
    cp -f @(f"{os.environ['HOME']}/.apollox/assets/gitlab/.gitlab-ci.yml") .

    # If there is a .dockerignore file, also include it
    if os.path.exists(f"{os.environ['HOME']}/.apollox/{_template_name}/.dockerignore"):
        cp -f @(f"{os.environ['HOME']}/.apollox/{_template_name}/.dockerignore") .

    # ----------------------------------------------------------------- TORIZONPACKAGES.JSON
    with open(f"{os.environ['HOME']}/.apollox/assets/json/torizonPackages.json", "r") as f:
        _torPackagesJson = json.load(f)

    # Check also the build part of Dockerfile, for the presence of torizon_packages_build
    with open(f"{os.environ['HOME']}/.apollox/{_template_name}/Dockerfile", "r") as f:
        dockerfileLines = f.readlines()

    buildDepDockerfile = any("torizon_packages_build" in line for line in dockerfileLines)

    if os.path.exists(f"{os.environ['HOME']}/.apollox/{_template_name}/Dockerfile.sdk") or buildDepDockerfile:
        _torPackagesJson["buildDeps"] = []

    # Save the modified JSON object to a file
    with open("./torizonPackages.json", "w") as f:
        json.dump(_torPackagesJson, f, indent=4)
    # ----------------------------------------------------------------- TORIZONPACKAGES.JSON


# GIT IGNORE
cp -f @(f"{os.environ['HOME']}/.apollox/{_template_name}/.gitignore") .

# DEPS.JSON
cp -f @(f"{os.environ['HOME']}/.apollox/{_template_name}/.conf/deps.json") .

# check if there are scripts defined in the .conf/deps.json
# if so, copy them to the project
_deps_file = open("./deps.json", "r")
_deps = json.loads(_deps_file.read())
_deps_file.close()

if "installDepsScripts" in _deps and len(_deps["installDepsScripts"]) > 0:

    if not os.path.exists("./installDepsScripts"):
        mkdir -p @("./installDepsScripts")

    # If there is no script in the .conf/installDepsScripts of the template,
    # but there is some script defined in the installDepsScripts with the
    # .conf/installDepsScripts path, then it comes from the
    # scripts/installDepsScripts folder of the vscode-torizon-templates repo.
    # This is useful when there are scripts that are common for many templates.
    for _script in _deps["installDepsScripts"]:
        if not os.path.exists(f"{os.environ['HOME']}/.apollox/{_template_name}/{_script}") and ".conf/installDepsScripts" in _script:
            _script_source = _script.replace(".conf", "scripts")
        else:
            _script_source = f"{_template_name}/{_script}"

        _script_dest = _script.replace(".conf/", "")
        cp -f @(f"{os.environ['HOME']}/.apollox/{_script_source}") @(f"./{_script_dest}")


# read the update table
for _update in _update_table:
    cp -f @(f"{os.environ['HOME']}/.apollox/{_template_name}/{_update['source']}") .


# change the contents
print("Renaming file contents ...", color=Color.YELLOW)

for root, dirs, files in os.walk("."):
    for file in files:
        file_path = os.path.join(root, file)

        mime_type, _ = mimetypes.guess_type(file_path)

        # ignore binary files
        if mime_type and mime_type.startswith("application/octet-stream"):
            continue

        # ignore the id_rsa files
        if "id_rsa" in file_path and not file_path.endswith(".pub"):
            os.chmod(file_path, 0o400)
            continue

        with open(file_path, "r") as f:
            content = f.read()

        content = content.replace("__change__", project_name)
        content = content.replace("__container__", _project_metadata["containerName"])
        content = content.replace("__home__", os.environ["HOME"])
        content = content.replace("__templateFolder__", _template_name)

        with open(file_path, "w") as f:
            f.write(content)

        # this means that the file passed all the checks
        print(file_path)


# we need to also replace inputs
print("Applying inputs ...", color=Color.YELLOW)
replace_tasks_input()

# back to the origin
os.chdir(_old_location)

# ---------------------------------------------------------------------- .VSCODE
print("Diff .vscode files ...", color=Color.YELLOW)

# TASKS.JSON
_open_merge_window(
    f"{project_folder}/.conf/tmp/tasks-next.json",
    f"{project_folder}/.vscode/tasks.json"
)

print("✅ tasks.json", color=Color.GREEN)

# LAUNCH.JSON
if _template_name != "tcb":
    _open_merge_window(
        f"{project_folder}/.conf/tmp/launch-next.json",
        f"{project_folder}/.vscode/launch.json"
    )

    print("✅ launch.json", color=Color.GREEN)

# SETTINGS.JSON
_open_merge_window(
    f"{project_folder}/.conf/tmp/settings-next.json",
    f"{project_folder}/.vscode/settings.json"
)

print("✅ settings.json", color=Color.GREEN)

# EXTENSIONS.JSON
if os.path.exists(f"{os.environ['HOME']}/.apollox/{_template_name}/.vscode/extensions.json"):
    _open_merge_window(
        f"{project_folder}/.conf/tmp/extensions-next.json",
        f"{project_folder}/.vscode/extensions.json"
    )

    print("✅ extensions.json", color=Color.GREEN)

# ---------------------------------------------------------------------- .VSCODE


# ----------------------------------------------------------------------- COMMON
print("Diff common files ...", color=Color.YELLOW)

if _template_name != "tcb":
    # DOCKERFILE.DEBUG
    if os.path.exists(f"{project_folder}/.con/tmp/Dockerfile.debug"):
        _open_merge_window(
            f"{project_folder}/.conf/tmp/Dockerfile.debug",
            f"{project_folder}/Dockerfile.debug"
        )

        print("✅ Dockerfile.debug", color=Color.GREEN)

    # DOCKERFILE.SDK
    if os.path.exists(f"{project_folder}/.conf/tmp/Dockerfile.sdk"):
        _open_merge_window(
            f"{project_folder}/.conf/tmp/Dockerfile.sdk",
            f"{project_folder}/Dockerfile.sdk"
        )

        print("✅ Dockerfile.sdk", color=Color.GREEN)

    # DOCKERFILE
    # all projects must have it (less TCB)
    # FIXME: should we not be more generic here? if there is tcb should be more
    _open_merge_window(
        f"{project_folder}/.conf/tmp/Dockerfile",
        f"{project_folder}/Dockerfile"
    )

    print("✅ Dockerfile", color=Color.GREEN)

    # DOCKER-COMPOSE.YML
    _open_merge_window(
        f"{project_folder}/.conf/tmp/docker-compose.yml",
        f"{project_folder}/docker-compose.yml"
    )

    print("✅ docker-compose.yml", color=Color.GREEN)

    # GITHUB ACTIONS
    _open_merge_window(
        f"{project_folder}/.conf/tmp/build-application.yaml",
        f"{project_folder}/.github/workflows/build-application.yaml"
    )

    print("✅ build-application.yaml", color=Color.GREEN)

    # GITLAB CI
    _open_merge_window(
        f"{project_folder}/.conf/tmp/.gitlab-ci.yml",
        f"{project_folder}/.gitlab-ci.yml"
    )

    print("✅ .gitlab-ci.yml", color=Color.GREEN)

    # DOCKER IGNORE
    if os.path.exists(f"{project_folder}/.conf/tmp/.dockerignore"):
        _open_merge_window(
            f"{project_folder}/.conf/tmp/.dockerignore",
            f"{project_folder}/.dockerignore"
        )

        print("✅ .dockerignore", color=Color.GREEN)

    # TORIZON PACKAGES
    _open_merge_window(
        f"{project_folder}/.conf/tmp/torizonPackages.json",
        f"{project_folder}/torizonPackages.json"
    )


# GIT IGNORE
_open_merge_window(
    f"{project_folder}/.conf/tmp/.gitignore",
    f"{project_folder}/.gitignore"
)

print("✅ .gitignore", color=Color.GREEN)

# DEPS.JSON
_open_merge_window(
    f"{project_folder}/.conf/tmp/deps.json",
    f"{project_folder}/.conf/deps.json"
)

print("✅ deps.json", color=Color.GREEN)
print("✅ common files OK", color=Color.GREEN)

# ----------------------------------------------------------------------- COMMON


# --------------------------------------------------------------------- SPECIFIC

# install dependencies scripts
print("Checking deps scripts ...", color=Color.YELLOW)

if "installDepsScripts" in _deps:
    if not os.path.exists(f"{project_folder}/.conf/installDepsScripts"):
        mkdir -p @(f"{project_folder}/.conf/installDepsScripts")

    for script in _deps["installDepsScripts"]:
        _script_src = script.replace(".conf/", "")

        _open_merge_window(
            f"{project_folder}/.conf/tmp/{_script_src}",
            f"{project_folder}/{_script}"
        )

        print(f"✅ {_script_dest}", color=Color.GREEN)

print("Diff specific table ...", color=Color.YELLOW)

for update in _update_table:
    source = os.path.basename(update["source"])
    target = update["target"]
    target = os.path.expandvars(target)

    # check if the file exists, if not simply copy it
    if os.path.exists(os.path.join(project_folder, target)):
        _open_merge_window(
            os.path.join(project_folder, ".conf/tmp", source),
            os.path.join(project_folder, target)
        )
    else:
        cp -f @(os.path.join(project_folder, ".conf/tmp", source)) @(os.path.join(project_folder, target))

    print(f"✅ {update['target']}", color=Color.GREEN)

print("✅ specific files OK", color=Color.GREEN)

# --------------------------------------------------------------------- SPECIFIC

# clean up tmp
rm -rf @(f"{project_folder}/.conf/tmp")

# update metadata.json
_project_metadata_file = open(f"{project_folder}/.conf/metadata.json", "w")
_project_metadata["torizonOSMajor"] = _templates_metadata["TorizonOSMajor"]
_project_metadata_file.write(json.dumps(_project_metadata, indent=4))
_project_metadata_file.close()

print("\n✅ Update done", color=Color.GREEN)
