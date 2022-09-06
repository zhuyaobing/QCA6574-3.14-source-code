FILESEXTRAPATHS_append := ":${THISDIR}/files"

KERNEL_SRC = "git://source.codeaurora.org/quic/la/kernel/msm-4.4"
SRC_BRANCH = "LV.HB.1.1.1_rb1.46"
SRC_TAG    = "LV.HB.1.1.1-36610-8x96.0"
SRC_URI    = "${KERNEL_SRC};protocol=http;branch=${SRC_BRANCH};tag=${SRC_TAG}"
SRC_URI   += "file://0001-Add-cnss2-support-for-two-PCIe-wlan-card.patch \
              file://0002-cnss2-Support-collecting-firmware-dump-during-driver.patch \
              file://0003-cnss2-Add-support-for-PCIe-WLAN-IPA-uc-SMMU-feature.patch \
              file://0004-msm-ipa-Add-WLAN-FW-SSR-event.patch \
              file://0005-cnss2-Add-API-to-check-if-WLAN-PCIe-device-is-down.patch \
              file://0006-cnss2-Add-force-wake-support.patch \
              file://0007-cnss2-cnss-api-update-for-genoa-pcie.patch \
              file://0008-cnss2-Export-a-platform-API-to-force-collect-ramdump.patch \
             "

CAF_PATCH_PATH = "https://source.codeaurora.org/quic/la/kernel/msm-4.4/patch/?"
PATCH_NAME_1   = "0001-2331561-cfg80211-NL80211_ATTR_SOCKET_OWNER-support-for-CMD_C.patch"
PATCH_NAME_2   = "0002-2502829-cfg80211-Updated-nl80211_commands-to-be-in-sync-with.patch"
PATCH_NAME_3   = "0003-2526709-cfg80211-nl80211-Optional-authentication-offload-to-.patch"
PATCH_NAME_4   = "0004-2331555-nl80211-Allow-SAE-Authentication-for-NL80211_CMD_CON.patch"
PATCH_NAME_5   = "0005-2526768-cfg80211-indicate-support-for-external-authenticatio.patch"
PATCH_NAME_6   = "0006-2331712-nl80211-Fix-external_auth-check-for-offloaded-authen.patch"
PATCH_NAME_7   = "0007-2561091-nl80211-Free-connkeys-on-external-authentication-fai.patch"
PATCH_NAME_8   = "0008-2337054-nl80211-fix-nlmsg-allocation-in-cfg80211_ft_event.patch"
SRC_URI       += "${CAF_PATCH_PATH}id=0dbd3a4c45026c1812a82345cdc9de593865ef50;downloadfilename=${PATCH_NAME_1};md5sum=9a1da3d9f723679e925b1e7753fa7d8f \
                  ${CAF_PATCH_PATH}id=38476b581e792025352370d8156969cd99e52eb3;downloadfilename=${PATCH_NAME_2};md5sum=db6c19f6803dba6fcbc55dbfdfd0ac1b \
                  ${CAF_PATCH_PATH}id=30467c7507c064cffcf5fd2fffdafc06f1b6f433;downloadfilename=${PATCH_NAME_3};md5sum=493293dedf1114e36c567ecbdc1e5605 \
                  ${CAF_PATCH_PATH}id=cb51fb6ba3931794cff236c42399bc22ec923e15;downloadfilename=${PATCH_NAME_4};md5sum=856d21f51c992a611255bb71db340eee \
                  ${CAF_PATCH_PATH}id=3d2a81a6262967bc280d14be3b0ec23a4bbe8ca0;downloadfilename=${PATCH_NAME_5};md5sum=c456df5e1d3664a8fdf93afcb694d7aa \
                  ${CAF_PATCH_PATH}id=682aa32d0947f50f25587d2e2681a029fbe5c7ee;downloadfilename=${PATCH_NAME_6};md5sum=ffe193bec469811bf0810aea026cf69c \
                  ${CAF_PATCH_PATH}id=d7c122d223359f4164463258374b6dcfdd148c36;downloadfilename=${PATCH_NAME_7};md5sum=1347114d2528769f00ee071af12ecd9a \
                  ${CAF_PATCH_PATH}id=df55603b24bc48fd765332d71a9ca1f82c1e8e39;downloadfilename=${PATCH_NAME_8};md5sum=9ff5b62db8f26b564bf77c26124a1058 \
                 "

S = "${WORKDIR}/git"

do_configure_prepend () {
cat >> ${S}/arch/${ARCH}/configs/${KERNEL_CONFIG} <<KERNEL_EXTRACONFIGS
CONFIG_CNSS2=y
CONFIG_CNSS2_DEBUG=y
CONFIG_CNSS_LOGGER=y
# CONFIG_CNSS is not set
# CONFIG_CNSS_ASYNC is not set
CONFIG_CRYPTO_GCM=y
KERNEL_EXTRACONFIGS
}
