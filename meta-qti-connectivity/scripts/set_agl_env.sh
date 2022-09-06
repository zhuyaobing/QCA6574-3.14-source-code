#!/bin/sh

#Copyright (c) 2018, The Linux Foundation. All rights reserved.

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

function build-8x96connx-image() {
  unset_bb_env
  export MACHINE=8x96connx
  export DISTRO=auto
  export BB_ENV_EXTRAWHITE="$BB_ENV_EXTRAWHITE KERNEL_ROOTDEVICE"
  cdbitbake automotive-connx-image
  if [ "$?" != "0" ]; then
      echo "Error run 'cdbitbake automotive-connx-image'."
      return 1
  fi
}

############################################################################
#Exec Commands:

# Set default sripts and work space path
SCRIPT_FOLDER="$(dirname "${BASH_SOURCE}")"
BSP_DIR=$(readlink -f ${SCRIPT_FOLDER}/../../..)
SCRIPT_FILE=${SCRIPT_FOLDER}/set_agl_env.sh
BBLAYERS_CONF="${BSP_DIR}/poky/build/conf/bblayers.conf"

cd ${BSP_DIR}/poky
export SHELL=/bin/bash
source build/conf/set_bb_env.sh > /dev/null 2>&1

echo "" >> ${BBLAYERS_CONF}
echo "## QTI Connectivity META Layers support" >> ${BBLAYERS_CONF}
echo "export BSPDIR = \"\${WORKSPACE}\"" >> ${BBLAYERS_CONF}
echo "BBLAYERS += \"${BSP_DIR}/sources/meta-qti-connectivity\"" >> ${BBLAYERS_CONF}
echo "BBLAYERS += \"${BSP_DIR}/sources/meta-qti-connectivity-prop\"" >> ${BBLAYERS_CONF}

cat <<EOF

Welcome to AGL BSP with QTI Connectivity Product

Build BSP image use command:

    build-8x96connx-image

Clean BSP image use command:

    buildclean

EOF
