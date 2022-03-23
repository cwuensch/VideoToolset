if not "%STORAGE_IN_PATH%"=="" (
  net use I: %STORAGE_IN_PATH% /user:%STORAGE_IN_USER% %STORAGE_IN_PASSWORD%
)
if not "%STORAGE_OUT_PATH%"=="" (
  net use O: %STORAGE_OUT_PATH% /user:%STORAGE_OUT_USER% %STORAGE_OUT_PASSWORD%
)

"C:\Program Files (x86)\VirtualDub\vdub.exe" %*