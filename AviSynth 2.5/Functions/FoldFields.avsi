# SetParity
#
#   Sets the parity of a clip.
#
# PARAMETERS:
#   parity : true for TFF, false for BFF.
#            These values correspond to those returned by the internal
#              GetParity function.
#            (I use the mnemonic "T" = "T"op = "T"rue to remember.)
#
function SetParity(clip c, bool parity)
{
    return parity ? c.AssumeTFF() : c.AssumeBFF()
}


# UnfoldFieldsVertical
#
#   Separates the fields in a clip and stacks them vertically.
#   Regardless of field order, even fields are on top.
#
#   Useful for applying spatial-temporal filters to interlaced
#   video.
#
# PARAMETERS:
#   "flip" : Pass true to flip the bottom field vertically.
#            Useful when dealing with spatial filters.
#            (Default: false)
#
# USAGE:
#   Should be used in conjunction with FoldFieldsVertical.
#
#   UnfoldFieldsVertical(true)
#   PixieDust()
#   FoldFieldsVertical(true)
#
# REQUIRES;
#   jdl-util.avsi (SetParity)
#
function UnfoldFieldsVertical(clip c, bool "flip")
{
    Assert(c.IsFrameBased(), "UnfoldFieldsVertical: clip must not have separated fields")
    flip = Default(flip, false)
    oldParity = c.GetParity()
    # c = c.IsFrameBased() ? c : c.Weave()
    c.AssumeTFF().SeparateFields().AssumeFrameBased()
    top = SelectEven()
    bottom = SelectOdd()
    StackVertical(top, flip ? bottom.FlipVertical()
    \                       : bottom)
    return (c.FrameCount() == 0)
    \      ? c
    \      : SetParity(oldParity)
}


# FoldFieldsVertical
#
#   Recombines the fields from a clip that resulted from calling
#   UnfoldFieldsVertical.  Undoes the work of UnfoldFieldsVertical.
#
# PARAMETERS:
#   "flip" : Pass true if the bottom field was flipped vertically with
#              UnfoldFieldsVertical.
#            (Default: false)
#
# USAGE:
#   See UnfoldFieldsVertical.
#
# REQUIRES:
#   jdl-util.avsi (SetParity)
#
function FoldFieldsVertical(clip c, bool "flip")
{
    Assert(c.IsFrameBased(), "FoldFieldsVertical: clip must not have separated fields")
    Assert(c.Height() % 2 == 0, "FoldFieldsVertical: unexpected frame height")
    flip = Default(flip, false)
    oldParity = c.GetParity()
    originalHeight = c.Height() / 2
    top = c.Crop(0, 0, c.Width(), originalHeight)
    bottom = c.Crop(0, originalHeight, c.Width(), originalHeight)
    bottom = flip ? bottom.FlipVertical() : bottom
    Interleave(top, bottom).AssumeFieldBased().AssumeTFF().Weave()
    return (c.FrameCount() == 0)
    \      ? c
    \      : SetParity(oldParity)
}
