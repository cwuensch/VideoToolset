# ReplaceFrames ersetzt einzelne defekte Frames von Source
# durch die entsprechenden Frames von Interpolated
#
# Parameter:
# ==========
# source:          Source-Clip mit zu ersetzenden Frames
# interpolated:    Clip mit den neuen Frames
# frame (int):     Nr des zu ersetzenden Frame
# frames (string): Nummern der zu ersetzenden Frames, durch Komma getrennt, keine Leerzeichen
#


function ReplaceFrames (clip source, clip interpolated, string frames) {
  pos = FindStr(frames, ",")
  
  cur = (pos==0) ? frames : LeftStr(frames, pos-1)
  cur = Int(Value(cur))
  frames = RightStr(frames, StrLen(frames)-pos)

  new = ReplaceFrames(source, interpolated, cur)

  return (pos==0) ? new : ReplaceFrames(new, interpolated, frames)
}

function ReplaceFrames (clip source, clip interpolated, int frame) {
  audio=source
  video=source.Trim(0, frame-1) ++ interpolated.Trim(frame, frame) ++ source.Trim(frame+1, 0)
  return AudioDub(video, audio)
}
