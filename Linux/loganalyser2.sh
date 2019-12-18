#!/bin/bash
helptext="loganalyser: loganalyser [input_file]\n\n 
Loganalyser can find unique ip's with mark \"ERROR\" or \"FATAL\".\n\n
input_file\tLogs file."


if [[ "$1" == "" ]]; then
	echo "Type -h or --help for help"
	exit;
elif [[ "$1" == "-h" ]]; then
	echo -e "$helptext";
	exit;
elif [[ "$1" == "--help" ]]; then
	echo -e "$helptext";
	exit;
fi
outarr=()
while read -r line; do
linem="${line//' '}"
oldIFS=$IFS
IFS="|"
read -ra ADDR <<< "$linem"
IFS=$oldIFS
flag="f"
if [[ "${ADDR[0]}" == "ERROR" ]] || [[ "${ADDR[0]}" == "FATAL" ]]; then
	for i in "${outarr[@]}"; do
		if [[ "$i" == "${ADDR[2]}" ]]; then
			flag="t";
		fi
	done
	if [[ "$flag" == "f" ]]; then
		outarr+=("${ADDR[2]}");
		echo "${ADDR[2]}";
	fi
fi
done < "$1"
