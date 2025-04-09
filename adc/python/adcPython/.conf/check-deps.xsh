#!/usr/bin/env xonsh

# Copyright (c) 2025 Toradex
# SPDX-License-Identifier: MIT

##
# This script is used to check if the dependencies, Debian packages, or and
# scripts, are installed in the system.
# The list of deb dependencies are defined in the .conf/deps.json file.
##

# use the xonsh environment to update the OS environment
$UPDATE_OS_ENVIRON = True
# Get the full log of error
$XONSH_SHOW_TRACEBACK = True
# this script expect to have the error handling
$RAISE_SUBPROC_ERROR = False

import os
import sys
import json
import shutil
from pathlib import Path
from torizon_templates_utils.errors import Error,Error_Out,last_return_code
from torizon_templates_utils.colors import Color,BgColor,print

# clean the workspace set device default to use the local docker engine
$DOCKER_HOST = ""

if "GITLAB_CI" in os.environ:
    print("ℹ️ :: GITLAB_CI :: ℹ️")
    $DOCKER_HOST = "tcp://docker:2375"

# docker and docker-compose are special cases
# TODO: check also for podman or other runtime
if shutil.which("docker") is None:
    Error_Out(
        "❌ you need docker installed",
        Error.ENOCONF
    )

_docker_compose_ret = !(docker compose version).returncode
if _docker_compose_ret != 0:
    Error_Out(
        "❌ you need docker compose plugin installed",
        Error.ENOCONF
    )

# get the deps at .conf/deps.json file
_f_deps = open(".conf/deps.json", "r")
_deps = json.load(_f_deps)
_f_deps.close()

# ok, docker and docker compose exists so let's check the packages
_packages_to_install = []

print("Checking dependencies...\n", color=Color.YELLOW)
_deps_pckgs = _deps["packages"]

for package in _deps_pckgs:
    dpkg_check = !(dpkg -s @(package))

    if dpkg_check.returncode != 0:
        _packages_to_install.append(package)
        print(f"😵 {package} debian package dependency not installed", color=Color.RED)
    else:
        print(f"👍 {package} debian package dependency installed", color=Color.GREEN)

_scripts_to_install: list[str] = []

if "installDepsScripts" in _deps:
    _deps_scripts = _deps["installDepsScripts"]
else:
    _deps_scripts = []

for script in _deps_scripts:
    script_installed = False
    if Path(".conf/.depok").exists():
        with open(".conf/.depok", "r") as f:
            if script in f.read():
                script_installed = True

    if not script_installed:
        _scripts_to_install.append(script)
        print(f"😵 {script} dependency installation script not executed before for this project", color=Color.RED)
    else:
        print(f"👍 {script} dependency installation script executed before for this project", color=Color.GREEN)

# this is only for aesthetics, to separate the output
print("")

_packages_installed_ok = True
_scripts_installed_ok = True
_installed_scripts = []

# check if there are any packages to be installed or script to be executed
if len(_packages_to_install) == 0 and len(_scripts_to_install) == 0:
    print("✅ All packages already installed")
    print("✅ All installation scripts already executed")

    exit(0)
else:
    _packages_installed_ok = True
    _scripts_installed_ok = True

    if len(_packages_to_install) > 0:
        _packages_installed_ok = False

    if len(_scripts_to_install) > 0:
        _scripts_installed_ok = False

    _installConfirm = input("Try to install the missing debian packages and execute the missing installation scripts? <y/N>: ")

    if _installConfirm == 'y':
        if len(_packages_to_install) > 0:
            sudo apt-get update

            for package in _packages_to_install:
                sudo apt-get install -y @(package)

                if last_return_code() != 0:
                    Error_Out(
                        f"❌ Error installing {package}",
                        Error.ENOPKG
                    )

            _packages_installed_ok = True

        if len(_scripts_to_install) > 0:
            for script in _scripts_to_install:
                if script.endswith('.sh'):
                    chmod +x @(script)

                _installed_scripts.append(script)
                ./@(script)

                if last_return_code() != 0:
                    Error_Out(
                        f"❌ Error executing {script}",
                        Error.ENOPKG
                    )

            _scripts_installed_ok = True

if _packages_installed_ok == True and _scripts_installed_ok == True:
    _f_depok = None
    if not Path(".conf/.depok").exists():
        _f_depok = open(".conf/.depok", "w")
    else:
        _f_depok = open(".conf/.depok", "a")

    for script in _installed_scripts:
        _f_depok.write(f"{script}\n")
    _f_depok.close()

    # this is only for aesthetics, to separate the output
    print("")

    print("✅ All packages installed")
    print("✅ All installation scripts executed")
