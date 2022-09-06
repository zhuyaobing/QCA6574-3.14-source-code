
do_configure_append() {
	sed -in '/# CONFIG_TELNETD is not set/d'  ${S}/.config
	sed -in '/# CONFIG_FEATURE_TELNETD_STANDALONE is not set/d'  ${S}/.config
	sed -in '/# CONFIG_FEATURE_TELNETD_INETD_WAIT is not set/d'  ${S}/.config
	sed -in '$a\CONFIG_TELNETD=y' ${S}/.config
	sed -in '$a\CONFIG_FEATURE_TELNETD_STANDALONE=y' ${S}/.config
	sed -in '$a\CONFIG_FEATURE_TELNETD_INETD_WAIT=y' ${S}/.config
}

