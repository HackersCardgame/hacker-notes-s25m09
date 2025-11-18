  484  man mdadm
  485  mdadm --assemble --run --readonly /dev/md65 /dev/sd[acde]1
  486  mdadm --assemble --run --readonly /dev/md65 /dev/sd[acdef]1
  489  mdadm --assemble --run --readonly /dev/md65 /dev/sd[acdef]1
  490  mdadm --stop /dev/md65 
  491  mdadm --assemble --run --readonly /dev/md65 /dev/sd[acdef]1
  492  mdadm --assemble --run --readonly /dev/md65 /dev/sd[cdef]1
  499  history  |grep mdadm
  500  history  |grep mdadm |less
  501  mdadm --assemble --run --readonly /dev/md65 /dev/sd[bcdef]1
  502  mdadm --stop /dev/md65 
  503  mdadm --assemble --run --readonly /dev/md65 /dev/sd[bcdef]1
  505  history |mdadm >>start-raid.sh
  506  history |grep mdadm >start-raid.sh
