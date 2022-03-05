LoadPlugin("C:\Programme\AviSynth 2.5\dll\RemoveGrain_v10.dll")
#LoadPlugin("C:\Programme\AviSynth 2.5\dll\Repair.dll")  # V1.0 verursacht die Farbschlieren!!
LoadPlugin("C:\Programme\AviSynth 2.5\dll\Repair_v09.dll")
LoadPlugin("C:\Programme\AviSynth 2.5\dll\SSE2Tools.dll")


# mit LimitChange (aus SSETools.dll, RemoveGrain-Package)
function LRemoveDust_YUY2(clip input, int clmode, int "limit")
{
clmode=default(clmode,17)
limit=default(limit,2)
repmode = 2
clensed = Clense(input, grey=true)
rep = Repair(clensed, input, mode=repmode, modeU=-1)
rg = RemoveGrain(rep, mode=clmode, modeU=-1)
return LimitChange(rg, input, limit, limitU=255)
}

# mit LimitChange (aus SSETools.dll, RemoveGrain-Package)
function LRemoveDust_YV12(clip input, int clmode, int "limit")
{
limit=default(limit,2)
clmode=default(clmode,17)
repmode = 2
clensed = Clense(input)
rep = Repair(clensed, input, mode=repmode)
rg = RemoveGrain(rep, mode=clmode)
return LimitChange(rg, input, limit)
}

# mit yv12lutxy (aus MaskTools 1.x -> stürzt ab)
function LRemoveDust(clip input, int _mode, int "limit")
{
limit=default(limit,4)
LL=string(limit)
STR="x "+LL+" + y < y "+LL+" - x "+LL+" - y > y "+LL+" + x ? ?"
repmode = 2
clensed = Clense(input)
rep=Repair(clensed, input, mode=repmode)
rg = RemoveGrain(rep, mode=_mode)
TemporalRepair(rg, rep)
return limit!=0 ? yv12lutxy(last,input,yexpr=STR,U=2,V=2) : last
}
