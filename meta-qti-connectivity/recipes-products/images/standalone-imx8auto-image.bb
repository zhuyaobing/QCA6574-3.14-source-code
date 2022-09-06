#Standalone Automotive image BBFILE for iMX8 platform
#The project specific tasks needs to be added in specific
#project related include file, ${PROJECTID}-image.inc file.

IMAGE_INSTALL = "packagegroup-core-boot ${CORE_IMAGE_EXTRA_INSTALL}"

IMAGE_LINGUAS = " "

inherit core-image
require recipes-products/images/standalone-imx8auto-image-prop.bb

IMAGE_ROOTFS_SIZE ?= "139264"
IMAGE_ROOTFS_EXTRA_SPACE_append = "${@bb.utils.contains("DISTRO_FEATURES", "systemd", " + 4096", "" ,d)}"


IMAGE_INSTALL += "firmware-imx-sdma"

#Common Required Tasks Listed
IMAGE_INSTALL += "iw"
IMAGE_INSTALL += "tcpdump"
IMAGE_INSTALL += "wireless-tools"
IMAGE_INSTALL += "iperf2"
IMAGE_INSTALL += "wpa-supplicant"
IMAGE_INSTALL += "wlan-sigmadut"
IMAGE_INSTALL += "wlan-config"
IMAGE_INSTALL += "rng-tools"

SYNERGY_DIR_PRESENT = "${@os.path.exists('${BSPDIR}/sources/synergy-bt-proprietary')}"
IMAGE_INSTALL += "${@bb.utils.contains('SYNERGY_DIR_PRESENT', 'True', 'alsa-lib', '', d)}"
IMAGE_INSTALL += "${@bb.utils.contains('SYNERGY_DIR_PRESENT', 'True', 'alsa-utils', '', d)}"

IMAGE_INSTALL += "pciutils"
IMAGE_INSTALL += "iputils"
IMAGE_INSTALL += "bridge-utils"
#IMAGE_INSTALL += "wlan-cnss-core"
IMAGE_INSTALL += "qcacld32-ll-rome"
#IMAGE_INSTALL += "qcacld32-ll-hasting"
#IMAGE_INSTALL += "qcacld32-ll-rome-cnss2"
#IMAGE_INSTALL += "qcacld20-ll-rome"
#IMAGE_INSTALL += "qcacld20-hl-rome"
#IMAGE_INSTALL += "qcacld20-hl-tfl"
