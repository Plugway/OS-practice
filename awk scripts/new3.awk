function abs(v) {return v < 0 ? -v : v}
{ 
    split($1, nums, "|");
    totalTime=nums[1];
    deltaAngle=nums[2];
    localTotalFrames=1;
    if(deltaAngle%2==0 || deltaAngle%3==0 || deltaAngle%5==0 || deltaAngle == 1)
    {
        currentAngle=0;
        while(1)
        {
            currentAngle=(deltaAngle+currentAngle)%360;
            if(currentAngle == 0)
            {
                break;
            }
            else
            {
                localTotalFrames++;
            }
        }
    }
    else
    {
        currentAngle=0;
        deltaAngleAbs=abs(deltaAngle);
        if(deltaAngleAbs<180)
        {
            while(1)
            {
                currentAngle+=deltaAngle;
                if((currentAngle>=360 && deltaAngle>=0) || (currentAngle<=-360 && deltaAngle<0))
                {
                    break;
                }
                else
                {
                    localTotalFrames++;
                }
            }
        }
        else
        {
            isFirstIteration=1;
            while(1)
            {
                prevAngle=currentAngle;
                currentAngle+=deltaAngle;
                if((currentAngle>=360 && deltaAngle>=0) || (currentAngle<=-360 && deltaAngle<0))
                {
                    currentAngle=currentAngle%360;
                }
                if( !isFirstIteration && abs(prevAngle)<abs(currentAngle))
                {
                    break;
                }
                else
                {
                    localTotalFrames++;
                }
                isFirstIteration=0;
            }
        }
    }
    delayPerFrame=totalTime/localTotalFrames;
    totalFrames=localTotalFrames;
    res=sprintf("%s%s%s%s%s%s%s", delayPerFrame, "|", deltaAngle, "|", totalTime, "|", totalFrames);
    print res;
}
