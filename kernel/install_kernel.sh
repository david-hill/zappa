version=$(cat include/config/kernel.release)
cp arch/x86/boot/bzImage /boot/vmlinuz-$version
rc=$?
if [ $rc -eq 0 ]; then
  dracut -f /boot/initramfs-$version.img $version
  rc=$?
  if [ $rc -eq 0 ]; then
    grub2-mkconfig -o /boot/grub2/grub.cfg
    rc=$?
    if [ $rc -eq 0 ]; then
      menuentry=$(grep $version /boot/grub2/grub.cfg  | grep menuentry | awk -F\' '{ print $2 }')
      grub2-set-default "$menuentry"
      rc=$?
    fi
  fi
fi


exit $rc
