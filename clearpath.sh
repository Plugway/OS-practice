#!/bin/bash
helptext="clearpath: clearpath [input]\n\n 
Clearpath can clear PATH or input string with delimeter(:).\n\n
input\tString you want to clear."


if [[ "$1" == "" ]]; then
	pathString=$PATH
elif [[ "$1" == "-h" ]] && [[ "$1" == "--help" ]]; then
	echo -e "$helptext"
	exit 0
elif [[ "$*" == *":"* ]]; then
	pathString="$*"
elif [[ "$*" == *"/"* ]]; then
	if [[ -n $(find "$*" -executable -type f) ]] 2>/dev/null ; then
		echo "$*"
		exit 0
	fi
	exit 0
fi
pathString="${pathString%'"'}"
pathString="${pathString#'"'}"
pathString="${pathString%"'"}"
pathString="${pathString#"'"}"
output=""
oldIFS=$IFS
IFS=":"
read -ra sortedADDR <<< "$( echo "$pathString" | tr ':' '\n' | awk -v RS='[\n]+' '!n[$0]++' | tr '\n' ':')"
IFS=$oldIFS
for i in "${sortedADDR[@]}"; do
	if [[ -n $(find "$i" -maxdepth 1 -executable -type f ) ]] 2>/dev/null ; then
		output+=":$i"
	fi
done
output="${output:1}"
echo "$output"
