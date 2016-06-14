#!/bin/bash

# Check if the number of parameters is correct
if [ $# -ne 2 ]
then
    echo "Usage: apsim.sh <input> <output>"
    exit -1
fi

#Uncomment the following line to trap the exceution somewhere
THISDIR=`pwd`
#THISDIR="/scratch/wrf/scratch/apsim"
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
apsim.sh $1 $2
EOF
chmod +x run_me_for_debug.sh

input=$1
output=$2

echo Input: $input
echo Output: $output
echo Running in $PWD

tar xfz /mnt/galaxyTools/apsim_ria/model/7.5/apsim.tar.gz

APSIMDIR=$PWD
export LD_LIBRARY_PATH=$APSIMDIR:$APSIMDIR/Model:$APSIMDIR/Files:$LD_LIBRARY_PATH
export PATH=$APSIMDIR:$APSIMDIR/Model:$APSIMDIR/Files:$PATH

cp $input input.zip
unzip -o -q input -d APSIM/
cd APSIM
rename -v -f 'y/A-Z/a-z/' *.[Xx][Mm][Ll]
cd ..
mv -f ./APSIM/* .

mono Model/ApsimToSim.exe AgMip.apsim 2>/dev/null

tmp_fifofile="./control.fifo"
mkfifo $tmp_fifofile
exec 6<>$tmp_fifofile
rm $tmp_fifofile

thread=`cat /proc/cpuinfo | grep processor | wc -l`
echo "detect $thread cores, will use $thread threads to run APSIM"
for ((i=0;i<$thread;i++));do 
  echo
done >&6 

for file in *.sim; do
{
  read -u6
  filename="${file%.*}"
  Model/ApsimModel.exe $file >> $filename.sum 2>/dev/null
  echo >&6
} &
done
wait
exec 6>&-

mkdir ./output
mv -f *.out ./output
mv -f *.sum ./output
mv -f ACMO_meta.dat ./output
cd output
zip -r -q ../retOut.zip *
cd ..
cp retOut.zip $output
exit 0
