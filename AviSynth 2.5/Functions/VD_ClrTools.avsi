# Arguments:
#   mode:  0=Histograms, 1=Show Hot Pixels, 2=Video Channels, 
#          3=Waveform Monitor, 4=Vectorscope
#
#   (input Characteristic args mainly used for luma calcs)
#   NTSC vs PAL
#   stdDef (601) vs hiDef (709)
#   rng255 vs rng219 (Pick rng255=false if you want luma black=0)
#
#   (show channels used in modes 0,2,3)
#   luma,red,green,blue
#
#   hotFixMode: 0=turn hot pixels black, 1=lower intensity, 2=lower saturation
#   showWFMgrid: turn it off to see better.


LoadVirtualdubPlugin("C:\Programme\VirtualDubMod\Plugins\clrtools.vdf", "VD_clrtools")


function VD_ClrTools(clip clip, int "mode",
			\ bool "NTSC", bool "stdDef", bool "rng255",
			\ bool "luma", bool "red", bool "green", bool "blue",
			\ int "hotFixMode", bool "showWFMgrid")
{
  return clip.VD_clrtools(default(mode,0),0,0,
			\ default(NTSC,false)?1:0,0, 
			\ default(stdDef,true)?1:0, 
			\ default(rng255,false)?1:0, 
			\ default(luma,true)?1:0, 
			\ default(red,true)?1:0, 
			\ default(green,true)?1:0, 
			\ default(blue,true)?1:0, 
			\ default(hotFixMode,0), 
			\ default(showWFMgrid,true)?1:0)
}

function VD_VectorScope(clip clip)
{
  clip = clip.isRGB32() ? clip : clip.ConvertToRGB32()
  a = VD_ClrTools(clip, 4)
  a = a.BicubicResize(clip.height, clip.height)
  StackHorizontal(clip, a)
  return last
}
