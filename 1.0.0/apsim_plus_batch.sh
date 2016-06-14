#!/bin/bash

# Check if the number of parameters is correct
if [ $# -ne 6 ]
then
    echo "Usage: apsim_plus_batch.sh <model_version> <json_input> <cultivar_input> <acmo_output> <apsim_input> <apsim_output>"
    exit -1
fi

THISDIR=`pwd`
#Uncomment the following line to trap the exceution somewhere
#THISDIR="/scratch/wrf/scratch/apsim_plus_batch"
cd $THISDIR

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

cat > run_me_for_debug.sh << EOF
source $DIR/env.sh
apsim_plus.sh $1 $2 $3 $4 $5 $6
EOF
chmod +x run_me_for_debug.sh

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

# Change to my root
cd $THISDIR

# Prepare JSON files
cp -f $JsonInput $PWD/json.zip
unzip -o -q json.zip -d json/
mkdir result
cd json
for file in *.json; do
{
  filename="${file%.*}"
  mkdir $THISDIR/result/$filename
  cp -f $filename.json $THISDIR/result/$filename/1.json
}
done
#cd ..
cd $THISDIR

# Prepare Cultivar files
source $UTIL_DIR/prepareCulFiles.sh "APSIM"

# Loop all the input JSON file
cd $THISDIR/result
for dir in */; do
{
  cd $dir
  batchId=${dir%/}
  
  # Run QuadUI
  source $UTIL_DIR/runAPSIM2ACMO.sh $batchId
  
  cd ..
}
done

cd $THISDIR/result

# Setup outputs
zip -r -q retIn.zip retIn_*
cp retIn.zip $apsimInput

zip -r -q retOut.zip retOut_*
cp retOut.zip $apsimOutput

zip -r -q acmo.zip *.csv
cp acmo.zip $AcmoOutput

#cd ..

exit 0
