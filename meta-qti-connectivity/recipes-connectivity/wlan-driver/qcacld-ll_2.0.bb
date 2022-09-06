require  qcacld-20-common.inc

DESCRIPTION = "Qualcomm Technologies, Inc WLAN CLD low latency driver version 2.0"
LICENSE = "ISC"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/${LICENSE};md5=f3b90e78ea0cffb20bf5cca7947a896d"

DEPENDS = "virtual/kernel"

FILESPATH =+ "${BSPDIR}/sources:"
SRC_URI = "file://wlan-opensource/qcacld-2.0/ \
          "
S = "${WORKDIR}/wlan-opensource/qcacld-2.0"

#inherit autotools module kernel-arch
inherit module kernel-arch

dr_installed_dir = "/home/root"

FILES_${PN}     += "lib/firmware/wlan/*"
#FILES_${PN}     += "${base_libdir}/modules/${KERNEL_VERSION}/extra/wlan.ko"
FILES_${PN} += "${dr_installed_dir}"
PROVIDES_NAME    = "kernel-module-wlan"
RPROVIDES_${PN} += "${PROVIDES_NAME}"

EXTRA_OEMAKE += "CONFGI_ARM_MDMFERMIUM=n CONFIG_WLAN_FEATURE_SAE=y CONFIG_LINUX_QCMBR=y WLAN_OPEN_SOURCE=1 CONFIG_NON_QC_PLATFORM=y CONFIG_ROME_IF=pci"

do_unpack_append() {
    bb.build.exec_func('do_download_patches', d)
}

do_download_patches() {
	cd ${S}
  wget --no-check-certificate https://source.codeaurora.org/quic/romeau/sba-patches/plain/sba-patches/QCA6574AU.LE.2.2.1/qcacld-2.0-LK310.patch -O qcacld-2.0-LK310.patch
}

do_patch() {
	cd ${S}
  patch -p1 -d ${S} < qcacld-2.0-LK310.patch

}

do_install () {

#     module_do_install

     install -d ${D}/lib/firmware/wlan/
     install -m 644 ${S}/firmware_bin/WCNSS_cfg.dat ${D}/lib/firmware/wlan/cfg.dat
}


do_install_append() {
    install -d ${D}${dr_installed_dir}
    cp ${S}/wlan.ko ${D}${dr_installed_dir}
}
