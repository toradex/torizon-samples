

# Python 3 Console Template Specific Documentation


> ⚠️ **WARNING:**  This is just the documentation part specific of this template. **For the complete and general Torizon IDE documentation, check the [developer website documentation](https://developer.toradex.com/torizon/application-development/ide-extension/)** ⚠️

> ⚠️ **WARNING:**  Remember to maintain pip updated, with the command  `python -m pip install --upgrade pip`

All projects follow the pipeline of tasks described in the [common contributing documentation](https://github.com/toradex/vscode-torizon-templates/blob/bookworm/CONTRIBUTING.md#contributing-templates). However, each project has its own specificities in terms of technologies and methods used to compile, deploy, and debug the code. Therefore, each of them has their own specific tasks in the **tasks.json** file.

As Python is an interpreted language, it does not have a compile step.

The deployable package is then copied into the running debug container using **scp**, in the task named **deploy-torizon-\${architecture}**. This task contains the entire sequence of tasks executed by the pipeline and, therefore, is unique to each template.

Remote debugging is performed by running **debugpy** inside the running container on the device, in a task named **start-torizon-debug\${architecture}**, and then attaching to this running container, as described at [VSCode Python remote debugging](https://code.visualstudio.com/docs/python/debugging#_remote-script-debugging-with-ssh). For local debugging, the method used is the one described in the [VSCode documentation for Python Debugging](https://code.visualstudio.com/docs/python/debugging) is used. The tasks that perform the debugging are those present in the **launch.json** file.

The dependencies of the project that should be installed using **pip** should be defined on the **requirements-debug.txt** file (remote Debug image and local host dependencies) and on the **requirements-release.txt** file (remote Release image dependencies). 

The source code of the template is a simple Hello World (Hello Torizon, actually) in Python.

## Create a Python Virtual Environment

How to create a virtual environment on this template:

 - On the terminal, run the command:

      `python -m venv .venv --system-site-packages`

      If you do not want to use Python packages installed with **apt** on your host remove the **--system-site-packages** argument. In this case, you have to include **debugpy** on the **requirements-debug.txt** file.

 - Press **F1**
 - Select the command **Python: Select Interpreter**
 - Select the Python interpreter of your **.venv** 
 - If it doesn't select the Python from the venv, press F1 and select the command
 **Developer: Reload Window**)

To install a Python package on the venv (and also on the Debug image), put it 
on the **requirements-debug.txt** file (to install it on the Release image put it
on the **requirements.release.txt** file)

For more details, please watch the demonstration video below:

<video controls width="90%">
  <source src="https://raw.githubusercontent.com/toradex/vscode-torizon-templates-documentation/bookworm/common/python3/createEnvPython3-v2.mp4" type="video/mp4">
</video>

[](https://raw.githubusercontent.com/toradex/vscode-torizon-templates-documentation/bookworm/common/python3/createEnvPython3-v2.mp4)

[The line above renders the video on GitHub but not on VSCode ]:<>

[As of now, the supported types of videos and audios are described in https://github.com/microsoft/vscode-docs/blob/vnext/release-notes/v1_72.md#built-in-preview-for-some-audio-and-video-files ]:<>