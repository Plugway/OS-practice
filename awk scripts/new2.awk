{ 
    split($1, nums, "|");
    delta=nums[1];
    time=nums[2];
    if(delta ~ /^[0-9]*$/ || delta ~ /^[-][0-9]*$/ || delta ~ /^[0-9]*[.][0-9]*$/ || delta ~ /^[-][0-9]*[.][0-9]*$/)
    {
        res=delta%360.0;
    }
    else
    {
        print "the angle must be a number.";
        exit 3;
    }
    if( !( time ~ /^[0-9]*$/ || time ~ /^[-][0-9]*$/ || time ~ /^[0-9]*[.][0-9]*$/ || time ~ /^[-][0-9]*[.][0-9]*$/ ) || time <= 0)
    {
        print "the animation time must be a positive number.";
        exit 4;
    }
    print res;
}
