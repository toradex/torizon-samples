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
_cmd_ret_reg: CommandPipeline
_cmd_ret_reg = !(docker ps -q -f name=registry)

if _cmd_ret_reg.out == "":
    print("⚠️  Please make sure to reload the VS Code Window if you had initialization errors")

    Error_Out(
        "❌ Docker container registry is not running!\n",
        Error.ENOCONF
    )

print("\n✅ Environment is valid!\n", color=Color.GREEN)
