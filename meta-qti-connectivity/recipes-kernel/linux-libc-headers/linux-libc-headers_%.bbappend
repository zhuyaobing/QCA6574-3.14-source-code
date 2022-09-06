KERNEL_SRC = "git://source.codeaurora.org/quic/la/kernel/msm-4.4"
SRC_BRANCH = "LV.HB.1.1.1_rb1.46"
SRC_TAG    = "LV.HB.1.1.1-36610-8x96.0"
SRC_URI    = "${KERNEL_SRC};protocol=http;branch=${SRC_BRANCH};tag=${SRC_TAG}"
SRC_URI   += "file://Fix-for-glibc-compilation-with-kernel4.4.patch"
SRC_URI   += "file://binder.h"


S = "${WORKDIR}/git"
