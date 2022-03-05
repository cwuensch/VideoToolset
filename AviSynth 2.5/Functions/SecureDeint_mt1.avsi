LoadPlugin("C:\Programme\AviSynth 2.5\dll\MaskTools_v1.5.8.dll")
LoadPlugin("C:\Programme\AviSynth 2.5\dll\EEDI2.dll")
LoadPlugin("C:\Programme\AviSynth 2.5\dll\TomsMoComp.dll")
LoadPlugin("C:\Programme\AviSynth 2.5\dll\LeakKernelDeint.dll")


function securedeint(clip i, int "th", int "l", int "mode")
{   th=default(th,6)
    l = default(l,1)
    mode=default(mode,2)

   function staticmask(clip e, int th, int l)
	{e0=e.motionmask(thy1=0,thy2=th,thc1=0,thc2=th,thSD=255,u=3,v=3).temporalsoften(6,1,1)
	e1=e0.trim(1,0)
	e2=e0.trim(2,0)
	e3=e0.trim(3,0)
	e4=e0.trim(4,0)
	e5=e0.trim(5,0)
	e6=e0.trim(6,0)
	e7=e0.trim(7,0)
	ea0=logic(e0,e1,"OR")
	ea1=logic(e2,e3,"OR")
	ea2=logic(e4,e5,"OR")
	ea3=logic(e6,e7,"OR")
	eb0=logic(ea0,ea1,"OR")
	eb1=logic(ea2,ea3,"OR")
	ec=logic(eb0,eb1,"OR")
	(l==0) ? ec .duplicateframe(0).duplicateframe(0).duplicateframe(0) :\
	(l==1) ? eb0.duplicateframe(0) :\
	(l==2) ? ea0 : e0
}
i.converttoyv12(interlaced=true).separatefields()
e=selecteven().staticmask(th, l)
o=selectodd().staticmask(th, l)
mi=interleave(e,o)
m=mi.bob() 
#interleave(mi.weave().tomsmocomp(-1,0,0), mi.doubleweave().selectodd().tomsmocomp(-1,0,0))
m=merge(m.trim(1,0),m,0.5).binarize(upper=false,u=3,v=3)

eedi = getparity(i) ? i.separatefields().eedi2(field=3) : i.separatefields().eedi2(field=2)
toms = interleave(i.tomsmocomp(-1,0,0), i.doubleweave().selectodd().tomsmocomp(-1,0,0))
krnl = i.leakkernelbob(order=(getparity(i) ? 1 : 0), threshold=0)
dumb = i.bob(0,1)

b = (mode==0) ? dumb : (mode==1) ? krnl : (mode==2) ? toms : eedi

d=i.doubleweave()

overlay(d,b,mask=m)
#interleave(min,m,mex)
getparity(i) ? assumetff() : assumebff()
}
