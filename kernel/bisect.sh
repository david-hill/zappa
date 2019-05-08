stderr=stderr
stdout=stdout
function startlog { 
  initial=$(date "+%s") 
  printf "%-60s" "$1" 
} 


function endlog { 
  message=$1 
  final=$(date "+%s") 
  elapsed=$(( $final - $initial )) 
  printf "%-15s\n" "$1 (${elapsed}s)" 
} 

git checkout Makefile
if [ "$1" == "-b" ]; then
  git bisect bad
elif [ "$1" == "-g" ]; then
  git bisect good
fi

startlog "Building kernel"

cdate="-"
cdate=$cdate$(date +"%Y%m%d%H%M%S")
cp .config config$cdate
rc=$?
if [ $rc -eq 0 ]; then
  sed -i -e "s/EXTRAVERSION =.*/EXTRAVERSION = $cdate/g" Makefile 
  rc=$?
  if [ $rc -eq 0 ]; then
    make -j12 bzImage
    rc=$?
    if [ $rc -eq 0 ]; then
      make -j12 modules
      rc=$?
      if [ $rc -eq 0 ]; then
        make -j12 modules_install
        rc=$?
        if [ $rc -eq 0 ]; then 
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
		if [ ! -z "$menuentry" ]; then
                  grub2-set-default "$menuentry"
                  rc=$?
		else
                  #grubby --info=ALL
                  grubby --add-kernel=/boot/vmlinuz-$version  --title=$version --make-default
		  rc=$?
		fi
              fi
            fi
          fi
        fi
      fi
    fi
  fi
fi

echo "Compile $rc" >> state
echo "Compile $rc"

exit $rc
