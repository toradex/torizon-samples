#!/usr/bin/env xonsh

# Copyright (c) 2025 Toradex
# SPDX-License-Identifier: MIT

##
# This script interprets the tasks.json file and runs the tasks defined in it.
##

# use the xonsh environment to update the OS environment
$UPDATE_OS_ENVIRON = True
# Get the full log of error
$XONSH_SHOW_TRACEBACK = True
# always return if a cmd fails
$RAISE_SUBPROC_ERROR = True

import os
import sys
import traceback
import torizon_templates_utils.tasks as vscode_tasks
from torizon_templates_utils import debug
from torizon_templates_utils.errors import Error,Error_Out,last_return_code
from torizon_templates_utils.colors import Color,BgColor,print

## In case of fire break glass
# debug.vscode_prepare()
# debug.breakpoint()

_script_root = os.path.dirname(os.path.realpath(__file__))

def _usage(_fdp:  bool):
    print(
"""

Task Runner script
This script interprets .vscode/tasks.json file and runs the tasks defined in it.

Usage:

    tasks.xsh <command> [sub command*] [options*]

    list                list the tasks.json labels defined

        show-hidden     by default the list hides the tasks that are set hidden.
                        Use this option to show them

    desc [task_label]   describe the task [task_label]

    run [task_label]    run the task [task_label]

Environment variables:

    TASKS_CUSTOM_SETTINGS_JSON          custom settings file (default: settings.json)

    TASKS_DEBUG                         to enable verbose debug output

    TASKS_DISABLE_INTERACTIVE_INPUT     to disable interactive input

    TASKS_OVERRIDE_ENV                  enable the override of the environment variables
                                        values with the ones set in the tasks.json file

    DOCKER_PSSWD                        to set the docker password in CI/CD pipelines


Copyrigth (c) 2025 Toradex and contributors
"""
    )

    if not _fdp:
        print("")
        print(
            "⚠️ :: WARNING :: ⚠️",
            color=Color.YELLOW
        )
        print(
            "This script depends on tasks.json and settings.json",
            color=Color.YELLOW
        )
        print(
            "These files need to be in the same directory .vscode/ as this script.",
            color=Color.YELLOW
        )
        print("")

        Error_Out(
            ".vscode/tasks.json or .vscode/settings.json not found",
            Error.ENOFOUND
        )
    else:
        Error_Out(
            "Invalid arguments",
            Error.EUSER
        )


# this is for vs code debug that sends the args as a unique string
if len(sys.argv) == 2 and " " in sys.argv[1]:
    _tmp = sys.argv
    sys.argv = [_tmp[0]]
    sys.argv.extend(_tmp[1].split())
elif len(sys.argv) < 2:
    _usage(True)

# if we are in the .vscode dir we can set the root to the parent dir
if os.path.basename(_script_root) == ".vscode":
    _script_root = os.path.dirname(_script_root)

# the cwd is the _script_root
os.chdir(_script_root)

## __main__
# aesthetic
print("")

_tasks_settings_json = "settings.json"
if "TASKS_CUSTOM_SETTINGS_JSON" in os.environ:
    print("ℹ️ :: CUSTOM SETTINGS :: ℹ️")
    print(f"Using custom settings file: {os.environ['TASKS_CUSTOM_SETTINGS_JSON']}")
    _tasks_settings_json = os.environ["TASKS_CUSTOM_SETTINGS_JSON"]


try:
    # setting the workspaceFolder
    os.environ["workspaceFolder"] = _script_root
    # setting the workspaceFolderBasename
    os.environ["workspaceFolderBasename"] = os.path.basename(_script_root)

    # parse the tasks.json file
    _settings = vscode_tasks.get_settings_json(_script_root, _tasks_settings_json)
    _tasks = vscode_tasks.get_tasks_json(_script_root)
    _task_runner = vscode_tasks.TaskRunner(_tasks.tasks, _tasks.inputs, _settings)

    if len(sys.argv) < 2 or len(sys.argv) > 3:
        _usage(True)

    if len(sys.argv) == 2:
        if sys.argv[1] == "list":
            _task_runner.list_labels(no_index=True)
        elif sys.argv[1] == "help":
            _usage(True)
        else:
            _usage(True)

    elif len(sys.argv) == 3:
        if sys.argv[1] == "list" and sys.argv[2] == "show-hidden":
            _task_runner.list_labels(no_index=True, show_hidden=True)
        elif sys.argv[1] == "desc":
            _task_runner.desc_task(sys.argv[2])
        elif sys.argv[1] == "run":
            _task_runner.run_task(sys.argv[2])
        else:
            _usage(True)

    # aesthetic
    print("")

except Exception as e:
    if "TASKS_DEBUG" in os.environ:
        traceback.print_exc()

    if isinstance(e, ReferenceError):
        Error_Out(
            f"❌ Error: {repr(e)}",
            Error.ENOFOUND
        )
    elif isinstance(e, ValueError):
        Error_Out(
            f"❌ Error: {repr(e)}",
            Error.EUSER
        )
    elif isinstance(e, RuntimeError):
        Error_Out(
            f"❌ Error: {repr(e)}",
            Error.ETASKEXEC
        )
    else:
        Error_Out(
            f"❌ Error: {repr(e)}",
            Error.EUNKNOWN
        )
