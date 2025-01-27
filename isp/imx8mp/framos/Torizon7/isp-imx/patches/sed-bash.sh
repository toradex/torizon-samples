#!/bin/sh

sed -i 's|^#!/bin/sh|#!/bin/bash|' /downloads/isp-imx-${ISP_IMX_VERSION}/build_output_release_v4l2/opt/imx8-isp/bin/start_isp.sh
sed -i 's|^#!/bin/sh|#!/bin/bash|' /downloads/isp-imx-${ISP_IMX_VERSION}/build_output_release_v4l2/opt/imx8-isp/bin/run.sh