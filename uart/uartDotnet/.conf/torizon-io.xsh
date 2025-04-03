#!/usr/bin/env xonsh

# always return if a cmd fails
$RAISE_SUBPROC_ERROR = True
# use the xonsh environment to update the OS environment
$UPDATE_OS_ENVIRON = True
# Get the full log of error
$XONSH_SHOW_TRACEBACK = True

import os
import sys
import requests
import traceback
from typing import List
import torizon_io_api as torizon_cloud
from torizon_templates_utils.errors import Error,Error_Out,last_return_code
from torizon_templates_utils.colors import Color,BgColor,print

# fail fast
if "PLATFORM_CLIENT_ID" not in os.environ:
    Error_Out(
        "❌ Environment variable PLATFORM_CLIENT_ID not set",
        Error.ENOCONF
    )

if "PLATFORM_CLIENT_SECRET" not in os.environ:
    Error_Out(
        "❌ Environment variable PLATFORM_CLIENT_SECRET not set",
        Error.ENOCONF
    )


def __get_jon_oster_token():
    headers = {
        "Content-Type": "application/x-www-form-urlencoded"
    }

    payload = {
        "grant_type": "client_credentials",
        "client_id": os.environ.get("PLATFORM_CLIENT_ID"),
        "client_secret": os.environ.get("PLATFORM_CLIENT_SECRET")
    }

    response = requests.post(
        "https://kc.torizon.io/auth/realms/ota-users/protocol/openid-connect/token",
        headers=headers,
        data=payload
    )

    response.raise_for_status()

    # and we have the AWESOME Jon Oster Token 🦪
    return response.json().get("access_token")


_token = __get_jon_oster_token()
_cfg = torizon_cloud.Configuration(
    host = "https://app.torizon.io/api/v2beta",
    access_token = _token
)

# print(_token)

def __get_target_by_hash(_hash: str) -> torizon_cloud.Package:
    with torizon_cloud.ApiClient(_cfg) as api_client:
        _api = torizon_cloud.PackagesApi(api_client)
        _packages = _api.get_packages(
            limit=sys.maxsize,
            hashes=[_hash]
        )

        if _packages.total == 0:
            Error_Out(
                f"❌ Package with hash {_hash} not found",
                Error.ENOFOUND
            )

        return _packages.values.pop()


def __get_fleed_id(fleet_name: str):
    with torizon_cloud.ApiClient(_cfg) as api_client:
        _api = torizon_cloud.FleetsApi(api_client)
        _fleets = _api.get_fleets(
            limit=sys.maxsize
        )

        _fleet_id = None
        for fleet in _fleets.values:
            if fleet.name == fleet_name:
                _fleet_id = fleet.id
                break

        if _fleet_id is None:
            Error_Out(
                f"❌ Fleet {fleet_name} not found",
                Error.ENOFOUND
            )

        return _fleet_id


def __get_fleet_devices(fleet_name: str):
    _fleet_id = __get_fleed_id(fleet_name)

    with torizon_cloud.ApiClient(_cfg) as api_client:
        _api = torizon_cloud.FleetsApi(api_client)
        _devices = _api.get_fleets_fleetid_devices(
            fleet_id=_fleet_id,
            limit=sys.maxsize
        )

        return _devices.values


def __resolve_platform_metadata(
    packages: List[torizon_cloud.Package],
    package_name: str
):
    _latest_version = 0
    _hash = None

    _ret = {
        "hash": None,
        "version": None
    }

    for package in packages:
        if package.name == package_name:
            if int(package.version) > _latest_version:
                _latest_version = int(package.version)
                _hash = package.hashes["sha256"]

    _ret["hash"] = _hash
    _ret["version"] = _latest_version

    return _ret


def package_new(package_name: str, docker_compose_path: str):
    # check if the file exists
    if not os.path.exists(docker_compose_path):
        Error_Out(
            f"❌ File {docker_compose_path} not found",
            Error.ENOFOUND
        )

    # read the file
    _docker_compose_content = None
    _docker_compose_length = 0
    with open(docker_compose_path, "rb") as f:
        _docker_compose_content = f.read()
        _docker_compose_length = len(_docker_compose_content)

    # get the latest version and increment it
    _ver = package_latest_version(package_name)
    _ver = int(_ver) + 1

    # push it
    with torizon_cloud.ApiClient(_cfg) as api_client:
        _api = torizon_cloud.PackagesApi(api_client)
        _ret = _api.post_packages(
            name=package_name,
            version=str(_ver),
            target_format="BINARY",
            content_length=_docker_compose_length,
            body=_docker_compose_content,
            hardware_id=["docker-compose"]
        )

        print(_ret.hashes["sha256"])


def package_latest_hash(package_name: str):
    with torizon_cloud.ApiClient(_cfg) as api_client:
        _api = torizon_cloud.PackagesApi(api_client)
        _packages = _api.get_packages(
            limit=sys.maxsize,
            name_contains=package_name
        )

        _ret = __resolve_platform_metadata(
            _packages.values,
            package_name
        )

        if _ret["hash"] is None:
            Error_Out(
                f"❌ Package {package_name} not found",
                Error.ENOFOUND
            )

        print(_ret["hash"])
        return _ret["hash"]


def package_latest_version(package_name: str):
    with torizon_cloud.ApiClient(_cfg) as api_client:
        _api = torizon_cloud.PackagesApi(api_client)
        _packages = _api.get_packages(
            limit=sys.maxsize,
            name_contains=package_name
        )

        _ret = __resolve_platform_metadata(
            _packages.values,
            package_name
        )

        if _ret["version"] is None:
            Error_Out(
                f"❌ Package {package_name} not found",
                Error.ENOFOUND
            )

        print(_ret["version"])
        return _ret["version"]


def update_fleet_latest(package_name: str, fleet_name: str):
    _hash = package_latest_hash(package_name)
    _package = __get_target_by_hash(_hash)

    with torizon_cloud.ApiClient(_cfg) as api_client:
        _api = torizon_cloud.UpdatesApi(api_client)
        _update_rq = torizon_cloud.UpdateRequest()
        _update_rq.package_ids = [
            _package.package_id
        ]
        _update_rq.fleets = [
            __get_fleed_id(fleet_name)
        ]

        _ret = _api.post_updates(
            update_request=_update_rq
        )

        print(len(_ret.affected))


def _usage():
    print("")
    print("usage:")
    print("")
    print("    Push a new 'docker-compose' package:")
    print("        package new <package name> <docker-compose.yml path>")
    print("    Get the latest hash pushed by package name:")
    print("        package latest hash <package name>")
    print("    Get the latest version pushed by package name:")
    print("        package latest version <package name>")
    print("")
    print("    Update a fleet with a defined package:")
    print("        update fleet latest <package name> <fleet name>")
    print("")


# "main"
try:
    _cmd = sys.argv[1]
    _sub = sys.argv[2]
    _third = sys.argv[3]
except IndexError:
    _usage()
    Error_Out(
        "❌ Command not found",
        Error.ENOFOUND
    )

# used to make the skip of the arguments dynamic depending on the command
x = 3

try:
    # check if the function exists
    _func = globals()[f"{_cmd}_{_sub}"]
except:
    # possible a cmd with three verbs?
    try:
        x = 4
        _func = globals()[f"{_cmd}_{_sub}_{_third}"]
    except:
        # no so let's show the usage and exit
        _usage()
        Error_Out(
            f"❌ Command {_cmd} not found",
            Error.ENOFOUND
        )

try:
    # execute the function
    _func(*sys.argv[x:])
except Exception as e:
    traceback.print_exc()
    Error_Out(
        f"❌ {_cmd} {_sub} {_third} failed",
        Error.EFAIL
    )
