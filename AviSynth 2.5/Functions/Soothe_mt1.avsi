LoadPlugin("C:\Programme\AviSynth 2.5\dll\MaskTools_v1.5.8.dll")


function Soothe(clip sharp, clip orig, int "keep")
{
keep  = default(keep, 24)
keep  = (keep>100) ? 100 : (keep<0) ? 0 : keep
KP    = string(keep)
diff  = yv12lutxy(orig,sharp,"x y - 128 +", U=1,V=1)
diff2 = diff.temporalsoften(1,255,255,32,2)
diff3 = yv12lutxy(diff,diff2,  "x 128 - y 128 - * 0 < x 128 - 100 / "  + KP 
 \                           + " * 128 + x 128 - abs y 128 - abs > x " + KP 
 \                           + " * y 100 " + KP + " - * + 100 / x ? ?",  U=1,V=1)
return( yv12lutxy(orig,diff3,"x y 128 - -",U=2,V=2) )
}