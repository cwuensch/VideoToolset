############################################
# Hue/Saturation/Intensity by Donald Graft #
#					   #
# there is a version of this filter called #
# "Tweak11 by Donald Graft" which can be   #
# used in Avisynth (directly in YUV-space) #
############################################

LoadVirtualdubPlugin("C:\Programme\VirtualDubMod\Plugins\hue.vdf", "_VD_Hue")


function DG_FloatToInt(f) { return round((default(f,1.0) - 1) * 100) }

function VD_HueSatInt(clip clip, int "hue", bool "preserve_luma", float "sat", float "inten",
  \  bool "r", bool "g", bool "b", bool "y", bool "c", bool "m")
{
  hue = default(hue, 0)
  sat = DG_FloatToInt(sat)
  inten = DG_FloatToInt(inten)
  flags = (default(r,true)?1:0)+(default(g,true)?2:0)+(default(b,true)?4:0)
    \ +(default(y,true)?8:0)+(default(c,true)?16:0)+(default(m,true)?32:0)
  return clip._VD_Hue(hue, default(preserve_luma,false)?1:0, sat, inten, flags)
}
