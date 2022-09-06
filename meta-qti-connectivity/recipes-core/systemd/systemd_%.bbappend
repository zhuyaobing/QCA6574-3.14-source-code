
FILESEXTRAPATHS_append := ":${THISDIR}/systemd-230"

SRC_URI_append += "file://70-net-setup-link.rules \
                   file://blacklist-wlan-tfl.conf \
		   file://systemd-rngd.service \
		  "

do_install_append() {
  install -d ${D}${sysconfdir}/modprobe.d

  install -m 0644 ${WORKDIR}/70-net-setup-link.rules ${D}${sysconfdir}/udev/rules.d/
  install -m 0644 ${WORKDIR}/blacklist-wlan-tfl.conf ${D}${sysconfdir}/modprobe.d/
  install -m 0644 ${WORKDIR}/systemd-rngd.service ${D}${systemd_system_unitdir}/

  ln -sf ${D}${systemd_system_unitdir}/systemd-rngd.service  \
	 ${D}${sysconfdir}/systemd/system/multi-user.target.wants/systemd-rngd.service

}

FILES_${PN} += "${sysconfdir}/modprobe.d/*"
