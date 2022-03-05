#Helper functions:

# revert PAL-DV to YV12 for quality reasons; 
# needs yuy2 input (ie. canopus-dv-decoder)
# only works properly with BFF.
# this is a workaround for commercial DV-Decoders, only!
# better use ffdshow or Cedocida with direct YV12 output enabled

	Function ReYV12(Clip Input)
	{	
		Y     = Input.ConverttoYV12() #.Greyscale()
		Input = Input.SeparateFields().AssumeFrameBased().SeparateFields().SelectEvery(4, 0, 2).Weave()
		U     = Input.UtoY().ConvertToYV12()
		V     = Input.VtoY().ConvertToYV12()
		YtoUV(U, V, Y)
	}
	

# Stupid bobbing trail using pixel doubling. 
# Requires RGB or YUY2.

	Function PointBob(clip Input)
	{	
		Order = Getparity(Input)# ? False : True
		Input = Input.SeparateFields.PointResize(Input.Width, Input.Height)
		Even  = Input.SelectEven() 
		Odd   = Input.SelectOdd() 
		Even = Order ? Even.Crop(0, 1, 0, 0).AddBorders(0, 0, 0, 1) : Even
		Odd  = Order ? Odd  : Odd .Crop(0, 1, 0, 0).AddBorders(0, 0, 0, 1)
		Interleave(Even, Odd).AssumeFrameBased()
		Order ? AssumeTFF() : AssumeBFF()

	}


# wrapping bob(), this means bicubic interpolation of fields
# this function also passed the Fieldorder information to the output,
# unlike bob() which always resetts the fieldorder to BFF.
# The current field stays untouched.

	Function DumbBob(clip Input, int "Height")
	{
		Input.Bob(0, 0.5, height = Height)
		GetParity(Input) ? AssumeTFF() : AssumeBFF()
	}



#fast ELA-bob, se=0 by default => dumb bob, 
# raising se will do some kind of limited local motion compenastion with se = search radius
# don't use higer values than 5 for se. 

	Function TomsBob(clip Input, int "se")
	{	
		se = Default(se, 0)

		Interleave(\
			Input.TomsMoComp(-1, se, 0), \
			Input.DoubleWeave().SelectOdd().TomsMoComp(-1, se, 0))

		AssumeFrameBased()
		GetParity(Input) ? AssumeTFF() : AssumeBFF()
	}



# fast kernel bob, Threshold=0 by default => dumb bob, 
# raising threshold will enable comb detection (weave static areas)
# only raise Threshold over 0 if you got telecined or fieldblended 
# video. Never use it with true interlaced stuff of video cameras,
# because it can result in strange deinterlacing holes when setting
# Threshold > 0.

	Function KrnlBob(clip Input, int "Threshold")
	{	
		Threshold = Default(Threshold, 0)
		Input.LeakKernelBob(Order = (GetParity(Input) ? 1 : 0), Threshold = Threshold)
		AssumeFrameBased()
		GetParity(Input) ? AssumeTFF() : AssumeBFF()
	}



# slow, but accurate EEDI-bob, always dumb ;)
# altering maxd changes the search radius for connecting diagonal lines

	Function EEDIbob(clip Input, int "maxd")
	{
		#GetParity(Input) ? Input.SeparateFields().EEDI2(Field = 3, maxd = maxd, pp = 0, estr = 0, dstr = 0, mthresh = 0, vthresh = 0, lthresh = 0) : Input.SeparateFields().EEDI2(Field = 2, maxd = maxd, pp = 0, estr = 0, dstr = 0, mthresh = 0, vthresh = 0, lthresh = 0)
		GetParity(Input) ? Input.SeparateFields().EEDI2(Field = 3, maxd = maxd) : Input.SeparateFields().EEDI2(Field = 2, maxd = maxd)

		AssumeFrameBased()
		GetParity(Input) ? AssumeTFF() : AssumeBFF()
	}



# very fast dumb EDI-bob with pretty good abilities to connect diagenals.
# Be careful: it is prone to artifacting

	Function Sangbob(clip Input, int "aa")
	{
		Function SangnomBob(clip Input, int "aa")
		{
			Getparity(Input) ? Interleave(Input.Sangnom(Order = 1, aa = aa), Input.Sangnom(Order = 0, aa = aa)) : Interleave(Input.Sangnom(Order = 0, aa = aa), Input.Sangnom(Order = 1, aa = aa))

			AssumeFrameBased()
			GetParity(Input) ? AssumeTFF() : AssumeBFF()
		}
	Y    = Input.ConvertToYV12().SangnomBob(aa)
	U    = Input.UtoY().ConvertToYV12().SangnomBob(aa)
	V    = Input.VtoY().ConvertToYV12().SangnomBob(aa)
	Y    = IsYV12(Input) ? Y : Y.ConvertToYUY2()
	U    = IsYV12(Input) ? U : U.ConvertToYUY2()
	V    = IsYV12(Input) ? V : V.ConvertToYUY2()
	YUV  = YtoUV(U, V, Y)
	
	Return YUV
	}


# cut down progressive to interlaced 
# eg.: 50 fps progressive to 25 fps interlaced or 59.94 fps progressive to 29.97 fps interlaced
# setting YV12 = True will output interlaced YV12. Be careful with this! 
# Only use it, if you are REALLY sure how to treat interlaced YV12.
# Only a handful of encoders will accept and treat interlaced YV12 correctly. 
# Such are for example: HcEnc, QUEnc or XVid.
# by default (YV12 = False) it puts out YUY2 which will be accepted by most encoders

	Function ReInterlace(clip Input, bool "YV12")
	{	
		YV12 = Default(YV12, false)
		Input = YV12 ? Input.ConvertToYV12 : Input.ConvertToYUY2()
		Input.SeparateFields().SelectEvery(4, 0, 3).Weave()
	}


# Experimental. Not for usage.

	Function SceneChange(Clip Input, int Threshold)
	{	
		MaskE = Input.Selecteven().Motionmask(thY1 = Threshold, thY2 = Threshold, thC1 = Round(Threshold * 0.5), thC2 = Round(Threshold * 0.5), thSD = 255, U = 3, V = 3)
		MaskO = Input.SelectOdd() .Motionmask(thY1 = Threshold, thY2 = Threshold, thC1 = Round(Threshold * 0.5), thC2 = Round(Threshold * 0.5), thSD = 255, U = 3, V = 3)
		Mask  = Interleave(MaskE, MaskO)
		Mask = Logic(Mask, Mask.Deleteframe(0), "AND", U = 3, V = 3)
	
		Return stackvertical(Input, Mask)
	}


# Deinterlacer that avoids residual combing with tricky motion at all cost.
# with bobbing-overweights-weaving-technology-tm

# "Threshold" declares the motion detection strenght. It is 6 by default.
# zero Threshold won't disable motion detection! 
# Threshold = -1 will disable motion detection.

# "Lenght" declares the temporal lenght of the motion mask:
# 0 -> 16 fields, most secure, static areas need some time to calm down.
# 1 ->  8 fields, pretty secure
# 2 ->  4 fields, unsecure
# 3 ->  2 fields, useless, most times, but static areas are calmed down immediatelly

# "Type" declares the kind of interpolation applied to moving areas:
# 0 -> Bicubic from bob()
# 1 -> Tomsmocomp() ELA-style of interpolation
# 2 -> v-t kernel interpolation from Kerneldeint()
# 3 -> EDI interpolatian from triticals EEDI2()
# 4 -> EDI interpolation from MarcFD's Sangnom()

	Function SecureBob(clip Input, int "Threshold", int "Length", int "Type")
	{	
		# StaticMask uses a long temporal window to create a motionmask that is resist to 
		Function StaticMask(Clip Fields, int Threshold, int Length)
		{	
			Fields_0 = Fields.MotionMask(thY1 = Threshold, thY2 = Threshold, thC1 = Round(Threshold * 0.5), thC2 = Round(Threshold * 0.5), thSD = 255, U = 3, V = 3)
			
			Fields_1 = Fields_0.Trim(1, 0)
			Fields_2 = Fields_0.Trim(2, 0)
			Fields_3 = Fields_0.Trim(3, 0)
			Fields_4 = Fields_0.Trim(4, 0)
			Fields_5 = Fields_0.Trim(5, 0)
			Fields_6 = Fields_0.Trim(6, 0)
			Fields_7 = Fields_0.Trim(7, 0)

			Fields_01        = Logic(Fields_0,    Fields_1,    "OR", U = 3, V = 3)
			Fields_23        = Logic(Fields_2,    Fields_3,    "OR", U = 3, V = 3)
			Fields_45        = Logic(Fields_4,    Fields_5,    "OR", U = 3, V = 3)
			Fields_67        = Logic(Fields_6,    Fields_7,    "OR", U = 3, V = 3)

			Fields_0123      = Logic(Fields_01,   Fields_23,   "OR", U = 3, V = 3)
			Fields_4567      = Logic(Fields_45,   Fields_67,   "OR", U = 3, V = 3)

			Fields_01234567  = Logic(Fields_0123, Fields_4567, "OR", U = 3, V = 3)

			(Length == 0) ? Fields_01234567.DuplicateFrame(0).DuplicateFrame(0).DuplicateFrame(0) :\
			(Length == 1) ? Fields_0123.    DuplicateFrame(0) :\
			(Length == 2) ? Fields_01 :\
					Fields_0
			Return Last
		}


		Threshold  = Default(Threshold, 3)
    		Length     = Default(Length,    1)
		Type       = Default(Type,      3)
		
		Input.ConvertToYV12(Interlaced = True).SeparateFields()
		EvenFields = Last.SelectEven().StaticMask(Threshold, Length) #.subtitle("X")
		OddFields  = Last.SelectOdd() .StaticMask(Threshold, Length) #.subtitle("X")
		
		CombMask   = Interleave(EvenFields, OddFields).dumbbob()
		CombMask   = Merge(CombMask.Trim(1, 0), CombMask, 0.5).Binarize(U = 3, V = 3, upper=false)

		Bobbed     = (Type == 0) ? Input.DumbBob() :\ 
		             (Type == 1) ? Input.TomsBob() :\ 
		             (Type == 2) ? Input.KrnlBob() :\ 
		             (Type == 3) ? Input.EEDIBob() :\
                                           Input.SangBob()    

		Weaved     = Input.DoubleWeave()

		Output     = IsYV12(Input) ? MaskedMerge(Weaved, Bobbed, CombMask, U = 3, V = 3) :\
		                             Overlay(Weaved, Bobbed, Mask = CombMask.ConvertToYUY2(), GreyMask = False)

		Output     = Output.AssumeFrameBased()
		Output     = GetParity(Input) ? Output.AssumeTFF() : Output.AssumeBFF()

		Ouput      = (Threshold < 0) ? Bobbed : Output

		Return Output #StackVertical(Output, Combmask)
	}



# Function to aid motion compensated standards conversions of camera materials (true interlaced)
# It offers a little automatism to help easy NTSC <-> PAL conversions.
# if the input is 50 fps, then it'll convert to 59.94 fps without any parameters given
# elseif the input is 60 fps, then it'll convert to 50 fps without any parameters given
# else if parameters given it uses num and den for the desired framerate

	Function ConvertMCfps(clip Input, int "Num", int "Den", int "BlkSize", int "lambda", float "ml")
	{       
		BlkSize = Default(BlkSize, 8)
		BlkSize = (BlkSize == 8) ? 8 : (BlkSize == 16) ? 16 : 4
		Rate= (Defined(Num) && Defined(Den)) ? -1 : FrameRate(Input)

		TM=true
		#lm=10000

		#Input = IsYV12(Input) ? Input : Input.ConvertToYV12() # Needed with older versions of mvtools
		Cropped = (BlkSize == 8) ? Input.Crop(4, 4, -4, -4) : (Blksize == 4) ? Input.Crop(2, 2, -6, -6) : Input.Crop(8, 8, -8, -8)

		Backward_Vec  = Input.  MVAnalyse(isb = True,  BlkSize=BlkSize, TrueMotion=TM, Pel=2, Idx=4, sharp=1, lambda = lambda)
		Forward_Vec   = Input.  MVAnalyse(isb = False, BlkSize=BlkSize, TrueMotion=TM, Pel=2, Idx=4, sharp=1, lambda = lambda)
		Backward_Vec2 = Cropped.MVAnalyse(isb = True,  BlkSize=BlkSize, TrueMotion=TM, Pel=2, Idx=3, sharp=1, lambda = lambda)
		Forward_Vec2  = Cropped.MVAnalyse(isb = False, BlkSize=BlkSize, TrueMotion=TM, Pel=2, Idx=3, sharp=1, lambda = lambda)
		
		Output = (Rate == 50) ?             \
			Input.MVFlowfps2(Backward_Vec, Forward_Vec, Backward_Vec2, Forward_Vec2, Num = 60000, Den = 1001, Idx = 4, Idx2 = 3, ml=ml) : \
		         ((Rate > 59.90) && (Rate < 60.01)) ? \
			Input.MVFlowFps2(Backward_Vec, Forward_Vec, Backward_Vec2, Forward_Vec2, Num = 50,    Den = 1,    Idx = 4, Idx2 = 3, ml=ml) : \
                	Input.MVFlowFps2(Backward_Vec, Forward_Vec, Backward_Vec2, Forward_Vec2, Num = Num,   Den = Den,  Idx = 4, Idx2 = 3, ml=ml)

		Return Output
	}



function MvBob(clip Input, int "BlkSize", int "Pel", int "CorrectTh", int "Threshold", int "Type", int "Length")
{

	#disable all scene detection of mvcompensate(), because mvbob() is self-correcting due to the corrector()
	sc = 255 

	# threshold for correcting failed compensated motion 
	CorrectTh = Default(CorrectTh, 8) 

	# deinterlacing threshold for the motion vector analysis do not go much higher than 10
	BobTh = Default(Threshold, 6)
	BobType = Default(Type, 3)

	#defaults for the MoComp
	BlkSize = Default(BlkSize, 8)
	scd = round(2000 * ((blksize * blksize) / 64))
	Pel = default(Pel, 2)
	Lambda = 6000

	#determine clip Fieldorder
	Order = (Input.GetParity == True) ? 1 : 0
	YV12 = IsYV12(Input)

	# create a motion adaptive bobbed clip with ELA interpolation from the Input
	Bobbed           = Input.SecureBob(Threshold = BobTh, Type=BobType, Length=Length)
	AnalyseBob       = Bobbed #.Reduceflicker() #YV12 ? Bobbed.RemoveGrain(11) : Bobbed.ConverTtoYV12().removegrain(11).ConvertToYUY2()

	# create clip for motion compensation
	Fields           = Bobbed

	# create motion vectors
	mvf              = AnalyseBob.MvAnalyse(BlkSize = BlkSize, Pel = Pel, isB = False, Chroma = True, idx = 1, TrueMotion = True, Sharp = 2, Lambda = Lambda, Overlap = BlkSize/2)
	mvb              = AnalyseBob.MvAnalyse(BlkSize = BlkSize, Pel = Pel, isB = True,  Chroma = True, idx = 1, TrueMotion = True, Sharp = 2, Lambda = Lambda, Overlap = BlkSize/2)
	#DePanMV       = Fields.depanestimate()
	#DePanMVBWD       = Fields.MvDePan(mvb, thSCD1 = scd, thSCD2 = 255, error=255, pixaspect=0.911)


	# create the motion compensated clip that are passed through to the output
	MoCompFWD        = Fields.MvCompensate(mvf, idx = 1, thSCD1 = scd)
	MoCompBWD        = Fields.MvCompensate(mvb, idx = 1, thSCD1 = scd)
# Experimental: Flow
#	MoFlowFWD        = Fields.MvFlow(mvf, idx = 1, thSCD1 = scd)
#	MoFlowBWD        = Fields.MvFlow(mvb, idx = 1, thSCD1 = scd)
# Experimental: GMC
#	DePanFWD         = Fields.DePan(data=DepanMV, offset=1.0) 
#	DePanBWD         = Fields.DePan(data=DepanMV, offset=-1.0)

	# create clips for mismatch detection
#	AnalyseBobFWD    = AnalyseBob.MvCompensate(mvf, idx = 1, thSCD1 = scd).converttoyv12().medianblur()
#	AnalyseBobBWD    = AnalyseBob.MvCompensate(mvb, idx = 1, thSCD1 = scd).converttoyv12().medianblur()

	AnalyseBobCurr   = AnalyseBob.Converttoyv12().BicubicResize(Input.Width * 2, Input.Height).MedianBlur().BicubicResize(Input.Width, Input.Height)
	AnalyseCompFWD   = MoCompFWD .converttoyv12().BicubicResize(Input.Width * 2, Input.Height).MedianBlur().BicubicResize(Input.Width, Input.Height)
	AnalyseCompBWD   = MoCompBWD .converttoyv12().BicubicResize(Input.Width * 2, Input.Height).MedianBlur().BicubicResize(Input.Width, Input.Height)
# Experimental: Flow
#	AnalyseFlowFWD   = MoFlowFWD .converttoyv12().BicubicResize(Input.Width * 2, Input.Height).MedianBlur().BicubicResize(Input.Width, Input.Height)
#	AnalyseFlowBWD   = MoFlowBWD .converttoyv12().BicubicResize(Input.Width * 2, Input.Height).MedianBlur().BicubicResize(Input.Width, Input.Height)
# Experimental: GMC
#	AnalyseDePanFWD  = DePanFWD  .Converttoyv12().BicubicResize(Input.Width * 2, Input.Height).MedianBlur().BicubicResize(Input.Width, Input.Height)
#	AnalyseDePanBWD  = DePanBWD  .Converttoyv12().BicubicResize(Input.Width * 2, Input.Height).MedianBlur().BicubicResize(Input.Width, Input.Height)

	AnalyseBobCurr   = YV12 ? AnalyseBobCurr : AnalyseBobCurr.ConvertToYUY2()
	AnalyseCompFWD   = YV12 ? AnalyseCompFWD : AnalyseCompFWD.ConvertToYUY2()
	AnalyseCompBWD   = YV12 ? AnalyseCompBWD : AnalyseCompBWD.ConvertToYUY2()
# Experimental: Flow
#	AnalyseFlowFWD   = YV12 ? AnalyseFlowFWD : AnalyseFlowFWD.ConvertToYUY2()
#	AnalyseFlowBWD   = YV12 ? AnalyseFlowBWD : AnalyseFlowBWD.ConvertToYUY2()
# Experimental: GMC
#	AnalyseDePanFWD  = YV12 ? AnalyseDePanFWD : AnalyseDePanFWD.ConvertToYUY2()
#	AnalyseDePanBWD  = YV12 ? AnalyseDePanBWD : AnalyseDePanBWD.ConvertToYUY2()
        
	# detect mismatches of mvtools and replace them with motion adaptive bobbed areas
	#MoCompCorrected  = Corrector(AnalyseBobCurr, Fields, AnalyseCompFWD, AnalyseCompBWD, AnalyseFlowFWD, AnalyseFlowBWD, MoCompFWD, MoCompBWD, MoFlowFWD, MoFlowBWD, Mode = 0, Th = CorrectTh)
	MoCompCorrected  = Corrector(AnalyseBobCurr, Fields, AnalyseCompFWD, AnalyseCompBWD, MoCompFWD, MoCompBWD, Mode = 0, Th = CorrectTh)

# Experimental: GMC
	#MoCompCorrected  = Corrector(AnalyseBobCurr, Fields, AnalyseBobFWD, AnalyseBobBWD, AnalyseDePanFWD, AnalyseDePanBWD, MoCompFWD, MoCompBWD, DePanFWD, DePanBWD, Mode = 1, Th = CorrectTh)	
	#MoCompCorrected  = Corrector(AnalyseBobCurr, Fields, AnalyseCompFWD, AnalyseCompBWD, MoCompFWD, MoCompBWD, Mode = 0, Th = CorrectTh)

	#MoCompCorrected   = Merge(Merge(MoCompFWD, MoCompBWD), Merge(MoFlowFWD, MoFlowBWD))
	# Select the Interpolated Fields 
	Compensated_Even = MoCompCorrected.SelectEven().SeparateFields().SelectOdd() 
	Compensated_Odd  = MoCompCorrected.SelectOdd() .SeparateFields().SelectEven()

	# Select the Original Fields
	Original_Even    = Input.SeparateFields().SelectEven()
	Original_Odd     = Input.SeparateFields().SelectOdd()

	# Merge them
	Output_Even      = Interleave(Original_Even, Compensated_Even).Weave()
	Output_Odd       = Interleave(Original_Odd , Compensated_Odd ).Weave()
	Output           = Interleave(Output_Even, Output_Odd)
	# Output           = Stackhorizontal(Bobbed, Output)
	# Assign the correct Fieldorder to the Output in Order to allow correct processing for following filters
	Output           = (order == 1) ? Output.AssumeTFF() : Output.AssumeBFF()
	#Output=interleave(Depanfwd, fields, depanbwd)
	Return  Output	#stackvertical(AnalyseBobCurr, AnalyseCompFWD)
}  


# needed plugins
#loadplugin("C:\Programme\AviSynth 2.5\dll\masktools.dll")	[V1.5.8]
loadplugin("C:\Programme\AviSynth 2.5\dll\masktools_v1.5.8.dll")

#loadplugin("C:\Programme\AviSynth 2.5\dll\mvtools.dll")	[V1.3.0]
loadplugin("C:\Programme\AviSynth 2.5\dll\mvtools_v1.8.4.dll")

loadplugin("C:\Programme\AviSynth 2.5\dll\tomsmocomp.dll")
loadplugin("C:\Programme\AviSynth 2.5\dll\leakkerneldeint.dll")

#loadplugin("C:\Programme\AviSynth 2.5\dll\eedi2.dll")		[V0.9.1]
loadplugin("C:\Programme\AviSynth 2.5\dll\eedi2.dll")

loadplugin("C:\Programme\AviSynth 2.5\dll\medianblur.dll")
loadplugin("C:\Programme\AviSynth 2.5\dll\corrector.dll")
loadplugin("C:\Programme\AviSynth 2.5\dll\sangnom.dll")

