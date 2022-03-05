LoadPlugin("C:\Programme\AviSynth 2.5\dll\MVTools_v1.8.4.dll")
LoadPlugin("C:\Programme\AviSynth 2.5\dll\TTempSmooth.dll")
LoadPlugin("C:\Programme\AviSynth 2.5\dll\Repair_v09.dll")
LoadPlugin("C:\Programme\AviSynth 2.5\dll\RemoveDirt_v0.6.1.dll")
LoadPlugin("C:\Programme\AviSynth 2.5\dll\RemoveGrain_v10.dll")


global idx_counter = 10

function MCNR_simple2( clip clp, int "frames", int "thY", int "thC", int "thY2", int "thC2",
 \                     int "blocksize", bool "chroME", bool "repairME", bool "removdirt",
 \                     float "LPrad", int "LPlosens", int "LPhisens")
{ 
  frames    = default( frames,      2 )  #  number of temporal neighbors to use for motion compensation & temporal filtering
  thY       = default( thY,         8 )  #  upper thresh for pixel differences to include into temporal filtering
  thC       = default( thC,         6 )  #  ditto, for chroma
  thY2      = default( thY2,       -1 )  #  lower diff. thresh, for TTempSmooth (= -1 --> use TemporalSoften, not TTempSmooth)
  thC2      = default( thC2,       -1 )  #  ditto, for chroma
  blocksize = default( blocksize,  16 )  #  blocksize for motion search & compensation
  removdirt = default( removdirt,false)  #  additionally use RemoveDirt? (tip: for strong noise - true, else false. Requires frames>1)
  chroME    = default( chroME,   false)  #  include chroma planes into motion search?
  repairME  = default( repairME, true )  #  simple repairing of MC/ME errors (good when using bigger thresh's).
  LPrad     = default( LPrad,     0.0 )  #  Lowpass protection: radius for gaussian blur
  LPlosens  = default( LPlosens,    1 )  #  LP protection: lower thresh for motion recognition
  LPhisens  = default( LPhisens,    5 )  #  LP protection: upper thresh for motion recognition
  
  frames    = (frames<1) ? 1 : (frames>4) ? 4 : frames
  removdirt = (frames==1) ? false : removdirt
  LPhisens  = (LPhisens>LPlosens) ? LPhisens : LPlosens+1
  
  dummy = blankclip(clp,width=64,height=32)
  
  global idx_counter = idx_counter + 1
  
  bw4 = (frames<4) ? dummy : clp.SrchCmpRp(blocksize,true, 4,chroME,repairME)
  bw3 = (frames<3) ? dummy : clp.SrchCmpRp(blocksize,true, 3,chroME,repairME)
  bw2 = (frames<2) ? dummy : clp.SrchCmpRp(blocksize,true, 2,chroME,repairME)
  bw1 =                      clp.SrchCmpRp(blocksize,true, 1,chroME,repairME)
  fw1 =                      clp.SrchCmpRp(blocksize,false,1,chroME,repairME)
  fw2 = (frames<2) ? dummy : clp.SrchCmpRp(blocksize,false,2,chroME,repairME)
  fw3 = (frames<3) ? dummy : clp.SrchCmpRp(blocksize,false,3,chroME,repairME)
  fw4 = (frames<4) ? dummy : clp.SrchCmpRp(blocksize,false,4,chroME,repairME)
  
  frames == 1  ?  interleave(             bw1,clp,fw1             )  :  \
  frames == 2  ?  interleave(         bw2,bw1,clp,fw1,fw2         )  :  \
  frames == 3  ?  interleave(     bw3,bw2,bw1,clp,fw1,fw2,fw3     )  :  \
                  interleave( bw4,bw3,bw2,bw1,clp,fw1,fw2,fw3,fw4 )
  
  removdirt ? removedirt() : last
  
  (thY2 < 0) || (thC2 < 0) ? temporalsoften(frames,thY,thC,32,2)
   \                       : ttempsmooth(frames,thY,thC,thY2,thC2,5,24)
  
  selectevery(frames*2+1,frames)
  
  LPrad < 1.01 ? last : LPprotect(last,clp,LPrad,LPlosens,LPhisens)
  
  return( last )
}

# --------------------------------

function SrchCmpRp( clip clp, int _blksize, bool _isb, int _delta, bool _chroME, bool _repair)
{
  vec  = clp.mvanalyse(truemotion=true,pel=2,blksize=_blksize,chroma=_chroME,isb=_isb,delta=_delta,idx=idx_counter)
  comp = clp.mvflow(vec,idx=idx_counter)
 # vec  = clp.mvanalyse(pel=2,blksize=_blksize,chroma=_chroME,isb=_isb,delta=_delta,idx=idx_counter)
 # comp = clp.mvcompensate(vec,idx=idx_counter)
  _repair ? repair(comp,clp,1,3) : comp
  return( last )
}

# --------------------------------

function LPprotect( clip NR, clip orig, float rad, int low, int high )
{
  ox = NR.width()
  oy = NR.height()
  HI = string(256.0/high)
  LO = string(256.0/high*low)
  ML = string(float(high)/(float(high)-low))
  diff = yv12lutxy(orig,NR,"x y - 128 +","y","y",U=3,V=3)
  diffLP = repair(diff,diff.removegrain(4,-1).bicubicresize(m4(ox/rad),m4(oy/rad)).bicubicresize(ox,oy,1,0),1,0)
  diff = yv12lutxy(diff,diffLP,"x 128 - y 128 - * 0 < 128 x y 128 - - ?",U=2,V=2)
  MyMoMask = logic( yv12lutxy(NR,NR.deleteframe(0),   "x y - abs "+HI+" * "+LO+" - "+ML+" *"),
   \                yv12lutxy(NR,NR.duplicateframe(0),"x y - abs "+HI+" * "+LO+" - "+ML+" *"), "max")
  maskedmerge(NR,yv12lutxy(orig,diff,"x y 128 - -","y","y",U=3,V=3),MyMoMask.fity2uv(),U=3,V=3)
  #MyMoMask.greyscale
  return( last )
}

# --------------------------------

function m4(float x) {return( x<16?16:int(round(x/4.0)*4)) }
