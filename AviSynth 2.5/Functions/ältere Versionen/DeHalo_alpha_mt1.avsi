LoadPlugin("C:\Programme\AviSynth 2.5\dll\MaskTools_v1.5.8.dll")
LoadPlugin("C:\Programme\AviSynth 2.5\dll\Repair_v09.dll")


function DeHalo_alpha(clip clp, float "rx", float "ry", float "darkstr", float "brightstr", float "lowsens", float "highsens", float "ss")
{
rx        = default( rx,        2.0 )
ry        = default( ry,        2.0 )
darkstr   = default( darkstr,   1.0 )
brightstr = default( brightstr, 1.0 )
lowsens   = default( lowsens,    50 )
highsens  = default( highsens,   50 )
ss        = default( ss,        1.5 )

LOS = string(lowsens)
HIS = string(highsens/100.0)
DRK = string(darkstr)
BRT = string(brightstr)
ox  = clp.width()
oy  = clp.height()
uv  = 1
uv2 = (uv==3) ? 3 : 2

halos  = clp.bicubicresize(m4(ox/rx),m4(oy/ry)).bicubicresize(ox,oy,1,0)
are    = yv12lutxy(clp.expand(U=uv,V=uv),clp.inpand(U=uv,V=uv),"x y -","x y -","x y -",U=uv,V=uv)
ugly   = yv12lutxy(halos.expand(U=uv,V=uv),halos.inpand(U=uv,V=uv),"x y -","x y -","x y -",U=uv,V=uv)
so     = yv12lutxy( ugly, are, "y x - y 0.001 + / 255 * "+LOS+" - y 256 + 512 / "+HIS+" + *" )
lets   = maskedmerge(halos,clp,so,U=uv,V=uv)
remove = (ss==1.0) ? clp.repair(lets,1,0) 
          \        : clp.lanczosresize(m4(ox*ss),m4(oy*ss))
          \             .logic(lets.expand(U=uv,V=uv).bicubicresize(m4(ox*ss),m4(oy*ss)),"min",U=uv2,V=uv2)
          \             .logic(lets.inpand(U=uv,V=uv).bicubicresize(m4(ox*ss),m4(oy*ss)),"max",U=uv2,V=uv2)
          \             .lanczosresize(ox,oy)
them   = yv12lutxy(clp,remove,"x y < x x y - "+DRK+" * - x x y - "+BRT+" * - ?",U=2,V=2)

return( them )
}

function m4(float x) {return(x<16?16:int(round(x/4.0)*4))}