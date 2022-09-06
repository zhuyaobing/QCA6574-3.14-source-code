SCMVERSION = "n"

FILESEXTRAPATHS_prepend := "${BSPDIR}/sources:${THISDIR}/files:"

MAINLINE_PRESENT = "${@os.path.exists('${BSPDIR}/sources/kernel')}"

python __anonymous () {
    ver=d.getVar("PV",True).split('.')
    d.setVar("PATCH_FOLDER", "lk-" + '.'.join((ver[0], ver[1])))

    if (d.getVar("MAINLINE_PRESENT", True) == 'True'):
        d.setVar("SRC_URI", "file://kernel/ ")
        d.appendVar("SRC_URI", " file://config/defconfig_${PV}")
        d.setVar("S", "${WORKDIR}/kernel")
}

SRC_URI += "file://config/defconfig_${PV}"
SRC_URI += "file://${PATCH_FOLDER}/"

do_copy_defconfig_append() {
    cat ${WORKDIR}/config/defconfig_${PV} >> ${B}/.config
}

do_patch_for_kernel() {
    # For RB line, need to apply kernel patch
    if [ ${MAINLINE_PRESENT} != "True" ]; then
        PATCH_PATH="${WORKDIR}/${PATCH_FOLDER}"
        pushd ${S}
        for i in $(ls ${PATCH_PATH})
        do
            patch -p1 -d . < ${PATCH_PATH}/$i
        done
        popd
    fi

}

addtask do_patch_for_kernel after do_patch before do_configure
