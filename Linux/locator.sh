#!/bin/bash
helptext="locator: locator [filename]\n\n 
Locator can find interna/external commands or files using PATH.\n\n
filename\tName of the command or file, you want to find."

if [[ "$1" = "" ]]; then
	echo "Write locator -h or locator --help for help";
	exit;
elif [[ "$1" = "-h" ]]; then
	echo -e "$helptext";
	exit;
elif [[ "$1" = "--help" ]]; then
	echo -e "$helptext";
	exit;
fi
interc="f"
if compgen -bk | grep -wq "$1"; then
	interc="t"
fi

IFS=":"
read -ra ADDR <<< "$PATH"

if ! [[ -x $1 ]] || [[ -d $1 ]]; then
	echo "Не исполняемый файл $1"
	exit 1;
fi

for i in "${ADDR[@]}"; do
	if [ -x "$i/$1" ]; then
		if [[ "$i" == "/bin" ]] && [[ "$interc" == "t" ]]; then
			echo "Found external command $1 at /bin/";
			exit;
		fi
		if [[ "$interc" == "t" ]]; then
			echo "Found internal command $1";
			exit;
		fi
		
		echo "Found: $i/$(basename -- $1)";
		exit;
	fi
done

if [[ "$1" == *"/"* ]] && [[ -f $1 ]]; then
	echo "Found: $(readlink -f "$1")";
	exit;
fi

echo "Nothing found :("
