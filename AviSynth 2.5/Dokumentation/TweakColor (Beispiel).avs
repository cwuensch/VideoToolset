LoadPlugin("C:\av\avisynth\myplugins\TweakColor.dll")
mode="YUY2" #"YV12"


### TweakColor ####
#
#  Based on built in Tweak.  Allows direct targeting of specific color hues and
#  saturation levels.  ie Red highlights ...
#
## params:
##   hue, sat, bright, cont = same as Tweak  
##   startHue = 0-359 starting hue to effect, in degrees. Exact magenta is ~ 50 degrees
##              Colors are 60 degrees appart.  +/-30 around center covers full color.
##              colors run clockwise: magenta(50),red(110),yellow(170),green(230),cyan(290),blue(350)
##              default=0
##   endHue = 0-359 ending hue.  If < startHue, we go clockwise. default=359
##   maxSat = Max saturation level to effect.  Sat is in percents running from 115%-0%. default=115
##   minSat = Min saturation level to effect.  Must be < maxSat. default=0
##   smooth = 0-64 Interpolates past max/min sats to smooth out changes (avoid contors). default=16.  
#
###################


##-- Make a color ramp for testing --##
clrC = blankclip(width=400,height=2,pixel_type=mode,color=$000000)
addClr(clrC,1,mode,getColor("green"))  #<<==== Change the color here =======


##-- Try Some settings -----------
#TweakColor(sat=.75,startHue=20,endHue=80,maxSat=75,minSat=50,smooth=0)   #magenta
#TweakColor(sat=0.75,startHue=80,endHue=140,maxSat=115,minSat=75)  #red
#TweakColor(sat=0,startHue=140,endHue=200,maxSat=75,minSat=50)   #yellow
TweakColor(sat=0,startHue=200,endHue=260,maxSat=75,minSat=50)  #green
#TweakColor(sat=0,startHue=260,endHue=320,maxSat=30,minSat=15)  #cyan
#TweakColor(sat=.75,startHue=320,endHue=359,maxSat=75,minSat=50)  #blue




#------ Function to create a color ramp ---------
function addClr(clip c, int num, string mode, string clr) { 

  return (num > 255) ? c \
	:  addClr(stackVertical(c,blankclip(width=400,height=2,pixel_type=mode,color=Eval(clr))),num+1,mode,clr)
   
}


#------ Function to pick a color by name ---------
function getColor(string clr) {

   return clr=="magenta" ? "num + (num * 65536)" : \
      clr=="yellow" ? "256* num + (num * 65536)": \
      clr=="red" ? "(num * 65536)": \
      clr=="blue" ? "num": \
      clr=="cyan" ? "num * 256 + num": \
      clr=="green" ? "num * 256": \
      "num * 256 + num + (num * 65536)" 
      #grey
}
