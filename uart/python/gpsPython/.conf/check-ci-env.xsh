#!/usr/bin/env xonsh

# Copyright (c) 2025 Toradex
# SPDX-License-Identifier: MIT

##
# This script is used to verify the sanity of the CI environment.
# Is useful to show to the user the env that should be set
# and fail fast if something is missing.
##

# use the xonsh environment to update the OS environment
$UPDATE_OS_ENVIRON = True
# Get the full log of error
$XONSH_SHOW_TRACEBACK = True
# this script should handle the subprocess errors
$RAISE_SUBPROC_ERROR = False

import os
from torizon_templates_utils.errors import Error,Error_Out
from torizon_templates_utils.colors import Color,BgColor,print

_env_vars_settings = [
    "DOCKER_REGISTRY",
    "DOCKER_LOGIN",
    "DOCKER_TAG",
    "TCB_CLIENTID",
    "TCB_CLIENTSECRET",
    "TCB_PACKAGE",
    "TCB_FLEET"
]

_env_vars_secrets = [
    "DOCKER_PSSWD",
    "PLATFORM_CLIENT_ID",
    "PLATFORM_CLIENT_SECRET",
    "PLATFORM_CREDENTIALS"
]

_env_vars_file_path = [
    "TORIZON_CI_SETTINGS_FILE"
]

_env_vars_empty_allowed = [
    "DOCKER_REGISTRY"
]


def _goto_error():
    Error_Out(
        "\n❌ THESE ENV VARIABLES NEED TO BE SET IN YOUR CI/CD ENVIRONMENT. Aborting ...\n",
        Error.ENOCONF
    )


_missing_env_var_settings = False
_missing_env_var_secrets = False
_missing_env_var_file_path = False

# check if we are running in a GitLab CI or GitHub Actions environment
if "CI" in os.environ:
    # validate the env vars
    for _env_var in _env_vars_settings:
        if _env_var not in os.environ and _env_var not in _env_vars_empty_allowed:
            _missing_env_var_settings = True
            print(f"❌ {_env_var} is not set and is required", color=Color.RED)

    if _missing_env_var_settings:
        print(" ⚠️ Missing settings.json variables \n", color=Color.BLACK, bg_color=BgColor.BRIGTH_YELLOW)

    for _env_var in _env_vars_secrets:
        if _env_var not in os.environ and _env_var not in _env_vars_empty_allowed:
            _missing_env_var_secrets = True
            print(f"❌ {_env_var} is not set and is required", color=Color.RED)

    if _missing_env_var_secrets:
        print(" ⚠️ Missing protected environment variables. Be sure to protect them using secrets or other mechanism from your CI/CD service provider. \n", color=Color.BLACK, bg_color=BgColor.BRIGTH_YELLOW)

    for _env_var in _env_vars_file_path:
        if _env_var not in os.environ:
            _missing_env_var_file_path = True
            print(f"❌ {_env_var} is not set and is required", color=Color.RED)

        elif os.path.exists(os.environ[_env_var]) == False:
            _missing_env_var_file_path = True
            print(f"❌ No file at the path set in {_env_var} variable", color=Color.RED)

    if _missing_env_var_file_path:
        print(" ⚠️ Missing variable or with wrong file path \n", color=Color.BLACK, bg_color=BgColor.BRIGTH_YELLOW)

    if _missing_env_var_settings or _missing_env_var_secrets or _missing_env_var_file_path:
        _goto_error()
