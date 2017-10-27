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
  if [[ $message =~ error ]]; then 
    if [ -d /home/stack ]; then 
      touch /home/stack/failed 
    fi 
  fi 
} 

if [ "$1" == "-f" ]; then
  force=1
else
  force=0
fi

startlog "Building kernel"

git checkout Makefile 2>>$stderr 1>>$stdout
rc=$?
if [ $rc -eq 0 ]; then
  git checkout master 2>>$stderr 1>>$stdout
  rc=$?
  if [ $rc -eq 0 ]; then
    git pull 2>>$stderr 1>>$stdout
    rc=$?
    if [ $rc -eq 0 ]; then
      gver=$(git tag | sort -V | grep -v rc | tail -1)
      pver=$(cat previous)
      if [[ $gver != $pver ]] || [ $force == 1 ]; then
        git checkout ${gver}
        rc=$?
        if [ $rc -eq 0 ]; then
          git pull origin ${gver}
          rc=$?
          if [ $rc -eq 0 ]; then
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
                            grub2-set-default "$menuentry"
                            rc=$?
                            if [ $rc -eq 0 ]; then
                              echo "$gver" > previous
                              endlog "done"
                            fi
                          fi
                        fi
                      fi
                    fi
                  fi
                fi
              fi
            fi
          fi
        fi
      else
        endlog "warning"
      fi
    fi
  fi
fi

exit $rc
