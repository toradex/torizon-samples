# .NET 8 C# Console Template Specific Documentation


> ⚠️ **WARNING:**  This is just the documentation part specific of this template. **For the complete and general Torizon IDE documentation, check the [developer website documentation](https://developer.toradex.com/torizon/application-development/ide-extension/)** ⚠️

All projects follow the pipeline of tasks described in the [common contributing documentation](https://github.com/toradex/vscode-torizon-templates/blob/bookworm/CONTRIBUTING.md#contributing-templates). However, each project has its own specificities in terms of technologies and methods used to compile, deploy, and debug the code. Therefore, each of them has their own specific tasks in the **tasks.json** file.

This .NET C# console template uses **dotnet publish** CLI command to compile the source code and create a deployable package, with tasks named **publish-torizon-\${architecture}**. However, for local debugging it is not necessary to create a deployable package so just the **dotnet build** task is enough in this case(please note that the **preLaunchTask** of local debug is **build-torizon-local** and not **publish-torizon-local**, but the publish local task is there just for you to use if for any specific reason you need this local publish).

For .NET templates it is important to point out that they do not use the torizon base containers (torizon/debian, torizon/wayland-base, torizon/wayland-base-vivante, etc.). Instead, they use custom **dotnet**, **aspdotnet** and **dotnet-uno** containers, which are based on the base containers but also contain the appropriate .NET runtime (and debugger for debug images) and some necessary dependencies to execute the code. Therefore, the **--no-self-contained** argument can be passed to the **dotnet publish** command to not compile and ship also the .NET runtime to the remote container.

The deployable package is then copied into the running debug container using **scp**, in the task named **deploy-torizon-\${architecture}**. This task contains the entire sequence of tasks executed by the pipeline and, therefore, is unique to each template.

Finally, remote debugging is performed by attaching to the Visual Studio Debugger (vsdbg) on the running container on the device using a [VSCode feature called Pipe Transport](https://code.visualstudio.com/docs/cpp/pipe-transport). For local debugging, the method used is the one described in the [VSCode documentation for .NET Debugging](https://learn.microsoft.com/en-us/dotnet/core/tutorials/debugging-with-visual-studio-code?pivots=dotnet-8-0) is used. The tasks that perform the debugging are those present in the **launch.json** file.

The source code of the template is inspired by the one created following the [instructions from the VSCode .NET app creation](https://learn.microsoft.com/en-us/dotnet/core/tutorials/debugging-with-visual-studio-code?pivots=dotnet-8-0) (without including the **obj** folder and without passing the **--use-program-main** argument).
