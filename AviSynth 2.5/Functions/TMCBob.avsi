LoadPlugin("C:\Programme\AviSynth 2.5\dll\TomsMoComp.dll")

########################################################################
# TMCBob(clip a, bool "tff")
#
# Erzeugt aus interlaced Video ein progressives doppelter Framerate
# (z.B. aus 25 fps interlaced ein 50 fps progressive)
#
# tff gibt die Field order des clip a an:
# true  --> Top Field First (Upper Field First)
# false --> Botttom Field First (Lower Field First)
# Falls nicht angegeben, wird true (Top Field First) angenommen
########################################################################

########################################################################
# HalfFpsBob(clip a)
#
# Erzeugt aus einem via TMCBob auf doppelte Framerate gebobbten Video
# ein progressives halber Framerate
# (z.B. aus 50 fps progressive ein 25 fps progressive)
########################################################################


function TMCBob(clip a, bool "tff") {
  tff = Default(tff,true)
  a = tff ? a.AssumeTFF() : a.AssumeBFF()
  f = a.TomsMoComp(-1,5,0)
  e = a.DoubleWeave().SelectOdd().TomsMoComp(-1,5,0)
  Interleave(f,e).AssumeFrameBased()
}

function HalfFpsBob(clip a) {
  SelectOdd(a)
}
