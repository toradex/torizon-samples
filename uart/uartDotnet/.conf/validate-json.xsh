#!/usr/bin/env xonsh

# Copyright (c) 2025 Toradex
# SPDX-License-Identifier: MIT

##
# This script is used to configure a Torizon device to be ready for development.
# WARNING:
# This script is not meant to be run manually. It's make part of the internal
# validation process from CI/CD.
##

# use the xonsh environment to update the OS environment
$UPDATE_OS_ENVIRON = True
# Get the full log of error
$XONSH_SHOW_TRACEBACK = True
# always return if a cmd fails
$RAISE_SUBPROC_ERROR = True

import os
import sys
import tty
import json


$SCRIPT_PATH = os.path.dirname(os.path.realpath(__file__))

# 1. go to the apollox directory
# 2. check recursively for all the .json files
# 3. check if the files are valid json

# 1.
cd $SCRIPT_PATH/..

# 2.
_files = !(find . -name "*.json")
_files_list = [os.path.abspath(f) for f in _files.out.split()]

_has_invalid_files = False

_allow_list = [
    "vscode-torizon-templates/.vscode/settings.json",
    "vscode-torizon-templates/scripts/.vscode/tasks.json",
    "vscode-torizon-templates/scripts/.vscode/launch.json"
]

for _file in _files_list:
    # 3.
    try:
        _can_skip = False
        for _allow in _allow_list:
            if _allow in _file:
                _can_skip = True
                break

        if _can_skip:
            continue

        with open(_file, "r") as f:
            json.load(f)
    except json.JSONDecodeError as e:
        _has_invalid_files = True
        print(f"❌ :: {_file}:{e.lineno} :: ❌")
        print(f"\t {e}")
        print("")
        continue
    except Exception as e:
        _has_invalid_files = True
        print(f"❌ :: {_file} :: ❌")
        print(f"\t {e}")
        print("")
        continue

if _has_invalid_files:
    sys.exit(1)
else:
    print("✅ :: All files are valid JSON :: ✅")
    sys.exit(0)
