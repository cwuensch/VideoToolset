########################################################################
# ReinterlaceBob(clip a, bool "tff")
#
# Erzeugt aus einem progressiven ein interlaced Video halber Framerate
# (z.B. aus 50 fps progressive ein 25 fps interlaced)
#
# tff gibt die Field order des zu erzeugenden interlaced Videos an:
# true  --> Top Field First (Upper Field First)
# false --> Botttom Field First (Lower Field First)
# Falls nicht angegeben, wird true (Top Field First) angenommen
########################################################################

function ReinterlaceBob(clip a, bool "tff") {
  tff = Default(tff,true)
  a = tff ? a.AssumeTFF() : a.AssumeBFF()
  a = a.ConvertToYUY2()
  SeparateFields(a).SelectEvery(4,0,3).Weave()
}