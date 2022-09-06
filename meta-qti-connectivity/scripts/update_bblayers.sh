#!/bin/sh

#Copyright (c) 2018-2021, The Linux Foundation. All rights reserved.

#Redistribution and use in source and binary forms, with or without
#modification, are permitted provided that the following conditions are
#met:
#    * Redistributions of source code must retain the above copyright
#      notice, this list of conditions and the following disclaimer.
#    * Redistributions in binary form must reproduce the above
#      copyright notice, this list of conditions and the following
#      disclaimer in the documentation and/or other materials provided
#      with the distribution.
#    * Neither the name of The Linux Foundation nor the names of its
#      contributors may be used to endorse or promote products derived
#      from this software without specific prior written permission.

#THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED
#WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
#MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT
#ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS
#BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
#CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
#SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
#BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
#WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
#OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
#IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


# This script tries to update conf/bblayers.conf for different project.

LCONF_VER=6

generate_common_bblayers()
{
    cat >> ${BBLAYERS_CONF} <<EOF
LCONF_VERSION = "${LCONF_VER}"

BBPATH = "\${TOPDIR}"
export BSPDIR := "\${@os.path.abspath(os.path.dirname(d.getVar('FILE', True)) + '/../..')}"

BBFILES ?= ""
BBLAYERS = " \\
  \${BSPDIR}/sources/poky/meta \\
  \\
  \${BSPDIR}/sources/meta-openembedded/meta-oe \\
  \${BSPDIR}/sources/meta-openembedded/meta-multimedia \\
  \${BSPDIR}/sources/meta-openembedded/meta-gnome \\
  \${BSPDIR}/sources/meta-openembedded/meta-networking \\
  \${BSPDIR}/sources/meta-openembedded/meta-python \\
  \${BSPDIR}/sources/meta-openembedded/meta-filesystems \\
  \\
  \${BSPDIR}/sources/meta-browser \\
  \${BSPDIR}/sources/meta-qt5 \\
"
EOF
}


bblayers_for_fsl_meta()
{
    local FSL_BSP_DIR="meta-imx"

    if [[ "${KERNELVERSION}" < "5.4" ]]; then
        FSL_BSP_DIR="meta-fsl-bsp-release/imx"
    fi

    cat >> ${BBLAYERS_CONF} <<EOF

##Freescale Yocto Project Release layer
BBLAYERS += " \${BSPDIR}/sources/${FSL_BSP_DIR}/meta-bsp "
BBLAYERS += " \${BSPDIR}/sources/${FSL_BSP_DIR}/meta-sdk "
BBLAYERS += " \${BSPDIR}/sources/meta-freescale-3rdparty "
BBLAYERS += " \${BSPDIR}/sources/meta-freescale-distro "
BBLAYERS += " \${BSPDIR}/sources/meta-freescale "

EOF

    case ${KERNELVERSION} in
        "4.1" | "4.9")
            echo "BBLAYERS += \" \${BSPDIR}/sources/poky/meta-yocto \""  >> ${BBLAYERS_CONF}
            ;;
        "5.4")
            echo "BBLAYERS += \" \${BSPDIR}/sources/meta-clang \"" >> ${BBLAYERS_CONF}
            ;&
            # Fall through
        "4.19")
            echo "BBLAYERS += \" \${BSPDIR}/sources/meta-rust \"" >> ${BBLAYERS_CONF}
            echo "BBLAYERS += \" \${BSPDIR}/sources/${FSL_BSP_DIR}/meta-ml \"" >> ${BBLAYERS_CONF}
            ;&
            # Fall through
        "4.14")
            echo "BBLAYERS += \" \${BSPDIR}/sources/poky/meta-poky \""  >> ${BBLAYERS_CONF}
            ;;
        *)
            echo "Not supported kernel version ${KERNELVERSION}"
            ;;
    esac
}

bblayers_for_qti_meta()
{
    cat >> ${BBLAYERS_CONF} <<EOF

##QTI Yocto Connecetivity layer
BBLAYERS += " \${BSPDIR}/sources/meta-qti-connectivity "
BBLAYERS += " \${BSPDIR}/sources/meta-qti-connectivity-prop "

EOF

    #Update BBMASK bbfiles
    if [ -f "${WORK_SPACE}/sources/meta-qti-connectivity/conf/standalone-bbmask.conf" ]; then
        cat ${WORK_SPACE}/sources/meta-qti-connectivity/conf/standalone-bbmask.conf >> ${BBLAYERS_CONF}
    fi

    echo 'BBMASK.="|meta-qti-connectivity/recipes-kernel/linux-kernel/linux-imx_3.10.17.bbappend"' >> ${BBLAYERS_CONF}

    if [ "${KERNELVERSION}" == "4.19" ]; then
        echo 'BBMASK.="|meta-qti-connectivity/recipes-core/busybox/busybox_%.bbappend"' >> ${BBLAYERS_CONF}
    fi
}

################################################################
#BBLAYERS_TEMPLATES=${WORK_SPACE}/sources/base/conf/bblayers.conf
#Current should in BUILD_DIR
BBLAYERS_CONF=conf/bblayers.conf

echo '' > ${BBLAYERS_CONF}
if [ "${KERNELVERSION}" == "4.19" ]; then
    LCONF_VER=7
fi

generate_common_bblayers
bblayers_for_fsl_meta
bblayers_for_qti_meta
