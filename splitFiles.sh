#!/bin/bash
#This shell script splits a large folder of files into many smaller subfolders. You can define the no. of files in a subfolder.
# Doubts: printf "format"

# Checking input...

read -p "Create folder by Models Y/N:" optSplit

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

if [ $optSplit == 'Y' ] || [ $optSplit == 'y' ]; then
    files=(`ls *.mat | sed -e 's/.\{18\}$//' | uniq`)
    echo 'Number of GCMs:' ${#files[*]}

    for uqfile in ${files[*]}; do
       mkdir -p $uqfile
       echo $uqfile$ext
       find . -maxdepth 1 -name $uqfile'*' -exec mv {} $uqfile/ \;
    done
    exit
else
  if [ $optSplit == 'N' ] || [ $optSplit == 'n' ]; then
    read -p "Number of folders:" nfold
    files=(`ls *.mat `)
    nfilesByFold=$(( ${#files[*]} / $nfold ))
    mod=$(( ${#files[*]} % $nfold ))

    for folder in $(seq 1 $nFold)
      do
         pos=$(( $pos - 1 ))
         mkdir -p rep$folder
         mv ${files[*]:$pos:$nfilesByFold} rep$folder
      done

  fi
fi


