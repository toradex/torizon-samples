# Generic Dockerfile Template Specific Documentation

In general, all projects follow the pipeline of tasks described in the [common contributing documentation](https://github.com/toradex/vscode-torizon-templates/blob/bookworm/CONTRIBUTING.md#contributing-templates). However, this is a special kind of generic template that is not made for any specific language and therefore does not have any debugging tasks, just the release ones (which uses the **Dockerfile** instead of the **Dockerfile.debug**).

Scenarios that this generic Dockerfile template can be useful include:

- A container that just executes bash scripts
- Customizing the weston initialization script (**weston.ini**)
- Using a toolbox container to perform some development task on the board. For example, using a container with gcc or g++ to quickly compile and execute a small code, which can be useful on specific hardware testing scenarios during development.

## Using This Template

As described before, this template has no debugging tasks. So, to use it, instead of pressing `F5`, to build the container and run it on the board, use the `run-container-torizon-release-<arch>` task. 

To run this task, click on the `Explorer` icon on the VSCode Activity bar (first icon on the vertical bar on the left of the VSCode screen), open the `TASK RUNNER` tab and then click on the task.

## Keep The Container Up and Attach To It's Shell

To keep the container running indefinely, change the `CMD []` line in the **Dockerfile** to the one below:

`CMD ["sleep", "infinity"]`

And then, to attach to the shell of this container, click on the Docker extension icon on the activity bar (vertical bar on the left here on VCode), right-click on this container, and then select the **Attach Shell** option.


An important side note is that every time you run the `run-container-torizon-release-<arch>` task it creates a new container. So, if you want to keep for example the history of shell commands that you performed and some configuration change that you made, start the container through the Docker extension. 
To do it, perform the same steps as for **Attach Shell**, but select the **Start** option instead. After that you can  **Attach Shell** if you want, in the same way as described defore.
