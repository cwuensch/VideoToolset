LoadPlugin("C:\Programme\AviSynth 2.5\dll\RemoveGrain_v10.dll")
LoadPlugin("C:\Programme\AviSynth 2.5\dll\Repair_v09.dll")
LoadPlugin("C:\Programme\AviSynth 2.5\dll\SSE2Tools.dll")


function LRemoveDust(clip input, int _mode, int _modeU, int "limit", int "limitU")
 {
 limit=default(limit,4)
 limitU=default(limitU,255)
 repmode = 2
 clensed = Clense(input)
 rep=Repair(clensed, input, mode=repmode)
 rg = RemoveGrain(rep, mode=_mode, modeU=_modeU)
 rd=TemporalRepair(rg, rep)
 return LimitChange(rd, input, limit, limitU)
 }