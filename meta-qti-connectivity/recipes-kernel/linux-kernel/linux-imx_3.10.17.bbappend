SCMVERSION = "n"

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

#SRC_URI = "file://kernel/ \
#          "

CAF_PATCH_PATH = "https://source.codeaurora.org/quic/la/kernel/msm-3.18/patch/?"
PATCH_NAME_1 = "0001-Add-strchrnul.patch"

SRC_URI += "${CAF_PATCH_PATH}id=11d200e95f3e84c1102e4cc9863a3614fd41f3ad;downloadfilename=${PATCH_NAME_1};md5sum=d7a3b4c7611f69c3e25a4c880d420982"

do_patch_prepend() {
    bb.build.exec_func('do_download_patches', d)
}

do_download_patches() {
    cd ${WORKDIR}
    wget --no-check-certificate https://www.codeaurora.org/patches/external/wlan/Automotive/3rdparty/fsl3-10/Release_15_09_10/cfg80211_3.10.17.patch
    wget --no-check-certificate https://source.codeaurora.org/quic/romeau/sba-patches/plain/sba-patches/QCA6564.LE.1.0.3.c0.c1.krack/0001-WLAN-subsystem-Sysctl-support-for-key-TCP-IP-paramet.patch -O 0001-WLAN-subsystem-Sysctl-support-for-key-TCP-IP-paramet.patch
    wget --no-check-certificate https://source.codeaurora.org/quic/romeau/sba-patches/plain/sba-patches/QCA6574AU.LE.2.2.1/cfg80211_3.10.17_wpa3.patch -O cfg80211_3.10.17_wpa3.patch
}

python do_patch_append() {
    import subprocess
    bb.build.exec_func('do_patch_for_wlan', d)
}

do_patch_for_wlan() {
    process_tmpdir=`mktemp -d patchtempXXXX000`
    TMPDIR=${process_tmpdir}

    patch -p1 < ../cfg80211_3.10.17.patch
    patch -p1 < ../0001-WLAN-subsystem-Sysctl-support-for-key-TCP-IP-paramet.patch
    patch -p1 < ../cfg80211_3.10.17_wpa3.patch


    rm -rf ${process_tmpdir}
}

do_before_configure () {


    cat >> ${WORKDIR}/defconfig <<KERNEL_EXTRACONFIGS
CONFIG_HOSTAP=m
CONFIG_CFG80211=m
CONFIG_MAC80211=m
CONFIG_HOSTAP_FIRMWARE=y
CONFIG_WIRELESS_EXT=y
CONFIG_WEXT_SPY=y
CONFIG_WEXT_PRIV=y
CONFIG_NL80211_TESTMODE=y

CONFIG_CFG80211_REG_DEBUG=y
CONFIG_CFG80211_CERTIFICATION_ONUS=y
CONFIG_CFG80211_DEBUGFS=y
CONFIG_CFG80211_INTERNAL_REGDB=y
CONFIG_PCI=y
CONFIG_PCI_IMX6=y
CONFIG_BRIDGE=y

KERNEL_EXTRACONFIGS

}

addtask before_configure after do_patch before do_configure
