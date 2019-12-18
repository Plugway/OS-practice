#!/bin/bash

function float
{
	bc -q 2> /dev/null
}

helptext="\e[38;05;10;1mINFO
\e[0mImageMagick: imagemagick angle animation_time image_name [output_file_name]\n
ImageMagick can get image and return an animation of its rotation\n
angle\t\t rotation angle in degrees per frame
animation_time\t the time during which the image will make a full turnover, is set in hundredths of a second
image_name\t name of the image you want to use
output_file_name name of the file to be created"

if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
	echo -e "$helptext";
	exit;
elif [[ "$1" == "" ]]; then
	echo "Write locator -h or locator --help for help";
	exit;
fi

deltaAngle=$1
totalTime=$2
res=$(awk '{split($1, nums, "|");delta=nums[1];time=nums[2];if(delta ~ /^[0-9]*$/ || delta ~ /^[-][0-9]*$/ || delta ~ /^[0-9]*[.][0-9]*$/ || delta ~ /^[-][0-9]*[.][0-9]*$/){res=delta%360.0;}else{print "the angle must be a number.";exit 3;}if( !( time ~ /^[0-9]*$/ || time ~ /^[-][0-9]*$/ || time ~ /^[0-9]*[.][0-9]*$/ || time ~ /^[-][0-9]*[.][0-9]*$/ ) || time <= 0){print "the animation time must be a positive number.";exit 4;}print res;}' <<< "$deltaAngle|$totalTime")
ecode=$?
if [ $ecode != 0 ]; then
	echo -e "\e[38;05;9;1mERROR(Code $ecode):\e[0m $res";
	exit 1;
else
	deltaAngle=$res;
fi
inputFile=$3

if ! identify "$inputFile" 2>/dev/null >/dev/null || file "$3" | grep -q "GIF" 2>/dev/null; then
	echo -e "\e[38;05;9;1mERROR(Code 1):\e[0m the specified input file must exist and must be an image.";
	exit 1;
fi

if [[ "$4" != "" ]]; then
	outputFile=$4;
else
	outputFile=${inputFile%.*}.gif;
fi

if [[ -e "$outputFile" ]]; then 
	echo -e "\e[38;05;11;1mWARNING: \e[0mthe specified output file already exists. Overwrite? (Y/N) ";
	read -r userInput;
	if [ "${userInput,,}" == "y" ]; then
		: 	
	elif [ "${userInput,,}" == "n" ]; then
		echo Stopping.;
		exit 0;
	else
		echo -e "\e[38;05;9;1mERROR(Code 2):\e[0m user input not recognized, stopping.";
		exit 1;
	fi
fi




temp=$PWD/temp
tempFolder=$temp
counter=1
while [ -e "$tempFolder" ]
do
	tempFolder=$temp$counter
	counter=$((counter+1))
done
mkdir "$tempFolder"

res2=$(awk 'function abs(v) {return v < 0 ? -v : v}{split($1, nums,"|");totalTime=nums[1];deltaAngle=nums[2];localTotalFrames=1;if(deltaAngle%2==0||deltaAngle%3==0 || deltaAngle%5==0 || deltaAngle == 1){currentAngle=0;while(1){currentAngle=(deltaAngle+currentAngle)%360;if(currentAngle == 0){break;}else{localTotalFrames++;}}}else{currentAngle=0;deltaAngleAbs=abs(deltaAngle);if(deltaAngleAbs<180){while(1){currentAngle+=deltaAngle;if((currentAngle>=360 &&deltaAngle>=0) || (currentAngle<=-360 && deltaAngle<0)){break;}else{localTotalFrames++;}}}else{isFirstIteration=1;while(1){prevAngle=currentAngle;currentAngle+=deltaAngle;if((currentAngle>=360 && deltaAngle>=0) || (currentAngle<=-360 && deltaAngle<0)){currentAngle=currentAngle%360;}if( !isFirstIteration && abs(prevAngle)<abs(currentAngle)){break;}else{localTotalFrames++;}isFirstIteration=0;}}}delayPerFrame=totalTime/localTotalFrames;totalFrames=localTotalFrames;res=sprintf("%s%s%s%s%s%s%s", delayPerFrame, "|", deltaAngle, "|", totalTime, "|", totalFrames);print res;}' <<< "$totalTime|$deltaAngle")

oldifs=$IFS
IFS="|"
read -ra ARR <<< "$res2"
IFS=$oldifs
totalTime=${ARR[2]}
deltaAngle=${ARR[1]}
totalFrames=${ARR[3]}
delayPerFrame=${ARR[0]}
echo totalTime="$totalTime"
echo totalFrames="$totalFrames"
echo delayPerFrame="$delayPerFrame"
echo deltaAngle="$deltaAngle"
if [ "$(float <<< "$delayPerFrame <= 1")" -eq "1" ]; then
	if [ "$(float <<< "$deltaAngle % 1 == 0")" -eq "1" ] && [ "$(float <<< "$totalTime % 1 == 0")" -eq "1" ]; then
	echo -en "\e[38;05;11;1mWARNING: 
\e[0mThe delay per frame ended up being 0.
Resulting gif cycle may take longer than $totalTime centiseconds.

Do you wish to continue with the original parameters? (Y/N) "
	read -r userInput
	if [ "${userInput,,}" == "y" ]; then
		:
	elif [ "${userInput,,}" == "n" ]; then
		echo Stopping.
		exit
	else
		echo -e "\e[38;05;9;1mERROR(Code 2):\e[0m user input not recognized, stopping."
		exit 1
	fi
fi
fi
if [ "$(float <<< "$deltaAngle % 2 == 0")" -eq "0" ] && [ "$(float <<< "$deltaAngle % 3 == 0")" -eq "0" ] && [ "$(float <<< "$deltaAngle % 5 == 0")" -eq "0" ] && [ "$(float <<< "${deltaAngle#-} == 1")" -eq "0" ]; then
	echo -en "\e[38;05;11;1mWARNING: \e[0mWith the specified angle the picture never ends up rotating in a full circle.
Do you wish to continue? (Y/N)"
	read -r userInput
	if [ "${userInput,,}" == "y" ]; then
		:
	elif [ "${userInput,,}" == "n" ]; then
		echo Stopping.
		exit
	else
		echo -e "\e[38;05;9;1mERROR(Code 2):\e[0m user input not recognized, stopping."
		exit 1
	fi
fi

currentAngle=0
totalFrames=${totalFrames#-}
delayPerFrame=${delayPerFrame#-}
for (( i = 0; i < totalFrames; ++i )); do
	echo Processing frame "$i"
	convert -virtual-pixel transparent -distort SRT $currentAngle +repage "$inputFile" "$tempFolder"/temp"$i".jpg
	currentAngle=$(float <<< "$currentAngle + $deltaAngle");
done
totalFramesFix=$((totalFrames - 1))
convert -dispose background -delay "$delayPerFrame" -loop 0 "$tempFolder"/temp%d.jpg[0-$totalFramesFix] "$outputFile"
rm -rf "$tempFolder"
echo Done.
