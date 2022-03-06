LoadPlugin("C:\Programme\AviSynth 2.5\dll6\AddGrainC_1.7.1.7.dll")
LoadPlugin("C:\Programme\AviSynth 2.5\dll6\dfttest_1.9.4.dll")
LoadPlugin("C:\Programme\AviSynth 2.5\dll6\EEDI2_0.9.2.0.dll")
LoadPlugin("C:\Programme\AviSynth 2.5\dll6\eedi3_0.9.2.1.dll")
LoadPlugin("C:\Programme\AviSynth 2.5\dll6\fft3dfilter_2.3.dll")
LoadPlugin("C:\Programme\AviSynth 2.5\dll6\KNLMeansCL_0.6.11.dll")
LoadPlugin("C:\Programme\AviSynth 2.5\dll6\masktools2_2.2.10.dll")
LoadPlugin("C:\Programme\AviSynth 2.5\dll6\mvtools2_2.7.21.22.dll")
LoadPlugin("C:\Programme\AviSynth 2.5\dll6\nnedi3_0.9.4.46.dll")
LoadPlugin("C:\Programme\AviSynth 2.5\dll6\PlanarTools_0.3.0.dll")
LoadPlugin("C:\Programme\AviSynth 2.5\dll6\RgTools_0.96.dll")
LoadPlugin("C:\Programme\AviSynth 2.5\dll6\TDeint_110.dll")
LoadPlugin("C:\Programme\AviSynth 2.5\dll6\yadifmod2_0.0.4-1.dll")
LoadPlugin("C:\Programme\AviSynth 2.5\dll\FixVHSOversharp.dll")

Import("C:\Programme\AviSynth 2.5\Functions\SMDegrain_v3.1.2.93s.avsi")
Import("C:\Programme\AviSynth 2.5\Functions\AnimeIVTCmod_v2.20.avsi")
Import("C:\Programme\AviSynth 2.5\Functions\QTGMC_3.357s.avsi")
Import("C:\Programme\AviSynth 2.5\Functions\ColorMill.avsi")

AVISource("Demo.avi")

#ColorYUV(gain_y=30, off_y=6)

ConvertToRGB32(matrix="Rec601", interlaced=false)
ColorMill(HSVHue=-3)
ConvertToYUY2(matrix="Rec601", interlaced=false)

#ConvertToYUY2(interlaced=true)
FixVHSOversharpL(30,12,8)
FixVHSOversharp(30,14,10)
FixVHSOversharp(30,12,8)
#ConvertToYV16(interlaced=true)

QTGMC(Preset="Very Slow", EZDenoise=10.0, NoisePreset="Slower", ChromaNoise=True, ShowNoise=false)   # Choose preset based on overall speed/quality you want. EdiThreads=4

#ConvertToYV16(matrix="Rec601", interlaced=false).Histogram(mode="levels")
