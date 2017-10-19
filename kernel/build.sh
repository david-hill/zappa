if [ "$1" == "-f" ]; then
  force=1
else
  force=0
fi

git checkout Makefile
git checkout master
git pull

gver=$(git tag | sort -V | grep -v rc | tail -1)
pver=$(cat previous)

if [[ $gver != $pver ]] || [ $force == 1 ]; then

  git checkout ${gver}
  git pull
  
  cdate="-"
  cdate=$cdate$(date +"%Y%m%d%H%M%S")
  
  sed -i -e "s/EXTRAVERSION =.*/EXTRAVERSION = $cdate/g" Makefile 
  make -j12 bzImage
  make -j12 modules
  make -j12 modules_install
  
  version=$(cat include/config/kernel.release)

  cp arch/x86/boot/bzImage /boot/vmlinuz-$version
  
  dracut -f /boot/initramfs-$version.img $version
  
  grub2-mkconfig -o /boot/grub2/grub.cfg
  
  menuentry=$(grep $version /boot/grub2/grub.cfg  | grep menuentry | awk -F\' '{ print $2 }')
  
  grub2-set-default "$menuentry"
  
  echo "$gver" > previous
fi
