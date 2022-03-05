Functions regarding interlace treatment by scharfis_brain | Dec. 20th, 2005
===========================================================================

Misc.:
------

function ReYV12(Clip Input)

	- reverts YUY2 decoded PAL-DV to its native DV-YV12
	- will enhance quality and processing speed
	- needs yuy2 input (ie. canopus-dv-decoder)
	- only works properly with BFF.
	- this is a workaround for commercial DV-Decoders, only!
	- better use ffdshow or Cedocida with direct YV12 output enabled
	- todo: add a function reYUY2(), to reacreate YUY2 after conversion, 
	  because U and V aren't in place with MPEG2-YV12!


ReInterlace(clip Input, bool "YV12")

	- returns a progressive clip into a weaved interlaced one. Output framerate will be halved.
	- by default it converts YV12 to YUY2, because most of the encoders will NOT treat
	  interlaced YV12 the correct way.
	- if you should need interlaced YV12 though, you may set YV12=True .



Wrapped deinterlacing functions:
--------------------------------

all these wrapped deinterlacing functions have those behaviours in common:
	- taking care of the fieldorder of the input
	- assuming framebased and the fieldorder of the input for the output
	- being compatible with YUY2 and YV12
	- doing a dumb (non-thresholded) bob


DumbBob(clip i, int "Height")

	- a wrapped bob(0, 0.5, height) (lossless for the current field)
	- height specifies a new image height


TomsBob(clip i, int "se")

	- wrapped tomsmocomp(-1, se, 0)
	- fast ELA-bob, se=0 by default


KrnlBob(clip Input, int "Threshold")

	- fast kernel bob, th=0 by default


EEDIbob(clip Input, int "maxd")

	- slow, but accurate EEDI-bob, always dumb ;)

SangBob(clip Input, int "aa")
	- very fast dumb EDI-bob with pretty good abilities to connect diagenals.
	- Be careful: it is prone to artifacting

PointBob(clip Input)
	- Bobbing by vertical pixel doubling.
	- does NOT accept YV12!

Advanced deinterlacing functions:
---------------------------------
They have the same in common like the wrapped functions, except the dumb-bob thing.


SecureBob(clip Input, int "Threshold", int "Length", int "Type")

	- deinterlacer that avoids residual combing with tricky motion at all cost 
	  using a quite long temporal motion mask.
	- "Threshold" declares the motion detection strenght. It is 6 by default.
	- zero Threshold won't disable motion detection! It will still weave bit-identical areas!
	- Threshold = -1 will disable motion detection.

	- "Lenght" declares the temporal lenght of the motion mask:
	- 0 -> 16 fields, most secure, static areas need some time to calm down.
	- 1 ->  8 fields, pretty secure
	- 2 ->  4 fields, unsecure
	- 3 ->  2 fields, useless, most times, but static areas are calmed down immediatelly

	- "Type" declares the kind of interpolation applied to moving areas:
	- 0 -> Bicubic from bob()
	- 1 -> Tomsmocomp() ELA-style of interpolation
	- 2 -> v-t kernel interpolation from Kerneldeint()
	- 3 -> EDI interpolatian from triticals EEDI2()
	- 4 -> EDI interpolation from MarcFD's Sangnom()

	- securedeint bases on the previously described wrapped deinterlacing functions




MvBob(clip Input, int "BlkSize", int "Pel", int "CorrectTh", int "Threshold", int "Type")

	- it is a motion compensated deinterlacer. Its image quality is superiour to all
	  other deinterlacers in most cases. It calms down moving image detail (no flicker), 
	  reduces noise (by accident :) ) and of course squeezes out every bit of image 
	  detail without introducing new kinds of artifacts.

	- int "Blksize" and "Pel" are directly taken from mvtools. Defaults 8 and 2
	- int "Threshold" is the deinterlacing threshold of the internal motion adaptive
	  deinterlacer. It is directly passed to the internal used SecureBob()
	- int "Type" defines the interpolation method of the inrternal used deinterlacer (see SecureBob())
	- int "CorrectTh" threshold for correcting false compensated areas. The higher the threshold
	  the more combing you'll get. Default 8

needed plugins:
(needs updating)
---------------
LoadPlugin("RemoveGrain_v10pre1.dll") # by kassandro      ( http://home.arcor.de/kassandro/ )

loadplugin("masktools.dll")           # by manao          ( http://manao4.free.fr/ )

loadplugin("mvtools.dll")             # by manao & fizick ( http://avisynth.org.ru/fizick.html )

loadplugin("leakkerneldeint.dll")     # by neuron2        ( http://neuron2.net/ ) 
                                         & leak           ( http://gast3.ssw.uni-linz.ac.at/~kp/AviSynth/ )

loadplugin("eedi2.dll")               # by tritical       ( http://bengal.missouri.edu/~kes25c/ )

loadplugin("tomsmocomp.dll")          # by TR Barry       ( http://home.comcast.net/~trbarry/downloads.htm )
loadplugin("undot.dll")               # by TR Barry 


These plugins are released under the terms of the GPL.
A complete package with sources can be found at: http://home.arcor.de/scharfis_brain/mvbob/mvbob-sources.rar