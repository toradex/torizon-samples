#!/usr/bin/env xonsh

# Copyright (c) 2025 Toradex
# SPDX-License-Identifier: MIT

##
# This script run a container if a container with the same name is not
# already running.
##

# use the xonsh environment to update the OS environment
$UPDATE_OS_ENVIRON = True
# Get the full log of error
$XONSH_SHOW_TRACEBACK = True
# this script should handle the subprocess errors
$RAISE_SUBPROC_ERROR = False

# clean the workspace set device default to use the local docker engine
$DOCKER_HOST = ""

import os
import argparse
from xonsh.procs.pipelines import CommandPipeline
from torizon_templates_utils.errors import Error,Error_Out,last_return_code
from torizon_templates_utils.colors import Color,BgColor,print

arg_parser = argparse.ArgumentParser()

arg_parser.add_argument(
    "--container-runtime",
    type=str,
    required=True,
    help="The container runtime to use"
)

arg_parser.add_argument(
    "--run-arguments",
    type=str,
    required=True,
    help="The arguments to run the container"
)

arg_parser.add_argument(
    "--container-name",
    type=str,
    required=True,
    help="The name of the container"
)

args = arg_parser.parse_args()
container_runtime = args.container_runtime.replace("\"", "")
run_arguments = args.run_arguments.replace("\"", "")
run_arguments = run_arguments.replace("'", "")
container_name = args.container_name.replace("\"", "")

if "GITLAB_CI" in os.environ:
    print("ℹ️ :: GITLAB_CI :: ℹ️")
    $DOCKER_HOST = "tcp://docker:2375"

# debug
print(f"Container Runtime: {container_runtime}")
print(f"Run Arguments: {run_arguments}")
print(f"Container Name: {container_name}")

# this is the way to attribute a type to a variable using xonsh
# only receiving the object from !() is not enough for pylsp
_exec_container_info: CommandPipeline = {}
_exec_container_info = !(@(container_runtime) container inspect @(container_name))

if _exec_container_info.returncode == 0:
    print(f"Container {container_name} already created")
    print(f"Checking if container {container_name} is running...")
else:
    if "No such container" in _exec_container_info.err:
        print("Container does not exists. Starting ...")
        print(f"Cmd: {container_runtime} run --name {container_name} {run_arguments}")
        evalx(f"{container_runtime} run --name {container_name} {run_arguments}")
