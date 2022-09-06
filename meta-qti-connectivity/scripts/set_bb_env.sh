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


# Setup Standalone Automotive BSP environment.
# Create softlink in BSP to QTI connectivity release codes if available.
# Update BSP configuration parameters.
# Export QTI Software Product specific PROJECTID.

umask 022

usage()
{
    local SCRIPT_PARAMS="[EULA=<eula>] [MACHINE=<machine>] [PROJECT=<projectid>]"
    echo
    echo "script usage for QTI Standalone Auto image"
    echo "${SCRIPT_PARAMS} source ${SCRIPT_FILE} [BUILDDIR]"
    echo "For example: PROJECT=QCA6584AULE201 source ${SCRIPT_FILE}"
    echo
    echo "EULA      :  FSL EULA, default 0 if undefined."
    echo "BUILDDIR  :  the build directory location, 'build' by default."
    echo "MACHINE   :  Supported machines, 'imx6qsabresd' by default. reference command \$list_machines"
    echo "PROJECT   :  Supported QTI Standalone SP"
    echo "    QCA6584AULE201 : QCA6584AU.LE.2.0.1 SP"
}

execute_command()
{
    eval "$1  > /dev/null 2>&1"

    if [ ! $? -eq 0 ]; then
        echo "Command execution failed: '$1'. Terminating..."
        exit 1
    fi
}

cleanenv()
{
    unset EULA MACHINE PROJECT DISTRO
}

list_machines()
{
    echo "Supported Machines by this BSP:"
    echo; ls ${WORK_SPACE}/sources/*/conf/machine/*.conf ${WORK_SPACE}/sources/meta-imx/*/conf/machine/*.conf | \
    sed s/\.conf//g | sed -r 's/^.+\///' | xargs -I% echo -e "\t%"
    echo
}

check_machine_valid()
{
    local MACHINES=`ls -1 ${WORK_SPACE}/sources/*/conf/machine ${WORK_SPACE}/sources/meta-imx/*/conf/machine`
    local VALID_MACHINE=`echo -e "${MACHINES}" | grep ${MACHINE}.conf$ | wc -l`
    if [ "$VALID_MACHINE" = "0" ]; then
        echo -e "\nThe MACHINE=$MACHINE is not supported by this build setup"
        list_machines
        return 1
    fi
}

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

buildclean()
{
    set -x
    cd ${WORK_SPACE}/${BUILD_DIR}
    rm -rf bitbake.lock pseudodone sstate-cache tmp/* cache && cd - || cd -
    set +x
}

cdbitbake()
{
    local ret=0
    cd ${WORK_SPACE}/${BUILD_DIR}
    bitbake $@ && cd - || ret=$? && cd -
    return $ret
}

rebake()
{
    cdbitbake -c cleanall $@ && \
    cdbitbake $@
}

build-imxauto-image()
{
    cdbitbake standalone-auto-image
    if [ "$?" != "0" ]; then
        echo "Error run building image."
        return 1
    fi
}

############################################################################
#Exec Commands:

# Set default sripts and work space path
SCRIPT_FOLDER="$(dirname "${BASH_SOURCE}")"
WORK_SPACE=$(readlink -f ${SCRIPT_FOLDER}/../../..)
SCRIPT_FILE=${SCRIPT_FOLDER}/set_bb_env.sh
PACKAGE_CLASSES="package_rpm"

set -x

cat  << EOF
IMPORTANT NOTICE:
Use of the set_bb_env.sh script will combine some open source licensed software and/or third party licensed software
components into the product. Redistribution and use of the open source and/or third party code
may legally require you to comply with the terms of the open source and/or third party license(s)
that apply to the code used and redistributed."

EOF

case $PROJECT in
    "QCA6584AULE201" | "")
        {
#            DISTRO=fsl-imx-x11
            export PROJECTID=QCA6584AULE201
        } ;;
    *)
        {
            echo "Invalid PROJECT, check script usage"
            usage
            cleanenv
            return 1
        } ;;
esac

# Default MACHINE
if [ -z "$MACHINE" ]; then
    MACHINE='imx6qsabresd'
else
    check_machine_valid
    if [ "$?" != "0" ]; then
        cleanenv
        return 1
    fi
fi

if [ -z "$DISTRO" ]; then
    DISTRO=fsl-imx-x11
fi

# Get current BSP kernel version
get_bsp_kernel_version
if [ -z "${KERNELVERSION}" ]; then
    echo "Can't find linux kernel bbfile, use 5.4 by default"
    KERNELVERSION="5.4"
fi

# Get all required source codes.
. ${SCRIPT_FOLDER}/extract_sourcecode.sh

#Default build-dir
BUILD_DIR=$1
if [ -z "$BUILD_DIR" ]; then
    BUILD_DIR='build'
fi

if [ -z "$EULA" ] || [ "$EULA" != "1" ]; then
    EULA=0
else
    EULA=1
fi

. ${WORK_SPACE}/sources/poky/oe-init-build-env ${BUILD_DIR} > /dev/null

# Generate the local.conf based on the Yocto defaults
# Update local.conf based on Yocto
mv conf/local.conf conf/local.conf.sample
grep -v '^#\|^$' conf/local.conf.sample > conf/local.conf
sed -e "s,MACHINE ??=.*,MACHINE ??= '$MACHINE',g" \
    -e "s,DISTRO ?=.*,DISTRO ?= '$DISTRO',g" \
    -e "s,PACKAGE_CLASSES ?=.*,PACKAGE_CLASSES ?= '$PACKAGE_CLASSES',g" \
    -i conf/local.conf

if grep -q '^DL_DIR ?=' conf/local.conf; then
    sed -e "s,^DL_DIR ?=.*,DL_DIR ?= \"\${BSPDIR}/downloads/\",g" -i conf/local.conf
else
    echo "DL_DIR ?= \"\${BSPDIR}/downloads/\"" >> conf/local.conf
fi

if grep -q '^ACCEPT_FSL_EULA\s*=' conf/local.conf; then
    sed -e "s/^ACCEPT_FSL_EULA\s*=.*/ACCEPT_FSL_EULA = \"$EULA\"/g" -i conf/local.conf
else
    echo "ACCEPT_FSL_EULA = \"$EULA\"" >> conf/local.conf
fi

# Export specific parameters for Yocto
if grep -q 'PROJECTID' conf/local.conf; then
    sed -e "s/^PROJECTID\s*=.*/PROJECTID = \"$PROJECTID\"/g" -i conf/local.conf
else
    echo "PROJECTID = \"$PROJECTID\"" >> conf/local.conf
fi

if grep -q 'KERNELVERSION' conf/local.conf; then
   sed -e "s/^KERNELVERSION\s*=.*/KERNELVERSION = \"$KERNELVERSION\"/g" -i conf/local.conf
else
   echo "KERNELVERSION = \"$KERNELVERSION\"" >> conf/local.conf
fi

#Workaround to fix KW build Error by remove "ERROR" in poky/meta/lib/oe/rootfs.py
#The "ERROR" will be tracked by log check, which will make build failed.
ROOTFSFILE=${WORK_SPACE}/sources/poky/meta/lib/oe/rootfs.py
sed -e "s/ERROR: |Error: |Error |ERROR/Error: |Error/g" -i ${ROOTFSFILE}

# Update bblayers.conf for PROJECT QCA6574AULE221
. ${WORK_SPACE}/${SCRIPT_FOLDER}/update_bblayers.sh

cleanenv

set +x

cat <<EOF

Welcome to Freescale Community BSP with QTI Connectivity Product

You can now run commands to build image:

    build-imxauto-image

EOF
