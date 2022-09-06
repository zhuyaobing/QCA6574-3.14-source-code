SCMVERSION = "n"

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

CAF_PATCH_URL ="https://source.codeaurora.org/quic/la/kernel/msm-3.14/patch/?id="

SRC_URI += "https://www.codeaurora.org/patches/external/wlan/Automotive/3rdparty/fsl3-10/Release_15_10_20/cfg80211_3.14.28.patch;downloadfilename=cfg80211_3.14.28.patch;md5sum=a1113fe6b4d08cc84ef852293751ea7d"

SRC_URI += "https://source.codeaurora.org/quic/la/kernel/msm-3.18/patch/?id=11d200e95f3e84c1102e4cc9863a3614fd41f3ad;downloadfilename=0001-Add-strchrnul.patch;md5sum=d7a3b4c7611f69c3e25a4c880d420982"



SRC_URI += "	${CAF_PATCH_URL}2f6ecce8947840c2233293f66b1203e9cdc06be0;downloadfilename=0001-cfg80211-Add-AP-stopped-interface.patch;md5sum=1fea1e8cd56425f6f5e6a2fa01a2d6cd \
		${CAF_PATCH_URL}ea9e417116601c381ca55de987074f92c6a2efce;downloadfilename=0001-cfg80211-Add-new-wiphy-flag-WIPHY_FLAG_DFS_OFFLOAD.patch;md5sum=0467c7a63e5e9ce1bdd0b931700109b2 \
		${CAF_PATCH_URL}dc8a840ee81c7adefc26334f29178114fd114ca2;downloadfilename=0001-cfg80211-Advertise-maximum-associated-STAs-in-AP-mod.patch;md5sum=40c684a4110438fc703c4c4fc411424b \
		${CAF_PATCH_URL}7f09a4171fa34a0ff243876dcd9087fa7fea25ca;downloadfilename=0001-mac80211-implement-HS2.0-gratuitous-ARP-unsolicited-.patch;md5sum=081259b5361b76f65b4fce69859c43bd \
		${CAF_PATCH_URL}b90fb762ba8f32b9522318cf3f56da242c7b1f91;downloadfilename=0001-cfg80211-Allow-BSS-hint-to-be-provided-for-connect.patch;md5sum=819ee69ba4ee5fd9a0215c9426845e6c \
		${CAF_PATCH_URL}94eb0e21d4065c738ce8ead20da56aed04c4cabc;downloadfilename=0001-cfg80211-clarify-BSS-probe-response-vs.-beacon-data.patch;md5sum=49bc0a78fb0514fb757d4299631bc7f2 \
		${CAF_PATCH_URL}cb52939e7e550eacb39d64391ffe344b8737d1e5;downloadfilename=0001-cfg80211-Dynamic-channel-bandwidth-changes-in-AP-mod.patch;md5sum=099896013753439c09b2167813ce3464 \
		${CAF_PATCH_URL}04f1767b2df84809f64deffe4179a1188f6706be;downloadfilename=0001-cfg80211-export-cfg80211_get_drvinfo-from-ethtool;md5sum=c506250424f483b3869aa7e207099a61 \
		${CAF_PATCH_URL}6634e158ff21260d6b24d9b4ad1aef8b9584b61d;downloadfilename=0001-cfg80211-export-regulatory_hint_user-API.patch;md5sum=35940ef06bca17ee1f6654aa9f88c9f2 \
		${CAF_PATCH_URL}5099deaff00d7f4ece10a620ab98a6e989616ce3;downloadfilename=0001-cfg80211-Pass-TDLS-peer-capability-information-in-td.patch;md5sum=143b5f067b0f2b57ac6f6c19acdb3026 \
		${CAF_PATCH_URL}72487e61feadd6b31ebc6308d6313b219dfe1cfb;downloadfilename=0001-nl80211-fix-scheduled-scan-RSSI-matchset-attribute-c.patch;md5sum=4ff02a6495e6a7df2902ac150e8696e1 \
		"

SRC_URI += "https://source.codeaurora.org/quic/romeau/sba-patches/plain/sba-patches/QCA6574AU.LE.2.2.1/cfg80211_3.14.28_wpa3.patch;downloadfilename=cfg80211_3.14.28_wpa3.patch;md5sum=9fb5a9a67abe8056036efe6ab3d30109"

SRC_URI += "https://source.codeaurora.org/quic/romeau/sba-patches/plain/sba-patches/QCA6564.LE.1.0.3.c0.c1.krack/0001-WLAN-subsystem-Sysctl-support-for-key-TCP-IP-paramet-2.patch;downloadfilename=0001-WLAN-subsystem-Sysctl-support-for-key-TCP-IP-paramet-2.patch;md5sum=2b32fe56deb9084542fe5505950ccf79"

do_before_configure () {


    cat >> ${WORKDIR}/defconfig <<KERNEL_EXTRACONFIGS
CONFIG_HOSTAP=y
CONFIG_CFG80211=y
CONFIG_MAC80211=y
CONFIG_HOSTAP_FIRMWARE=y
CONFIG_WIRELESS_EXT=y
CONFIG_CFG80211_WEXT=y
CONFIG_WEXT_SPY=y
CONFIG_WEXT_PRIV=y
CONFIG_NL80211_TESTMODE=y

CONFIG_CFG80211_REG_DEBUG=y
CONFIG_CFG80211_CERTIFICATION_ONUS=y
CONFIG_CFG80211_DEBUGFS=y
CONFIG_CFG80211_INTERNAL_REGDB=y
CONFIG_BRIDGE=y

KERNEL_EXTRACONFIGS

}

addtask before_configure after do_patch before do_configure
