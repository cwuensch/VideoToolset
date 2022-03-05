# Histogram-Funktion für AviSynth 2.58
# ====================================
#
# Workaround zur Sichtbarmachung des klassischen Histogramms
#
# Parameter: siehe Core-Function Histogram
#


function Histogramm(clip clp, string "mode") {
mode = default(mode, "classic")

clp = clp.isYV12 || (mode=="stereo") || ((mode=="classic" || mode=="luma") && clp.isYUY2) ? clp : clp.ConvertToYV12()

# Mode = "classic"
clp.Histogram("classic")
vid = last.Crop(0, 0, clp.Width-last.Width, 0)
hist = last.Crop(clp.Width, 0, 0, 0).Tweak(cont=10.0, coring=false)
classic = StackHorizontal(vid, hist)

# Mode = other
other = clp.Histogram(mode)

(mode=="classic") ? classic : other

return last
}
