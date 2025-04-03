#!/usr/bin/env xonsh

# Copyright (c) 2025 Toradex
# SPDX-License-Identifier: MIT

##
# This script is used to publish the container image to a registry
# and generate the final production docker-compose file.
##

# use the xonsh environment to update the OS environment
$UPDATE_OS_ENVIRON = True
# Get the full log of error
$XONSH_SHOW_TRACEBACK = True
# always return if a cmd fails
$RAISE_SUBPROC_ERROR = True

import os
import sys
import xonsh.environ as xenv
from torizon_templates_utils import debug
from torizon_templates_utils.args import get_optional_arg,get_arg_iterative
from torizon_templates_utils.errors import Error,Error_Out
from torizon_templates_utils.colors import Color,BgColor,print

## In case of fire break glass
# debug.vscode_prepare()
# debug.breakpoint()

$DOCKER_HOST = ""

if "GITLAB_CI" in os.environ:
    print("ℹ️ :: GITLAB_CI :: ℹ️")
    $DOCKER_HOST = "tcp://docker:2375"

_iterative = False
if "TASK_ITERATIVE" in os.environ:
    _iterative = True


# check env vars
if "DOCKER_PSSWD" not in os.environ:
    Error_Out(
        "❌ DOCKER_PSSWD not set",
        Error.ENOCONF
    )
else:
    _docker_psswd = os.environ["DOCKER_PSSWD"]

if "DOCKER_LOGIN" not in os.environ:
    Error_Out(
        "❌ DOCKER_LOGIN not set",
        Error.ENOCONF
    )
else:
    _docker_login = os.environ["DOCKER_LOGIN"]

if "DOCKER_REGISTRY" not in os.environ:
    Error_Out(
        "❌ DOCKER_REGISTRY not set",
        Error.ENOCONF
    )
else:
    _docker_registry = os.environ["DOCKER_REGISTRY"]


# For DockerHub it can be empty
if _docker_registry == "registry-1.docker.io":
    _docker_registry = ""

# xonsh env works in a very weird way, so we need to merge the envs
xos = xenv.Env(os.environ)
__xonsh__.env = xos

# Login
print(f"Performing container registry login ...")

echo @(_docker_psswd) | docker login --username @(_docker_login) --password-stdin @(_docker_registry)

print("✅ Logged in the container registry", color=Color.GREEN)
