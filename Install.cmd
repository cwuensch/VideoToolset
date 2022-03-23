@echo off

echo Checkout repository
rem git clone https://github.com/cwuensch/VideoToolset.git
echo - Downloading ZIP...
powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/archive/refs/heads/master.zip', 'VideoToolset.zip') "
echo - Extracting...
powershell -command " Expand-Archive -Path 'VideoToolset.zip' -DestinationPath 'VideoToolset\' "
echo - Deleting...
echo del VideoToolset.zip


echo Install VC Runtime
rem start /w "" "VideoToolset\Install\VCRuntime\Visual C++ 2005 Redistribution Pack" /q
rem start /w VideoToolset\Install\VCRuntime\vcredist2008_x86.exe /q
start /w VideoToolset\Install\VCRuntime\vcredist2010_x86.exe /q
start /w VideoToolset\Install\VCRuntime\vcredist2012_x86.exe /install /quiet
start /w VideoToolset\Install\VCRuntime\vcredist2013_x86.exe /install /quiet
start /w VideoToolset\Install\VCRuntime\vcredist2015-2019_x86.exe /install /quiet
rem start /w VideoToolset\Install\VCRuntime\VC_redist2022_x86.exe /install /quiet
rem start /w VideoToolset\Install\VCRuntime\vcredist2012_x64.exe /install /quiet
rem #start /w VideoToolset\Install\VCRuntime\vcredist2013_x64.exe /install /quiet
rem start /w VideoToolset\Install\VCRuntime\vcredist2015-2019_x64.exe /install /quiet
rem start /w VideoToolset\Install\VCRuntime\VC_redist2022_x64.exe /install /quiet


echo Install Cedocida DV-Codec (?)
echo - Copying...
copy /y "VideoToolset\Codecs\Cedocida 0.2.3 (x64)\cedocida.dll" "%windir%\SysWOW64\"
copy /y "VideoToolset\Codecs\Cedocida 0.2.3 (x64)\x64\cedocida.dll" "%windir%\system32\"
echo - Register...
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\drivers.desc" /v cedocida.dll /d "Cedocida DV Codec" /f
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Drivers32" /v vidc.dvsd /d "cedocida.dll" /f
reg add "HKLM\Software\Wow6432Node\Microsoft\Windows NT\CurrentVersion\drivers.desc" /v cedocida.dll /d "Cedocida DV Codec" /f
reg add "HKLM\Software\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Drivers32" /v vidc.dvsd /d "cedocida.dll" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\MediaResources\icm\vidc.dvsd" /v Driver /d "cedocida.dll" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\MediaResources\icm\vidc.dvsd" /v Description /d "Cedocida DV Codec" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\MediaResources\icm\vidc.dvsd" /v FriendlyName /d "Cedocida DV Codec" /f

echo Install HuffYUV 2.1.1 CCE-Patch
echo - Extracting...
powershell -command " Expand-Archive -Path 'VideoToolset\Codecs\HuffYUV\HuffYUV64.zip' -DestinationPath 'HuffYUV\' "
echo - Copying...
copy /y "VideoToolset\Codecs\HuffYUV\HuffYUV 2.1.1\huffyuv (CCEsp-Patch).dll" "%windir%\SysWOW64\huffyuv.dll"
copy /y "HuffYUV\huffyuv.dll" "%windir%\system32\"
echo - Register...
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\drivers.desc" /v huffyuv.dll /d "Huffyuv lossless codec [HFYU]" /f
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Drivers32" /v VIDC.HFYU /d "huffyuv.dll" /f
reg add "HKLM\Software\Wow6432Node\Microsoft\Windows NT\CurrentVersion\drivers.desc" /v huffyuv.dll /d "Huffyuv lossless codec [HFYU]" /f
reg add "HKLM\Software\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Drivers32" /v VIDC.HFYU /d "huffyuv.dll" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\MediaResources\icm\vidc.dvsd" /v Driver /d "huffyuv.dll" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\MediaResources\icm\vidc.dvsd" /v Description /d "Huffyuv lossless codec [HFYU]" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\MediaResources\icm\vidc.dvsd" /v FriendlyName /d "Huffyuv lossless codec [HFYU]" /f
echo - Deleting...
rmdir /s /q "HuffYUV"

echo Install Lagarith 1.3.14 (64bit)
echo - Extracting...
powershell -command " Expand-Archive -Path 'VideoToolset\Codecs\Lagarith\Lagarith 1.3.14 (64-bit).zip' -DestinationPath 'Lagarith\' "
echo - Copying...
copy /y "Lagarith\lagarith\lagarith32\lagarith.dll" "%windir%\SysWOW64\"
copy /y "Lagarith\lagarith\lagarith64\lagarith.dll" "%windir%\system32\"
echo - Register...
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\drivers.desc" /v lagarith.dll /d "Lagarith lossless codec [LAGS]" /f
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Drivers32" /v VIDC.LAGS /d "lagarith.dll" /f
reg add "HKLM\Software\Wow6432Node\Microsoft\Windows NT\CurrentVersion\drivers.desc" /v lagarith.dll /d "Lagarith lossless codec [LAGS]" /f
reg add "HKLM\Software\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Drivers32" /v VIDC.LAGS /d "lagarith.dll" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\MediaResources\icm\vidc.dvsd" /v Driver /d "lagarith.dll" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\MediaResources\icm\vidc.dvsd" /v Description /d "Lagarith lossless codec [LAGS]" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\MediaResources\icm\vidc.dvsd" /v FriendlyName /d "Lagarith lossless codec [LAGS]" /f
echo - Deleting...
rmdir /s /q "Lagarith"

echo Install UTVideo 13.3.1 Codec
echo - Extracting...
powershell -command " Expand-Archive -Path 'VideoToolset\Codecs\UTVideo\utvideo-13.3.1.zip' -DestinationPath 'UTVideo\' "
echo - Installing...
copy /y "UTVideo\x64\utv_*.dll" "%windir%\system32\"
copy /y "UTVideo\utv_*.dll" "%windir%\SysWOW64\"
start /w %windir%\SysWOW64\regsvr32.exe /s %windir%\system32\utv_dmo.dll
start /w %windir%\SysWOW64\regsvr32.exe /s %windir%\system32\utv_mft.dll
start /w %windir%\system32\regsvr32.exe /s %windir%\system32\utv_dmo.dll
start /w %windir%\system32\regsvr32.exe /s %windir%\system32\utv_mft.dll
echo - Register...
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\drivers.desc" /v utv_vcm.dll /d "UTVideo VfW Codec" /f
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Drivers32" /v VIDC.ULRA /d "%windir%\system32\utv_vcm.dll" /f
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Drivers32" /v VIDC.ULRG /d "%windir%\system32\utv_vcm.dll" /f
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Drivers32" /v VIDC.ULY4 /d "%windir%\system32\utv_vcm.dll" /f
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Drivers32" /v VIDC.ULY2 /d "%windir%\system32\utv_vcm.dll" /f
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Drivers32" /v VIDC.ULY0 /d "%windir%\system32\utv_vcm.dll" /f
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Drivers32" /v VIDC.ULH4 /d "%windir%\system32\utv_vcm.dll" /f
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Drivers32" /v VIDC.ULH2 /d "%windir%\system32\utv_vcm.dll" /f
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Drivers32" /v VIDC.ULH0 /d "%windir%\system32\utv_vcm.dll" /f
reg add "HKLM\Software\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Drivers32" /v VIDC.ULRA /d "%windir%\system32\utv_vcm.dll" /f
reg add "HKLM\Software\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Drivers32" /v VIDC.ULRG /d "%windir%\system32\utv_vcm.dll" /f
reg add "HKLM\Software\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Drivers32" /v VIDC.ULY4 /d "%windir%\system32\utv_vcm.dll" /f
reg add "HKLM\Software\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Drivers32" /v VIDC.ULY2 /d "%windir%\system32\utv_vcm.dll" /f
reg add "HKLM\Software\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Drivers32" /v VIDC.ULY0 /d "%windir%\system32\utv_vcm.dll" /f
reg add "HKLM\Software\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Drivers32" /v VIDC.ULH4 /d "%windir%\system32\utv_vcm.dll" /f
reg add "HKLM\Software\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Drivers32" /v VIDC.ULH2 /d "%windir%\system32\utv_vcm.dll" /f
reg add "HKLM\Software\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Drivers32" /v VIDC.ULH0 /d "%windir%\system32\utv_vcm.dll" /f
echo - Deleting...
rmdir /s /q "UTVideo"


echo Install AviSynth 2.60
echo - Installing...
start /w "" "VideoToolset\Install\AviSynth\AviSynth 2.60 (Single Thread).exe" /S /D="C:\Program Files\AviSynth 2.5"

echo Copy AviSynth folder from GitHub
xcopy /e /y "VideoToolset\AviSynth 2.5" "C:\Program Files\"
mklink /d "C:\Programme" "C:\Program Files"

echo Copy FFT3 Dlls
copy /y "VideoToolset\Windows\System32 (64bit)\fftw3.dll" "%windir%\System32\"
copy /y "VideoToolset\Windows\SysWOW64\fftw3.dll" "%windir%\SysWOW64\"
copy /y "VideoToolset\Windows\SysWOW64\libfftw3*.dll" "%windir%\SysWOW64\"

echo Copy VirtualDub 1.10.4
echo - Extracting...
powershell -command " Expand-Archive -Path 'VideoToolset\Install\VirtualDub\VirtualDub 1.10.4.zip' -DestinationPath 'C:\Program Files (x86)\VirtualDub\' "
powershell -command " Expand-Archive -Path 'VideoToolset\Install\VirtualDub\plugins32.zip' -DestinationPath 'C:\Program Files (x86)\VirtualDub\plugins32\' "
mklink /d "C:\Programme\VirtualDub" "C:\Program Files (x86)\VirtualDub"
echo - Registry import...
reg import "VideoToolset\Install\VirtualDub\VirtualDub.reg"

echo Set path (unnötig)
setx PATH "C:\Program Files (x86)\VirtualDub;%PATH%"
set PATH="C:\Program Files (x86)\VirtualDub;%PATH%"


echo Connect network storage
rem net use S: "\\u000000.your-storagebox.de\backup" /user:u000000 PASSWORD
net use I: "\\u000000-sub2.your-storagebox.de\u000000-sub2" /user:u000000-sub2 PASSWORD
net use O: "\\u000000-sub3.your-storagebox.de\u000000-sub3" /user:u000000-sub3 PASSWORD

echo Start VirtualDub reencoding (Demo)
cd VideoToolset
"C:\Program Files (x86)\VirtualDub\vdub.exe" "VideoToolset\Demo.avs" /s "VideoToolset\Recompress_UTVideo.vcf" /x
dir

echo Start VirtualDub reencoding (real)
"C:\Program Files (x86)\VirtualDub\vdub.exe" "I:\Schildkröten-6\Kleine Geschichten von wilden Tieren - Die Meeresschildkröte.avs" /i "VideoToolset\Recompress_UTVideo2.vcf" "O:\\Video_out1.avi" /x
dir O:\
