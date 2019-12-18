{
       curstr=$1;
       split(curstr, curarray, "")
       result="";
       curnum="";
       exprflag="f";
       numwr="f";
       unit="";
       minusFlag=1;
       failFlag="f";
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
           else if(exprflag == "t" && curarray[j] ~ /^[0-9]+$/)
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
                       print "An unit defenition error has occured.";
                       exit 1;
                   }
               }
               if(unit == "t")
               {
                   if(curarray[j] == "s")
                   {
                       curExprArr[length(curExprArr)+1]=curnum*minusFlag;
                   }
                   else if(curarray[j] == "h")
                   {
                       curExprArr[length(curExprArr)+1]=curnum*3600*minusFlag;
                   }
                   else if(curarray[j] == "d")
                   {
                       curExprArr[length(curExprArr)+1]=curnum*86400*minusFlag;
                   }
                   else if(sprintf("%s%s%s", curarray[j], curarray[j+1], curarray[j+2]) == "min")
                   {
                       curExprArr[length(curExprArr)+1]=curnum*60*minusFlag;
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
                       curExprArr[length(curExprArr)+1]=curnum*minusFlag;
                   }
                   else if(sprintf("%s%s", curarray[j], curarray[j+1]) == "mm")
                   {
                       curExprArr[length(curExprArr)+1]=curnum/1000.0*minusFlag;
                   }
                   else if(sprintf("%s%s", curarray[j], curarray[j+1]) == "sm")
                   {
                       curExprArr[length(curExprArr)+1]=curnum/100.0*minusFlag;
                   }
                   else if(sprintf("%s%s", curarray[j], curarray[j+1]) == "dm")
                   {
                       curExprArr[length(curExprArr)+1]=curnum/10.0*minusFlag;
                   }
                   else if(sprintf("%s%s", curarray[j], curarray[j+1]) == "km")
                   {
                       curExprArr[length(curExprArr)+1]=curnum*1000*minusFlag;
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
                       curExprArr[length(curExprArr)+1]=curnum/1000.0*minusFlag;
                   }
                   else if(curarray[j] == "t")
                   {
                       curExprArr[length(curExprArr)+1]=curnum*1000*minusFlag;
                   }
                   else if(sprintf("%s%s", curarray[j], curarray[j+1]) == "mg")
                   {
                       curExprArr[length(curExprArr)+1]=curnum/1000000.0*minusFlag;
                   }
                   else if(sprintf("%s%s", curarray[j], curarray[j+1]) == "kg")
                   {
                       curExprArr[length(curExprArr)+1]=curnum*minusFlag;
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
           if(m == length(curExprArr))
           {
               break;
           }
           fnum=curExprArr[m];
           snum=curExprArr[m+1];
           curExprArr[m+1]=fnum+snum;
       }
       result=sprintf("%s%s", result, curExprArr[length(curExprArr)]);
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
}
