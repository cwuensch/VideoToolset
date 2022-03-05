########################################################################
# Reinterlace(clip a, bool "tff")
#
# Erzeugt aus einem progressiven ein interlaced Video halber Framerate
# (z.B. aus 50 fps progressive ein 25 fps interlaced)
#
# tff gibt die Field order des zu erzeugenden interlaced Videos an:
# true  --> Top Field First (Upper Field First)
# false --> Botttom Field First (Lower Field First)
# Falls nicht angegeben, wird false (Lower Field First) angenommen
########################################################################

function Reinterlace(clip c, bool "tff")
{
    tff = Default(tff, false)
    c=c.SeparateFields()
    c=c.SelectEvery(4,0,3)
    c=(tff ? Interleave(c.SelectEven.Crop(0,0,0,-1).AddBorders(0,1,0,0), c.SelectOdd).AssumeTFF : c.AssumeBFF)
    #Trim(2,0).SelectEvery(4,1,2)  # Output TFF
    c.Weave()
}
