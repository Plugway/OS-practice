#!/bin/bash
helptext="shardcollect: shardcollect [dir]\n\n 
Shardcollect can print subdirs in which files are not executed.\n\n
dir\tProcessing dir. If not specified then the current directory is used."

if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
	echo -e "$helptext"
	exit 0
elif [[ "$1" == "" ]]; then
	pathString=$PWD
elif [[ "$1" == *"/"* ]]; then
	pathString=$1;
else
	exit 1;
fi
if ! [ -d "$pathString" ]; then
	echo -e  "ERROR: The specified directory does not exist."
	exit 1
fi
out=""
lsofout="$(lsof +D "$pathString" 2>/dev/null)"
IFS=
for i in "$pathString"*; do
	if [ -d "$i" ]; then
		if [ "$(grep "$i" <<< "$lsofout")" == "" ]; then
		    	echo "$i"
			out="$i"
		fi
	fi
done
if [[ "$out" == "" ]]; then
	exit 1;
fi
