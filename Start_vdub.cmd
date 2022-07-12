if not "%STORAGE_IN_PATH%"=="" (
  net use I: %STORAGE_IN_PATH% /user:%STORAGE_IN_USER% %STORAGE_IN_PASSWORD%
)
if not "%STORAGE_OUT_PATH%"=="" (
  net use O: %STORAGE_OUT_PATH% /user:%STORAGE_OUT_USER% %STORAGE_OUT_PASSWORD%
)

if not "%VNC_CONNECT%"==""  (
  if "%VNC_ID%"=="" and not "%VNC_ID%"=="-" (
    "C:\Program Files\UltraVNC\winvnc.exe" -autoreconnect -connect %VNC_CONNECT% -run
  ) else (
    "C:\Program Files\UltraVNC\winvnc.exe" -id:%VNC_ID% -autoreconnect -connect %VNC_CONNECT% -run
  )
)

"C:\Program Files (x86)\VirtualDub\vdub.exe" %*