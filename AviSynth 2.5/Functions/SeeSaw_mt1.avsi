#  SeeSaw v0.3e (02 Jan 2006)
#
#  (Full Name: "Denoiser-and-Sharpener-are-riding-the-SeeSaw" )
#
#  This function provides a (simple) implementation of the "crystality sharpen" principle.
#  In conjunction with a user-specified denoised clip, the aim is to enhance
#  weak detail, hopefully without oversharpening or creating jaggies on strong
#  detail, and produce a result that is temporally stable without detail shimmering, 
#  while keeping everything within reasonable bitrate requirements.
#  This is done by intermixing source, denoised source and a modified sharpening process,
#  in a seesaw-like manner.
#
#  This version is considered alpha.  
#
#  Usage:
#
#  a = TheNoisySource
#  b = a.YourPreferredDenoising()
#  SeeSaw( a, b, [parameters] )
#
#  You're very much encouraged to feed your own custom denoised clip into SeeSaw.
#  If the "denoised" clip parameter is omitted, a simple "spatial pressdown" filter is used.
#
#
#  Fiddled together by Didée, for your pleasure.
#

LoadPlugin("C:\Programme\AviSynth 2.5\dll\MaskTools_v1.5.8.dll")
LoadPlugin("C:\Programme\AviSynth 2.5\dll\RemoveGrain_v10.dll")
#LoadPlugin("C:\Programme\AviSynth 2.5\dll\Repair.dll")
LoadPlugin("C:\Programme\AviSynth 2.5\dll\Repair_v09.dll")



# =======  Main function  =======

function SeeSaw( clip  clp, clip "denoised", 
 \               int   "NRlimit",int "NRlimit2", 
 \               float "Sstr",   int "Slimit", float "Spower", float "SdampLo", float "SdampHi", float "Szp",
 \               float "bias",   int "Smode",    int "sootheT",  int "sootheS", float "ssx",     float "ssy")
{
ssx      = default( ssx,      1.0 )       # supersampling factor x  /  SeeSaw doesn't require supersampling urgently. 
ssy      = default( ssy,      ssx )       # supersampling factor y  /  if at all, small values ~1.25 seem to be enough.
NRlimit  = default( NRlimit,    2 )       # absolute limit for pixel change by denoising
NRlimit2 = default( NRlimit2, NRlimit+1)  # limit for intermediate denoising
Sstr     = default( Sstr,     1.5 )       # Sharpening strength (don't touch this too much)
Slimit   = default( Slimit, NRlimit+2 )   # positive: absolute limit for pixel change by sharpening
                                          # negative: pixel's sharpening difference is reduced to diff=pow(diff,1/abs(limit))
Spower   = default( Spower,     4 )       # exponent for modified sharpener
Szp      = default( Szp,     16+2 )       # zero point - below: overdrive sharpening - above: reduced sharpening
SdampLo  = default( SdampLo, Spower+1 )   # reduces overdrive sharpening for very small changes
SdampHi  = default( SdampHi,   24 )       # further reduces sharpening for big sharpening changes. Try 15~30. "0" disables.
bias     = default( bias,      49 )       # bias towards detail ( >= 50 ) ,  or towards calm result ( < 50 )
Smode    = default( Smode,     ssx<1.35 ? 11 : ssx<1.51 ? 20 : 19 )
sootheT  = default( sootheT,  49 )        # 0=minimum, 100=maximum soothing of sharpener's temporal instableness.
                                          # (-100 .. -1 : will chain 2 instances of temporal soothing.)
sootheS  = default( sootheS,   0 )        # 0=minimum, 100=maximum smoothing of sharpener's spatial effect.

Szp   = Szp / pow(Sstr, 1.0/4.0) / pow( (ssx+ssy)/2.0, 1.0/2.0 ) 
SdampLo = SdampLo / pow(Sstr, 1.0/4.0) / pow( (ssx+ssy)/2.0, 1.0/2.0 )

ox=clp.width
oy=clp.height
xss = m4(ox*ssx)
yss = m4(oy*ssy)
NRL   = string( NRlimit  )
NRL2  = string( NRlimit2 )
NRLL  = string( int(round( NRlimit2 * 100.0/bias - 1.0 )) )
SLIM  = string( abs(Slimit) )
BIAS1 = string( bias )
BIAS2 = string( 100-bias )
#ZRP   = string( abs(Szp) )
#PWR   = string( abs(Spower) )
#DMP   = string( SdampLo )

denoised = defined(denoised) ? denoised : yv12lutxy(clp,clp.removegrain(4,-1),"x "+NRL+" + y < x "+NRL+" + x "+NRL+" - y > x "+NRL+" - y ? ?",U=2,V=2)

NRdiff = yv12lutxy(clp,denoised,"x y - 128 +","x y - 128 +","x y - 128 +",U=3,V=3)
tame   = yv12lutxy(clp,denoised,"x "+NRLL+" + y < x "+NRL2+" + x "+NRLL+" - y > x "+NRL2+" - x "+BIAS1+" * y "+BIAS2+" * + 100 / ? ?")
head   = tame.sharpen2(Sstr,Spower,Szp,SdampLo,SdampHi,4)
# head = head.maskedmerge(tame,tame.prewitt(multiplier=1.0).expand().removegrain(20))

(ssx==1.0 && ssy==1.0) ? repair(tame.sharpen2(Sstr,Spower,Szp,SdampLo,SdampHi,Smode),head,1,-1,-1) 
 \                     : repair(tame.lanczosresize(xss,yss).sharpen2(Sstr,Spower,Szp,SdampLo,SdampHi,Smode),head.bicubicresize(xss,yss,-.2,.6),1,-1,-1).lanczosresize(ox,oy)

Soothe(last,tame,sootheT,sootheS)
sharpdiff= yv12lutxy(tame,last,"x y - 128 +",U=1,V=1)

(NRlimit==0) ? clp : \
yv12lutxy(clp,NRdiff,"y 128 "+NRL+" + > x "+NRL+" - y 128 "+NRL+" - < x "+NRL+" + x y 128 - - ? ?",
 \                   "y 128 "+NRL+" + > x "+NRL+" - y 128 "+NRL+" - < x "+NRL+" + x y 128 - - ? ?",
 \                   "y 128 "+NRL+" + > x "+NRL+" - y 128 "+NRL+" - < x "+NRL+" + x y 128 - - ? ?",U=3,V=3)

Slimit>=0 ? yv12lutxy(last,sharpdiff,"y 128 "+SLIM+" + > x "+SLIM+" - y 128 "+SLIM+" - < x "+SLIM+" + x y 128 - - ? ?",U=2,V=2)
 \        : yv12lutxy(last,sharpdiff,"y 128 = x x y 128 - abs 1 "+SlIM+" / ^ y 128 - y 128 - abs / * - ?",U=2,V=2)

return( last )
}


# =======  Modified sharpening function  =======

function sharpen2(clip clp, float strength, int power, float zp, float lodmp, float hidmp, int rgmode) 
{
STR  = string( strength )
PWR  = string( 1.0/float(power) )
ZRP  = string(    ZP    )
DMP  = string(   lodmp  )
HDMP = (hidmp==0) ? "1" : "1 x y - abs "+string(hidmp)+" / 4 ^ +"

yv12lutxy( clp, clp.RemoveGrain(rgmode,-1,-1), \
           "x y = x x x y - abs "+ZRP+" / "+PWR+" ^ "+ZRP+" * "+STR+" * x y - 2 ^ x y - 2 ^ "+DMP+" + / * x y - x y - abs / * "+HDMP+" / + ?",U=2,V=2)
return( last )
}


# =======  Soothe() function to stabilze sharpening  =======

function Soothe(clip sharp, clip orig, int "sootheT", int "sootheS")
{
sootheT  = default(sootheT, 25 )
sootheS  = default(sootheS,  0 )
sootheT  = (sootheT > 100) ? 100 : (sootheT < -100) ? -100 : sootheT
sootheS  = (sootheS > 100) ? 100 : (sootheS < 0) ? 0 : sootheS
ST    = string( 100 - abs(sootheT))
SSPT  = string( 100 - abs(sootheS))

yv12lutxy(orig,sharp,"x y - 128 +","x y - 128 +","x y - 128 +", U=1,V=1)

(sootheS==0) ? last
 \           : yv12lutxy( last, last.removegrain(20,-1,-1),
 \             "x 128 - y 128 - * 0 < x 128 - 100 / "+SSPT+" * 128 + x 128 - abs y 128 - abs > x "+SSPT+" * y 100 "+SSPT+" - * + 100 / x ? ?", U=1,V=1)
 
(sootheT==0) ? last
 \           : yv12lutxy( last, last.temporalsoften(1,255,0,32,2),
 \           "x 128 - y 128 - * 0 < x 128 - 100 / "+ST+" * 128 + x 128 - abs y 128 - abs > x "+ST+" * y 100 "+ST+" - * + 100 / x ? ?", U=1,V=1)

(sootheT > -1) ? last 
 \             : yv12lutxy( last, last.temporalsoften(1,255,0,32,2),
 \             "x 128 - y 128 - * 0 < x 128 - 100 / "+ST+" * 128 + x 128 - abs y 128 - abs > x "+ST+" * y 100 "+ST+" - * + 100 / x ? ?", U=1,V=1)

yv12lutxy(orig,last,"x y 128 - -","x y 128 - -","x y 128 - -",U=1,V=1)
# mergechroma(sharp)  #  not needed in SeeSaw
return( last )
}


# =======  MOD4-and-atleast-16 helper function  =======

function m4(float x) {x<16?16:int(round(x/4.0)*4)}


