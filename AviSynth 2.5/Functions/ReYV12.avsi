# ReYV12 (aus MVBob)
# ==================
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
