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
import json
import yaml
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

# these are needed
_compo_file_path = get_arg_iterative(
    index=1,
    prompt="docker-compose.yml root file path: ",
    default_type=str,
    default=None,
    iterative=_iterative
)
_tag = get_arg_iterative(
    index=2,
    prompt="Image tag: ",
    default_type=str,
    default=None,
    iterative=_iterative
)
_image_name = get_arg_iterative(
    index=3,
    prompt="Image name: ",
    default_type=str,
    default=None,
    iterative=_iterative
)

# optional
_gpu = get_optional_arg(4, "")

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


if "TORIZON_ARCH" not in os.environ:
    Error_Out(
        "❌ TORIZON_ARCH not set",
        Error.ENOCONF
    )
else:
    _torizon_arch = os.environ["TORIZON_ARCH"]

if "APP_ROOT" not in os.environ:
    Error_Out(
        "❌ APP_ROOT not set",
        Error.ENOCONF
    )
else:
    _app_root = os.environ["APP_ROOT"]

_tasks_settings_json = "settings.json"
if "TASKS_CUSTOM_SETTINGS_JSON" in os.environ:
    _tasks_settings_json = os.environ["TASKS_CUSTOM_SETTINGS_JSON"]
    print("ℹ️ :: CUSTOM SETTINGS :: ℹ️")
    print(f"Using custom settings file: {_tasks_settings_json}")

# fix up the torizon arch
if _torizon_arch == "aarch64":
    _torizon_arch = "arm64"
elif _torizon_arch == "armv7":
    _torizon_arch = "arm"
elif _torizon_arch == "arm":
    _torizon_arch = "arm"
elif _torizon_arch == "armhf":
    _torizon_arch = "arm"
elif _torizon_arch == "x86_64":
    _torizon_arch = "amd64"
elif _torizon_arch == "riscv":
    _torizon_arch = "riscv64"

_image_arch = _torizon_arch

# read the settings.json file
_obj_settings = {}

try:
    _settings_path = os.path.join(_compo_file_path, ".vscode", _tasks_settings_json)
    with open(_settings_path, "r") as f:
        _settings = json.load(f)
except FileNotFoundError as fex:
    Error_Out(
        f"❌ Error: {fex.strerror} :: {fex.filename} :: {_settings_path}",
        Error.ENOFOUND
    )

_local_registry = _settings["host_ip"]

# set env
os.environ["LOCAL_REGISTRY"] = f"{_local_registry}:5002"
os.environ["TAG"] = _tag

if _docker_registry == "registry-1.docker.io" or _docker_registry == "":
    os.environ["DOCKER_LOGIN"] = _docker_login
else:
    os.environ["DOCKER_LOGIN"] = f"{_docker_registry}/{_docker_login}"

# make sure to have binfmt
xonsh ./.vscode/tasks.xsh run run-torizon-binfmt

# start to build the image
cd @(_compo_file_path)
print(f"Rebuilding {os.environ['DOCKER_LOGIN']}/{_image_name}:{_tag} ...")

# xonsh env works in a very weird way, so we need to merge the envs
xos = xenv.Env(os.environ)
__xonsh__.env = xos

# run the build-container-torizon-release-<arch> but without override the env
$TASKS_OVERRIDE_ENV = False
xonsh ./.vscode/tasks.xsh run @(f"build-container-torizon-release-{_image_arch}")

# back to the origin
cd -
print("✅ Image rebuild and tagged", color=Color.GREEN)

# push it
print(f"Pushing {os.environ['DOCKER_LOGIN']}/{_image_name}:{_tag} ...")

xonsh ./.vscode/tasks.xsh run docker-login

docker push @(f"{os.environ['DOCKER_LOGIN']}/{_image_name}:{_tag}")

print("✅ Image pushed", color=Color.GREEN)

# generate the production docker-compose file
print("Generating production docker-compose file ...")
print("Reading the docker-compose file ...")

_compose_obj = {}

try:
    _compose_file_path_full = os.path.join(_compo_file_path, "docker-compose.yml")
    with open(_compose_file_path_full, "r") as f:
        _compose_obj = yaml.safe_load(f)
except FileNotFoundError as fex:
    Error_Out(
        f"❌ Error: {fex.strerror} :: {fex.filename}",
        Error.ENOFOUND
    )

print("✅ docker-compose.yml loaded", color=Color.GREEN)

# cleaning
print("Cleaning services ...")

_compose_services = _compose_obj["services"]
_remove_keys = []
_prod_keys = []

for service in _compose_services:
    _service = _compose_services[service]

    if "debug" in service:
        _remove_keys.append(service)
    else:
        _prod_keys.append(service)


# remove the debug services
for key in _remove_keys:
    _compose_services.pop(key)

print("✅ Services cleaned", color=Color.GREEN)

# replace the env  variables
print("Replacing variables ...")

for service in _prod_keys:
    _service = _compose_services[service]

    if "build" in _service:
        _service.pop("build")

    _service["image"] = _service["image"].replace("${DOCKER_LOGIN}", os.environ["DOCKER_LOGIN"])
    _service["image"] = _service["image"].replace("${TAG}", _tag)
    _service["image"] = _service["image"].replace("${GPU}", _gpu)

print("✅ Variables replaced", color=Color.GREEN)

# write the object back to a file
_f_ref = open(f"{_compo_file_path}/docker-compose.prod.yml", "w")
yaml.dump(
    _compose_obj,
    _f_ref,
    indent=2
)
_f_ref.close()

print("✅ docker-compose.prod.yml generated", color=Color.GREEN)
