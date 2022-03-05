# Korrigiert progressive Szenen, die in falscher Field-Zusammensetzung aufgezeichnet sind
# (Löscht das erste und letzte Field, und vertauscht dazwischen die Darstellungs-Reihenfolge der Fields.
#  Das zusammengesetzte Frame ist somit wieder korrekt (Top Field ist oben), und die Reihenfolge ist bei progressive Aufnahmen egal)
function FixInterlace(clip source, int fFirst, int fLast)
{
  SeparateFields(source)
  DeleteFrame(fLast, fFirst)
  AssumeFieldBased().Weave()

  frFirst=min(fFirst,fLast)/2
  frLast=max(fFirst,fLast)/2-1

  a=Trim(0, frFirst - 1)
  b=Trim(frFirst, frLast).SeparateFields().ComplementParity().Weave().AssumeFrameBased()
  c=Trim(frLast + 1, 0)
  return (a+b+c)
}

# Korrigiert Frames an Szenenübergängen, bei denen Halbbilder verschiedener Szenen gemischt wurden
# (Verdoppelt das obere und das untere Field, um reine Frames zu erreichen.)
function FixMixedFrame(clip source, int nrFrame)
{
  AssumeTFF(source).SeparateFields()
  DuplicateFrame(nrFrame*2 + 1)
  DuplicateFrame(nrFrame*2)
  Weave().AssumeFrameBased()
  return last
}
