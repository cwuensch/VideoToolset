####
##
## SuperSampled TomsMoComp v0.1 by mf
## 
## Uses TMC's internal interpolation to hopefully create a better result than
## with normal TomsMoComp. Also allows for double framerate output (bob).
##
## Usage: SSTomsMoComp("tff") # (or "bff" for bottom field first)
##

LoadPlugin("C:\Programme\AviSynth 2.5\dll\TomsMoComp.dll")


function SSTomsMoComp(clip input, string parity, int "effort", bool "vf", bool "bob", \
bool "downsize") {

# function parameters
effort   = Default(effort, 6)      # Search Effort
vf       = Default(vf, false)      # Vertical blur
bob      = Default(bob, false)     # Output double framerate
downsize = Default(downsize, true) # Downsize to original size


# internal vars
parity2 = (parity == "tff") ? 1 : (parity == "bff") ? 0 : 2
boolparity = (parity2 == 2) ? false : true
Assert(boolparity, "Parity can either be "+Chr(34)+"tff"+Chr(34)+" or "+Chr(34)+"bff"+Chr(34))
vf2 = vf ? 1 : 0
bobheight = input.height-1


input.SeparateFields()
TomsMoComp(0, -1, 0)
crop1 = last
crop2 = crop1.SelectOdd().Crop(0, 0, -0, -1)
crop3 = crop1.SelectEven().Crop(0, 1, -0, -0)
crop4 = crop1.SelectOdd().Crop(0, bobheight, -0, -0)
crop5 = crop1.SelectEven().Crop(0, 0, -0, -bobheight)
crop6 = StackVertical(crop2, crop4)
crop7 = StackVertical(crop5, crop3)
Interleave(crop7, crop6)
Weave()
weaved = last

weaved.TomsMoComp(1, effort, vf2)
topfield = last
weaved.TomsMoComp(0, effort, vf2)
bottomfield = last

firstfield = (parity2 == 1) ? topfield : bottomfield
secondfield = (parity2 == 1) ? bottomfield : topfield
Interleave(firstfield, secondfield)
bobbed = last

nonresized = bob ? bobbed : firstfield

nonresized.LanczosResize(input.width, input.height)
resized = last

return downsize ? resized : nonresized

 }