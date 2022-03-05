LoadPlugin("C:\Programme\AviSynth 2.5\dll\RemoveGrain_v10.dll")
LoadPlugin("C:\Programme\AviSynth 2.5\dll\Repair_v09.dll")
LoadPlugin("C:\Programme\AviSynth 2.5\dll\MaskTools_v1.5.8.dll")


function LRemoveDust(clip input, int _mode, int "limit", int "limitC")
{
limit  = default(limit, 4)
limitC = default(limitC,0)      #  default chroma limit: no chroma limiting!
#limitC = default(limitC,limit) #  alternative: default chroma limit = luma limit
LLy    = string(limit)
LLc    = string(limitC)
STRy   = "x "+LLy+" + y < y "+LLy+" - x "+LLy+" - y > y "+LLy+" + x ? ?"
STRc   = "x "+LLc+" + y < y "+LLc+" - x "+LLc+" - y > y "+LLc+" + x ? ?"
uv = (limitC < -1) ?  limitC
 \ : (limitC <  0) ?  1
 \ : (limitC <  1) ?  2 
 \ :                  3

repmode   = 2
repmodeUV = (uv > 1) ? repmode : -1
_modeUV   = (uv > 1) ? _mode   : -1

clensed = Clense(input)
rep     = Repair(clensed, input, mode=repmode, modeU=repmodeUV)
rg      = RemoveGrain(rep, mode=_mode, modeU=_modeUV)
TemporalRepair(rg, rep)
yv12lutxy(last, input, STRy, STRc, STRc, U=uv, V=uv)
return last
}