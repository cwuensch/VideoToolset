LoadPlugin("C:\Programme\AviSynth 2.5\dll\mt_MaskTools_v2.0a32.dll")
LoadPlugin("C:\Programme\AviSynth 2.5\dll\DctFilter.dll")
LoadPlugin("C:\Programme\AviSynth 2.5\dll\DeBlock.dll")


function Deblock_QED ( clip clp, int "quant1", int "quant2", 
 \                     int "aOff1", int "bOff1", int "aOff2", int "bOff2", int "uv" )
{
#by Didée from 2007.08.20 - 19:17
quant1 = default( quant1, 24 )
quant2 = default( quant2, 22 )

aOff1  = default( aOff1, 2 )
bOff1  = default( bOff1, 4 )  
aOff2  = default( aOff2, 4 )  
bOff2  = default( bOff2, 8 )  
uv     = default( uv,      1 )        #  uv=3 -> use proposed method for chroma deblocking
                                      #  uv=2 -> no chroma deblocking at all (fastest method)
                                      #  uv=1|-1 -> directly use chroma debl. from the normal|strong deblock()
ox   = clp.width()
oy   = clp.height()                
xmod = 16-(ox%16)
ymod = 16-(oy%16)

clp = (xmod==16) ? clp : clp.pointresize(ox+xmod,oy,0,0,ox+xmod+0.01,oy)
clp = (ymod==16) ? clp : clp.pointresize(clp.width(),oy+ymod,0,0,clp.width(),oy+ymod-0.01)

# With avisynth scripting, there is no information available about the position of the  currently 
# processed pixel ... there simply is no such thing like an "actual" processed pixel.
# So first I've to build up a grid covering the transitions between all 8x8 blocks,
# and make some LUTmania with it later. Yes, this is cumbersome.

block = blankclip(clp,width=6*4,height=6*4,color=$000000).addborders(4,4,4,4,color=$FFFFFF)
block = stackhorizontal( block,block,block,block)
block = stackvertical(   block,block,block,block) .pointresize(32,32) .mt_binarize(upper=false)
block = stackhorizontal( block,block,block,block,block,block,block,block)
block = stackvertical(   block,block,block,block,block,block)
block = stackhorizontal( block,block,block)
block = stackvertical(   block,block,block)
block = (block.width<ox)  ? stackhorizontal( block,block,block) : block
block = (block.height<oy) ? stackvertical(   block,block      ) : block
block = block .crop(0,0,ox,oy) 
block = (uv!=3) ? block
 \    : YtoUV(block.crop(0,0,ox/2,oy/2),block.crop(0,0,ox/2,oy/2),block)
block = block.trim(1,1) .loop(framecount(clp))

block2 = mt_lutxy(block.mt_expand(U=3,V=3),block,"x y -","x y -","x y -",U=3,V=3)

# create normal deblocking (for block borders) and strong deblocking (for block interiour)
normal   = clp.deblock(quant=quant1,aOffset=aOff1,bOffset=bOff1)
strong   = clp.deblock(quant=quant2,aOffset=aOff2,bOffset=bOff2)

# build difference maps of both
normalD  = mt_makediff(clp,normal,U=uv,V=uv)
strongD  = mt_makediff(clp,strong,U=uv,V=uv)

# separate border values of the difference maps, and set the interiours to '128'
strongD2 = mt_lutxy(StrongD,block,"y 255 == x 128 ?","y 255 == x 128 ?","y 255 == x 128 ?",U=uv,V=uv)
normalD2 = mt_lutxy(normalD,block,"y 255 == x 128 ?","y 255 == x 128 ?","y 255 == x 128 ?",U=uv,V=uv)

# interpolate the border values over the whole block: DCTFilter can do it. (Kiss to Tom Barry!)
# (Note: this is not fully accurate, but a reasonable approximation.)
strongD3 = strongD2.mt_lut("x 128 - 1.0 * 4 * 128 +","x 128 - 1.0 * 4 * 128 +","x 128 - 1.0 * 4 * 128 +",U=uv,V=uv).dctfilter(1.0,1.0,0.0,0.0,0.0,0.0,0.0,0.0)# .yv12lut("x 128 - 2 / 128 +")

# apply compensation from "normal" deblocking to the borders of the full-block-compensations calculated 
# from "strong" deblocking ... 
strongD4 = mt_lutxy(strongD3,normalD2,"y 128 == x 128 - 4 / 128 + y ?","y 128 == x 128 - 4 / 128 + y ?","y 128 == x 128 - 4 / 128 + y ?",U=uv,V=uv)
 #strongD4=maskedmerge(strongD4,strongD4.removegrain(19),block2,U=3,V=3)
 
# ... and apply it.
deblocked= mt_makediff(clp,strongD4,U=uv,V=uv) 

# simple decisions how to treat chroma
deblocked = (uv<0) ? deblocked.mergechroma(strong) : uv<2 ? deblocked.mergechroma(normal) : deblocked

deblocked

xmod==16 ? last : last.crop(0,0,-xmod,-0)
ymod==16 ? last : last.crop(0,0,-0,-ymod)

return( last )
}
