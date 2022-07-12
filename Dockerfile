FROM mcr.microsoft.com/windows:1809-amd64

## Enable Remote Desktop (rdp) - not working
## (from https://withinrafael.com/2018/03/09/using-remote-desktop-services-in-containers/)
#EXPOSE 3389
#RUN net user /add Christian \
# && net user Christian Juli!!2022 \
# && net localgroup "Remote Desktop Users" Christian /add \
# && net localgroup "Administrators" Christian /add \
# && reg add "HKLM\System\CurrentControlSet\Control\Terminal Server" /v TemporaryALiC /t REG_DWORD /d 1


## Install DirectX (not working?)
## (from https://serverfault.com/questions/984285/connect-to-tightvnc-in-a-windows-container)
#RUN dism.exe /online /quiet /norestart /Add-Capability /CapabilityName:Tools.Graphics.DirectX~~~~0.0.1.0


# Install VC-Runtime 2013 und mehr (?)
RUN echo Downloading... \
 && powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Install/VCRuntime/Visual C++ 6.0 Redistribution Pack.exe', 'C:\Visual C++ 6.0 Redistribution Pack.exe') " \
 && powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Install/VCRuntime/vcruntime_2002.zip', 'C:\vcruntime_2002.zip') " \
 && powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Install/VCRuntime/vcruntime_2003.zip', 'C:\vcruntime_2003.zip') " \
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
 && echo - 1. Visual C++ 6.0 Redistribution Pack.exe \
 && (start /w "" "C:\Visual C++ 6.0 Redistribution Pack.exe" /Q || echo Error!) \
 && echo - 2. vcruntime_2002.zip \
 && (powershell -command " Expand-Archive -Path 'C:\vcruntime_2002.zip' -DestinationPath 'C:\Windows\SysWOW64\' " || echo Error!) \
 && echo - 3. vcruntime_2003.zip \
 && (powershell -command " Expand-Archive -Path 'C:\vcruntime_2003.zip' -DestinationPath 'C:\Windows\SysWOW64\' " || echo Error!) \
 && echo - 4. Visual C++ 2005 Redistribution Pack.exe \
 && (start /w "" "C:\Visual C++ 2005 Redistribution Pack.exe" /Q || echo Error!)\
 && echo - 5. vcredist2008_x86.exe \
 && (start /w C:\vcredist2008_x86.exe /q || echo Error!) \
 && echo - 6. vcredist2010_x86.exe \
 && (start /w C:\vcredist2010_x86.exe /q || echo Error!) \
 && echo - 7. vcredist2012_x86.exe \
 && (start /w C:\vcredist2012_x86.exe /install /quiet || echo Error!) \
 && echo - 8. vcredist2013_x86.exe \
 && (start /w C:\vcredist2013_x86.exe /install /quiet || echo Error!) \
 && echo - 9. vcredist2015-2019_x86.exe \
 && (start /w C:\vcredist2015-2019_x86.exe /install /quiet || echo Error!) \
 && echo - 10. VC_redist2022_x86.exe \
 && (start /w C:\VC_redist2022_x86.exe /install /quiet || echo Error!) \
 && echo - 11. vcredist2012_x64.exe \
 && (start /w C:\vcredist2012_x64.exe /install /quiet || echo Error!) \
 && echo - 12. vcredist2013_x64.exe \
 && (start /w C:\vcredist2013_x64.exe /install /quiet || echo Error!)  \
 && echo - 13. vcredist2015-2019_x64.exe \
 && (start /w C:\vcredist2015-2019_x64.exe /install /quiet || echo Error!) \
 && echo - 14. VC_redist2022_x64.exe \
 && (start /w C:\VC_redist2022_x64.exe /install /quiet || echo Error!) \
 && echo Deleting... \
 && del /q "C:\vcruntime*.zip" \
 && del /q "C:\Visual C++ 6.0 Redistribution Pack.exe" \
 && del /q "C:\Visual C++ 2005 Redistribution Pack.exe" \
 && del /q "C:\vcredist*.exe" \
 && del /q "C:\VC_redist2022*.exe" \
 && echo Finished.


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
# && del "C:\HuffYUV64.zip" \
# && echo Finished.
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
# && del "C:\Lagarith.zip" \
# && echo Finished.

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
 && del "C:\UTVideo.zip" \
 && echo Finished.


# Install AviSynth 2.60
RUN echo Downloading... \
 && powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Install/AviSynth/AviSynth 2.60 (Single Thread).exe', 'C:\AviSynth.exe') " \
 && echo Installing... \
 && start /w C:\AviSynth.exe /S /D="C:\Program Files\AviSynth 2.5" \
 && echo Link to Programme... \
 && mklink "C:\Programme" "C:\Program Files" /D \
 && echo Deleting... \
 && del "C:\AviSynth.exe" \
 && echo Finished.

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
 && del "C:\VirtualDub.zip" \
 && del "C:\plugins32.zip" \
 && del "C:\VirtualDub.reg" \
 && echo Finished.


## Install UltraVNC (not working in Docker)
#RUN echo Downloading... \
## && powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Install/UltraVNC/UltraVNC_1_3_81_X64_Setup.exe', 'C:\UltraVNC.exe') " \
## && powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Install/UltraVNC/setup.inf', 'C:\setup.inf') " \
# && powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Install/UltraVNC/UltraVnc_1381.zip', 'C:\UltraVnc.zip') " \
# && echo Installing... \
## && start /w C:\UltraVNC.exe /very silent /no restart /loadinf="C:\setup.inf" \
# && powershell -command " Expand-Archive -Path 'C:\UltraVnc.zip' -DestinationPath 'C:\Program Files\UltraVNC\' " \
# && move "C:\Program Files\UltraVNC\x64\*" "C:\Program Files\UltraVNC\" \
# && powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Install/UltraVNC/UltraVNC.ini', 'C:\Program Files\UltraVNC\UltraVNC.ini') " \
# && echo Installing Mirror driver... \
# && start /w certutil -addstore "TrustedPublisher" "C:\Program Files\UltraVNC\ultravnc.cer" \
# && start /w "" "C:\Program Files\UltraVNC\winvnc.exe" -installdriver \
# && start /w certutil -delstore trustedpublisher 01302f6c9f56b5a7b00d148510a5a59e \
# && start /w C:\Windows\SysWOW64\netsh firewall add allowedprogram "C:\Program Files\UltraVNC\winvnc.exe" "winvnc.exe" ENABLE ALL \
# && echo Deleting... \
## && del "C:\UltraVNC.exe" \
## && del "C:\setup.inf" \
# && del "C:\UltraVnc.zip" \
# && echo Finished.


# Set path (unnötig)
RUN setx PATH "C:\Program Files (x86)\VirtualDub;%PATH%"

# Copy VirtualDub- and start script
ADD "Recompress_UTVideo*.vcf" "C:/"
ADD "Start_vdub.cmd" "C:/"

# Set VDub as entrypoint
ENTRYPOINT ["C:/Start_vdub.cmd"]
CMD ["Demo.avs", "/s", "Recompress_UTVideo.vcf", "/x"]
CMD ["/?"]
