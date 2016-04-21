#!/bin/sh -ex

KERNEL=linux-image-4.4.0-0.bpo.1-armmp-lpae

# update packages
cp /etc/resolv.conf ${ROOTFS}/etc/resolv.conf
proot-helper sh -ex << EOF
apt-get update
apt-get -y upgrade
EOF

# create fstab entry
sh -c 'echo "/dev/mmcblk0p1\t/\text4\trelatime,errors=remount-ro\t0\t1" \
    > ${ROOTFS}/etc/fstab'

# configure u-boot
mkdir -p ${ROOTFS}/etc/flash-kernel
echo "Cubietech Cubieboard2" >> ${ROOTFS}/etc/flash-kernel/machine

# install board specific packages
proot-helper apt-get -y install --no-install-recommends ${KERNEL} \
    flash-kernel sunxi-tools u-boot-tools

# install machinekit
proot-helper apt-get -y install machinekit-rt-preempt machinekit-posix

# enable autologin serial console
cat <<EOF > ${ROOTFS}/sbin/autologin
#!/bin/sh
exec /bin/login -f root
EOF

chmod a+x ${ROOTFS}/sbin/autologin
echo 'S0:23:respawn:/sbin/getty -l /sbin/autologin -n -L ttyS0 115200 vt102' \
    >> ${ROOTFS}/etc/inittab

# update kernel cmdline
echo 'LINUX_KERNEL_CMDLINE="console=ttyS0,115200 hdmi.audio=EDID:0 disp.screen0_output_mode=EDID:1280x1024p60 root=/dev/mmcblk0p1 rootwait panic=10 ${extra}"' \
    >> ${ROOTFS}/etc/default/flash-kernel

proot-helper flash-kernel
