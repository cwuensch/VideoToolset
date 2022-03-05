#Helper functions:

	#motion compensated framerate converter; yv12 only
	#function mvfps(clip i, float fps, int "blur")
	#{       
	#	blur=default(blur,1)
	#	fwd=mvtools0962_mvanalyse(i,isb=false,lambda=400)
	#	bwd=mvtools0962_mvanalyse(i,isb=true, lambda=400)
	#	i.mvtools0962_mvconvertfps(bwd,fwd,fps=fps*blur)
	#	temporalsoften(round((blur)/3),255,255)
	#	selectevery(blur,round(blur/2))
	#}

	#revert PAL-DV to YV12 for quality reasons; needs yuy2 input (ie. canopus-dv-decoder)
	function reYV12(clip i)
	{
		yx=i.converttoyv12().greyscale()
		x=i.separatefields().separatefields().selectevery(4,0,2).weave()
		ux=x.utoy().converttoyv12()
		vx=x.vtoy().converttoyv12()
		ytouv(ux,vx,yx)
	}



function MVbob(clip c,int "blksize", int "pel", int "lambda", int "th", int "ths", int "bobth", bool "predenoise")
{
	#find static parts (experimental)
	function static_o_matic(clip i, clip j, int thy, int thc)
	{
		a = isyv12(i) ? i.motionmask(thy1=0,thy2=thy,thc1=0,thc2=thc,thSD=255,y=3,u=3,v=3) \
			      : i.converttoyv12().motionmask(thy1=0,thy2=thy,thc1=0,thc2=thc,thSD=255,y=3,u=3,v=3)
	#	a=i.converttoyv12().motionmask(thy1=0,thy2=thy,thc1=0,thc2=thc,thSD=255,y=3,u=3,v=3)
		logic(a,a.trim(1,0),"OR",y=3,u=3,v=3)
		RemoveGrain(1) # undot()
		overlay (i,j, mask=last) # MaskedMerge(i,j,last,U=3,V=3) # 
	}

#disable all scene detection of mvcompensate(), because mvbob() is self-correcting due to the corrector()
	sc=255 

# threshold for correcting failed compensated motion 
	th=default(th,8) 

# threshold for correcting static areas
	ths=default(ths,3)

# deinterlacing threshold for the motion vector analysis do not go much higher than 10
	bobth=default(bobth,8)

#denoise the video for the bobber (better static areas for noisy video, crappy)
	predenoise=default(predenoise,false)

#defaults for the mocomp
	blksize=default(blksize,8)
	scd=(blksize==8)? 300 : round(300/4)
	pel=default(pel,2)
	lambda=default(lambda,1000)

#determine clip Fieldorder
	order=(c.getparity==true)? 1:0
	yv12 = isyv12(c)

	# bobx 	-> kerneldeinterlaced video, used for motion search

	# mvf   -> motion vectors forward
	# mvb   -> motion vectors backward

	# bobd 	-> blurred bobx for error checking (correcting false compensated blocks!)
	# bobdf -> forward  compensated bobd
	# bobdb -> backward compensated bobd
	# bobdm -> average of bobdb and bobdf

	# fields-> ELA-deinterlaced fields for motion compensated output and compensation correction
	# mcf   -> forward  compensated fields
	# mcb   -> backward compensated fields
	# cv    -> average of mcb and mcf

	# dpf   -> forward  compensated fields (global motion)
	# dpb   -> backward compensated fields (global motion)
	# dp    -> average of dpb and dpf

	# mc    -> corrected motion compensated result

# create clip for motion analysis and hole-filling
	bobt=predenoise ? c.temporalsoften(2,5,10) : c
	bobc=bobt.leakkernelbob(order=order,threshold=bobth,twoway=true,sharp=true)
	bobc= (order==1) ? bobc.assumetff() : bobc.assumebff()
	bobx= yv12 ? bobc : bobc.converttoyv12()
	bobd=bobx.RemoveGrain(1).bicubicresize(bobx.width,bobx.height/2) # bobx.undot().verticalreduceby2()
	bobd=bobd.lanczosresize(bobx.width,bobx.height).blur(0,1)


# create clip for motion compensation
	fieldsx = c.tdeint(mode=1,mthreshl=bobth,mthreshc=bobth+2,type=3,Link=0)
	fields= yv12 ? fieldsx : fieldsx.converttoyv12()


# create motion vectors
	mvf=bobd.mvanalyse(blksize=blksize,pel=pel,isb=false,chroma=true,idx=1)#,search=3,searchparam=10)
	mvb=bobd.mvanalyse(blksize=blksize,pel=pel,isb=true, chroma=true,idx=1)#,search=3,searchparam=10)

# create clips for mismatch detection
	#local motion
	bobdf=bobd.mvcompensate(mvf,mode=1,thscd1=scd,thSCD2=sc,idx=1)
	bobdb=bobd.mvcompensate(mvb,mode=1,thscd1=scd,thSCD2=sc,idx=1)
	#bobdm=bobdf.mergeluma(bobdb,0.5).mergechroma(bobdb,0.5)
	bobdm=merge(bobdf,bobdb,0.5)

	#global motion
#	bobdpf=fields.MVDepan(mvf, zoom=true, rot=true, pixaspect=1.0 )
#	bobdpb=fields.MVDepan(mvb, zoom=true, rot=true, pixaspect=1.0 )
#	bobdpm=bobdpf.mergeluma(bobdpb,0.5).mergechroma(bobdpb,0.5)

# create the motion compensated clip that are passe to the output
	#local motion
	mcf=fields.mvcompensate(mvf,mode=1,thscd1=scd,thSCD2=sc,idx=2).deblock()
	mcb=fields.mvcompensate(mvb,mode=1,thscd1=scd,thSCD2=sc,idx=2).deblock()
	#cv=mcf.mergechroma(mcb,0.5).mergeluma(mcb,0.5)
	cv=merge(mcf,mcb,0.5)

	#global motion
#	dpf=fields.MVDepan(vectors=mvf, zoom=false, rot=false, pixaspect=1.0,thscd1=scd,thSCD2=sc,info=false,error=255 )
#	dpb=fields.MVDepan(vectors=mvb, zoom=true,  rot=true,  pixaspect=1.0,thscd1=scd,thSCD2=sc, info=false,error=255 )
#	dp=dpf.mergechroma(dpb,0.5).mergeluma(dpb,0.5)


# detect mismatches of mvtools and replace them with motion adaptive bobbed areas
	mc=corrector(bobd,fields,   bobdf,bobdb,  mcf,mcb,   mode=0,th=th)
	#mc=corrector(bobd,fields,   bobdpf,bobdpb,bobdf,bobdb,   dpf,dpb,mcf,mcb,   mode=0,th=th)

# merge corrected output and raw output into one frame horizontally
	mc=stackhorizontal(mc,cv) 

# select the correct lines 
	compensated_even=(order==0) ? mc.selecteven().separatefields().selectodd()  : mc.selecteven().separatefields().selectodd()
	compensated_odd =(order==0) ? mc.selectodd() .separatefields().selecteven() : mc.selectodd() .separatefields().selecteven()

# ensure correct chroma format
	compensated_even=yv12 ? compensated_even : compensated_even.converttoyuy2()
	compensated_odd =yv12 ? compensated_odd  : compensated_odd .converttoyuy2()

# merge them with the original fields
	original_even=c.separatefields().selecteven()#.lev(0)
	original_odd =c.separatefields().selectodd()#.lev(0)

	even=interleave(stackhorizontal(original_even, original_even), compensated_even).weave()
	odd =interleave(stackhorizontal(original_odd , original_odd ), compensated_odd ).weave()

	interleave(even,odd)

#separate into corrected and raw video || correct static areas
	mc_corr=crop(last,0,0,width/2,0)
	mc_raw =crop(last,width/2,0,0,0)
	static_o_matic(mc_raw,mc_corr,ths,ths)

# some lines for developement, visualisation and comparision.... uncomment if wished...
#	stackhorizontal(last,fieldsx) 	#show mvdeinterlaced and t-deinterlaced video side by side for comparsion
#	interleave(last,fieldsx)	#alternate mv- and t-deinterlaced video

}  


# new
#LoadPlugin("C:\Programme\AviSynth 2.5\dll\RemoveGrain_v10pre1.dll")
LoadPlugin("C:\Programme\AviSynth 2.5\dll\RemoveGrain_v10.dll")

# updated
#loadplugin("C:\Programme\AviSynth 2.5\dll\TDeint_v1b4.dll")	
loadplugin("C:\Programme\AviSynth 2.5\dll\TDeint.dll")		# [V1.1]

loadplugin("C:\Programme\AviSynth 2.5\dll\leakkerneldeint.dll")
loadplugin("C:\Programme\AviSynth 2.5\dll\masktools_v1.5.8.dll")

# as before
#loadplugin("C:\Programme\AviSynth 2.5\dll\MVTools_v0.9.6.2.dll")	# nicht zu finden - CW
#loadplugin("C:\Programme\AviSynth 2.5\dll\MVtools_v0.9.9.1.dll")	# ersetzt durch v1.8.4 + DeBlock + Corrector - CW
loadplugin("C:\Programme\AviSynth 2.5\dll\MVTools_v1.8.4.dll")		# neue Version - CW

# no more needed
# LoadPlugin("C:\Programme\AviSynth 2.5\dll\undot.dll")

LoadPlugin("C:\Programme\AviSynth 2.5\dll\DeBlock.dll")
LoadPlugin("C:\Programme\AviSynth 2.5\dll\Corrector.dll")
