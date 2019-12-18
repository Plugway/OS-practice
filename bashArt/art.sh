#!/bin/bash

input=$1

if [[ "$input" == "--help" ]] || [[ "$input" == "-h" ]]; then
	echo "$(<./help.txt)";
elif [[  "$input" == "animation" ]]; then
	./animation.sh;
elif [[  "$input" != "" ]]; then
	echo -e "$(<./images/$input.txt)";
else
	echo "Type -h or --help for help";
fi
