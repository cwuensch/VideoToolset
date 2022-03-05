FROM mcr.microsoft.com/windows/servercore:ltsc2019-amd64

# Install Cedocida DV-Codec (?)
RUN echo Downloading... \
 && mkdir C:\Cedocida \
 && mkdir C:\Cedocida\x64 \
 && powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Codecs/Cedocida 0.2.3 (x64)/cedocida_dv_only.inf', 'C:\Cedocida\cedocida_dv_only.inf') " \
 && powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Codecs/Cedocida 0.2.3 (x64)/cedocida.dll', 'C:\Cedocida\cedocida.dll') " \
 && powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Codecs/Cedocida 0.2.3 (x64)/x64/cedocida.dll', 'C:\Cedocida\x64\cedocida.dll') " \
 && echo Installing... \
 && rundll32.exe setupapi,InstallHinfSection DefaultInstall 132 "C:\Cedocida\cedocida_dv_only.inf" \
 && echo Deleting... \
 && del /s /f "C:\Cedocida"

# Install HuffYUV 2.1.1 CCE-Patch
RUN echo Downloading... \
 && powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Codecs/HuffYUV/HuffYUV 2.1.1.zip', 'C:\HuffYUV.zip') " \
 && powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Codecs/HuffYUV/HuffYUV 2.1.1/huffyuv (CCEsp-Patch).dll', 'C:\huffyuv_CCE.dll') " \
 && echo Extracting... \
 && powershell -command " Expand-Archive -Path 'C:\HuffYUV.zip' -DestinationPath 'C:\HuffYUV\' " \
 && move /y "C:\huffyuv_CCE.dll" "C:\HuffYUV\huffyuv.dll" \
 && echo Installing... \
 && rundll32.exe setupapi,InstallHinfSection DefaultInstall 132 "C:\HuffYUV\huffyuv.inf" \
 && echo Deleting... \
 && del /s /f "C:\HuffYUV" \
 && del "C:\HuffYUV.zip"

# Install Lagarith 1.3.14 (64bit)
RUN echo Downloading... \
 && powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Codecs/Lagarith/Lagarith 1.3.14 (64-bit)', 'C:\Lagarith.zip') " \
 && echo Extracting... \
 && powershell -command " Expand-Archive -Path 'C:\Lagarith.zip' -DestinationPath 'C:\Lagarith\' " \
 && echo Installing... \
 && "C:\Lagarith\lagarith\install.bat" \
 && echo Deleting... \
 && del /s /f "C:\Lagarith"

# Install UTVideo 18.2.1 Codec
RUN echo Downloading... \
 && powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Codecs/UTVideo/utvideo-18.2.1-win.exe', 'C:\utvideo.exe') " \
 && echo Installing... \
 && 'C:\utvideo.exe' /S" \
 && echo Deleting... \
 && del "C:\utvideo.exe"


# Install AviSynth 2.58
RUN echo Downloading... \
 && powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Install/AviSynth/AviSynth 2.58 alpha2 (070919).exe', 'C:\AviSynth.exe') " \
 && echo Installing... \
 && 'C:\AviSynth.exe' /S /D='C:\Program Files\AviSynth 2.5'" \
 && echo Deleting... \
 && del "C:\AviSynth.exe"

# Copy AviSynth folder from GitHub
ADD "AviSynth 2.5" "C:\Program Files\AviSynth 2.5\"

# Copy FFT3 Dlls
ADD "Windows\System32 (64bit)\fftw3.dll" "C:\Windows\System32\"
ADD "Windows\SysWOW64\fftw3.dll" "C:\Windows\SysWOW64\"

# Copy VirtualDub2
RUN echo Downloading... \
 && powershell -command " (New-Object Net.WebClient).DownloadFile('https://github.com/cwuensch/VideoToolset/raw/master/Install/VirtualDub/VirtualDub2_44282.zip', 'C:\VirtualDub.zip') " \
 && echo Extracting... \
 && powershell -command " Expand-Archive -Path 'C:\VirtualDub.zip' -DestinationPath 'C:\Program Files (x86)\VirtualDub\' " \
 && echo Deleting... \
 && del "C:\VirtualDub.zip"


# Set path (experimental)
#RUN setx PATH "C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE\;C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\BIN;C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\Tools;C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\VCPackages;c:\Program Files (x86)\Microsoft SDKs\Windows\v7.0A\bin\NETFX 4.0 Tools;c:\Program Files (x86)\Microsoft SDKs\Windows\v7.0A\bin;%PATH%"
RUN setx PATH "C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE\;%PATH%"

# Include MSBuild in path (prefer native x64 compiler)
RUN setx PATH "%PATH%;C:\Windows\Microsoft.NET\Framework64\v4.0.30319;C:\Windows\Microsoft.NET\Framework\v4.0.30319"

# Set MSBuild as entrypoint
ENTRYPOINT ["C:/Program Files (x86)/VirtualDub/VirtualDub.exe"]
CMD ["/help"]
