# Copyright (c) 2018, The Linux Foundation. All rights reserved.

# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#    * Redistributions of source code must retain the above copyright
#      notice, this list of conditions and the following disclaimer.
#    * Redistributions in binary form must reproduce the above
#      copyright notice, this list of conditions and the following
#      disclaimer in the documentation and/or other materials provided
#      with the distribution.
#    * Neither the name of The Linux Foundation nor the names of its
#      contributors may be used to endorse or promote products derived
#      from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT
# ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS
# BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
# BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
# OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
# IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#!/bin/sh
SCRIPT_FOLDER="$(dirname "${BASH_SOURCE}")"
META_CONN_DIR="$(readlink -f ${SCRIPT_FOLDER}/..)"
AGL_WORK_SPACE="$(readlink -f ${SCRIPT_FOLDER}/../../..)"
BBLAYERS_CONFIG="conf/bblayers.conf"
COMMON_IMAGE_FILE="../meta-qti-bsp/recipes-products/images/common-auto-image.inc"
TARGET_IMAGE_FILE="../meta-qti-bsp/recipes-products/images/8x96auto/8x96auto-image.inc"
KERNEL_APPEND_FILE="${META_CONN_DIR}/recipes-kernel/linux-kernel/linux-msm-4.4_git.bbappend"

if [ ! -f ${BBLAYERS_CONFIG} ]; then
    echo "Can't find file ${BBLAYERS_CONFIG}"
    exit 1
fi

if grep -q 'meta-qti-connectivity' ${BBLAYERS_CONFIG}; then
    echo "BBLAYERS for open-source already updated."
    exit 0
fi

#Update BBLayers and BBMASK.
cat >> ${BBLAYERS_CONFIG} <<EOF

#### Setup For AGL Dual WiFi #######
## QTI Connectivity META Layers support
export BSPDIR = "\${WORKSPACE}"
BBLAYERS += "${AGL_WORK_SPACE}/sources/meta-qti-connectivity"

## BBMASK for Dual WiFi Setup
BBMASK.="|meta-qti-bsp/recipes-connectivity/wpa-supplicant/wpa-supplicant_2.5.bbappend"
BBMASK.="|meta-qti-bsp/recipes-connectivity/hostap-daemon/hostapd_2.5.bbappend"
BBMASK.="|meta-qti-bsp/recipes-connectivity/sigma-dut/sigma-dut_git.bb"
BBMASK.="|meta-qti-connectivity/recipes-products/images/standalone-auto-image.bb"
BBMASK.="|meta-qti-connectivity/recipes-products/images/standalone-imx8auto-image.bb"
BBMASK.="|meta-qti-connectivity/recipes-products/images/automotive-connx-image.bb"
BBMASK.="|meta-qti-connectivity/recipes-connectivity/wlan-driver/qcacld-hl_2.0.bb"
BBMASK.="|meta-qti-connectivity/recipes-connectivity/wlan-driver/qcacld-hl-tfl_2.0.bb"
BBMASK.="|meta-qti-connectivity/recipes-connectivity/wlan-driver/qcacld-ll_2.0.bb"
BBMASK.="|meta-qti-connectivity/recipes-connectivity/wlan-driver/qcacld-hl-rome_2.0.bb"
BBMASK.="|meta-qti-connectivity/recipes-core/systemd/systemd_%.bbappend"
BBMASK.="|meta-qti-connectivity/recipes-kernel/linux-kernel/linux-imx_%.bbappend"
BBMASK.="|meta-qti-connectivity/recipes-kernel/linux-kernel/linux-imx_3.10.17.bbappend"
BBMASK.="|meta-qti-connectivity/recipes-kernel/linux-libc-headers/linux-libc-headers_%.bbappend"
BBMASK.="|meta-qti-connectivity/recipes-kernel/lk/lk_git.bbappend"
EOF

if [ ! -f ${COMMON_IMAGE_FILE} ]; then
    echo "Can't find file ${COMMON_IMAGE_FILE}"
    exit 1
fi

if [ ! -f ${TARGET_IMAGE_FILE} ]; then
    echo "Can't find file ${COMMON_IMAGE_FILE}"
    exit 1
fi

#Update IMAGE_INSTALL_remove
sed -i -e 's/iperf //g' ${TARGET_IMAGE_FILE}
sed -i -e 's/wpa-supplicant qcacld-utils qcacld hostapd sigma-dut //g' ${TARGET_IMAGE_FILE}
sed -i -e 's/ ath6kl-utils ftm//g' ${TARGET_IMAGE_FILE}

cat >> ${COMMON_IMAGE_FILE} <<EOF

### Image Setup for AGL Dual WiFi ###
IMAGE_INSTALL_remove += "qcacld"
IMAGE_INSTALL_remove += "hostapd"
IMAGE_INSTALL_remove += "sigma-dut"

IMAGE_INSTALL += "qcacld-ll"
IMAGE_INSTALL += "qcacld-ll-dualwifi"
IMAGE_INSTALL += "wlan-config"
IMAGE_INSTALL += "wlan-sigmadut"
IMAGE_INSTALL += "pciutils"
EOF

if [ ! -f ${KERNEL_APPEND_FILE} ]; then
    echo "Can't find file ${KERNEL_APPEND_FILE}"
    exit 1
fi

sed -i -e '/KERNEL_SRC/d' ${KERNEL_APPEND_FILE}
sed -i -e '/SRC_BRANCH/d' ${KERNEL_APPEND_FILE}
sed -i -e '/SRC_TAG/d' ${KERNEL_APPEND_FILE}
sed -i -e '/^S =/d' ${KERNEL_APPEND_FILE}
