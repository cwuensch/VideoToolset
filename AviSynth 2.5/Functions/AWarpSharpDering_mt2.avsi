#
# AWarpSharpDering 1.0 by Kurt Bernhard Pruenner
#
# Tries to clean up slight ringing around edges by heavily AWarpSharp-ing the 
# image and then applying it only to the areas where the difference is small 
# enough so detail isn't destroyed.
#
# Currently only processes the chroma, as that's what sharpeners that cause the
# ringing in the first place operate on.
#
# depth ........ Depth of the AWarpSharpening
#
# diffthresh ... differences between the source and the sharpened clip larger 
#                than this will not be touched; the smaller the difference the
#                more of the sharpened clip will be used
#
# lumathresh ... since the ringing is mostly notable in bright places this
#                threshold will prevent dark areas from being hit too hard, so
#                for instance linework will be preserved
#
# debug ........ 0 - normal operation
#                1 - return sharpened clip
#                2 - return diffthresh mask
#                3 - return lumathresh mask
#                4 - return combined mask
#                5 - return source (for comparison)
# 

LoadPlugin("C:\Programme\AviSynth 2.5\dll\aWarpSharp(Pruned).dll")


function AWarpSharpDering(clip source, float "depth",int "diffthresh",int "lumathresh",int "debug")
{
  depth=Default(depth,32.0)
  diffthresh=Default(diffthresh,8)
  lumathresh=Default(lumathresh,32)
  debug=Default(debug,0)
  
  sharpened=source.AWarpSharp(depth=depth,blurlevel=2,cm=0,bm=0) 

  # absolute differences mask
  diffmask=YV12LUTxy(source,sharpened,yexpr="x y - x y > *",Y=3,U=1,V=1).Levels(0,0.5,diffthresh,255,0,coring=false)

  # source-luma mask
  lumamask=source.Deflate(Y=3,U=1,V=1).Levels(16,0.5,16+lumathresh,0,255,coring=false)

  # both masks multiplied
  mask=YV12LUTxy(lumamask,diffmask,yexpr="x y * 255 /",Y=3,U=1,V=1).Deflate()
  
  result=MergeChroma(MaskedMerge(source,sharpened,mask,Y=3,U=1,V=1),source)
  
  result=debug != 1 ? result : sharpened
  result=debug != 2 ? result : diffmask.Levels(0,1.0,255,16,240,coring=false).MergeChroma(source.BlankClip(color_yuv=$808080))
  result=debug != 3 ? result : lumamask.Levels(0,1.0,255,16,240,coring=false).MergeChroma(source.BlankClip(color_yuv=$808080))
  result=debug != 4 ? result : mask.Levels(0,1.0,255,16,240,coring=false).MergeChroma(source.BlankClip(color_yuv=$808080))
  result=debug != 5 ? result : source
  
  return result
}

