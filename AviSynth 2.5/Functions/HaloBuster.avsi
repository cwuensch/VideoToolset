Function HaloBuster (clip input, bool "lsb", int "a", float "h", float "thr", float "elast")
{
lsb = Default(lsb, False)
a= Default (a, 32)
h = Default(h, 6.4)
thr = Default(thr, 1.0)
elast = Default(elast, 1.5)
gray = lsb ? input.converttoy8 () : input.converttoy8 ().Dither_convert_8_to_16()
gray = stackvertical (dither_get_msb (gray).padding (a, a, a, a),dither_get_lsb (gray).padding (a, a, a, a))
clean = knlmeanscl (gray, d=0, a=a, s=0, h=h, lsb_inout=True)
mask = TCannyMod (converttoyv12 (clean.ditherpost (mode=-1)), sigma=1.5, mode=1, gmmax=50)
mask = mask.converttoy8 ()
mask = mt_lut (mask, "x 255 / 0.24 - 3.2 * 0.0 max 1.0 min 255 *")
mask = mt_expand (mask)
mask = mt_inflate (mask)
merge  = dither_merge16_8 (gray, clean, mask)
limit = Dither_limit_dif16 (gray, merge, thr=thr, elast=elast)
crop = Dither_crop16 (limit, a, a, -a, -a)
luma = lsb ? crop : crop.ditherpost (mode=-1)
final = input.IsY8 () ? luma : ytouv (input.utoy8 (), input.vtoy8 (), luma)
return final
}

Function Padding (clip input, int "left", int "top", int "right", int "bottom")
{
w = input.width ()
h = input.height ()

output = input.PointResize (w+left+right, h+top+bottom, -left, -top, w+left+right, h+top+bottom)

return output
}