# WLAN driver qcacld version 2.0 basic bbclass.

inherit module kernel-arch

PACKAGE_ARCH = "${MACHINE_ARCH}"

LICENSE = "ISC"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/${LICENSE};md5=f3b90e78ea0cffb20bf5cca7947a896d"

WLAN_MODULE_NAME ?= "wlan"
WLAN_CHIP_NAME ?= ""

DEPENDS = "virtual/kernel"

FILESPATH =+ "${BSPDIR}/sources/wlan-opensource:"
SRC_URI = "file://qcacld-2.0/"
S = "${WORKDIR}/qcacld-2.0"

FILES_${PN}     += "lib/firmware/wlan/*"
FILES_${PN}     += "${base_libdir}/modules/${KERNEL_VERSION}/extra/${WLAN_MODULE_NAME}.ko"
RPROVIDES_${PN}  += "kernel-module-${WLAN_MODULE_NAME} kernel-module-${WLAN_MODULE_NAME}-${KERNEL_VERSION}"

EXTRA_OEMAKE += "CONFIG_WLAN_FEATURE_11W=y CONFIG_LINUX_QCMBR=y"

do_compile_prepend() {
    sed -in '/Werror/d' ${S}/Kbuild
}

FIRMWARE_CFG_PATH = "${D}${base_libdir}/firmware/wlan/${CHIP_NAME}"

do_install () {
    module_do_install

    install -d ${FIRMWARE_CFG_PATH}
    install -m 644 ${S}/firmware_bin/WCNSS_cfg.dat ${FIRMWARE_CFG_PATH}/cfg.dat
}
