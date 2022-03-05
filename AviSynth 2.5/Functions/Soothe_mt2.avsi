LoadPlugin("C:\Programme\AviSynth 2.5\dll\mt_MaskTools_v2.0a32.dll")


function Soothe(clip sharp, clip orig, int "keep")
{
#Soothe_MT2.avs by Didèe - 16.05.2007
Assert( sharp.width == orig.width && sharp.height == orig.height,
 \      "Soothe: clip dimensions must match!")
keep  = default(keep, 24)
keep  = (keep>100) ? 100 : (keep<0) ? 0 : keep
KP    = string(keep)
diff  = mt_makediff(orig,sharp)
diff2 = diff.temporalsoften(1,255,0,40,2)
diff3 = mt_lutxy(diff,diff2,  "x 128 - y 128 - * 0 < x 128 - 100 / "  + KP 
 \                          + " * 128 + x 128 - abs y 128 - abs > x " + KP 
 \                          + " * y 100 " + KP + " - * + 100 / x ? ?")
return( mt_makediff(orig,diff3,U=2,V=2 ) )
}