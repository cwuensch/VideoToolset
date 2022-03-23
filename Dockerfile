FROM mcr.microsoft.com/windows:1809-amd64

# Install VC-Runtime 2013 und mehr (?)
RUN echo Downloading... \
 && powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Install/VCRuntime/Visual C++ 2005 Redistribution Pack.exe', 'C:\Visual C++ 2005 Redistribution Pack.exe') " \
 && powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Install/VCRuntime/vcredist2008_x86.exe', 'C:\vcredist2008_x86.exe') " \
 && powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Install/VCRuntime/vcredist2010_x86.exe', 'C:\vcredist2010_x86.exe') " \
 && powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Install/VCRuntime/vcredist2012_x86.exe', 'C:\vcredist2012_x86.exe') " \
 && powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Install/VCRuntime/vcredist2013_x86.exe', 'C:\vcredist2013_x86.exe') " \
 && powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Install/VCRuntime/vcredist2015-2019_x86.exe', 'C:\vcredist2015-2019_x86.exe') " \
 && powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Install/VCRuntime/VC_redist2022_x86.exe', 'C:\VC_redist2022_x86.exe') " \
 && powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Install/VCRuntime/vcredist2012_x64.exe', 'C:\vcredist2012_x64.exe') " \
 && powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Install/VCRuntime/vcredist2013_x64.exe', 'C:\vcredist2013_x64.exe') " \
 && powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Install/VCRuntime/vcredist2015-2019_x64.exe', 'C:\vcredist2015-2019_x64.exe') " \
 && powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Install/VCRuntime/VC_redist2022_x64.exe', 'C:\VC_redist2022_x64.exe') " \
 && echo Installing... \
 && start /w "" "C:\Visual C++ 2005 Redistribution Pack.exe" /Q \
 && start /w C:\vcredist2008_x86.exe /q \
 && start /w C:\vcredist2010_x86.exe /q \
 && start /w C:\vcredist2012_x86.exe /install /quiet \
 && start /w C:\vcredist2013_x86.exe /install /quiet \
 && start /w C:\vcredist2015-2019_x86.exe /install /quiet \
 && start /w C:\VC_redist2022_x86.exe /install /quiet \
 && start /w C:\vcredist2012_x64.exe /install /quiet \
 && rem start /w C:\vcredist2013_x64.exe /install /quiet \
 && start /w C:\vcredist2015-2019_x64.exe /install /quiet \
 && start /w C:\VC_redist2022_x64.exe /install /quiet \
 && echo Deleting... \
 && del /q "C:\Visual C++ 2005 Redistribution Pack.exe" \
 && del /q "C:\vcredist*.exe" \
 && del /q "C:\VC_redist2022*.exe"


# Install Cedocida DV-Codec (?)
RUN echo Downloading... \
 && powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Codecs/Cedocida 0.2.3 (x64)/cedocida.dll', 'C:\Windows\SysWOW64\cedocida.dll') " \
 && powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Codecs/Cedocida 0.2.3 (x64)/x64/cedocida.dll', 'C:\Windows\system32\cedocida.dll') " \
 && echo Register... \
 && reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\drivers.desc" /v cedocida.dll /d "Cedocida DV Codec" /f \
 && reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Drivers32" /v vidc.dvsd /d "cedocida.dll" /f \
 && reg add "HKLM\Software\Wow6432Node\Microsoft\Windows NT\CurrentVersion\drivers.desc" /v cedocida.dll /d "Cedocida DV Codec" /f \
 && reg add "HKLM\Software\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Drivers32" /v vidc.dvsd /d "cedocida.dll" /f \
 && reg add "HKLM\SYSTEM\CurrentControlSet\Control\MediaResources\icm\vidc.dvsd" /v Driver /d "cedocida.dll" /f \
 && reg add "HKLM\SYSTEM\CurrentControlSet\Control\MediaResources\icm\vidc.dvsd" /v Description /d "Cedocida DV Codec" /f \
 && reg add "HKLM\SYSTEM\CurrentControlSet\Control\MediaResources\icm\vidc.dvsd" /v FriendlyName /d "Cedocida DV Codec" /f


## Install HuffYUV 2.1.1 CCE-Patch
#RUN echo Downloading... \
# && powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Codecs/HuffYUV/HuffYUV 2.1.1/huffyuv (CCEsp-Patch).dll', 'C:\Windows\SysWOW64\huffyuv.dll') " \
# && powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Codecs/HuffYUV/HuffYUV64.zip', 'C:\HuffYUV64.zip') " \
# && echo Extracting... \
# && powershell -command " Expand-Archive -Path 'C:\HuffYUV64.zip' -DestinationPath 'C:\HuffYUV\' " \
# && echo Copying... \
# && move /y "C:\HuffYUV\huffyuv.dll" "C:\Windows\system32\" \
# && echo Register... \
# && reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\drivers.desc" /v huffyuv.dll /d "Huffyuv lossless codec [HFYU]" /f \
# && reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Drivers32" /v VIDC.HFYU /d "huffyuv.dll" /f \
# && reg add "HKLM\Software\Wow6432Node\Microsoft\Windows NT\CurrentVersion\drivers.desc" /v huffyuv.dll /d "Huffyuv lossless codec [HFYU]" /f \
# && reg add "HKLM\Software\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Drivers32" /v VIDC.HFYU /d "huffyuv.dll" /f \
# && reg add "HKLM\SYSTEM\CurrentControlSet\Control\MediaResources\icm\vidc.dvsd" /v Driver /d "huffyuv.dll" /f \
# && reg add "HKLM\SYSTEM\CurrentControlSet\Control\MediaResources\icm\vidc.dvsd" /v Description /d "Huffyuv lossless codec [HFYU]" /f \
# && reg add "HKLM\SYSTEM\CurrentControlSet\Control\MediaResources\icm\vidc.dvsd" /v FriendlyName /d "Huffyuv lossless codec [HFYU]" /f \
# && echo Deleting... \
# && del /s /q "C:\HuffYUV" \
# && del "C:\HuffYUV64.zip"
#
## Install Lagarith 1.3.14 (64bit)
#RUN echo Downloading... \
# && powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Codecs/Lagarith/Lagarith 1.3.14 (64-bit).zip', 'C:\Lagarith.zip') " \
# && echo Extracting... \
# && powershell -command " Expand-Archive -Path 'C:\Lagarith.zip' -DestinationPath 'C:\Lagarith\' " \
# && echo Copying... \
# && move /y "C:\Lagarith\lagarith\lagarith32\lagarith.dll" "C:\Windows\SysWOW64\" \
# && move /y "C:\Lagarith\lagarith\lagarith64\lagarith.dll" "C:\Windows\system32\" \
# && echo Register... \
# && reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\drivers.desc" /v lagarith.dll /d "Lagarith lossless codec [LAGS]" /f \
# && reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Drivers32" /v VIDC.LAGS /d "lagarith.dll" /f \
# && reg add "HKLM\Software\Wow6432Node\Microsoft\Windows NT\CurrentVersion\drivers.desc" /v lagarith.dll /d "Lagarith lossless codec [LAGS]" /f \
# && reg add "HKLM\Software\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Drivers32" /v VIDC.LAGS /d "lagarith.dll" /f \
# && reg add "HKLM\SYSTEM\CurrentControlSet\Control\MediaResources\icm\vidc.dvsd" /v Driver /d "lagarith.dll" /f \
# && reg add "HKLM\SYSTEM\CurrentControlSet\Control\MediaResources\icm\vidc.dvsd" /v Description /d "Lagarith lossless codec [LAGS]" /f \
# && reg add "HKLM\SYSTEM\CurrentControlSet\Control\MediaResources\icm\vidc.dvsd" /v FriendlyName /d "Lagarith lossless codec [LAGS]" /f \
# && echo Deleting... \
# && del /s /q "C:\Lagarith" \
# && del "C:\Lagarith.zip"

# Install UTVideo 13.3.1 Codec
RUN echo Downloading... \
 && powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Codecs/UTVideo/utvideo-13.3.1.zip', 'C:\UTVideo.zip') " \
 && echo Extracting... \
 && powershell -command " Expand-Archive -Path 'C:\UTVideo.zip' -DestinationPath 'C:\UTVideo\' " \
 && echo Copying... \
 && move /y "C:\UTVideo\x64\utv_*.dll" "C:\Windows\system32\" \
 && move /y "C:\UTVideo\utv_*.dll" "C:\Windows\SysWOW64\" \
 && echo Register... \
 && start /w C:\Windows\system32\regsvr32.exe /s C:\Windows\system32\utv_dmo.dll \
 && start /w C:\Windows\system32\regsvr32.exe /s C:\Windows\system32\utv_mft.dll \
 && start /w C:\Windows\SysWOW64\regsvr32.exe /s C:\Windows\SysWOW64\utv_dmo.dll \
 && start /w C:\Windows\SysWOW64\regsvr32.exe /s C:\Windows\SysWOW64\utv_mft.dll \
 && reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\drivers.desc" /v utv_vcm.dll /d "UTVideo VfW Codec" /f \
 && reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Drivers32" /v VIDC.ULRA /d "C:\Windows\system32\utv_vcm.dll" /f \
 && reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Drivers32" /v VIDC.ULRG /d "C:\Windows\system32\utv_vcm.dll" /f \
 && reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Drivers32" /v VIDC.ULY4 /d "C:\Windows\system32\utv_vcm.dll" /f \
 && reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Drivers32" /v VIDC.ULY2 /d "C:\Windows\system32\utv_vcm.dll" /f \
 && reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Drivers32" /v VIDC.ULY0 /d "C:\Windows\system32\utv_vcm.dll" /f \
 && reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Drivers32" /v VIDC.ULH4 /d "C:\Windows\system32\utv_vcm.dll" /f \
 && reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Drivers32" /v VIDC.ULH2 /d "C:\Windows\system32\utv_vcm.dll" /f \
 && reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Drivers32" /v VIDC.ULH0 /d "C:\Windows\system32\utv_vcm.dll" /f \
 && reg add "HKLM\Software\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Drivers32" /v VIDC.ULRA /d "utv_vcm.dll" /f \
 && reg add "HKLM\Software\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Drivers32" /v VIDC.ULRG /d "utv_vcm.dll" /f \
 && reg add "HKLM\Software\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Drivers32" /v VIDC.ULY4 /d "utv_vcm.dll" /f \
 && reg add "HKLM\Software\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Drivers32" /v VIDC.ULY2 /d "utv_vcm.dll" /f \
 && reg add "HKLM\Software\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Drivers32" /v VIDC.ULY0 /d "utv_vcm.dll" /f \
 && reg add "HKLM\Software\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Drivers32" /v VIDC.ULH4 /d "utv_vcm.dll" /f \
 && reg add "HKLM\Software\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Drivers32" /v VIDC.ULH2 /d "utv_vcm.dll" /f \
 && reg add "HKLM\Software\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Drivers32" /v VIDC.ULH0 /d "utv_vcm.dll" /f \
 && echo Deleting... \
 && del /s /q "C:\UTVideo" \
 && del "C:\UTVideo.zip"


# Install AviSynth 2.60
RUN echo Downloading... \
 && powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Install/AviSynth/AviSynth 2.60 (Single Thread).exe', 'C:\AviSynth.exe') " \
 && echo Installing... \
 && start /w C:\AviSynth.exe /S /D="C:\Program Files\AviSynth 2.5" \
 && echo Link to Programme... \
 && mklink "C:\Programme" "C:\Program Files" /D \
 && echo Deleting... \
 && del "C:\AviSynth.exe"

# Copy AviSynth folder from GitHub
ADD ["AviSynth 2.5", "C:/Program Files/AviSynth 2.5/"]

# Copy FFT3 Dlls
ADD ["Windows/System32 (64bit)/fftw3.dll", "C:/Windows/System32/"]
ADD "Windows/SysWOW64/fftw3.dll" "C:/Windows/SysWOW64/"
ADD "Windows/SysWOW64/libfftw3*.dll" "C:/Windows/SysWOW64/"


# Copy VirtualDub 1.10.4
RUN echo Downloading... \
 && powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Install/VirtualDub/VirtualDub 1.10.4.zip', 'C:\VirtualDub.zip') " \
 && powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Install/VirtualDub/plugins32.zip', 'C:\plugins32.zip') " \
 && powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Install/VirtualDub/VirtualDub.reg', 'C:\VirtualDub.reg') " \
 && echo Extracting... \
 && powershell -command " Expand-Archive -Path 'C:\VirtualDub.zip' -DestinationPath 'C:\Program Files (x86)\VirtualDub\' " \
 && powershell -command " Expand-Archive -Path 'C:\plugins32.zip' -DestinationPath 'C:\Program Files (x86)\VirtualDub\plugins32\' " \
 && echo Link to Programme... \
 && mklink "C:\Programme\VirtualDub" "C:\Program Files (x86)\VirtualDub" /D \
 && echo Registry import... \
 && reg import "C:\VirtualDub.reg" \
 && echo Deleting... \
 && del "C:\VirtualDub.zip"


# Set path (unnötig)
RUN setx PATH "C:\Program Files (x86)\VirtualDub;%PATH%"

# Copy VirtualDub and start script
ADD "Recompress_UTVideo*.vcf" "C:/"
ADD "Start_vdub.cmd" "C:/"

# Set VDub as entrypoint
ENTRYPOINT ["C:/Start_vdub.cmd"]
CMD ["Demo.avs", "/s", "Recompress_UTVideo.vcf", "/x"]
CMD ["/?"]
