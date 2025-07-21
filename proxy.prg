*!*	 oWMI = Getobject('winmgmts://')
*!*	 cQuery = "select * from win32_process where name='opera-proxy.windows-amd64.exe'"
*!*	 oResult = oWMI.ExecQuery(cQuery)
*!*	 For Each oProcess In oResult
*!*	 	oProcess.Terminate(0)
*!*	 Next
    
*Set proxy

*!*	PUBLIC px
*!*	px = CreateObject("wscript.shell")

*!*	px.Run([cmd /c "powershell -command ""$reg = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings'; Set-ItemProperty -Path $reg -Name ProxyEnable -Value 1; Set-ItemProperty -Path $reg -Name ProxyServer -Value '127.0.0.1:18080'"""], 0, 1)

*!*	Release px

* unset proxy



PUBLIC px
px = CreateObject("wscript.shell")

px.Run([cmd /c "powershell -command ""$reg = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings'; Set-ItemProperty -Path $reg -Name ProxyEnable -Value 0; Remove-ItemProperty -Path $reg -Name ProxyServer -ErrorAction SilentlyContinue"""], 0, 1)

Release px
