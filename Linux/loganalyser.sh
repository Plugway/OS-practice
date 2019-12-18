#!/bin/bash
function index
{
	for i in "${!sourcearr[@]}"; do
   		if [[ "${sourcearr[$i]}" = "$1" ]]; then
		       echo "${i}";
		fi
	done
}

function indexcount
{
	for i in "${!sourcecount[@]}"; do
   		if [[ "${sourcecount[$i]}" = "$1" ]]; then
		       echo "$i";
		fi
	done
}

helptext="loganalyser: loganalyser [input_file]\n\n 
Loganalyser can find most requested server.\n\n
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
if ! [ -f "$1" ]; then
echo "File doesn't exist"
exit 1;
fi
sourcearr=()
sourcecount=()
counter=0
for res in $( cut -d '|' -f 4 < "$1" | sort | uniq | sed -e 's/[[:space:]]*$//' ); do
	COUNT=$( grep -o "$res" <<< "$( cat "$1" )" | wc -l)
	sourcecount[$counter]=$COUNT
	sourcearr[$counter]=$res
	counter="$(( counter + 1 ))"
done
maxval="$(echo "${sourcecount[@]}" | awk -v RS=' ' '1' | sort -r | head -1)"
resindex="$( indexcount "$maxval")"
echo "${sourcearr[$resindex]}" with result "${sourcecount[$resindex]}"
