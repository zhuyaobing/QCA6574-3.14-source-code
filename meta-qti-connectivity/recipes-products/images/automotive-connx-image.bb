# meta-qti-connectivity bblayer for AGL BSP image

MACHINE ??= "8x96connx"

inherit qperf

require recipes-products/images/machine-auto-image.bb
require recipes-platform/images/agl-demo-platform.bb

IMAGE_ROOTFS_SIZE = "2097152"
IMAGE_ROOTFS_EXTRA_SPACE_append = "${@bb.utils.contains("DISTRO_FEATURES", "systemd", " + 4096", "" ,d)}"

IMAGE_INSTALL_remove += "ces2017-demo can-utils init-can navigation weston-examples"
IMAGE_INSTALL_remove += "mediaplayer settings mixer hvac poiapp"
IMAGE_INSTALL_remove += "dlt-daemon-test common-api-test"
IMAGE_INSTALL_remove += "rh850-firmware rh850-flash"
IMAGE_INSTALL_remove += "packagegroup-ivi-common-core packagegroup-agl-core"
IMAGE_INSTALL_remove += "pulseaudio-module-acdb pulseaudio-module-codec-control"
IMAGE_INSTALL_remove += "wqy-microhei strongswan mm-rtp-test"
IMAGE_INSTALL_remove += "ttf-bitstream-vera ttf-dejavu-sans ttf-dejavu-sans-mono ttf-dejavu-serif"
IMAGE_INSTALL_remove += "af-main af-binder af-binder-binding-afb-dbus-binding af-binder-binding-authlogin"
IMAGE_INSTALL_remove += "libafbwsc"
IMAGE_INSTALL_remove += "web-runtime"
IMAGE_INSTALL_remove += "firmware-links"
IMAGE_INSTALL_remove += "packagegroup-agl-demo-platform"
IMAGE_INSTALL_remove += "linux-firmware-ath9k linux-firmware-ralink"
IMAGE_INSTALL_remove += "libhardware-legacy qmi-client-helper"
IMAGE_INSTALL_remove += "neutrino-eth"

IMAGE_INSTALL += "lib32-lk"
IMAGE_INSTALL += "libcutils"
IMAGE_INSTALL += "liblog"
IMAGE_INSTALL += "system-core-adbd"
IMAGE_INSTALL += "system-core-usb"
IMAGE_INSTALL += "system-core"

IMAGE_INSTALL += "qcacld-ll"
IMAGE_INSTALL += "qcacld-ll-dualwifi"
IMAGE_INSTALL += "wlan-config"
IMAGE_INSTALL += "wlan-sigmadut"
IMAGE_INSTALL += "wpa-supplicant"
IMAGE_INSTALL += "pciutils"
IMAGE_INSTALL += "iw"
IMAGE_INSTALL += "wireless-tools"
IMAGE_INSTALL += "iperf"
