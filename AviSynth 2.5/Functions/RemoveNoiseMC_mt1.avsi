LoadPlugin("C:\Programme\AviSynth 2.5\dll\MVTools_v1.8.4.dll")
#LoadPlugin("C:\Programme\AviSynth 2.5\dll\RemoveGrain_v10.dll")   # in SeeSaw
#LoadPlugin("C:\Programme\AviSynth 2.5\dll\Repair_v09.dll")        # in SeeSaw
LoadPlugin("C:\Programme\AviSynth 2.5\dll\FluxSmooth.dll")
LoadPlugin("C:\Programme\AviSynth 2.5\dll\VagueDenoiser.dll")
LoadPlugin("C:\Programme\AviSynth 2.5\dll\RemoveDirt_v1.0pre.dll")

#LoadPlugin("C:\Programme\AviSynth 2.5\dll\RemoveDirt_v0.6.1.dll")
#Import("c:\Programme\AviSynth 2.5\Functions\RemoveDirt_v10.avsi")

Import("c:\Programme\AviSynth 2.5\Functions\SeeSaw_mt1.avsi")


function RemoveTempGrain(clip input, int _mode)
{
  rg = RemoveGrain(input, mode=_mode)
  return TemporalRepair(rg, input)
}

function RemoveDirt(clip input, int limit, int rgrain, bool "_grey")
{
  _grey = default(_grey, false)
  _dgr1 = 0.4+rgrain*0.3
  _dgr2 = 0.5+rgrain*0.4
  repmode = 1
  clensed = Clense(input, grey=_grey, cache=4)
  restore = input.FluxSmoothST(3+3*rgrain,rgrain)
  restore = Repair(restore, input, mode=repmode, modeU= _grey ? -1 : repmode)
  restore = rgrain==0 ? restore.RemoveGrain(1) : \
    restore.VagueDenoiser(threshold=_dgr1, chromaT=_dgr1, nsteps=6, percent=75).RemoveGrain(1)
  alt = input.VagueDenoiser(threshold=_dgr2, chromaT=_dgr2, nsteps=6, percent=100).RemoveGrain(5)
  return RestoreMotionBlocks(clensed, restore, neighbour=input, alternative=alt, pthreshold=4+2*rgrain, cthreshold=6+2*rgrain, gmthreshold=40, dist=1, dmode=2, debug=false, noise=limit, noisy=12, grey=_grey)
}

global idx_c = 25

function RemoveNoiseMC(clip clip,int "rdlimit", int "rgrain", int "denoise", float "csharp", bool "_grey")
{
  rdlimit = default(rdlimit,11)
  rgrain = default(rgrain,2)
  denoise = default(denoise,8)
  csharp = (rgrain>1) ? (rgrain>2) ? default(csharp,0.31) : default(csharp,0.28) : default(csharp,0.25)
  _grey = default(_grey,false)
  _dgr = 0.6+rgrain*0.4  
  dummy = clip.BlankClip(length=0)
  global idx_c = idx_c + 1
  cbs = 8
  ccf = cbs*cbs/64
  cpn = (denoise>8) ? (denoise>12) ? 50*ccf : 58*ccf : 66*ccf
  bvec2 = clip.MVAnalyse(isb=false, blksize=cbs, delta=2, pel=2, truemotion=true, pnew=cpn, idx=idx_c)
  bvec1 = clip.MVAnalyse(isb=false, blksize=cbs, delta=1, pel=2, truemotion=true, pnew=cpn, idx=idx_c)
  fvec1 = clip.MVAnalyse(isb=true, blksize=cbs, delta=1, pel=2, truemotion=true, pnew=cpn, idx=idx_c)
  fvec2 = clip.MVAnalyse(isb=true, blksize=cbs, delta=2, pel=2, truemotion=true, pnew=cpn, idx=idx_c)
  backw1 = rdlimit>13 ? \
    rdlimit>20 ? \
      clip.MVFlow(bvec1).Deblock(quant=22, aOffset=6, bOffset=6) : \
      clip.MVFlow(bvec1).Deblock(quant=16, aOffset=4, bOffset=4) : \
    clip.MVFlow(bvec1)
  forw1  = rdlimit>13 ? \
    rdlimit>20 ? \
      clip.MVFlow(fvec1).Deblock(quant=22, aOffset=6, bOffset=6) : \
      clip.MVFlow(fvec1).Deblock(quant=16, aOffset=4, bOffset=4) : \
    clip.MVFlow(fvec1)
  clp = interleave(backw1,clip,forw1)
  clp = clp.RemoveDirt(rdlimit,rgrain,_grey)
  dnc = denoise==0 ? clp.RemoveTempGrain(rgrain).SelectEvery(3,1) : dummy
  clp = clp.SelectEvery(3,1)
  dnc = denoise==0 ? dnc : \
    clp.MVDenoise(bvec2, bvec1, fvec1, fvec2, thT=denoise, thSAD=190+15*denoise, thmv=40, thSCD1=230+5*denoise)
  vid_mo = dnc.VagueDenoiser(threshold=_dgr, chromaT=_dgr, nsteps=6, percent=75)
  vid_mo = rgrain==1 ? vid_mo.RemoveGrain(1) : vid_mo.RemoveGrain(5)
  dnc = dnc.ConditionalFilter(dnc, vid_mo, "(YDifferenceFromPrevious()+YDifferenceToNext())/AverageLuma()", "<", "0.3")
  clp = clp.SeeSaw(dnc, Sstr=csharp, Szp=12, SdampHi=20, bias=40)
  return clp
}

