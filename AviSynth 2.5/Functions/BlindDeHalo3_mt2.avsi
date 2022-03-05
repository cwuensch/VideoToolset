LoadPlugin("C:\Programme\AviSynth 2.5\dll\mt_MaskTools_v2.0a32.dll")
LoadPlugin("C:\Programme\AviSynth 2.5\dll\RemoveGrain_v10.dll")


function BlindDeHalo3( clip clp, float "rx", float "ry", int "strength",
 \                     float "lodamp", float "hidamp", float "sharpness", float "tweaker",
 \                     int "PPmode", int "PPlimit", bool "interlaced")
{
rx =         default( rx,           3.0 )
ry =         default( ry,           3.0 )
strength =   default( strength,     125 )
lodamp =     default( lodamp,       0.0 )
hidamp =     default( hidamp,       0.0 )
sharpness =  default( sharpness,    0.0 )
tweaker =    default( tweaker,      0.0 )
PPmode =     default( PPmode,         0 )
PPlimit =    default( PPlimit, (abs(PPmode)==3) ? 4 : 0 )
interlaced = default( interlaced, false )

sharpness = (sharpness>1.58) ? 1.58 : sharpness
tweaker   = (tweaker > 1.00) ? 1.00 : tweaker
strength  = float(strength)*(1.0+sharpness*0.25)
RR   = string((rx+ry)/2.0)
ST   = string(float(strength)/100.0)
LD   = string(lodamp)
HD   = string(pow(hidamp,2))
TWK0 = "x y - 12 "+ST+" / "+RR+" / /"
TWK  = "x y - 12 "+ST+" / "+RR+" / / abs"
TWK_HLIGHT = "x y - abs 1 < 128 "+TWK+" 128 "+TWK+" - "+TWK+" 128 / * + "+TWK0+" "+TWK+" "+LD+" + / * "
 \         + "128 "+TWK+" - 20 / 2 ^ 128 "+TWK+" - 20 / 2 ^ "+HD+" + / * 128 + ?"

i     = (interlaced==false) ? clp : clp.separatefields()
oxi   = i.width
oyi   = i.height
sm    = i.bicubicresize(m4(oxi/rx),m4(oyi/ry))
mm    = mt_lutxy(sm.mt_expand(),sm.mt_inpand(),"x y - 4 *").mt_expand().mt_deflate().blur(1.58).mt_inflate().bicubicresize(oxi,oyi,1.0,.0).mt_inflate()
sm    = sm.bicubicresize(oxi,oyi,1.0,.0)
smd   = mt_lutxy(i.sharpen(tweaker),sm,TWK_HLIGHT)
smd   = (sharpness==0.0) ? smd : smd.blur(sharpness)
clean = mt_lutxy(i,smd,yexpr="x y 128 - -").mergechroma(i)
clean = mt_merge(i,clean,mm)

LL    = string(PPlimit)
LIM   = "x "+LL+" + y < x "+LL+" + x "+LL+" - y > x "+LL+" - y ? ?"

base  = (PPmode<0) ? i : clean
small = base .bicubicresize(m4(oxi/sqrt(rx*1.5)),m4(oyi/sqrt(ry*1.5)))
ex1   = small.mt_expand().blur(.5)
in1   = small.mt_inpand().blur(.5)
hull  = mt_logic( mt_lutxy( ex1.mt_expand().RemoveGrain(12,-1), ex1, "x y - 1 1 / * 1.0 ^ 1 - 5 *" )
 \               ,mt_lutxy( in1, in1.mt_inpand().RemoveGrain(12,-1), "x y - 1 1 / * 1.0 ^ 1 - 5 *" )
 \               ,"max", U=-128, V=-128)
 \     .bicubicresize(oxi,oyi,1.0,.0)

postclean = (abs(PPmode)== 1) ?  mt_merge(base,small.bicubicresize(oxi,oyi,1.0,.0),hull,Y=3,U=2,V=2)
 \        : (abs(PPmode)== 2) ?  mt_merge(base,base.RemoveGrain(19,-1),hull,Y=3,U=2,V=2)
 \        : (abs(PPmode)== 3) ?  mt_merge(base,base.RemoveGrain(4,-1),hull,Y=3,U=2,V=2)
 \        :                      clean

postclean = (PPlimit==0) ?  postclean
 \        :                 mt_lutxy(base,postclean,yexpr=LIM,U=2,V=2)

(PPmode==0) ? clean   : postclean
interlaced  ? weave() : last

return( last )
}
#---------------------------------------------------------
function m4(float x) {return(x<16?16:int(round(x/4.0))*4)}
