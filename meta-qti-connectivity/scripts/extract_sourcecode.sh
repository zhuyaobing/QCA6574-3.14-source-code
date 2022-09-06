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


# This script will extract all required open source code.
# . sources/meta-qti-connectivity/scripts/extract_sourcecode.sh

download_git_code()
{
    local GIT_URL=$1 GIT_REV=$2
    local GIT_NAME="" SRC_DIR=""

    if [ -z "$GIT_URL" ]; then
        echo "Invalid Git Url"
        return 1
    fi

    GIT_NAME=${GIT_URL##*/}
    SRC_DIR="${WORK_SPACE}/sources"

    if [ -d ${SRC_DIR}/${GIT_NAME} ]; then
        #Source Code already downloaded.
        return 0
    fi

    echo "Downloading ${GIT_NAME}"
    execute_command "pushd ${SRC_DIR}"
    execute_command "git clone ${GIT_URL}"
    execute_command "popd"

    if [ ! -d ${SRC_DIR}/${GIT_NAME} ]; then
        echo "Download ${GIT_NAME} failed from ${GIT_URL}"
        return 1
    fi

    if [ ! -z ${GIT_REV} ]; then
        execute_command "pushd ${SRC_DIR}/${GIT_NAME}"
        execute_command "git checkout ${GIT_REV}"
        execute_command "popd"
    fi
    echo "Download ${GIT_NAME} completed"
}

META_FSL_GIT="git://git.yoctoproject.org/meta-freescale"
META_FSL_3RD_GIT="git://github.com/Freescale/meta-freescale-3rdparty"
META_FSL_DIS_GIT="git://github.com/Freescale/meta-freescale-distro"

case ${KERNELVERSION} in
    "4.9")
        #For manifest: imx-4.9.11-1.0.0_ga
        META_FSL_REV="a398b50b7fc084a9e68cc3000c218d5028522a25"
        META_FSL_3RD_REV="68314612e236cab1da82d72a0da62635a3523f84"
        META_FSL_DIS_REV="cd5c7a2539f40004f74126e9fdf08254fd9a6390"
        ;;
    "4.14")
        #For mainfest: imx-4.14.78-1.0.0_ga
        META_FSL_REV="407c6cf408969445031a492e2d25e0e2749582ea"
        META_FSL_3RD_REV="88a29631809d1af0df618245430db29f2a7012b5"
        META_FSL_DIS_REV="f7e2216e93aff14ac32728a13637a48df436b7f4"
        ;;
    "4.19")
        #For manifest: imx-4.19.35-1.1.0.xml
        META_FSL_REV="2142f7ded1b3115ccc21f7575fd83e2376247193"
        META_FSL_3RD_REV="da422478d38e744283bcf61123c4a526396c7030"
        META_FSL_DIS_REV="d4e77ea682fa10d0d54a723b3d3099c44fc5e95c"
        ;;
    "5.4")
        #For manifest: imx-5.4.70-2.3.2.xml
        META_FSL_REV="14f1a630a47375432f93c556927b879b51d84c4e"
        META_FSL_3RD_REV="dbcc686f52c3c84db8cb86aa8973a4e373651b98"
        META_FSL_DIS_REV="ca27d12e4964d1336e662bcc60184bbff526c857"
        ;;
    *)
        echo "Not supported kernel version ${KERNELVERSION}"
        return 1
        ;;
esac

download_git_code ${META_FSL_GIT} ${META_FSL_REV}
download_git_code ${META_FSL_3RD_GIT} ${META_FSL_3RD_REV}
download_git_code ${META_FSL_DIS_GIT} ${META_FSL_DIS_REV}
