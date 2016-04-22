#!/bin/sh -ex

UBOOT=u-boot-sunxi-with-spl.bin.gz
BOARD=Cubieboard2
IMAGE=${BOARD}-machinekit-1.0.img
SRC=https://d-i.debian.org/daily-images/armhf/daily/u-boot

# download u-boot
wget ${SRC}/${BOARD}/${UBOOT}
gunzip ${UBOOT}

# create 4GB sparse file
rm -f ${IMAGE}
dd if=/dev/zero of=${IMAGE} count=0 bs=1 seek=3965190144

# create partitions
fdisk ${IMAGE} <<EOF
n
p
1


w
EOF

LOOPDEV=$(losetup -f)

# format partitions
losetup ${LOOPDEV} ${IMAGE} -o $((2048*512))
mkfs.ext4 -L Machinekit ${LOOPDEV}

# mount partitions
mkdir -p mnt_root
mount ${LOOPDEV} mnt_root

# populate ROOT
echo "populate root..."
tar cpf - -C ${ROOTFS} . | tar xpf - -C mnt_root

umount mnt_root
losetup -d ${LOOPDEV}

# install u-boot
losetup ${LOOPDEV} ${IMAGE}
dd if=${UBOOT%.*} of=${LOOPDEV} bs=1024 seek=8
losetup -d ${LOOPDEV}

# create bmap
bmaptool create ${IMAGE} -o ${IMAGE}.bmap

bzip2 -9 ${IMAGE}
mv ${IMAGE}.bz2 ${IMAGE}.bmap /work/images
