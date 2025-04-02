#!/usr/bin/env xonsh

# Copyright (c) 2025 Toradex
# SPDX-License-Identifier: MIT

##
# This script is used to open Windows side firewall.
# This is needed to have access to the services running on WSL outside Windows.
##

# use the xonsh environment to update the OS environment
$UPDATE_OS_ENVIRON = True
# Get the full log of error
$XONSH_SHOW_TRACEBACK = True
# this script should handle the subprocess errors
$RAISE_SUBPROC_ERROR = False

import os
import sys
from xonsh.procs.pipelines import CommandPipeline
from torizon_templates_utils.errors import Error,Error_Out,last_return_code
from torizon_templates_utils.colors import Color,BgColor,print

# this only make sense for WSL
if "WSL_DISTRO_NAME" in os.environ and os.environ["WSL_DISTRO_NAME"] != "":
    home = os.environ["HOME"]
    workspace = sys.argv[1]
    exc_remoteport: CommandPipeline = {}
    exc_remoteport = !(ifconfig eth0 | grep 'inet ')

    if exc_remoteport.returncode != 0:
        print(f"{exc_remoteport.err}\n")

        Error_Out(
            "❌ Error: Cannot get the IP address of the WSL",
            Error.EUNKNOWN
        )

    # Add here all the ports that you want to share with Windows
    ports = [
        8090,
        5002
    ]
    super_script: str = ""
    addr = "0.0.0.0"
    ports_str = ",".join([str(port) for port in ports])

    # remove firewall exception rules
    super_script += f"(Remove-NetFireWallRule -DisplayName ApolloX) -or $true ; "

    # adding exception rules for inbound and outbound rules
    super_script += f" New-NetFireWallRule -DisplayName ApolloX -Direction Outbound -LocalPort {ports_str} -Action Allow -Protocol TCP ; "
    super_script += f" New-NetFireWallRule -DisplayName ApolloX -Direction Inbound -LocalPort {ports_str} -Action Allow -Protocol TCP ; "

    # for each port we need to netsh interface
    for port in ports:
        super_script += f" (netsh interface portproxy delete v4tov4 listenport={port} listenaddress={addr}) -or $true ; "

    # FIXME:    this presumes that the xonsh is installed in the default location
    #           that is the user path .local/bin
    super_script += f" wsl -e /{home}/.local/bin/xonsh {workspace}/.vscode/tasks.xsh run run-docker-registry-wsl ; "

    for port in ports:
        super_script += f" (netsh interface portproxy add v4tov4 listenport={port} listenaddress={addr} connectport={port} connectaddress={exc_remoteport.out.split()[1]}) -or $true ; "

    # hmmm 😏
    super_script = super_script.strip()

    if "DEBUG_SHARED_PORTS" in os.environ:
        print(f"start-process powershell -verb runas -ArgumentList '-NoProfile -C \"{super_script} echo done\"'")
        # run it
        powershell.exe -NoProfile -C @(f"start-process powershell -verb runas -ArgumentList '-NoProfile -C \"{super_script} echo done; Read-Host ; \"'")
    else:
        # run it
        powershell.exe -NoProfile -C @(f"start-process powershell -verb runas -ArgumentList '-NoProfile -C \"{super_script} echo done\"'")
