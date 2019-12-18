#!/bin/bash
helptext="normconf: normconf [filename]\n\n 
Normconf can make a normalized configuration file \"[filename] _normal.txt\".
Supports the following units:
time - s, min, h, d;
distance - mm, sm, dm, m, km;
mass - mg,g, kg, t.
Also supports addition and subtraction.\n\n
filename\tName of the file, you want to normalize."

if [[ "$1" = "" ]]; then
	echo "Write normconf -h or normconf --help for help";
	exit;
elif [[ "$1" = "-h" ]]; then
	echo -e "$helptext";
	exit;
elif [[ "$1" = "--help" ]]; then
	echo -e "$helptext";
	exit;
fi
if ! [ -f "$1" ]; then
	echo "Error. File does not exist.";
	exit 1;
fi
errorCount=0
filepath=$(realpath "$1")
filedir=$(dirname "$filepath")
filename=$(basename -- "$1")
filename="${filename%.*}"
savename="${filename}_normal.txt"
if [ -f "$savename" ]; then
	echo "File \"$savename\" already exist, can't save.";
	exit 1;
else
	touch "$filedir/$savename";
fi

while read -r line; do
	line="${line// /}"
	res=$(awk '
function alen(a, i) {
    for(i in a);
    return i;
}
{
       arrlen=0;
       curstr=$1;
       split(curstr, curarray, "");
       result="";
       curnum="";
       exprflag="f";
       numwr="f";
       unit="";
       minusFlag=1;
       split("", curExprArr, "");
       operCount=1;
       if(curstr !~ /=/)
       {
           print "Expr error.";
           exit 1;
       }
       for (j=1; j <= length(curstr); j++) 
       {
           if(curarray[j] != "=" && exprflag == "f")
           {
               result=sprintf("%s%s", result, curarray[j]);
           }
           else if(exprflag == "f")
           {
	       if(curarray[j+1] == "")
               {
                   print "An unit defenition error has occured.";
                   exit 1;
               }
               exprflag="t";
               result=sprintf("%s%s", result, "=");
           }
           else if(exprflag == "t" && curarray[j] ~ /^[0-9,.]+$/)
           {
               numwr="t";
               curnum=sprintf("%s%s", curnum, curarray[j]);
           }
           else if(exprflag == "t" && numwr == "t")
           {
               numwr="f";
               if(unit == "")
               {
                   if(((curarray[j] == "s" || curarray[j] == "h" || curarray[j] == "d") && curarray[j+1] !~ /^[A-Za-z]+$/ ) || sprintf("%s%s%s", curarray[j], curarray[j+1], curarray[j+2]) == "min")
                   {
                       unit="t";
                   }
                   else if ((curarray[j] == "m" && curarray[j+1] !~ /^[A-Za-z]+$/ ) || sprintf("%s%s", curarray[j], curarray[j+1]) == "mm" || sprintf("%s%s", curarray[j], curarray[j+1]) == "sm" || sprintf("%s%s", curarray[j], curarray[j+1]) == "dm" || sprintf("%s%s", curarray[j], curarray[j+1]) == "km")
                   {
                       unit="d";
                   }
                   else if (curarray[j] == "g" || curarray[j] == "t" || sprintf("%s%s", curarray[j], curarray[j+1]) == "mg" || sprintf("%s%s", curarray[j], curarray[j+1]) == "kg")
                   {
                       unit="m";
                   }
                   else
                   {
                       print "An unit defenition error has occured";
                       exit 1;
                   }
               }
               if(unit == "t")
               {
                   if(curarray[j] == "s")
                   {
                       curExprArr[alen(curExprArr, arrlen)+1]=curnum*minusFlag;
                   }
                   else if(curarray[j] == "h")
                   {
                       curExprArr[alen(curExprArr, arrlen)+1]=curnum*3600*minusFlag;
                   }
                   else if(curarray[j] == "d")
                   {
                       curExprArr[alen(curExprArr, arrlen)+1]=curnum*86400*minusFlag;
                   }
                   else if(sprintf("%s%s%s", curarray[j], curarray[j+1], curarray[j+2]) == "min")
                   {
                       curExprArr[alen(curExprArr, arrlen)+1]=curnum*60*minusFlag;
                   }
                   else
                   {
                       print "Time conversion error has occured";
                       exit 1;
                   }
               }
               else if(unit == "d")
               {
                   if(curarray[j] == "m")
                   {
                       curExprArr[alen(curExprArr, arrlen)+1]=curnum*minusFlag;
                   }
                   else if(sprintf("%s%s", curarray[j], curarray[j+1]) == "mm")
                   {
                       curExprArr[alen(curExprArr, arrlen)+1]=curnum/1000.0*minusFlag;
                   }
                   else if(sprintf("%s%s", curarray[j], curarray[j+1]) == "sm")
                   {
                       curExprArr[alen(curExprArr, arrlen)+1]=curnum/100.0*minusFlag;
                   }
                   else if(sprintf("%s%s", curarray[j], curarray[j+1]) == "dm")
                   {
                       curExprArr[alen(curExprArr, arrlen)+1]=curnum/10.0*minusFlag;
                   }
                   else if(sprintf("%s%s", curarray[j], curarray[j+1]) == "km")
                   {
                       curExprArr[alen(curExprArr, arrlen)+1]=curnum*1000*minusFlag;
                   }
                   else
                   {
                       print "Distance conversion error has occured";
                       exit 1;
                   }
               }
               else if(unit == "m")
               {
                   if(curarray[j] == "g")
                   {
                       curExprArr[alen(curExprArr, arrlen)+1]=curnum/1000.0*minusFlag;
                   }
                   else if(curarray[j] == "t")
                   {
                       curExprArr[alen(curExprArr, arrlen)+1]=curnum*1000*minusFlag;
                   }
                   else if(sprintf("%s%s", curarray[j], curarray[j+1]) == "mg")
                   {
                       curExprArr[alen(curExprArr, arrlen)+1]=curnum/1000000.0*minusFlag;
                   }
                   else if(sprintf("%s%s", curarray[j], curarray[j+1]) == "kg")
                   {
                       curExprArr[alen(curExprArr, arrlen)+1]=curnum*minusFlag;
                   }
                   else
                   {
                       print "Mass conversion error has occured";
                       exit 1;
                   }
               }
               minusFlag=1;
               curnum=0;
           }
           else if(exprflag == "t" && curarray[j] == "-")
           {
               minusFlag=-1;
           }
       }
       for(m in curExprArr)
       {
           if(m == alen(curExprArr, arrlen))
           {
               break;
           }
           fnum=curExprArr[m];
           snum=curExprArr[m+1];
           curExprArr[m+1]=fnum+snum;
       }
       result=sprintf("%s%s", result, curExprArr[alen(curExprArr, arrlen)]);
       if(unit == "t")
       {
           result=sprintf("%s%s", result, "s");
       }
       else if(unit == "d")
       {
           result=sprintf("%s%s", result, "m");
       }
       else if(unit == "m")
       {
           result=sprintf("%s%s", result, "kg");
       }
   print result;
}' <<< "$line")
if [ $? != 0 ]; then
	echo "$res in \"$line\""
	((errorCount++))
else
	echo "$res" >> "$filedir/$savename"
fi
done < "$filepath"
echo "Done. Errors: $errorCount"
