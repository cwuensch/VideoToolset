function ColorMill(clip c,  int "mpMiddlePoint", int "mpBooster", int "mpBaseShift",  int "HSVHue", int "HSVSat", int "HSVValue",  \
                   int "GammaRed", int "GammaGreen", int "GammaBlue",  int "LevelsDark", int "LevelsMiddle", int "LevelsLight",  \
                   int "DarkRed", int "DarkGreen", int "DarkBlue",  int "MidRed", int "MidGreen", int "MidBlue",  int "LightRed", int "LightGreen", int "LightBlue",  \
                   int "SatDark", int "SatMiddle", int "SatLight",  int "SharpPreproc", int "SharpDamH", int "SharpDamL", int "SharpPostproc",  \
                   bool "GammaPreproc", bool "KeepBrightness", bool "BadSource")
{
    mpMiddlePoint = Default(mpMiddlePoint, 0)
    mpBooster     = Default(mpBooster, 0)
    mpBaseShift   = Default(mpBaseShift, 0)
    
    HSVHue        = Default(HSVHue, 0)
    HSVSat        = Default(HSVSat, 0)
    HSVValue      = Default(HSVValue, 0)
    
    GammaRed      = Default(GammaRed, 0)
    GammaGreen    = Default(GammaGreen, 0)
    GammaBlue     = Default(GammaBlue, 0)

    LevelsDark    = Default(LevelsDark, 0)
    LevelsMiddle  = Default(LevelsMiddle, 0)
    LevelsLight   = Default(LevelsLight, 0)
    
    DarkRed       = Default(DarkRed, 0)
    DarkGreen     = Default(DarkGreen, 0)
    DarkBlue      = Default(DarkBlue, 0)
    MidRed        = Default(MidRed, 0)
    MidGreen      = Default(MidGreen, 0)
    MidBlue       = Default(MidBlue, 0)
    LightRed      = Default(LightRed, 0)
    LightGreen    = Default(LightGreen, 0)
    LightBlue     = Default(LightBlue, 0)
    
    SatDark       = Default(SatDark, 0)
    SatMiddle     = Default(SatMiddle, 0)
    SatLight      = Default(SatLight, 0)

    SharpPreproc  = Default(SharpPreproc, 0)
    SharpDamH     = Default(SharpDamH, 0)
    SharpDamL     = Default(SharpDamL, 2)
    SharpPostproc = Default(SharpPostproc, 0)
    
    GammaPreproc  = Default(GammaPreproc, true)
    KeepBrightness= Default(KeepBrightness, true)
    BadSource     = Default(BadSource, false)

    LoadVirtualdubPlugin("C:\Programme\VirtualDub\plugins32\ColorMill.vdf", "ColorMill", 0)

    ColorMill(c,  \
        256*(DarkGreen+100) + (DarkRed+100),  \
        256*(MidRed+100) + (DarkBlue+100),  \
        256*(MidBlue+100) + (MidGreen+100),  \
        256*(LightGreen+100) + (LightRed+100),  \
        256*(LevelsDark+100) + (LightBlue+100),  \
        256*(LevelsMiddle+100) + (LevelsLight+100),  \
        256*(SatMiddle+100) + (SatDark+100),  \
        256*(GammaRed+100) + (SatLight+100),  \
        256*(GammaBlue+100) + (GammaGreen+100),  \
        256*(HSVSat+100) + (HSVHue+100),  \
        256*(mpMiddlePoint+100) + (HSVValue+100),  \
        256*(mpBaseShift+100) + (mpBooster+100),  \
        256*(SharpDamH+100) + (SharpPreproc+100),  \
        256*(SharpDamL*2) + (SharpPostproc+100),  \
        (GammaPreproc ? 4 : 0) + (BadSource ? 2 : 0) + (KeepBrightness ? 1 : 0))
}