Function TweenFlashFrames(clip c, float "FlashThresh", bool "Show") {
# TweenFlashFrames() by StainlessS
# PROGRESSIVE.
# Replace single isolated bad frames eg Black or White with a frame tweened from those either side using MvTools, and RT_Stats.
# Will Likely fix a single Bright/Dark Flash frame after scene change where will be replaced with a blend of before and after frames.
#    This due to NoPan failure, ie frames before and after flash are likely to be more similar (even though dif scenes) than to flash frame.
#    There has been no attempt to fix this fortunate failure.
# FlashThresh Default 1.15 (white flash detect), is a threshold of AveLuma_Ratio, Flash_Frame_AveLuma / Adjacent_Frame_AveLuma.
#   Values above 1.0 detect WHITE/Flash frames, Below 1.0 detect BLACK/Flash frames (suggest for Black eg 1.0/1.15 = 0.87)
#   When FlashThresh above 1.0 (detecting WHITE flash) : 
#       If AveLuma_Ratio > FlashThresh, for both adjacent frames then is possible white flash
#   When FlashThresh below 1.0 (detecting BLACK flash) : 
#       If AveLuma_Ratio < FlashThresh, for both adjacent frames then is possible black flash
#   When FlashThresh < 0.0, will simultaneously fix both White and Black Flash frames, eg -1.15 will use equivalent to 1.15 for white
#       and 1.0/1.15 for Black.
#   1.0 or -1.0 exactly, Throws an Error.
# Show: Puts indicator on fixed frames.
    c
    FlashThresh = Float(Default(FlashThresh,1.15))                  # Default detects White flash
    Show=Default(Show,False)
    Assert(FlashThresh != 1.0 && FlashThresh != -1.0,"TweenFlashFrames: FlashThresh Cannot be 1.0 Nor -1.0")
    (FlashThresh < 0.0 && FlashThresh > -1.0) ? 1.0 / FlashThresh : FlashThresh
    CondS="""
        ave_p   = Max(RT_AverageLuma(delta=-1), 0.01)               # Avoid Division By Zero
        ave     = RT_AverageLuma()
        ave_n   = Max(RT_AverageLuma(delta=1), 0.01)
        rat_p   = ave / ave_p                                       # AveLuma_Ratio for Prev
        rat_n   = ave / ave_n                                       # AveLuma_Ratio for Next
        Flash   =(FlashThresh<0.0)
            \ ? ((rat_p > -FlashThresh && rat_n > -FlashThresh) || (rat_p < -1.0/FlashThresh && rat_n < -1.0/FlashThresh))
            \ : (FlashThresh>1.0)
            \ ? (rat_p > FlashThresh && rat_n > FlashThresh)
            \ : (rat_p < FlashThresh && rat_n < FlashThresh)
        dif_p=RT_YDifference(delta=-1)                              # Diff Prev <-> Curr
        dif_n=RT_YDifference(delta=1)                               # Diff Curr <-> Next
        dif_pn=RT_YDifference(current_frame-1,delta=2)              # Diff Prev <-> Next (either side of current)
        NoPan = (dif_pn < dif_p && dif_pn < dif_n)                  # (Prev<->Next < Prev<->Curr) AND (Prev<->Next < Curr<->Next) 
        clpn = (Flash && NoPan) ? 1 : 0
#       RT_DebugF("%d ] Rat_p=%.2f Rat_n=%.2f Flash=%s Dif_pn=%.2f Dif_p=%.2f Dif_n=%.2f NoPan=%s Tween=%s",
#               \ current_frame,rat_p,rat_n,(Flash)?"T":"F",Dif_pn,Dif_p,Dif_n,(NoPan)?"T":"F",(clpn==1)?"Y":"N")
        clpn
    """
    PrevC=DeleteFrame(FrameCount-1).DuplicateFrame(0)               # Make clip where prev frames are aligned with curr frames (same length)
    super = PrevC.MSuper()
    backward_vectors = MAnalyse(super, isb = true,truemotion=true, delta=2)
    forward_vectors  = MAnalyse(super, isb = false,truemotion=true, delta=2)
    TweenC = PrevC.MFlowInter(super, backward_vectors, forward_vectors, time=50, ml=70)     # Tweened clip
    TweenC = (Show) ? TweenC.Subtitle("FRAME FIXED",size=30,text_color=$0000FF,align=5) : TweenC
    CondS2=RT_StrReplace(CondS,"FlashThresh",String(FlashThresh))   # Import explicit FlashThresh into condition string
    ConditionalSelect(Last,CondS2,Last,TweenC)                      # Fix bad frames
    return Last
}