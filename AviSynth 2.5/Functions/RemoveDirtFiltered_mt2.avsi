# RemoveDirtFiltered
# (wendet ein spatial abgeschwächtes RemoveDirt 0.6.1 an)
#
# nach einer Idee von Didée

LoadPlugin("C:\Programme\AviSynth 2.5\dll\mt_MaskTools_v2.0a32.dll")
LoadPlugin("C:\Programme\AviSynth 2.5\dll\RemoveGrain_v10.dll")
LoadPlugin("C:\Programme\AviSynth 2.5\dll\RemoveDirt_v0.6.1.dll")


function RemoveDirtFiltered(clip c)
{
RD   = c.RemoveDirt()
RDD1 = mt_makediff(c,RD,U=3,V=3)
RDD2 = RDD1.RemoveGrain(4) #.RemoveGrain(11)  # Original: erst 4, dann 11
RDD3 = mt_lutxy(RDD2,RDD1,"x 128 - y 128 - * 0 < y x 128 - abs y 128 - abs > y y 128 - x 128 - - 128 + ? ?",U=3,V=3)

return (c.mt_makediff(RDD3,U=3,V=3))
}
