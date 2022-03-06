FROM mcr.microsoft.com/windows:1809-amd64

# Install Cedocida DV-Codec (?)
RUN echo Downloading... \
 && mkdir C:\Cedocida \
 && mkdir C:\Cedocida\x64 \
 && powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Codecs/Cedocida 0.2.3 (x64)/cedocida_dv_only.inf', 'C:\Cedocida\cedocida.inf') " \
 && powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Codecs/Cedocida 0.2.3 (x64)/cedocida.dll', 'C:\Cedocida\cedocida.dll') " \
 && powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Codecs/Cedocida 0.2.3 (x64)/x64/cedocida.dll', 'C:\Cedocida\x64\cedocida.dll') " \
 && echo Installing... \
 && rundll32.exe setupapi,InstallHinfSection DefaultInstall 132 C:\Cedocida\cedocida.inf \
 && echo Deleting... \
 && del /s /q "C:\Cedocida"

# Install HuffYUV 2.1.1 CCE-Patch
RUN echo Downloading... \
 && powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Codecs/HuffYUV/HuffYUV 2.1.1.zip', 'C:\HuffYUV.zip') " \
 && powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Codecs/HuffYUV/HuffYUV 2.1.1/huffyuv (CCEsp-Patch).dll', 'C:\huffyuv_CCE.dll') " \
 && powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Codecs/HuffYUV/HuffYUV64.zip', 'C:\HuffYUV64.zip') " \
 && powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Codecs/HuffYUV/huffyuv64.inf', 'C:\huffyuv64.inf') " \
 && echo Extracting... \
 && powershell -command " Expand-Archive -Path 'C:\HuffYUV.zip' -DestinationPath 'C:\HuffYUV\' " \
 && powershell -command " Expand-Archive -Path 'C:\HuffYUV64.zip' -DestinationPath 'C:\HuffYUV\HuffYUV64\' " \
 && move /y "C:\huffyuv_CCE.dll" "C:\HuffYUV\huffyuv.dll" \
 && move /y "C:\huffyuv64.inf" "C:\HuffYUV\huffyuv64.inf" \
 && echo Installing... \
 && rundll32.exe setupapi,InstallHinfSection DefaultInstall 132 C:\HuffYUV\huffyuv64.inf \
 && echo Deleting... \
 && del /s /q "C:\HuffYUV" \
 && del "C:\HuffYUV.zip"

# Install Lagarith 1.3.14 (64bit)
RUN echo Downloading... \
 && powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Codecs/Lagarith/Lagarith 1.3.14 (64-bit).zip', 'C:\Lagarith.zip') " \
 && echo Extracting... \
 && powershell -command " Expand-Archive -Path 'C:\Lagarith.zip' -DestinationPath 'C:\Lagarith\' " \
 && echo Installing... \
 && cd "C:\Lagarith\lagarith" \
 && C:\Lagarith\lagarith\install.bat \
 && echo Deleting... \
 && del /s /q "C:\Lagarith"

# Install UTVideo 13.3.1 Codec
RUN echo Downloading... \
 && powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Codecs/UTVideo/utvideo-13.3.1.zip', 'C:\UTVideo.zip') " \
 && echo Extracting... \
 && powershell -command " Expand-Archive -Path 'C:\UTVideo.zip' -DestinationPath 'C:\UTVideo\' " \
 && echo Installing... \
 && rundll32.exe setupapi,InstallHinfSection DefaultInstall 132 C:\UTVideo\utvideo64.inf \
 && echo Deleting... \
 && del /s /q "C:\UTVideo"


# Install AviSynth 2.60
RUN echo Downloading... \
 && powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Install/AviSynth/AviSynth 2.60 (Single Thread).exe', 'C:\AviSynth.exe') " \
 && echo Installing... \
 && C:\AviSynth.exe /S /D='C:\Program Files\AviSynth 2.5' \
 && echo Deleting... \
 && del "C:\AviSynth.exe"

# Copy AviSynth folder from GitHub
ADD ["AviSynth 2.5", "C:/Program Files/AviSynth 2.5/"]

# Copy FFT3 Dlls
ADD ["Windows/System32 (64bit)/fftw3.dll", "C:/Windows/System32/"]
ADD "Windows/SysWOW64/fftw3.dll" "C:/Windows/SysWOW64/"

# Copy VirtualDub 1.10.4
RUN echo Downloading... \
 && powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Install/VirtualDub/VirtualDub 1.10.4.zip', 'C:\VirtualDub.zip') " \
 && powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Install/VirtualDub/plugins32.zip', 'C:\plugins32.zip') " \
 && powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Install/VirtualDub/VirtualDub.reg', 'C:\VirtualDub.reg') " \
 && echo Extracting... \
 && powershell -command " Expand-Archive -Path 'C:\VirtualDub.zip' -DestinationPath 'C:\Program Files (x86)\VirtualDub\' " \
 && powershell -command " Expand-Archive -Path 'C:\plugins32.zip' -DestinationPath 'C:\Program Files (x86)\VirtualDub\plugins32\' " \
 && echo Registry import... \
 && reg import "C:\VirtualDub.reg" \
 && echo Deleting... \
 && del "C:\VirtualDub.zip"


# Set path (unnötig)
RUN setx PATH "C:\Program Files (x86)\VirtualDub;%PATH%"

# Set VDub as entrypoint
ENTRYPOINT ["C:/Program Files (x86)/VirtualDub/vdub.exe"]
CMD ["Demo.avi", "/s", "Recompress_UTVideo.vcf", "/x"]
CMD ["/?"]
