# AudioAnalyze-Function for AviSynth 2.58
# =======================================
#
# NOTE: AviSynth 2.58 is REQUIRED for this function!!!
#
# Replace %Windir%\System32\AviSynth.dll with the newer one.
#
#
# Parameter mode:
# - "separate":   Display Left and Right channel separately
# - "average":    Display the average of both channels
# - "graphical":  Display a graphical view
#


function AudioAnalyze(clip clp, string "mode") {
mode = default(mode, 0)

clp = clp.isYV12() ? clp : clp.ConvertToYV12()

# Mode = "separate"
a=clp
a=a.Subtitle("Audio 1 Min:", y=0)
a=a.Subtitle("Audio 1 Avg:", y=20)
a=a.Subtitle("Audio 1 Max:", y=40)
a=a.ScriptClip("Subtitle(String(AudioMin(1)), x=110, y=0)")
a=a.ScriptClip("Subtitle(String(AudioRMS(1)), x=110, y=20)")
a=a.ScriptClip("Subtitle(String(AudioMax(1)), x=110, y=40)")

a=a.Subtitle("Audio 2 Min:", x=500, y=0)
a=a.Subtitle("Audio 2 Avg:", x=500, y=20)
a=a.Subtitle("Audio 2 Max:", x=500, y=40)
a=a.ScriptClip("Subtitle(String(AudioMin(2)), x=610, y=0)")
a=a.ScriptClip("Subtitle(String(AudioRMS(2)), x=610, y=20)")
a=a.ScriptClip("Subtitle(String(AudioMax(2)), x=610, y=40)")

# Mode = "average"
b=clp
b=b.Subtitle("Audio Min:", y=0)
b=b.Subtitle("Audio Avg:", y=20)
b=b.Subtitle("Audio Max:", y=40)
b=b.ScriptClip("Subtitle(String(AudioMin(0)), x=100, y=0)")
b=b.ScriptClip("Subtitle(String(AudioRMS(0)), x=100, y=20)")
b=b.ScriptClip("Subtitle(String(AudioMax(0)), x=100, y=40)")

# Mode = "graphical"
c=clp.Histogram(mode="AudioLevels")

(mode=="separate") ? a : b
(mode=="graphical") ? c : last

return last
}
