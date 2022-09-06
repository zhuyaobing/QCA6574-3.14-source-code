DESCRIPTION = "WLAN Device specific config"
LICENSE = "ISC"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/${LICENSE};md5=f3b90e78ea0cffb20bf5cca7947a896d"
PR = "r3"

inherit autotools systemd

FILESPATH =+ "${BSPDIR}/sources/wlan-opensource:"

SRC_URI = "file://mdm-init/"

S = "${WORKDIR}/mdm-init/"

EXTRA_OECONF = "--enable-thirdparty-wlan=yes"

FILES_${PN} += "${datadir}/misc/wifi/*"
FILES_${PN} += "${nonarch_base_libdir}/firmware/wlan/*"
FILES_${PN} += "${sysconfdir}/init.d/*"
