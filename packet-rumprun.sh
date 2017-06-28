#!/bin/sh

if [ "$#" -ne 3 ]; then

echo "Usage: Please provide the path to your identity file (ssh_key_file.pub) as the first argument, the ssh user as the second and the host ip address as the third (i.e. user@ip-address)"
exit 1
fi

SSH_IDENTITY=$1
SSH_USER=$2
SSH_HOST=$3

ssh -i $SSH_IDENTITY $SSH_USER@$SSH_HOST 'bash' <<-'ENDSSH'

	nix-env -i git-2.12.2 htop-2.0.2 libvirt-3.1.0 tmux-2.3 vim-8.0.0329 bridge-utils-1.5
	nix-env -iA nixos.binutils

	sed -i '$ d' /etc/nixos/configuration.nix
	cat <<-'EOF' >> /etc/nixos/configuration.nix
	  # Xen Support
	  virtualisation.xen.enable = true;

	  # Dom0 Memory
	  virtualisation.xen.domain0MemorySize = 2048;

	  # Connect xen bridge to the outside world
	  networking.interfaces.bond0.proxyARP = true;

	  # Docker
	  virtualisation.docker.enable = true;

          # ISO mount for testing
          fileSystems = {
            "/media/cdrom" = {
              device = "/data/alpine-xen-3.5.2-x86_64.iso";
              fsType = "iso9660";
              options = [ "loop" ];
            };
          };
	}
	EOF

	mkdir /data
	cd /data
	curl -O https://nl.alpinelinux.org/alpine/v3.5/releases/x86_64/alpine-xen-3.5.2-x86_64.iso
	mkdir -p /media/cdrom
	dd if=/dev/zero of=/data/a1.img bs=1M count=3000

	cat <<-'EOF' > /etc/a1.cfg
	# Alpine Linux PV DomU

	# Kernel paths for install
	kernel = "/media/cdrom/boot/vmlinuz-grsec"
	ramdisk = "/media/cdrom/boot/initramfs-grsec"
	extra="modules=loop,squashfs console=hvc0"

	# Path to HDD and iso file
	disk = [
	'format=raw, vdev=xvda, access=w, target=/data/a1.img',
	'format=raw, vdev=xvdc, access=r, devtype=cdrom, target=/data/alpine-xen-3.5.2-x86_64.iso'
	]

	# Network configuration
	vif = ['ip=172.16.0.5,bridge=xenbr0']

	# DomU settings
	memory = 512
	name = "alpine-a1"
	vcpus = 1
	maxvcpus = 1
	EOF

	nixos-rebuild switch

	docker pull mato/rumprun-toolchain-xen-x86_64

	echo "Rebooting system to boot up as xen Dom0"
	reboot
ENDSSH

sleep 10
echo "Waiting for machine to reboot"
nc -z $SSH_HOST 22 > /dev/null &
PROC_ID=$!

while kill -0 "$PROC_ID" >/dev/null 2>&1;
do
        echo "Waiting for machine to reboot" `date`
        sleep 15
done

ssh -t -i $SSH_IDENTITY $SSH_USER@$SSH_HOST "tmux"

# Things left to automate/workflow if done manually
# - Bind mount to /output when running container
# - Copy rumprun (which is actually a plain old shell script) out of container through mount
# - Maybey modify or intercept xl config created / get to learn the rumprun shell script top to bottom
# - https://github.com/rumpkernel/rumprun/blob/master/app-tools/rumprun
# - Modify entrypoint/command or create derivative image to just use as build command
# - Profit
