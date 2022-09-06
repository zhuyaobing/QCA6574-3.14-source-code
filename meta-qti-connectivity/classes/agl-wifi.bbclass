#QTI AGL BSP specific wlan driver bbclass
inherit signature

inherit ${@bb.utils.contains('BASEMACHINE', '8x96auto', 'qperf', '', d)}

DUAL_WIFI = "${@d.getVar('PN', True) == 'qcacld-ll-dualwifi'}"
WLAN_MODULE_NAME = "${@bb.utils.contains('DUAL_WIFI', 'True', 'wlan-cnss2', 'wlan-cnss0', d)}"
WLAN_CHIP_NAME   = "${@bb.utils.contains('DUAL_WIFI', 'True', 'cnss2', 'cnss0', d)}"

PACKAGES =+ "kernel-module-${WLAN_MODULE_NAME}"

EXTRA_OEMAKE += "CONFIG_IPA_OFFLOAD=n MODNAME=${WLAN_MODULE_NAME} CHIP_NAME=${WLAN_CHIP_NAME}"
