# iip :  Integrated Image Processor, v.0.5a (Patched by Redfox - 26.08.2007)
#
#
#  ---------------
# |  It is slow.  |
#  ---------------
#
# New in v.0.5 :
#
# EQ [int] : Edge quality. 0=deaktivated (don't do that!!!), 1=standard (as formerly), 2=better'n'slower, 3=evenbetter'n'evenslower
# Note: when using EQ = 2|3, then it's a good idea to *DEACTIVATE* deringing in iiP (don't hit the dog twice).
#
# warp_Y, warp_UV [bool] additional Luma & Chroma Warping. 
#
# Luma warping should make the picture more 'gracile' when upsizing to bigger resolution, e.g. DVD -> HDTV.
# For same resolution or downsizing, it may (?) help for sources with distorted detail. Or it may not - YMMV.
#
# Chroma warping helps on sources with bleeding colors (e.g. Enterprise: on the uniforms, the red stripes are bleeding into 
#   the blue cloth, which looks *very* ugly [like an aquarell that's gotten wet]. It looks much better with chroma warping.)
# On clean sources, chroma warping is a waste of CPU cycles.
#
# exborder [bool] : exclude outmost 8-pixel-border from sharpening (gradient masked)
#
# dering: old method: called with positive values for "dering"
#         new method: called with negative values for "dering" (better, but slower)
#
# detail_floor [int] : was formerly hardcoded, now user-definable. default 20.
#
#
### Patched by Redfox:
# - works now with Masktools 1.5.8
# - RemoveGrain(1) instead of UnDot()
# - RemoveGrain(11) instead of Blur(1.0)
###


LoadPlugin("C:\Programme\AviSynth 2.5\dll\MaskTools_v1.5.8.dll")
LoadPlugin("C:\Programme\AviSynth 2.5\dll\RemoveGrain_v10.dll")
LoadPlugin("C:\Programme\AviSynth 2.5\dll\WarpSharp.dll")
LoadPlugin("C:\Programme\AviSynth 2.5\dll\aWarpSharp.dll")
LoadPlugin("C:\Programme\AviSynth 2.5\dll\LoadPluginEx.dll")
LoadPlugin("C:\Programme\AviSynth 2.5\dll\DustV5.dll")



function Ylevels(clip clp, int a, float gamma, int b, int c, int d)
       { wicked="x "+string(a)+" - "+string(b)+" "+string(a)+" - / 1 "+string(gamma)+" / ^ "+string(d)+" "+string(c)+" - * "+string(c)+" +"
        # Reminder: Yexpr = "x a - b a - / 1 gamma / ^ d c - * c +"
        # return( clp.subtitle(wicked) )
         return( clp.YV12LUT(Yexpr = wicked) )  
         }

function FineEdge( clip clp, int "div" )
       {
         logic(  clp.DEdgeMask(0,255,0,255,"5 10 5 0 0 0 -5 -10 -5", setdivisor=true, divisor=div)
          \     ,clp.DEdgeMask(0,255,0,255,"5 0 -5 10 0 -10 5 0 -5", setdivisor=true, divisor=div), "max", Y=3,U=1,V=1 )
         }

function iip( clip  clp, 
 \            int   "dest_x",       int   "dest_y", 
 \            int   "duststr",      float "dustweight", 
 \            float "ss1_x",        float "ss1_y", 
 \            int   "detailcontr1", int   "detailcontr2",
 \            int   "contr_radius", float "PixSharp", 
 \            float "ss2_x",        float "ss2_y", 
 \            int   "Xstren",       int   "Xlimit",  
 \            float "subpelstren",  int   "flatweight",
 \            bool  "antiflicker1", bool  "antiflicker2",
 \            int   "protect_floor",int   "protect_bias",
 \            int   "dering",       float "dering_weight",
 \            int   "dering_floor", float "dering_bias",
 \            int   "detail_floor",
 \            int   "EQ",           bool  "exborder",
 \            bool  "warp_Y",       bool  "warp_UV",
 \            string "debug", 
 \            int   "cropx",        int   "cropy"
 \            )
{
ox = clp.width
oy = clp.height
xcorr=(int(ox/16.0+.9999)*16)-ox
ycorr=(int(oy/ 8.0+.9999)* 8)-oy
dest_x =      default(dest_x, clp.width)
dest_y =      default(dest_y, clp.height)
ss1_x =       default(ss1_x, 1.414)
ss1_y =       default(ss1_y, 1.414)
ss2_x =       default(ss2_x, 3.5)
ss2_y =       default(ss2_y, 3.5)
duststr =     default(duststr, 2)
dustweight =  default(dustweight, 1.0)
antiflicker1= default(antiflicker1, true)
antiflicker2= default(antiflicker2, true)
Xlimit =      default(Xlimit, 255)  #  SS<3 ?  23 : 255
Xstren =      default(Xstren, 255)  #  SS<3 ? 216 : 255
detailcontr1= default(detailcontr1, 104)
detailcontr2= default(detailcontr2, 208)
contr_radius= default(contr_radius, 2)
PixSharp =    default(PixSharp, 0.4)
subpelstren = default(subpelstren, 1.58)
flatweight =  default(flatweight, 0)
protect_floor=default(protect_floor, 0)
protect_bias= default(protect_bias, 16)
dering =      default(dering, -80)
dering_floor= default(dering_floor, 8)
dering_floor= dering<0 ? dering_floor*2 : dering_floor
dering_bias = default(dering_bias, 16)
dering_weight=default(dering_weight, 1.0)
detail_floor= default(detail_floor, 20)
EQ =          default(EQ, 2)
EQ = (EQ>3) ? 3 : EQ
exborder =    default(exborder, false)
warp_Y =      default(warp_Y, false)
warp_UV =     default(warp_UV, false)
debug =       default(debug, "Mickey Mouse")
cropx =       default(cropx, 40)
cropy =       default(cropy, 20)

cropx=int(cropx/4)*4
cropy=int(cropy/4)*4
xx_ss1 = int(ox*ss1_x/16+.5)*16
yy_ss1 = int(oy*ss1_y/16+.5)*16
xx_ss2 = int(ox*ss2_x/16+.5)*16
yy_ss2 = int(oy*ss2_y/16+.5)*16
xx_small = int(ox/(abs(dering)/80+1.0)/16+.5)*16 + 32
yy_small = int(oy/(abs(dering)/80+1.0)/16+.5)*16 + 16

# Now I have the other idea - but it's too slow, yet
clp = antiflicker1 == true ? clp.temporalsoften(2,2,3,23,2) : clp

#---------------------------------------------------------------------------------------------------------------------
# Base denoising by PixieDust
#
dusted = clp.addborders(0,0,xcorr,ycorr).converttoyuy2().PixieDust(limit=duststr).converttoyv12().crop(0,0,-xcorr,-ycorr)
dusted = (dustweight==0.0) ? clp 
 \                         : ( dustweight<1.00 ? Overlay(clp, dusted, opacity=dustweight)
 \                                             : dusted )  

soft=dusted.bicubicresize(xx_small,yy_small,.2,.4).bicubicresize(xx_ss1,yy_ss1,1.0,.0)

#---------------------------------------------------------------------------------------------------------------------
# Build EdgeMask to protect already sharp detail from oversharpening
#
YV12subtract( dusted.sharpen(0.6).sharpen(0.6), dusted.RemoveGrain(11).RemoveGrain(11) )

edge00 = bicubicResize(xx_ss1,yy_ss1,-1.0,1.0)
edge0=edge00
 \     .YV12LUT(Yexpr="x 128 - abs "+string(protect_floor)+" - "+string(protect_bias)+" *")
 \     .deflate(Y=3,U=1,V=1).inflate(Y=3,U=1,V=1).blur(1.58)
edge00 = edge00.yv12lut(yexpr="x 128 - 2 *").expand(Y=3,U=1,V=1).blur(1.58)

#---------------------------------------------------------------------------------------------------------------------
# Build DeRing'ing Mask: +++ OLD ROUTINE +++
#
dering > 0 ? expand(Y=3,U=1,V=1) : NOP
edge1b = dering > 0
 \     ? yv12subtract( expand(Y=3,U=1,V=1).blur(1.58),
 \                     inpand(Y=3,U=1,V=1),tol=1,wideRange=true            )
 \      .bicubicResize(xx_ss1,yy_ss1,-1.0,1.0)
 \      .yv12LUT(Yexpr="x 128 - abs "+string(dering_floor)+" - "+string(dering_bias)+" *")
 \      .deflate(Y=3,U=1,V=1).blur(1.58)
 \     : last
                                                                                        # .Ylevels(0,3.0,255,0,255)
#---------------------------------------------------------------------------------------------------------------------
# 1st supersampling stage to perform sharpening at
#

(ss1_x > 1.0 || ss1_y > 1.0) ? dusted.Lanczosresize(xx_ss1,yy_ss1)
 \                           : dusted

#---------------------------------------------------------------------------------------------------------------------
# Build DeRing'ing Mask & perform dering'ing:   +++ NEW ROUTINE (Pre-processor) +++
#
tmpp = string(dering_floor)
edge1b = dering < 0
 \                   ?  yv12subtract( last, last.xsharpen(255,255),tol=1,wideRange=true )
 \                     .yv12lut(yexpr="x 128 - abs "+tmpp+" *")
 \                     .expand().inflate().expand().inflate().FineEdge(dering_bias).blur(1.58)
 \                     .greyscale.Ylevels(19,1.6,208,0,255)
 \                   : edge1b
dering < 0 ? maskedmerge( last, soft, edge1b, Y=3,U=1,V=1) : NOP

#-------- iterative sharpening, currently only 3-fold: its slow enough ... --------
 
temp = last
shrpcnt = 0
mskcnt  = 0
shrpcnt = (PixSharp     != 0) ? shrpcnt + 1 : shrpcnt
shrpcnt = (detailcontr2 != 0) ? shrpcnt + 1 : shrpcnt
shrpcnt = (detailcontr1 != 0) ? shrpcnt + 1 : shrpcnt
mskcnt  = (EQ>shrpcnt)        ? shrpcnt     : EQ

# Stage 1 :  UnsharpMasking, wide radius -----------------------
detailcontr1 != 0 
 \                ?   unsharpmask(detailcontr1,contr_radius,0)
 \                :   NOP
detailcontr1 != 0 && (shrpcnt==1 || mskcnt>1 && shrpcnt>=mskcnt) && (EQ>0) 
 \                ?   MaskedMerge(last,temp,edge0.expand.inflate.inflate, Y=3,U=1,V=1)
 \                :   NOP
mskcnt = (detailcontr1 != 0 && (shrpcnt==1 || mskcnt>1 && shrpcnt>=mskcnt)) 
 \                ?   mskcnt - 1
 \                :   mskcnt
shrpcnt = detailcontr1 != 0 ? shrpcnt - 1 : shrpcnt

# Stage 2 :  UnsharpMasking, small radius ----------------------
detailcontr2 != 0 
 \                ?   unsharpmask(detailcontr2,           1,0)
 \                :   NOP
detailcontr2 != 0 && (shrpcnt==1 || mskcnt>1&&shrpcnt>=mskcnt) && (EQ>0)
 \                ?   MaskedMerge(last,temp,edge0.inflate.inflate,Y=3,U=1,V=1,useMMX=true)
 \                :   NOP
mskcnt = (detailcontr2 != 0 && (shrpcnt==1 || mskcnt>1&&shrpcnt>=mskcnt))
 \                ?   mskcnt - 1
 \                :   mskcnt
shrpcnt = detailcontr2 != 0 ? shrpcnt - 1 : shrpcnt

# Stage 3 :  per-pixel sharpening ------------------------------
PixSharp   != 0.0 
 \                ?   sharpen( PixSharp )
 \                :   NOP
PixSharp   != 0.0 && shrpcnt > 0 && EQ>0
 \                ?   MaskedMerge(last,temp,edge0, Y=3,U=1,V=1)
 \                :   NOP
RemoveGrain(1)

#---------------------------------------------------------------------------------------------------------------------
# DeRing'ing of sharpen'ed clip: +++ OLD ROUTINE (Post-processor) +++
#
dering > 0 ? MaskedMerge(last,last.unfilter(-dering,-dering),edge1b.bicubicresize(xx_ss1,yy_ss1),Y=3,U=1,V=1)
 \          : NOP

# Now I have the other idea - but it's too slow, yet
antiflicker2 == true ? temporalsoften(1,2,3,23,2) : NOP

#---------------------------------------------------------------------------------------------------------------------
# 2nd supersampling stage to perform SubPel operation & XSharpening at
#
# Notes: Luma Warping  - may help for sources that are hard to get a "clean" picure from.
#                      - Should help making the picture a little more "gracile" when doing DVD -> HDTV upsizing 

xx_ss2 != ox || yy_ss2 != oy ? LanczosResize(xx_ss2,yy_ss2) : NOP

subpelstren != 0.0 ? blur(subpelstren) : NOP

warp_Y ? awarpsharp(depth=(ss2_x+ss2_y)/2*3,thresh=0.5,blurlevel=2,cm=0) : NOP

Xstren != 0 && Xlimit !=0 ? xsharpen(Xstren,Xlimit) : NOP

LanczosResize(dest_x,dest_y).RemoveGrain(1)

#---------------------------------------------------------------------------------------------------------------------
# Build new EdgeMask of the enhanced clip
#
edge2 = bicubicresize(int(dest_x/1.75/16+.5)*16,int(dest_y/1.75/16+.5)*16,1.0,.0)
 \     .DEdgeMask(0,255,0,255,"-5 -7 -5  -7 48 -7  -5 -7 -5",Y=3,U=1,V=1,setdivisor=true,divisor=1)
bordermask = blankclip(edge2,width=dest_x-16,height=dest_y-16,color=$FFFFFF)
 \          .addborders(2,2,2,2,color=$8F8F8F).addborders(2,2,2,2,color=$6F6F6F)
 \          .addborders(2,2,2,2,color=$202020).addborders(2,2,2,2,color=$000000)
edge2 = edge2 
 \     .levels( (detail_floor+int(detailcontr1/15+detailcontr2/30+PixSharp*15)), 4.0,128,flatweight,255,false)
 \     .bicubicResize(dest_x,dest_y,1.0,0)
edge2 = exborder ? edge2.logic(bordermask,"min") : edge2
edge2 = edge2 
 \     .inflate(Y=3,U=1,V=1).inflate(Y=3,U=1,V=1)
 \     .blur(1.58).greyscale()
 \     .inflate(Y=3,U=1,V=1).inflate(Y=3,U=1,V=1)
 \     .temporalsoften(1,63,63,255,2)

#---------------------------------------------------------------------------------------------------------------------
# Put original de-noised & not-sharpened clip into areas still appearing flat, after all that sharpening 
#
MaskedMerge(dusted.lanczosresize(dest_x,dest_y),last,edge2,Y=3,U=1,V=1)

#---------------------------------------------------------------------------------------------------------------------
# Chroma Warping - often useful for sources where colors are "bleeding". Superfluid for clean sources.
#
warp_UV ? MergeChroma( aWarpSharp(depth = 8.5 * (dest_x/ox + dest_y/oy), thresh=0.5, cm=1, blurlevel=2) ) : NOP

#---------------------------------------------------------------------------------------------------------------------
# Visualizations
#
debug == "dering"   ? overlay(last,blankclip(last,color=$00A000),mask=edge1b.bicubicresize(dest_x,dest_y),mode="blend",opacity=dering_weight)
 \                  : NOP
debug == "protect"  ? overlay(last,blankclip(last,color=$00A000),mask=edge0.bicubicresize(dest_x,dest_y),mode="blend",opacity=0.75)
 \                  : NOP
debug == "detail"   ? overlay(last,blankclip(last,color=$00A000),mask=edge2.bicubicresize(dest_x,dest_y),mode="blend",opacity=0.75)
 \                  : NOP
debug == "compareH" ? stackhorizontal(clp.lanczosresize(dest_x,dest_y).crop(cropx,0,-cropx,-0).addborders(0,0,4,0,color=$800000).subtitle("Original"),
 \                                    last.crop(cropx,0,-cropx,-0).subtitle("iiP") )
 \                  : NOP
debug == "compareV" ? stackvertical(clp.lanczosresize(dest_x,dest_y).crop(0,cropy,-0,-cropy).addborders(0,0,0,4,color=$800000).subtitle("Original"),
 \                                  last .crop(0,cropy,-0,-cropy).subtitle("iiP") )
 \                  : NOP
debug == "showall"  ? stackvertical( stackhorizontal( edge0 .greyscale().lanczosresize(dest_x,dest_y).crop(cropx,cropy,-cropx,-cropy)
 \                                                          .addborders(0,0,4,4,color=$800000).subtitle("Protection of sharp edges"),
 \                                                    edge1b.greyscale().lanczosresize(dest_x,dest_y).crop(cropx,cropy,-cropx,-cropy)
 \                                                          .addborders(0,0,0,4,color=$800000).subtitle("DeRing'ing") ),
 \                                   stackhorizontal( edge2 .greyscale().lanczosresize(dest_x,dest_y).crop(cropx,cropy,-cropx,-cropy)
 \                                                          .addborders(0,0,4,0,color=$800000).subtitle("Detail areas"),
 \                                                    last  .crop(cropx,cropy,-cropx,-cropy).subtitle("iiP") ) )
 \                  : NOP

return(last)
}