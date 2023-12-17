# VPU Generic Dockerfile Sample

This sample demonstrates the use of VPU on i.MX8 devices for hardware
accelerated encoding and decoding. It performs the encoding and decoding
tests listed in the table below. The table also specifies what codec is
supported by each target.


|              | verdin-imx8mm | verdin-imx8mp | apalis-imx8 |
|--------------|---------------|---------------|-------------|
| H.264 Encode | ✅            | ✅            | ✅          |
| H.264 Decode | ✅            | ✅            | ✅          |
| H.265 Encode | ❌            | ✅            | ❌          |
| H.265 Decode | ✅            | ✅            | ✅          |
| VP8 Encode   | ✅            | ❌            | ❌          |
| VP8 Decode   | ✅            | ✅            | ✅          |
| VP9 Decode   | ✅            | ✅            | ❌          |

Please select the correct SoM(MACHINE) in the Dockerfile and docker-compose.yml
before running the test.
