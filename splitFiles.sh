#!/bin/bash
#This shell script splits a large folder of files into many smaller subfolders. You can define the no. of files in a subfolder.

# First args should be the output folder


# Checking input...

read -p "Split or unsplit by models (split/unsplit):" optSplit

if [ -z "$1" ]; then
   echo "Please specify a directory to split, as a parameter to the script."
   exit
else
   if [ ! -d "$1" ]; then
      echo "directory $1 does not exist."
      exit
   fi
fi

# set variables
cd $1

if [ $optSplit == 'Split' ] || [ $optSplit == 'split' ]; then
    files=(`ls *.mat | sed -e 's/.\{18\}$//' | uniq`)
    echo 'Number of GCMs:' ${#files[*]}

    for uqfile in ${files[*]}; do
       mkdir -p $uqfile
       echo $uqfile$ext
       find -maxdepth 1 -name $uqfile'*' -exec mv {} $uqfile/ \;
    done
    exit
else
  if [ $optSplit == 'Unsplit' ] || [ $optSplit == 'unsplit' ]; then
    find . -name '*' -type f -exec mv -f {} . \;
    find -mindepth 1 -maxdepth 1 -type d -exec rm -r {} \;
  fi
fi


