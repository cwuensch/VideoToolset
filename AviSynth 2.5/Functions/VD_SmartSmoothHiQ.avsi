##########################################
# Smart Smoother HiQ by Klaus Post, v2.1 #
#                                        #
# diameter (3-13, odd),                  #
# threshold (1-200), amount (1-254)      #
# difference (0-50)                      #
# mode = "average" or "weighted"         #
# weighted_difference = weigh with diff. #
##########################################

function SmartSmoothHiQ(clip, int "diameter", int "threshold", int "amount", string "mode",
   \  bool "grayscale", bool "weighted_difference", int "maintain_diffweight")

{
  LoadVirtualdubPlugin("C:\Programme\VirtualDubMod\plugins\SmoothHiQ.vdf", "_VD_SmartSmoothHiQ")
  mode = default(mode, "weighted")
  mode = (mode=="average") ? 0 : (mode=="weighted") ? 1 : -1 
  Assert(mode>=0, """VD_SmartSmoothHiQ: "mode" parameter must be "average" or "weighted"""")
  return clip._VD_SmartSmoothHiQ(default(diameter,5), default(threshold,50), 0, default(amount,254),
   \  mode, default(grayscale,false)?1:0, default(weighted_difference,true)?1:0, default(maintain_diffweight,0))
}

