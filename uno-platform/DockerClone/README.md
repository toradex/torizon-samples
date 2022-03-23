# DEPRECATED

This sample is not maintained anymore. Instead, use the following resource:

We have promoted the Torizon VS Code integration to stable. Start a Uno Platform
project following instructions from
[.NET Uno Development and Debugging on Torizon Using Visual Studio Code](https://developer.toradex.com/knowledge-base/net-uno-development-and-debugging-on-torizon-using-visual-studio-code).

# Docker Desktop Clone (Using Uno)

## How to Run

Prerequisites:
- Toradex board with Latest Torizon
	- Tested devices:
		- Colibri iMX7D
		- Colibri iMX6DL
		- Apalis iMX6Q
		- Apalis iMX8QM
		- Verdin iMX8MM
- 1024x600 minimum resolution screen
	- For `am32v7` devices do not use resolutions above 1138x640
	- For `arm64v8` devices do not use resolutions above 1920x1080
- Input device
	- Mouse (preferred)
	- Touch screen

### arm64v8 Devices

For run the demo download the `docker-compose-arm64v8.yml` from this repository on the board and execute:

```bash
mv docker-compose-arm64v8.yml docker-compose.yml
docker-compose up
```

### arm32v7 Devices

For run the demo download the `docker-compose-arm32v7.yml` from this repository on the board and execute:

```bash
mv docker-compose-arm32v7.yml docker-compose.yml
docker-compose up
```

This will go up two containers one with the graphic composer `Weston` and the other with the demo app the `DockerClone`.

### VGA Forcing Resolutions

In the `Colibri iMX7` and `Colibri iMX6`, when using VGA, for a good experience you will have to set the resolution to be used. On the u-boot command line execute:

- iMX7D
```bash
env set tdxargs video=Unknown-1:1024x600
env save
boot
```

- iMX6DL
```bash
env set tdxargs video=DPI-1:1024x600
env save
boot
```

## Notes

⚠️ Torizon IDE Extensions do not have support for Uno Platform projects at moment, the support is under development. Use the code from this repository as a common .NET 5 project.

⚠️ To build the Docker images check the `ARG IMAGE_ARCH` on the `Dockerfile`
