medianblur 0.84

made by Tonny Petersen (tsp@person.dk)

medianblur is a spatial median blur filter with a variable radius.
 If you want to use it with radius 1 consider using removegrain(mode=4) instead.
medianblurcw is a centerweighted medianblur filter with a variable radius.
medianblurb is binary medianblur filter. It will take advantage of integer SSE if present.
medianblurt is a temporal-spatial median blur filter with optional motion compensation using Manaos MVTools. 
If you want to use it with a temporal and spatial radius of 1 consider using DeGrainMedian(limitY=255,limitUV=255,mode=0)

ML3Dex means extended multilevel 3 Dimensional filtering. This filter should cause less artifact compared to medianblurt while removing the same amount of noise. This filter can also use MVTools for motion compensation. The filter is based on the description in: MOTION PICTURE RESTORATION. by Anil
 Christopher Kokaram. Ph.D. Thesis. May 1993 (http://www.mee.tcd.ie/~ack/papers/a4ackphd.ps.gz) (Fizick thanks for finding this ;-) )



Usage:

medianblur(clip,int radiusy,int radiusu,int radiusv,bool calcborder)

radiusy,u & v: specify the radius to use. Default is 2. If the supplied radius is between -1 and -255
 the plane is set to -radius. If the the radius is 0 the plane is copied unaltered. If the radius is
 less than -255 the plane isn't processed at all.

calcborder: if true (default) the borders of the frame is filtered too. If false then the border is copied from the source clip.

for the centerweighted version:



medianblurcw(clip,int radiusy,int radiusu,int radiusv,int weighty,int weightu,weightv, bool calcborder)

weighty,u & v: specify the centerweight = number of times the centerpixel should be replicated. Default 1.



binary mask version:

medianblurcw(clip,int radiusy,int radiusu,int radiusv,int thresholdy,int thresholdu,thresholdv, bool calcborder)

thresholdy,u & v: specify the threshold to use to make the mask. Afterwards the mask is medianblured. Default 127.


temporal medianblur:


medianblurt(clip,int radiusy,int radiusu,int radiusv,int temporalradius, bool mc, bool calcborder,bool markscenechange,int blksize,int pel,int lambda, int thSCD1, int thSCD2,bool spfull,bool bsfull)

radiusy,u & v: same as medianblur with the small difference that radius can be set to 0.
 This disable spatial blurring. If you want to copy the plane set it to -1

temporalradius: Number of frames to search before and after current frame. Default 2.

mc: Use Motion Compensation. This is achieved using Manaos MVTools. It's has only been tested with version 0.9.8.1 . 
Get it in this thread: http://forum.doom9.org/showthread.php?s=&threadid=84770&perpage=20&pagenumber=1 or here http://manao4.free.fr/MVTools-v0.9.8.1.zip 
Don't use version 0.9.8.0. This version would cause an error. Default is false. 

markscenechange: If set to true there will be a red square in the upper left corner when MVTools detects a scenechange.
If this happens to often the temporal filtering will be decreased. Increase thSCD1 or thSCD2. Default false.

blksize,pel,lambda,thSCD1,thSCD2,searchparam: Parameters to control MVTools. for the meaning of each parameter see MVTools documentation.
Defaults:blksize 4, pel 1, lambda 1000,thSCD1 200,thSCD2 175,searchparam=1

bsfull,spfull: If set to true the blocksize(bsfull) and/or searchparam(spfull) are applied to the frames before the current frame and the frames after.
 If set to false then they are only applied to the frames before the current frame. This speeds the motion compensation up but decrease the posible noise reduction.
 Defaults are false,false.
 

extended Multi Level 3Dimensional:

ml3dex(clip,bool mc, int Y, int U, int V,bool markscenechange, int blksize, int pel, int lambda, int thSCD1, int thSCD2,bool spfull,bool bsfull)

good values for cartoons are ml3dex(blksize=4,searchparam=60,lambda=0,thSCD1=1000)

mc: Use Motion Compensation. This is achieved using Manaos MVTools. It's has only been tested with version 0.9.8.1 and 0.9.8.4. 
Get it in this thread: http://forum.doom9.org/showthread.php?s=&threadid=84770&perpage=20&pagenumber=1 or here http://manao4.free.fr/MVTools-v0.9.8.1.zip 
Don't use version 0.9.8.0. This version would cause an error. Default is false. 

markscenechange: If set to true there will be a red square in the upper left corner when MVTools detects a scenechange.
If this happens to often the filter can't remove scratches and larger defects as efficient. Increase thSCD1 or thSCD2. Default false.

blksize,pel,lambda,thSCD1,thSCD2,searchparam: Parameters to control MVTools. for the meaning of each parameter see MVTools documentation.
Defaults: blksize 8, pel 1, lambda 1000,thSCD1 200,thSCD2 200,searchparam=1


Y,U,V: Controls which planes the filter is applied to. If set to 3 the plane will be filter, if 2 the plane will be copied from the source,
 if 1 the plane will be ignored and from 0 to -255 the plane will be assigned the absolute value. Default Y 3,U=2, V=2


mc: Use Motion Compensation. This is achieved using Manaos MVTools. It's has only been tested with version 0.9.8.1 and 0.9.8.4. 
Get it in this thread: http://forum.doom9.org/showthread.php?s=&threadid=84770&perpage=20&pagenumber=1 or here http://manao4.free.fr/MVTools-v0.9.8.1.zip 
Don't use version 0.9.8.0. This version would cause an error. Default is true. 

blksize,pel,lambda,thSCD1,thSCD2: Parameters to control MVTools. for the meaning of each parameter see MVTools documentation.
Defaults: blksize 4, pel 1, lambda 1000,thSCD1 200,thSCD2 175

bsfull,spfull: If set to true the blocksize(bsfull) and/or searchparam(spfull) are applied to the frames before the current frame and the frames after.
 If set to false then they are only applied to the frames before the current frame. This speeds the motion compensation up but decrease the posible noise reduction.
 Defaults are false,false.



changelog:

Version 0.1	First version. Really slow and buggy. Used a modified bubblesort to find the median causing the filter to be extremely slow with large radii.

Version 0.2	Changed the sort algorithm to radix sort resulting in a great speed improvement especially for large radii. Also fixed a couple of bugs.

Version 0.3	optimized the sort algorithm even more. Also added the ability to process the borders.

version 0.31 bugfix. Should make the same output as tmedianblur except for the borders.

version 0.4	Added medianblurcw a centerweighted median blur

version 0.5	Added medianblurb and medianblurt. 

version 0.6 Fixed a couple of bugs and added iteger SSE optimization for medianblur for radius below 4. This results in a 85-400% speed increase

version 0.65 More bugs removed. Added assembler optimization resulting in 30-60% speedincrease for medianblurcw, medianblurt and medianblur(for radius >3)

version 0.7 Added support for motion compensation in medianblurt using manaos MVTools.

version 0.8 Added ML3Dex a multilevel temporal medianblur filter that can use MVTools for motion compensation.

version 0.81 Bugfixes and added an option to show when mvtools detects a scenechange.

version 0.82 fixed a bug that caused a access violating in medianblurt and ml3dex

version 0.83 fixed a bug causing a memory leak with motion compensation. Now calls MVTools with named arguments. This should increase support of different versions of MVTools.

version 0.84 Added the option searchparam bsfull and spfull to ml3dex and medianblurt.

sourcecode released under GPL se copying.txt

Thanks to Manao for creating MVTools.
