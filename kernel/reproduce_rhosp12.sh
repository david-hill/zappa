cd /var/lib/jenkins/cloud/
rc=$?
if [ $rc -eq 0 ]; then
  git checkout 12.0
  rc=$?
  if [ $rc -eq 0 ]; then
    sed -i 's/rhel=.*/rhel=7.3/g' setup.cfg.local
    rc=$?
    if [ $rc -eq 0 ]; then
      sed -i 's/releasever=.*/releasever=rhosp12/g' setup.cfg.local
      rc=$?
      if [ $rc -eq 0 ]; then
        sed -i 's/minorver=.*/minorver=12.0/g' setup.cfg.local
        rc=$?
        if [ $rc -eq 0 ]; then
          bash delete_virsh_vms.sh
          rc=$?
          if [ $rc -eq 0 ]; then
            bash delete_undercloud.sh
            rc=$?
            if [ $rc -eq 0 ]; then
              bash create_undercloud.sh internal
              rc=$?
              if [ $rc -eq 0 ]; then
                bash stop_vms.sh
                rc=$?
              fi
            fi
          fi
        fi
      fi
    fi
  fi
fi

echo "Reproduce $rc" >> /usr/src/kernels/linux-stable-new/state
echo "Reproduce $rc"

exit $rc
