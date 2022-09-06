
do_compile_prepend() {
    sed -in '/Werror/d' ${S}/Kbuild
}
