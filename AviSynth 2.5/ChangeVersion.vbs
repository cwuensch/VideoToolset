' Wechselt die zu verwendende AviSynth-Version
'
' (C) 2007 by Christian Wünsch
'

Option Explicit

Dim Versions, DLLs
Versions = Array("2.5.8.1", "2.5.6.0", "2.6.0.6", "2.6.0.5")
DLLs = Array("AviSynth 2.58.dll", "AviSynth 2.56.dll", "AviSynth 2.6.dll", "AviSynth 2.6MT.dll")

Dim WshShell, fso
Dim SystemDir, CurrentVer, NewVer, OldDLL, NewDLL, i

Set WshShell = WScript.CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")


SystemDir = WScript.Path + "\..\SysWoW64"
CurrentVer = fso.GetFileVersion(SystemDir + "\AviSynth.dll")

For i=0 To UBound(Versions, 1)
  If Versions(i) = CurrentVer Then
    OldDLL = DLLs(i)
    If i < UBound(Versions, 1) Then
      NewDLL = DLLs(i+1)
      NewVer = Versions(i+1)
    End If
    Exit For
  End If
Next
If NewVer = "" Then
  NewDLL = DLLs(0)
  NewVer = Versions(0)
  If OldDLL = "" Then OldDLL = "AviSynth.bak"
End If

If MsgBox("Aktuelle AviSynth-Version: " + CurrentVer + vbCrLf + vbCrLf + "Ersetzen durch Version " + NewVer + "?", vbYesNo + vbQuestion, "AviSynth Version wechseln") = vbYes Then
  fso.MoveFile SystemDir + "\AviSynth.dll", SystemDir + "\" + OldDLL
  fso.MoveFile SystemDir + "\" + NewDLL, SystemDir + "\AviSynth.dll"
End If
