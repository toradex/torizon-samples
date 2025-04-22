#!/usr/bin/env xonsh

# Copyright (c) 2025 Toradex
# SPDX-License-Identifier: MIT

##
#  This script sets the variables from a custom settings json file  on the
#  CI/CD pipeline, by passing the path of this file at the
#  TORIZON_CI_SETTINGS_FILE env var.
#   By default, the default value is the normal settings.json file, which is
#   at .vscode/settings.json.
##

# use the xonsh environment to update the OS environment
$UPDATE_OS_ENVIRON = True
# Get the full log of error
$XONSH_SHOW_TRACEBACK = True
# always return if a cmd fails
$RAISE_SUBPROC_ERROR = True

import os
import json
from torizon_templates_utils.errors import Error,Error_Out
from torizon_templates_utils.colors import Color,BgColor,print


def _goto_error(file_path):
    Error_Out(
        f"\n❌ Problem in {file_path} file ...\n",
        Error.ENOCONF
    )

file_path = os.environ["TORIZON_CI_SETTINGS_FILE"]

with open(file_path) as f:

    settings = json.load(f)

    if "torizon_arch" not in settings or settings["torizon_arch"] == "":
        print(f"❌ torizon_arch not present or empty in {file_path} file", color=Color.RED)
        _goto_error(file_path)

    os.environ["TORIZON_ARCH"] = settings["torizon_arch"]
    if os.environ["TORIZON_ARCH"] == "aarch64":
        os.environ["TORIZON_ARCH"] = "arm64"
    if os.environ["TORIZON_ARCH"] == "armhf":
        os.environ["TORIZON_ARCH"] = "arm"

    if "GITLAB_CI" in os.environ:
            with open(os.environ["GITLAB_ENV"], "a") as f:
                f.write(f"TORIZON_ARCH={os.environ['TORIZON_ARCH']}\n")
    elif "CI" in os.environ:
        with open(os.environ["GITHUB_ENV"], "a") as f:
            f.write(f"TORIZON_ARCH={os.environ['TORIZON_ARCH']}\n")
