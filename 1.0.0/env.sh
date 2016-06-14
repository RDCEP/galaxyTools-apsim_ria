#!/bin/bash

if [ -z "$PACKAGE_BASE" ];
then
  # For testing purposes
  export PACKAGE_BASE="/mnt/galaxyTools/apsim_ria/1.0.0"
  echo "Setting PACKAGE_BASE=$PACKAGE_BASE"
  source /mnt/galaxyTools/mono/2.10/env.sh
  #source /mnt/galaxyTools/mono/4.2.3/env.sh
  source /mnt/galaxyTools/boost/1.51.0/env.sh
  source /mnt/galaxyTools/pymodules/default/env.sh
fi

export PATH="/mnt/galaxyTools/apsim_ria/1.0.0:$PATH"
export APSIM="/mnt/galaxyTools/apsim_ria/1.0.0"
