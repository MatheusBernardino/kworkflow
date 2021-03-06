function vm_mount_old
{
  sudo mount -o loop,offset=32256 $VDISK $QEMU_MNT
}

function vm_mount
{
  mkdir -p $MOUNT_POINT
  say "Mount $VDISK in $MOUNT_POINT"
  guestmount -a $VDISK -i $MOUNT_POINT
  if [ "$?" != 0 ] ; then
    complain "Something went wrong when tried to mount $VDISK in $MOUNT_POINT"
  fi
}

function vm_umount
{
  say "Unmount $MOUNT_POINT"
  guestunmount $MOUNT_POINT
  if [ "$?" != 0 ] ; then
    complain "Something went wrong when tried to unmount $VDISK in $MOUNT_POINT"
  fi
}

function vm_boot
{
  $QEMU -hda $VDISK \
    ${QEMU_OPTS} \
    -kernel $BUILD_DIR/$TARGET/arch/x86/boot/bzImage \
    -append "root=/dev/sda1 debug console=ttyS0 console=ttyS1 console=tty1" \
    -net nic -net user,hostfwd=tcp::5555-:22 \
    -serial stdio \
    -device virtio-gpu-pci,virgl -display gtk,gl=on 2> /dev/null
}

function vm_up
{

  check_local_configuration

  say "Starting Qemu with: "
  echo "$QEMU ${configurations[qemu_hw_options]}" \
       "${configurations[qemu_net_options]}" \
       "${configurations[qemu_path_image]}"

  $QEMU ${configurations[qemu_hw_options]} \
        ${configurations[qemu_net_options]} \
        ${configurations[qemu_path_image]}
}

function vm_ssh
{
  say "SSH to: port: " ${configurations[port]} " ip: " ${configurations[ip]}
  ssh -p ${configurations[port]} ${configurations[ip]}
}

function vm_prepare
{
  local path_ansible=$HOME/.config/kw/deploy_rules/
  local current_path=$PWD
  say "Deploying with Ansible, this will take some time"
  cd $path_ansible
  ansible-playbook kworkflow.yml --extra-vars "user=$USER" || cd $current_path
  cd $current_path
}
