# Usage of Docker container:

```
docker run --rm --env VNC_CONNECT=wu....tk:6500 --env VNC_ID=1025 -v C:/local:C:/source --workdir "C:/source" cwuensch/avisynth:2.60 "C:\source\Demo.avs" /s "C:\Recompress_UTVideo.vcf" /x

docker run --rm --env STORAGE_IN_PATH="\\u000000-sub2.your-storagebox.de\u000000-sub2" --env STORAGE_IN_USER="u000000-sub2" --env STORAGE_IN_PASSWORD="xyz" --env STORAGE_OUT_PATH="\\u000000-sub3.your-storagebox.de\u000000-sub3" --env STORAGE_OUT_USER="u000000-sub3" --env STORAGE_OUT_PASSWORD="xyz" cwuensch/avisynth:2.60 "I:\Schildkröten-6\Kleine Geschichten von wilden Tieren - Die Meeresschildkröte.avs" /i "C:\Recompress_UTVideo2.vcf" "O:\Video_out.avi" /x

docker run --rm -v C:/local:C:/source/ --workdir "C:/source" --entrypoint "cmd" cwuensch/avisynth:2.60 /c "C:\Program Files (x86)\VirtualDub\vdub.exe" "C:\source\Demo.avs" /s C:\source\Recompress_UTVideo.vcf /x
```


UltraVNC:
---------

To view progress on GitHub runner, please install UltraVNC viewer and

1. Run a listener on the host that is stored within GitHub secret "VNC_CONNECT":
   ```
   vncviewer -listen 6900 -disablesponsor -dsmplugin SecureVNCPlugin64.dsm
   ```

2. Run a repeater on a publicly accessible host stored in GitHub secret "VNC_CONNECT"
   and connect to the repeater host with "VNC_ID":
   ```
   vncviewer -proxy w....tk:6900 ID:<VNC_ID> -disablesponsor -dsmplugin SecureVNCPlugin64.dsm
   ```
