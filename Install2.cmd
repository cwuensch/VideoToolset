@echo off
mkdir VideoToolset

echo Checkout Git repository (sparse)
git clone --sparse --depth 1 --filter=blob:none --no-checkout https://github.com/cwuensch/VideoToolset.git
cd VideoToolset
git sparse-checkout set "AviSynth 2.5"
git checkout
cd ..


echo Install VC Runtime
echo - Downloading...
rem powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Install/VCRuntime/Visual C++ 2005 Redistribution Pack.exe', 'VideoToolset\Visual C++ 2005 Redistribution Pack.exe') "
rem powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Install/VCRuntime/vcredist2008_x86.exe', 'VideoToolset\vcredist2008_x86.exe') "
powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Install/VCRuntime/vcredist2010_x86.exe', 'VideoToolset\vcredist2010_x86.exe') "
powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Install/VCRuntime/vcredist2012_x86.exe', 'VideoToolset\vcredist2012_x86.exe') "
powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Install/VCRuntime/vcredist2013_x86.exe', 'VideoToolset\vcredist2013_x86.exe') "
powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Install/VCRuntime/vcredist2015-2019_x86.exe', 'VideoToolset\vcredist2015-2019_x86.exe') "
rem powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Install/VCRuntime/VC_redist2022_x86.exe', 'VideoToolset\VC_redist2022_x86.exe') "
rem powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Install/VCRuntime/vcredist2012_x64.exe', 'VideoToolset\vcredist2012_x64.exe') "
rem powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Install/VCRuntime/vcredist2013_x64.exe', 'VideoToolset\vcredist2013_x64.exe') "
rem powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Install/VCRuntime/vcredist2015-2019_x64.exe', 'VideoToolset\vcredist2015-2019_x64.exe') "
rem powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Install/VCRuntime/VC_redist2022_x64.exe', 'VideoToolset\VC_redist2022_x64.exe') "
echo - Installing...
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
echo - Deleting... \
del /q "VideoToolset\Visual C++ 2005 Redistribution Pack.exe"
del /q "VideoToolset\vcredist*.exe"
del /q "VideoToolset\VC_redist2022*.exe"


echo Install Cedocida DV-Codec (?)
echo - Downloading...
powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Codecs/Cedocida 0.2.3 (x64)/cedocida.dll', '%windir%\SysWOW64\cedocida.dll') "
powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Codecs/Cedocida 0.2.3 (x64)/x64/cedocida.dll', '%windir%\system32\cedocida.dll') "
echo - Register...
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\drivers.desc" /v cedocida.dll /d "Cedocida DV Codec" /f
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Drivers32" /v vidc.dvsd /d "cedocida.dll" /f
reg add "HKLM\Software\Wow6432Node\Microsoft\Windows NT\CurrentVersion\drivers.desc" /v cedocida.dll /d "Cedocida DV Codec" /f
reg add "HKLM\Software\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Drivers32" /v vidc.dvsd /d "cedocida.dll" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\MediaResources\icm\vidc.dvsd" /v Driver /d "cedocida.dll" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\MediaResources\icm\vidc.dvsd" /v Description /d "Cedocida DV Codec" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\MediaResources\icm\vidc.dvsd" /v FriendlyName /d "Cedocida DV Codec" /f

echo Install HuffYUV 2.1.1 CCE-Patch
echo - Downloading...
powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Codecs/HuffYUV/HuffYUV 2.1.1/huffyuv (CCEsp-Patch).dll', '%windir%\SysWOW64\huffyuv.dll') "
powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Codecs/HuffYUV/HuffYUV64.zip', 'VideoToolset\HuffYUV64.zip') "
echo Extracting...
powershell -command " Expand-Archive -Path 'VideoToolset\HuffYUV64.zip' -DestinationPath 'VideoToolset\HuffYUV\' "
echo - Copying...
copy /y "VideoToolset\HuffYUV\huffyuv.dll" "%windir%\system32\"
echo - Register...
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\drivers.desc" /v huffyuv.dll /d "Huffyuv lossless codec [HFYU]" /f
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Drivers32" /v VIDC.HFYU /d "huffyuv.dll" /f
reg add "HKLM\Software\Wow6432Node\Microsoft\Windows NT\CurrentVersion\drivers.desc" /v huffyuv.dll /d "Huffyuv lossless codec [HFYU]" /f
reg add "HKLM\Software\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Drivers32" /v VIDC.HFYU /d "huffyuv.dll" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\MediaResources\icm\vidc.dvsd" /v Driver /d "huffyuv.dll" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\MediaResources\icm\vidc.dvsd" /v Description /d "Huffyuv lossless codec [HFYU]" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\MediaResources\icm\vidc.dvsd" /v FriendlyName /d "Huffyuv lossless codec [HFYU]" /f
echo - Deleting...
rmdir /s /q "VideoToolset\HuffYUV"
del "VideoToolset\HuffYUV64.zip"

echo Install Lagarith 1.3.14 (64bit)
echo - Downloading...
powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Codecs/Lagarith/Lagarith 1.3.14 (64-bit).zip', 'VideoToolset\Lagarith.zip') "
echo - Extracting...
powershell -command " Expand-Archive -Path 'VideoToolset\Lagarith.zip' -DestinationPath 'VideoToolset\Lagarith\' "
echo - Copying...
copy /y "VideoToolset\Lagarith\lagarith\lagarith32\lagarith.dll" "%windir%\SysWOW64\"
copy /y "VideoToolset\Lagarith\lagarith\lagarith64\lagarith.dll" "%windir%\system32\"
echo - Register...
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\drivers.desc" /v lagarith.dll /d "Lagarith lossless codec [LAGS]" /f
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Drivers32" /v VIDC.LAGS /d "lagarith.dll" /f
reg add "HKLM\Software\Wow6432Node\Microsoft\Windows NT\CurrentVersion\drivers.desc" /v lagarith.dll /d "Lagarith lossless codec [LAGS]" /f
reg add "HKLM\Software\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Drivers32" /v VIDC.LAGS /d "lagarith.dll" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\MediaResources\icm\vidc.dvsd" /v Driver /d "lagarith.dll" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\MediaResources\icm\vidc.dvsd" /v Description /d "Lagarith lossless codec [LAGS]" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\MediaResources\icm\vidc.dvsd" /v FriendlyName /d "Lagarith lossless codec [LAGS]" /f
echo - Deleting...
rmdir /s /q "VideoToolset\Lagarith"
del "VideoToolset\Lagarith.zip"

echo Install UTVideo 13.3.1 Codec
echo - Extracting...
powershell -command " Expand-Archive -Path 'VideoToolset\Codecs\UTVideo\utvideo-13.3.1.zip' -DestinationPath 'VideoToolset\UTVideo\' "
echo - Installing...
copy /y "VideoToolset\UTVideo\x64\utv_*.dll" "%windir%\system32\"
copy /y "VideoToolset\utv_*.dll" "%windir%\SysWOW64\"
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
rmdir /s /q "VideoToolset\UTVideo"
del "VideoToolset\UTVideo.zip"


echo Install AviSynth 2.60
echo - Downloading...
powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Install/AviSynth/AviSynth 2.60 (Single Thread).exe', 'VideoToolset\AviSynth.exe') "
echo - Installing...
start /w VideoToolset\AviSynth.exe /S /D="C:\Program Files\AviSynth 2.5"
echo - Link to Programme...
mklink /d "C:\Programme" "C:\Program Files"
echo - Deleting...
del "VideoToolset\AviSynth.exe"

echo Copy AviSynth folder from GitHub
echo - Copying...
xcopy /e /y "VideoToolset\AviSynth 2.5" "C:\Program Files\"
echo - Deleting...
rmdir /s /q "VideoToolset\AviSynth 2.5"

echo Copy FFT3 Dlls
echo - Downloading...
powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Windows/System32 (64bit)/fftw3.dll', '%windir%\System32\') "
powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Windows/SysWOW64/fftw3.dll', '%windir%\SysWOW64\') "
powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Windows/SysWOW64/libfftw3-3.dll', '%windir%\SysWOW64\') "
powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Windows/SysWOW64/libfftw3f-3.dll', '%windir%\SysWOW64\') "
powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Windows/SysWOW64/libfftw3l-3.dll', '%windir%\SysWOW64\') "


echo Copy VirtualDub 1.10.4
echo - Downloading...
powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Install/VirtualDub/VirtualDub 1.10.4.zip', 'VideoToolset\VirtualDub.zip') "
powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Install/VirtualDub/plugins32.zip', 'VideoToolset\plugins32.zip') "
powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Install/VirtualDub/VirtualDub.reg', 'VideoToolset\VirtualDub.reg') "
echo - Extracting...
powershell -command " Expand-Archive -Path 'VideoToolset\VirtualDub.zip' -DestinationPath 'C:\Program Files (x86)\VirtualDub\' "
powershell -command " Expand-Archive -Path 'VideoToolset\plugins32.zip' -DestinationPath 'C:\Program Files (x86)\VirtualDub\plugins32\' "
echo - Link to Programme...
mklink /d "C:\Programme\VirtualDub" "C:\Program Files (x86)\VirtualDub"
echo - Registry import...
reg import "VideoToolset\VirtualDub.reg"
echo - Deleting...
del "VideoToolset\VirtualDub.zip"
del "VideoToolset\VirtualDub.reg"
del "VideoToolset\plugins32.zip"


echo Downloading...
powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Recompress_UTVideo.vcf', 'VideoToolset\') "
powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Recompress_UTVideo2.vcf', 'VideoToolset\') "
powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Demo.avs', 'VideoToolset\') "
rem powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Demo.avi', 'VideoToolset\') "

echo Set path (unnötig)
setx PATH "C:\Program Files (x86)\VirtualDub;%PATH%"
set PATH="C:\Program Files (x86)\VirtualDub;%PATH%"


echo Connect network storage
rem net use S: "\\u000000.your-storagebox.de\backup" /user:u000000 PASSWORD
net use I: "\\u000000-sub2.your-storagebox.de\u000000-sub2" /user:u000000-sub2 PASSWORD
net use O: "\\u000000-sub3.your-storagebox.de\u000000-sub3" /user:u000000-sub3 PASSWORD

echo Start VirtualDub reencoding (Demo)
cd VideoToolset
"C:\Program Files (x86)\VirtualDub\vdub.exe" "Demo.avs" /s "Recompress_UTVideo.vcf" /x
dir

echo Start VirtualDub reencoding (real)
"C:\Program Files (x86)\VirtualDub\vdub.exe" "I:\Schildkröten-6\Kleine Geschichten von wilden Tieren - Die Meeresschildkröte.avs" /i "VideoToolset\Recompress_UTVideo2.vcf" "O:\\Video_out1.avi" /x
dir O:\
