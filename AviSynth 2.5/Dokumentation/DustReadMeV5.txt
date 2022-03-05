Dust Version 5 by Steady 01/23/2003

New parameters added. All are optional.

  output="YUY2/RGB/RGB32/RGB24"

The default is to output the same format as the input. RGB is the
same as RGB32. Dust works internally on YUV 4:4:4 planar
(One Y,U, and V for each pixel). Future versions may have the option
of working in RGB space.


-------------------------------------

  limit=5

Sets the strength of the temporal filtering. (How much it can change the
original pixel).Note that high settings (> ~8) will be 'overridden'
by other internal settings. The default settings are:

FaeryDust 2
PixieDust 5
GoldDust 8
SpaceDust Does not apply

-----------------------------------------------------------------------

FaeryDust uses temporal filtering only. It should preserve the maximum
detail. (Not really true yet with strong settings but will be :)
Recommended limit settings 1-5

SpaceDust is just the spatial filter from PixieDust. It is for those
who want the April version speed from Dust now :) It can improve the
visual quality quite a bit. However unlike PixieDust, It can only reduce
noise - not remove it. So the compression gains (and compressed quality)
will be less.

PixieDust is essentially FaeryDust + SpaceDust (with some twists). It is
probably the best to use for medium noise and those who shoot for
1-CD encodes. Recommended limit settings 3-8.

GoldDust uses heavier filtering. Not really very developed yet.