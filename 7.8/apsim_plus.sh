#!/bin/bash

modelVersion=$1
JsonInput=$2
CultivarInput=$3
AcmoOutput=$4
apsimInput=$5
apsimOutput=$6

echo modelVersion: $modelVersion
echo JsonInput: $JsonInput
echo CultivarInput: $CultivarInput
echo AcmoOutput: $AcmoOutput
echo apsimInput: $apsimInput
echo apsimOutput: $apsimOutput
echo Running in $PWD

UTIL_DIR=/mnt/galaxyTools/ria_util/1.0.0/

# Setup QuadUI and ACMOUI
source $UTIL_DIR/setupAgMIPTools.sh

# Setup APSIM model
source $UTIL_DIR/setupAPSIM.sh $modelVersion

# Prepare JSON files
batchId="1"
mkdir result
mkdir result/$batchId
cp -f $JsonInput $PWD/result/$batchId/1.json

# Prepare Cultivar files
source $UTIL_DIR/prepareCulFiles.sh "APSIM"

cd result

# Run QuadUI
cd $batchId
source $UTIL_DIR/runAPSIM2ACMO.sh $batchId
cd ..

# Setup outputs
cp retIn_$batchId.zip $apsimInput
cp retOut_$batchId.zip $apsimOutput
cp $batchId.csv $AcmoOutput

cd ..

exit 0
