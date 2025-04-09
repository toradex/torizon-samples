

# Python 3 Console Template Specific Documentation


> ⚠️ **WARNING:**  This is just the documentation part specific of this template. **For the complete and general Torizon IDE documentation, check the [developer website documentation](https://developer.toradex.com/torizon/application-development/ide-extension/)** ⚠️

> ⚠️ **WARNING:**  Remember to maintain pip updated, with the command  `python -m pip install --upgrade pip`

All projects follow the pipeline of tasks described in the [common contributing documentation](https://github.com/toradex/vscode-torizon-templates/blob/bookworm/CONTRIBUTING.md#contributing-templates). However, each project has its own specificities in terms of technologies and methods used to compile, deploy, and debug the code. Therefore, each of them has their own specific tasks in the **tasks.json** file.

As Python is an interpreted language, it does not have a compile step.

The deployable package is then copied into the running debug container using **scp**, in the task named **deploy-torizon-\${architecture}**. This task contains the entire sequence of tasks executed by the pipeline and, therefore, is unique to each template.

Remote debugging is performed by running **debugpy** inside the running container on the device, in a task named **start-torizon-debug\${architecture}**, and then attaching to this running container, as described at [VSCode Python remote debugging](https://code.visualstudio.com/docs/python/debugging#_remote-script-debugging-with-ssh). For local debugging, the method used is the one described in the [VSCode documentation for Python Debugging](https://code.visualstudio.com/docs/python/debugging) is used. The tasks that perform the debugging are those present in the **launch.json** file.

The python packages of the project that should be installed using **pip** should be defined on:
- **requirements-local.txt** file for host/local debugging packages
- **requirements-debug.txt** file for remote debugging image package (installed on **Dockerfile.debug** file)
- **requirements-release.txt** file for production (release) image packages (installed on **Dockerfile** file)

The source code of the template is a simple Hello World (Hello Torizon, actually) in Python.

## Create and Modify the Python Virtual Environment

> ⚠️ **WARNING:** When the template workspace opens in VSCode, a task called **create-venv** which creates a virtual environment at **.venv** is executed (also the **host-install-pip-requirements** is executed in sequence). However, if you can recreate and modify the Python virtual environment by following the steps described below. ⚠️

How to recreate and modify the Python virtual environment on this template:

 - Remove the **.venv** folder
 - If you want to modify the command that creates the virtual env (for example to add the **--system-site-packages** argument or even create a **.conda** environment instead of **.venv**), you can do so by modifying the **create-venv** task at the **.vscode/tasks.json** file
 - Click on the **create-venv** task on the **TASK RUNNER** tab
 -  If you made changes to the **.venv** path, update the **python.defaultInterpreterPath** configuration at **.vscode/settings.json**

 > If some problem occurs after updating the virtual env, try reloading the VSCode Windows (there is a **vscode-reload-window** task on the **TASK RUNNER** tab) to see if the problem persists
