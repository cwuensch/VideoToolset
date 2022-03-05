LoadPlugin("C:\Programme\AviSynth 2.5\dll\RemoveDirt_v0.9.dll")
LoadPlugin("C:\Programme\AviSynth 2.5\dll\RemoveGrain_v10.dll")
LoadPlugin("C:\Programme\AviSynth 2.5\dll\Repair_v09.dll")
LoadPlugin("C:\Programme\AviSynth 2.5\dll\MVTools_v1.8.4.dll")  # nur für RemoveDirtMC


function RemoveDirt_V09(clip input, bool "_grey", int "repmode") 
{
	_grey=default(_grey, false)
	repmode=default(repmode, 16)
	clmode=17
	clensed=Clense(input, grey=_grey, cache=4)
	sbegin = ForwardClense(input, grey=_grey, cache=-1)
	send = BackwardClense(input, grey=_grey, cache=-1)
	alt=Repair(SCSelect(input, sbegin, send, clensed, debug=true), input, mode=repmode, modeU = _grey ? -1 : repmode ) 
	restore=Repair(clensed, input, mode=repmode, modeU = _grey ? -1 : repmode)
	corrected=RestoreMotionBlocks(clensed, restore, neighbour=input, alternative=alt, gmthreshold=70, dist=1, dmode=2, debug=false, noise=10, noisy=12, grey=_grey)
	return RemoveGrain(corrected, mode=clmode, modeU = _grey ? -1 : clmode )
}
 

function RemoveDirt2(clip input, int limit, bool "_grey")
{
  _grey=default(_grey, false)
  clensed=input.Clense(grey=_grey, cache=4)
  alt=input.RemoveGrain(2)
  return RestoreMotionBlocks(clensed,input,alternative=alt,pthreshold=4,cthreshold=6, gmthreshold=40,dist=1,dmode=2,debug=false,noise=limit,noisy=16,grey=_grey)
}

function RemoveTempGrain(clip input, int _mode)
{
  rg = RemoveGrain(input, mode=_mode)
  return TemporalRepair(rg, input)
}

function RemoveDirtMC(clip, int "limit", bool "_grey")
{
  _grey=default(_grey, false)
  limit = default(limit,6)
  bvec = clip.MVAnalyse(isb=false, blksize=8, delta=1, pel=2, truemotion=true, idx=1)
  fvec = clip.MVAnalyse(isb=true, blksize=8, delta=1, pel=2, truemotion=true, idx=1)
  backw = clip.MVFlow(bvec)
  forw  = clip.MVFlow(fvec)
  clp=interleave(backw,clip,forw)
  clp=clp.RemoveDirt2(limit,_grey)
  dnc=clp.RemoveTempGrain(1)
  clp=clp.SelectEvery(3,1)
  dnc=dnc.SelectEvery(3,1)
#  clp=clp.SeeSaw(dnc,Sstr=0.26,Szp=12,SdampHi=20,bias=40)
  return clp
}