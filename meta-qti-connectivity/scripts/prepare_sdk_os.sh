# Copyright (c) 2020-2021, The Linux Foundation. All rights reserved.

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

get_bsp_kernel_version()
{
    local BBFILE
    local DIR

    DIR=${WORK_SPACE}/sources/meta-fsl-bsp-release
    if [ -d ${WORK_SPACE}/sources/meta-imx ]; then
        DIR=${WORK_SPACE}/sources/meta-imx
    fi

    if [ ! -d ${DIR} ]; then
        echo "bsp dir not exist"
        return 1
    fi

    BBFILE="$(find ${DIR} -name "linux-imx_*.bb")"
    KERNELVERSION="$(echo ${BBFILE##*linux-imx_} | awk -F '.' 'BEGIN{OFS="."}{print $1,$2}')"
}


# === Setup BSP environment with Open Source Code === #

# Set default sripts and work space path
SCRIPT_FOLDER="$(dirname "${BASH_SOURCE}")"
WORK_SPACE=$(readlink -f ${SCRIPT_FOLDER}/../../..)

# Update BBLayers in bblayers.conf
echo 'BBLAYERS += " ${BSPDIR}/sources/meta-qti-connectivity "' >> conf/bblayers.conf
#Update BBMASK bbfiles
if [ -f "${WORK_SPACE}/sources/meta-qti-connectivity/conf/standalone-bbmask.conf" ]; then
    cat ${WORK_SPACE}/sources/meta-qti-connectivity/conf/standalone-bbmask.conf >> conf/bblayers.conf
fi
echo 'BBMASK.="|meta-qti-connectivity/recipes-kernel/linux-kernel/linux-imx_3.10.17.bbappend"' >> conf/bblayers.conf


sed -i -e 's/IMAGE_ROOTFS_SIZE ??= "65536"/IMAGE_ROOTFS_SIZE ??= "139264"/g' ../sources/poky/meta/conf/bitbake.conf

# Install common packages into image
echo  'MACHINE_ESSENTIAL_EXTRA_RRECOMMENDS += "pciutils"
MACHINE_ESSENTIAL_EXTRA_RRECOMMENDS += "iputils"
MACHINE_ESSENTIAL_EXTRA_RRECOMMENDS += "iw"
MACHINE_ESSENTIAL_EXTRA_RRECOMMENDS += "iperf2"
MACHINE_ESSENTIAL_EXTRA_RRECOMMENDS += "wpa-supplicant"
MACHINE_ESSENTIAL_EXTRA_RRECOMMENDS += "wlan-sigmadut"
MACHINE_ESSENTIAL_EXTRA_RRECOMMENDS += "wlan-config"
MACHINE_ESSENTIAL_EXTRA_RRECOMMENDS += "rng-tools"
MACHINE_ESSENTIAL_EXTRA_RRECOMMENDS += "bridge-utils"
' >> conf/local.conf

# Use PROJECTID for specific package, will optimize this part.
PROJECTID=$1
if [ -z "${PROJECTID}" ]; then
    echo "No PROJECT provided, use default PROJECT=QCA6574AULE221"
    PROJECTID="QCA6574AULE221"
fi

case ${PROJECTID} in
    "QCA6574AULE221")
        echo "MACHINE_ESSENTIAL_EXTRA_RRECOMMENDS += \"qcacld32-ll-rome\"" >> conf/local.conf
        ;;
    "QCA6584AULE201")
        echo "MACHINE_ESSENTIAL_EXTRA_RRECOMMENDS += \"qcacld20-hl-rome\"" >> conf/local.conf
        echo "MACHINE_ESSENTIAL_EXTRA_RRECOMMENDS += \"wlan-dsrc\"" >> conf/local.conf
        ;;
    "QCA6574AULE26")
        echo "MACHINE_ESSENTIAL_EXTRA_RRECOMMENDS += \"qcacld32-ll-rome\"" >> conf/local.conf
        echo "MACHINE_ESSENTIAL_EXTRA_RRECOMMENDS += \"qcacld32-ll-rome-cnss2\"" >> conf/local.conf
        ;;
    "QCA6696LE01")
        echo "MACHINE_ESSENTIAL_EXTRA_RRECOMMENDS += \"wlan-cnss-core\"" >> conf/local.conf
        echo "MACHINE_ESSENTIAL_EXTRA_RRECOMMENDS += \"qcacld32-ll-hasting\"" >> conf/local.conf
        ;;
esac

get_bsp_kernel_version
if [ -z "${KERNELVERSION}" ]; then
    echo "Can't find linux kernel bbfile, use 5.4 by default"
    KERNELVERSION="5.4"
fi

# wirless-tools only available with specific package
WIRELESS_TOOL="$(find ${WORK_SPACE}/sources -name "wireless-tools*.bb")"
if [ ! -z "${WIRELESS_TOOL}" ]; then
    echo "MACHINE_ESSENTIAL_EXTRA_RRECOMMENDS += \"wireless-tools\"" >> conf/local.conf
fi

echo "PROJECTID = \"$PROJECTID\"" >> conf/local.conf
echo "KERNELVERSION = \"$KERNELVERSION\"" >> conf/local.conf

echo "Please run following command to build image."
echo "bitbake core-image-minimal"
