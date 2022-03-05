# http://forum.doom9.org/showpost.php?p=1570968&postcount=7
# http://avisynth.nl/index.php/Histograms_in_RGB_%26_CMY
#
#
# Histograms in RGB & CMY
#
# HistogramRGBParade presents a fairly standard RGB parade color scope.
# Uses the "Classic" avisynth histogram for each RGB component, but applied to columns rather than rows
# - The "width" setting controls the size of the histogram display. Default is 0.25 (height is always 256 pixels)
# Examples:
#   HistogramRGBParade()
#   HistogramRGBParade(width=0.15) # display histogram a bit smaller (from default 0.25)
#
# HistogramRGBLevels / HistogramCMYLevels are like the "Levels" avisynth histogram but for RGB and CMY instead of YUV
# - Set range=false to hide the 16-235 range (a left-over from the Y histogram used to build these)
# - "factor" has same usage as Avisynth Histogram function
# Examples:
#   HistogramRGBLevels()
#   HistogramCMYLevels()
#   HistogramRGBLevels(range=false) # don't show tv-range from luma graph

#---

function HistogramBoth( clip input, bool "interlaced", bool "vectorscope" )
{
  # Zeigt RGB- und Levels- Histogramm nebeneinander an
  interlace = default(interlaced, false)
  vectorscope = default(vectorscope, false)

  a = input.ConvertToYV16 (matrix="Rec601", interlaced=interlace).Histogram(mode="levels")
  b = input.ConvertToRGB32(matrix="Rec601", interlaced=interlace).HistogramRGBLevels().ConvertToYV16()
  c = input.ConvertToYV16 (matrix="Rec601", interlaced=interlace).Histogram(mode="color2")

  a = a.Crop(input.Width(), 0, 0, 240-a.Height())
  b = b.Crop(input.Width(), 0, 0, 210-b.Height())
  c = c.Crop(input.Width(), 0, 0, 0)

  #a = (input.Height() > a.Height()+b.Height()) ? a.AddBorders(0, 0, 0, input.Height() - a.Height() - b.Height()) : a
  hist = Stackvertical(a,b)

  hist2 = hist.Height() > c.Height() ? \ 
           StackHorizontal(hist, c.AddBorders(0,0,0,hist.Height() - c.Height())) : \
           StackHorizontal(hist.AddBorders(0,0,0,c.Height() - hist.Height()), c)
  hist = vectorscope ? hist2 : hist

  hist = input.IsYUY2()   ? hist.ConvertToYUY2 (matrix="Rec601", interlaced=interlace) : \
         input.IsYV12()   ? hist.ConvertToYV12 (matrix="Rec601", interlaced=interlace) : \
         input.IsYV16()   ? hist.ConvertToYV16 (matrix="Rec601", interlaced=interlace) : \
         input.IsRGB()    ? hist.ConvertToRGB32(matrix="Rec601", interlaced=interlace) : \
         hist

  input.Height() > hist.Height() ? \ 
           StackHorizontal(input, hist.AddBorders(0,0,0,input.Height() - hist.Height())) : \
           StackHorizontal(input.AddBorders(0,0,0,hist.Height() - input.Height()), hist)
}

function HistogramRGBLevels( clip input, bool "range", float "factor" )
{
    return HistogramRGBLevelsType( input, input.ConvertToRGB(), $800000, $008000, $000080, range, factor )
}

function HistogramCMYLevels( clip input, bool "range", float "factor" )
{
    return HistogramRGBLevelsType( input, input.ConvertToRGB().Invert(), $008080, $800080, $808000, range, factor )
}

function HistogramRGBParade( clip input, float "width" )
{
    return HistogramRGBParadeType( input, input.ConvertToRGB(), $800000, $008000, $000080, width )
}

#---

# Generic levels form, not very useful as a standalone function
function HistogramRGBLevelsType( clip input, clip rgb, int color1, int color2, int color3, bool "range", float "factor" )
{
    range = default(range,true)
    ChannelHeight = 64
    Gap = 8  # divisible by 4

    r = rgb.ShowRed  ("YV12").HistogramChannel("Levels", color1, "add", ChannelHeight, range, factor)
    g = rgb.ShowGreen("YV12").HistogramChannel("Levels", color2, "add", ChannelHeight, range, factor)
    b = rgb.ShowBlue ("YV12").HistogramChannel("Levels", color3, "add", ChannelHeight, range, factor)
    gap = BlankClip(r, height=Gap)
    hist = StackVertical(r,gap,g,gap,b).ConvertToMatch(input)
    return input.Height() > hist.Height() ? \ 
           StackHorizontal(input, hist.AddBorders(0,0,0,input.Height() - hist.Height())) : \
           StackHorizontal(input.AddBorders(0,0,0,hist.Height() - input.Height()), hist)
}

# Generic parade form, not very useful as a standalone function
function HistogramRGBParadeType( clip input, clip rgb, int color1, int color2, int color3, float "width" )
{
    width = default(width,0.25)
    Gap = 8  # divisible by 4

    rgb = rgb.PointResize( m4(rgb.Width()*width), m4(rgb.Height()) ).TurnRight()
    r = rgb.ShowRed  ("YV12").HistogramChannel("Classic", color1, "chroma", 0, true)
    g = rgb.ShowGreen("YV12").HistogramChannel("Classic", color2, "chroma", 0, true)
    b = rgb.ShowBlue ("YV12").HistogramChannel("Classic", color3, "chroma", 0, true)
    gap = BlankClip(r, height=Gap)
    hist = StackVertical(r,gap,g,gap,b).TurnLeft().ConvertToMatch(input)
    return input.Height() > hist.Height() ? \ 
           StackHorizontal(input, hist.AddBorders(0,0,0,input.Height() - hist.Height())) : \
           StackHorizontal(input.AddBorders(0,0,0,hist.Height() - input.Height()), hist)
}

# Used by functions above, not a standalone function
function HistogramChannel( clip input, string type, int color, string colorMode, int height, bool range, float "factor" )
{
    input.Histogram(type, factor).Crop(input.Width(),0,0,height).Greyscale()
    range ? last : Levels(128,1.0,255,0,255,false)
    return Overlay(BlankClip(color=color), mode=colorMode)
}

# Returns "input" converted to same colorspace as "ref"
function ConvertToMatch( clip input, clip ref )
{
    return ref.IsYV12()  ? input.IsYV12()  ? input : input.ConvertToYV12()  : \
           ref.IsRGB32() ? input.IsRGB32() ? input : input.ConvertToRGB32() : \
           ref.IsRGB24() ? input.IsRGB24() ? input : input.ConvertToRGB24() : \
           ref.IsYUY2()  ? input.IsYUY2()  ? input : input.ConvertToYUY2()  : \
           ref.IsYV16()  ? input.IsYV16()  ? input : input.ConvertToYV16()  : \
           ref.IsYV24()  ? input.IsYV24()  ? input : input.ConvertToYV24()  : \
           ref.IsY8()    ? input.IsY8()    ? input : input.ConvertToY8()    : \
           ref.IsYV411() ? input.IsYV411() ? input : input.ConvertToYV411() : \
           input
}

# Convert value to multiple of 4 which is  >= 16
function m4( float x ) { return (x < 16 ? 16 : int(round(x / 4.0) * 4)) }