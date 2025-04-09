#!/usr/bin/env xonsh

# Copyright (c) 2025 Toradex
# SPDX-License-Identifier: MIT

##
# This script is used to verify the sanity of development environment.
# It's check if the dependencies process are running.
##

# use the xonsh environment to update the OS environment
$UPDATE_OS_ENVIRON = True
# Get the full log of error
$XONSH_SHOW_TRACEBACK = True
# this script should handle the subprocess errors
$RAISE_SUBPROC_ERROR = False

import os
from xonsh.procs.pipelines import CommandPipeline
from torizon_templates_utils.errors import Error,Error_Out
from torizon_templates_utils.colors import Color,BgColor,print

$DOCKER_HOST = ""

if "GITLAB_CI" in os.environ:
    print("ℹ️ :: GITLAB_CI :: ℹ️")
    $DOCKER_HOST = "tcp://docker:2375"


_env_vars_settings = [
    "TORIZON_PSSWD",
    "TORIZON_LOGIN",
    "HOST_IP",
    "TORIZON_IP",
    "TORIZON_ARCH"
]

print("\n⚠️ VALIDATING ENVIRONMENT\n", color=Color.YELLOW)

# print the environment info for future debug
print(f"OS:         {os.uname().sysname}")
print(f"OS Version: {os.uname().release}")
print(f"OS Arch:    {os.uname().machine}")
print(f"Under WSL:  {os.getenv('WSL_DISTRO_NAME', 'false')}")

# print info about the vs code
_cmd_ret_reg: CommandPipeline
_cmd_ret_reg = !(code --version)

if _cmd_ret_reg.returncode == 0:
    print("VS Code:")
    print(f"{_cmd_ret_reg.out}")

    # get the extension version
    _cmd_ret_reg = !(code --list-extensions --show-versions | grep toradex.apollox-vscode)
    if _cmd_ret_reg.returncode == 0:
        print(f"TOR Extension:  {_cmd_ret_reg.out}")
    else:
        print("Extension:  Not installed")
else:
    print("VS Code:     None")


_missing_env_var_settings = False

# validate the env vars
for _env_var in _env_vars_settings:
    if _env_var not in os.environ:
        _missing_env_var_settings = True
        print(f"❌ {_env_var} is not set and is required", color=Color.RED)

if _missing_env_var_settings:
    print("\n⚠️  Did you forget to set default device?", color=Color.BLACK, bg_color=BgColor.BRIGTH_YELLOW)
    print("If you are facing issues even after setting default device, please remove the registered device and connect it again.\n")

    Error_Out(
        "❌ Missing settings.json properties, aborting\n",
        Error.ENOCONF
    )

# check if docker is running
_cmd_ret = !(docker info).returncode

if _cmd_ret != 0:
    print("⚠️  Please start Docker", color=Color.YELLOW)
    print("⚠️  Please make sure to reload the VS Code window after starting Docker", color=Color.YELLOW)

    Error_Out(
        "❌ Docker is not running!\n",
        Error.ENOCONF
    )

# check if the docker container with name registry is running
_cmd_ret_reg = !(docker ps -q -f name=registry)

if _cmd_ret_reg.out == "":
    print("⚠️  Please make sure to reload the VS Code Window if you had initialization errors")

    Error_Out(
        "❌ Docker container registry is not running!\n",
        Error.ENOCONF
    )

# check if the registry container is using the port 5002
_cmd_ret_reg = !(docker ps -f name=registry --format "{{.Ports}}")

if "5002->5000/tcp" not in _cmd_ret_reg.out:
    Error_Out(
        f"❌ Docker container registry is not using port 5002!\nMaybe there is some conflict with another container using the same name/port\n{_cmd_ret_reg.out}",
        Error.ENOCONF
    )

# check if the binfmt is enabled
_cmd_ret_reg = !(bash -c 'cat /proc/sys/fs/binfmt_misc/status')

if "enabled" not in _cmd_ret_reg.out:
    Error_Out(
        "❌ binfmt is not enabled!\n",
        Error.ENOCONF
    )


# check if the binfmt is registered
# FIXME: we check for arm64 and arm32 for now, if a new arch is introduced
# we need to add the check here
_cmd_ret_reg = !(bash -c 'ls /proc/sys/fs/binfmt_misc/qemu-aarch64')
if "qemu-aarch64" not in _cmd_ret_reg.out:
    Error_Out(
        "❌ binfmt for arm64 is not registered!\n",
        Error.ENOCONF
    )

_cmd_ret_reg = !(bash -c 'ls /proc/sys/fs/binfmt_misc/qemu-arm')
if "qemu-arm" not in _cmd_ret_reg.out:
    Error_Out(
        "❌ binfmt for arm32 is not registered!\n",
        Error.ENOCONF
    )


print("\n✅ Environment is valid!\n", color=Color.GREEN)
