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

# git revert git revert 1e6f74536de08b5e50cf0e37e735911c2cef7c62
# git revert 1f8b977ab32dc5d148f103326e80d9097f1cefb5 
# ("sock: enable MSG_ZEROCOPY")
# git revert c1d1b437816f0afa99202be3cb650c9d174667bc 
# ("net: convert (struct ubuf_info)->refcnt to refcount_t") 
# git revert 581fe0ea61584d88072527ae9fb9dcb9d1f2783e
cdate="-"
cdate=$cdate$(date +"%Y%m%d%H%M%S")
startlog "Backup config file"
cp .config config$cdate
rc=$?
if [ $rc -eq 0 ]; then
   endlog "done"
  startlog "Updating kernel version"
  sed -i -e "s/EXTRAVERSION =.*/EXTRAVERSION = $cdate/g" Makefile 
  rc=$?
  if [ $rc -eq 0 ]; then
    endlog "done"
    startlog "Compiling kernel"
    make -j12 bzImage
    rc=$?
    if [ $rc -eq 0 ]; then
      endlog "done"
      startlog "Compiling modules"
      make -j12 modules
      rc=$?
      if [ $rc -eq 0 ]; then
        endlog "done"
        startlog "Installing modules"
        make -j12 modules_install
        rc=$?
        if [ $rc -eq 0 ]; then 
          endlog "done"
          startlog "Copying kernel"
          version=$(cat include/config/kernel.release)
          cp arch/x86/boot/bzImage /boot/vmlinuz-$version
          rc=$?
          if [ $rc -eq 0 ]; then
            endlog "done"
            startlog "Generating new initramfs"
            dracut -f /boot/initramfs-$version.img $version
            rc=$?
            if [ $rc -eq 0 ]; then
              endlog "done"
              startlog "Updating grub configuration"
              grub2-mkconfig -o /boot/grub2/grub.cfg
              rc=$?
              if [ $rc -eq 0 ]; then
                menuentry=$(grep $version /boot/grub2/grub.cfg  | grep menuentry | awk -F\' '{ print $2 }')
                startlog "Setting default kernel to $menuentry"
                grub2-set-default "$menuentry"
                rc=$?
                if [ $rc -eq 0 ]; then
                  echo "$gver" > previous
                  endlog "done"
                else
                  endlog "error"
                fi
              fi
            else
              endlog "error"
            fi
          else
            endlog "error"
          fi
        else
          endlog "error"
        fi
      else
        endlog "error"
      fi
    else
      endlog "error"
    fi
  else
    endlog "error"
  fi
else
  endlog "error"
fi

exit $rc
