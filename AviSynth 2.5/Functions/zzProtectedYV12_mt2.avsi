# Funktionen zur verlustfreien Bearbeitung von RGB-Videos im YV12-Format
# siehe http://forum.gleitz.info/showthread.php?t=33835&p=342893

LoadPlugin("C:\Programme\AviSynth 2.5\dll\mt_MaskTools_v2.0a30.dll")
#LoadPlugin("C:\Programme\AviSynth 2.5\dll\MaskTools_v1.5.8.dll")
LoadPlugin("C:\Programme\AviSynth 2.5\dll\FFT3DFilter.dll")

Import("C:\Programme\AviSynth 2.5\Functions\LimitedSharpenFaster_mt2.avsi")


function FFT3DFilter_RGB(clip input, float "sigma_y", float "sharpen_y", int "limit_y", float "sigma_u", float "sharpen_u", int "limit_u", float "sigma_v", float "sharpen_v", int "limit_v") {
  input = input.PointResize(input.Width * 2, input.Height * 2).ConvertToYV12(matrix="pc.601")

  sigma_y == 0 ? input : input.PointResize(input.Width / 2, input.Height / 2).\
    FFT3DFilter(sigma = sigma_y, sharpen = sharpen_y).\
    PointResize(input.Width, input.Height).MergeChroma(input, 1)
  LL = string(limit_y)
  STR = "x "+LL+" + y < y "+LL+" - x "+LL+" - y > y "+LL+" + x ? ?"
  limit_y == 0 ? last : yv12lutxy(last, input, yexpr=STR, U=2, V=2)

  sigma_u == 0 ? last : last.\
    FFT3DFilter(sigma = sigma_u, sharpen = sharpen_u)
  LL = string(limit_u)
  STR = "x "+LL+" + y < y "+LL+" - x "+LL+" - y > y "+LL+" + x ? ?"
  limit_u == 0 ? last : yv12lutxy(last, input, Y=2, uexpr=STR, V=2)

  sigma_v == 0 ? last : last.\
    FFT3DFilter(sigma = sigma_v, sharpen = sharpen_v)
  LL = string(limit_v)
  STR = "x "+LL+" + y < y "+LL+" - x "+LL+" - y > y "+LL+" + x ? ?"
  limit_v == 0 ? last : yv12lutxy(last, input, Y=2, U=2, vexpr=STR)

  ConvertToRGB32(matrix="pc.601").PointResize(last.Width / 2, last.Height / 2)
}

function LimitedSharpenFaster_RGB(clip input, int "mode", int "border", int "strength_luma", int "strength_chroma") {
  input = input.PointResize(input.Width * 2, input.Height * 2).ConvertToYV12(matrix="pc.601")

  luma = strength_luma == 0 ? input.YV12LUT(Y=2, U=0, V=0) : input.YV12LUT(Y=2, U=0, V=0).PointResize(input.Width / 2, input.Height / 2).\
    LimitedSharpenFaster(Smode = mode, strength = strength_luma, exborder = border).\
    PointResize(input.Width, input.Height)

  chroma = strength_chroma == 0 ? input.YV12LUT(Y=0, U=2, V=2) : input.YV12LUT(Y=0, U=2, V=2).\
    LimitedSharpenFaster(Smode = mode, strength = strength_chroma, exborder = border)
    MergeChroma(luma, chroma, 1)

  ConvertToRGB32(matrix="pc.601").PointResize(last.Width / 2, last.Height / 2)
}