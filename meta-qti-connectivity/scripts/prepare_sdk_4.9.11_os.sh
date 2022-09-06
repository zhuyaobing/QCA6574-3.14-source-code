# Copyright (c) 2018-2019, The Linux Foundation. All rights reserved.

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

echo 'BBLAYERS += " ${BSPDIR}/sources/meta-qti-connectivity "' >>  conf/bblayers.conf
echo 'export PROJECTID="QCA6574AULE221"' >> conf/bblayers.conf
echo 'BBMASK ="meta-qti-connectivity/recipes-products/images/automotive-connx-image.bb"
BBMASK.="|meta-qti-connectivity/recipes-kernel/linux-kernel/linux-msm-4.4_git.bbappend"
BBMASK.="|meta-qti-connectivity/recipes-kernel/lk/lk_git.bbappend"
BBMASK.="|meta-qti-connectivity/recipes-kernel/linux-libc-headers/linux-libc-headers_%.bbappend"
BBMASK.="|meta-qti-connectivity/recipes-kernel/linux-kernel/linux-imx_3.10.17.bbappend"
' >> conf/bblayers.conf

sed -i -e 's/IMAGE_ROOTFS_SIZE ??= "65536"/IMAGE_ROOTFS_SIZE ??= "139264"/g' ../sources/poky/meta/conf/bitbake.conf

echo  'MACHINE_ESSENTIAL_EXTRA_RRECOMMENDS += "pciutils"
MACHINE_ESSENTIAL_EXTRA_RRECOMMENDS += "qcacld-ll"
MACHINE_ESSENTIAL_EXTRA_RRECOMMENDS += "qcacld-hl-rome"
MACHINE_ESSENTIAL_EXTRA_RRECOMMENDS += "iw"
MACHINE_ESSENTIAL_EXTRA_RRECOMMENDS += "iperf"
MACHINE_ESSENTIAL_EXTRA_RRECOMMENDS += "wireless-tools"
MACHINE_ESSENTIAL_EXTRA_RRECOMMENDS += "wpa-supplicant"
MACHINE_ESSENTIAL_EXTRA_RRECOMMENDS += "wlan-sigmadut"
MACHINE_ESSENTIAL_EXTRA_RRECOMMENDS += "wlan-config"
MACHINE_ESSENTIAL_EXTRA_RRECOMMENDS += "rng-tools"
' >> conf/local.conf
echo "Please run following command to build image."
echo "bitbake core-image-minimal"

