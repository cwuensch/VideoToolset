LoadPlugin("C:\Programme\AviSynth 2.5\dll\RemoveGrain_v10.dll")
#LoadPlugin("C:\Programme\AviSynth 2.5\dll\Repair.dll")  # V1.0 verursacht die Farbschlieren!!
LoadPlugin("C:\Programme\AviSynth 2.5\dll\Repair_v09.dll")
LoadPlugin("C:\Programme\AviSynth 2.5\dll\SSE2Tools.dll")  # nur für RemoveDust2


function RemoveDust(clip input, int _mode)
{
  repmode = 2
  clensed = Clense(input)
  rep=Repair(clensed, input, mode=repmode)
  rg = RemoveGrain(rep, mode=_mode)
  return TemporalRepair(rg, rep)
}

# RemoveDust2(4,2,x): (4,2,1) leicht bis (4,2,4) stark; bei mode=3,4,9 thin line problem
# Kann nicht bis zum Rand arbeiten, eventuell zweimal cropen, erst ein Stück Rand dran lassen (mod4), danach weg.
function RemoveDust2(clip input, int _mode, int _modeU, int "limit")
{
  limit=default(limit,4)
  repmode = 2
  clensed = Clense(input)
  rep=Repair(clensed, input, mode=repmode)
  rg = RemoveGrain(rep, mode=_mode, modeU=_modeU)
  rd=TemporalRepair(rg, rep)
  return LimitChange(rd, input, limit, limitU=255)
}

function RemoveDust_Redfox(clip input, int "repmode", int "TRsmooth", bool "_grey", int "RGmode", int "RGmodeChroma")
{ 
  repmode= default(repmode, 9)
  TRsmooth= default(TRsmooth, 0)
  _grey= default(_grey, false)
  RGmode = default(RGmode, 2)			#1,2,5,17,18
  RGmodeChroma = default(RGmodeChroma, 1)	#1,2,5,17,18

  clensed = Clense(input, grey=_grey)
  rep=Repair(clensed, input, mode=repmode, modeU=_grey ? -1 : repmode)
  rg = RemoveGrain(rep, mode=RGmode, modeU=_grey ? -1 : RGmodeChroma, modeV=_grey ? -1 : RGmodeChroma)
  return TemporalRepair(rg, rep, grey=_grey, smooth=TRsmooth)
}