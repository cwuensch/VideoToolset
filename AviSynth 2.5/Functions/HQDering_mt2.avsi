######
##
## HQDering v0.1 by mf
##
## Applies derining by using a smart smoother near edges (where ringing occurs) only.
##
## Usage: Import("HQDering-v0.1.avs")
##        HQDering()
##
####

LoadPlugin("C:\Programme\AviSynth 2.5\dll\mt_MaskTools_v2.0a32.dll")
#LoadPlugin("C:\Programme\AviSynth 2.5\dll\MaskTools_v1.5.8.dll")


function HQDering(clip input, int "strength", int "overall", clip "smoother") {

 strength = Default(strength, 255)	# strength, 0-255
 overall  = Default(overall, 0)		# overall smoothing, 0-255
 smoothed = defined(smoother) ? smoother : input.Deen("a3d",4,15,15,20)	# filter that smooths

 normalmask=input.mt_edge(thY1=3, thY2=255, mode="sobel", chroma="none")

 amplifiedmask=normalmask.Levels(0, 3.3, 90, 0, 255).Blur(1.0)

 thickmask=normalmask.mt_inflate().mt_inflate().mt_inflate().Levels(0, 3.3, 90, 0, 255)
  \ .Blur(1.0).mt_inflate().mt_inflate().mt_inflate().Levels(0, 3.3, 255, 0, 255)
  \ .mt_inflate().mt_inflate()

 ringingmask=mt_lutxy(amplifiedmask.mt_invert(), thickmask, expr="x y * 255 /").Levels(60, 3.0, 140, overall, strength)

 mt_merge(input, smoothed, ringingmask)

}