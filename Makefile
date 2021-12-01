.PHONY: install uninstall

install:
	mkdir -p /etc/X11/xorg.conf.d
	mkdir -p /etc/gpu-select/
	cp -f intel.conf /etc/gpu-select/
	cp -f nvidia.conf /etc/gpu-select/
	cp -f gpu-select /usr/bin/
	chmod 755 /usr/bin/gpu-select
	cp -f gpu-select.conf /etc/modprobe.d/
	echo "bbswitch" >/etc/modules-load.d/bbswitch.conf
	cp -f gpu-select-intel.service /etc/systemd/system
	systemctl enable gpu-select-intel.service
	update-initramfs -k all -c
	systemctl list-unit-files | grep -q nvidia-persistenced.service && systemctl disable --now nvidia-persistenced.service

uninstall:
	rm -rf /etc/gpu-select
	rm -f /usr/bin/gpu-select
	rm -f /etc/modprobe.d/gpu-select.conf
	rm -f /etc/modules-load.d/bbswitch.conf
	systemctl disable gpu-select-intel.service
	rm -f /etc/systemd/system/gpu-select-intel.service
	systemctl list-unit-files | grep -q nvidia-persistenced.service && systemctl enable --now nvidia-persistenced.service
	update-initramfs -k all -c
