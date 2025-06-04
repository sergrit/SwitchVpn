*proc
FUNCTION mListApp  
	Lparameters NameApp
	Declare Integer CreateToolhelp32Snapshot In WIN32API Integer dwFlags, Integer th32ProcessID
	Declare Integer Process32First In WIN32API Integer lhSnapshot, String lppe
	Declare Integer Process32Next  In WIN32API Integer lhSnapshot, String lppe
	Declare Integer CloseHandle    In Kernel32 Integer hObject
	Local lnRetCode, lppe, lhSnapshot, Kol1, lppee1
	Kol1=0
	NameApp=Upper(NameApp)
	lppe=Chr(44)+Chr(1)+Replicate(Chr(0),298)
	lhSnapshot=CreateToolhelp32Snapshot(2,0)
	lnRetCode=Process32First(lhSnapshot,@lppe)
	Do While lnRetCode<>0
		lppee1=Upper(Substr(lppe,37,256))
		If At(NameApp,lppee1)>0
			Kol1=Kol1+1
		Endif
		lnRetCode=Process32Next(lhSnapshot,@lppe)
	Enddo
	CloseHandle(lhSnapshot)
	Clear Dlls
	Return Kol1
EndFunc
****************************************
Procedure ClosedExe
	Lparameters pFile
	 oWMI = Getobject('winmgmts://')
	 cQuery = "select * from win32_process where name='"+pFile+"'"
	 oResult = oWMI.ExecQuery(cQuery)
	 For Each oProcess In oResult
	 	oProcess.Terminate(0)
	 Next
	 Release oResult,oWMI
EndProc
****************************************
Procedure ClosedAllExe
Lparameters lexename
	li=0
	Do while mListApp(m->lexename)>0 .and. li<10
		If li#0
			Wait WINDOW "" timeout 1
			If mListApp(m->lexename)>0
				ClosedExe(m->lexename)
			EndIf	
		Else
			ClosedExe(m->lexename)
		EndIf	
		li=li+1
	EndDo
EndProc
****************************************
Procedure ClosedAll
	ClosedAllExe(PNameOpera)
	ClosedAllExe(PNameHola)
	ClosedAllExe(PNameWind)
	ClosedAllExe(PNameDumb)
EndProc
****************************************
Function httping
Local lpf,lcPing
	lpf=k_drive+"wping.txt"
	SafeDel(lpf)
	*px.Run([cmd /c "]+k_drive+[wget.exe" -e https_proxy=127.0.0.1:18080 -O wping.txt https://www.dropbox.com/s/cpan5ywqv9w9eob/wping.txt?dl=1],0,1)
	px.Run([cmd /c "]+k_drive+[wget.exe" -e https_proxy=]+m->Bindadd+[ -O wping.txt https://www.google.com/images/branding/googlelogo/1x/googlelogo_color_272x92dp.png],0,1)
	llping=FileSize(lpf)>0
	SafeDel(lpf)
	Return llPing
EndFunc
****************************************
Function WaitExe
	Lparameters lexename
	Local li
	li=0
	Do while li<6
		stray.TipText="(*) Proxy poll (waiting "+Alltrim(Str(li+1))+" from 5)..."
		WriteActLog(stray.TipText)
		If mListApp(lexename)=0 
			Wait WINDOW "" TIMEOUT 1
		Else			
			stray.TipText="(*) Proxy pinging (1 from 3)..."
			WriteActLog(stray.TipText)
			Wait WINDOW "" TIMEOUT 1
			If httping()
				Exit
			Else
				stray.TipText="(*) Proxy pinging (2 from 3)..."
				WriteActLog(stray.TipText)
				Wait WINDOW "" TIMEOUT 3
				If httping()
					Exit
				Else
					stray.TipText="(*) Proxy pinging (3 from 3)..."
					WriteActLog(stray.TipText)
					Wait WINDOW "" TIMEOUT 5 
					If httping()
						Exit
					Else
						li=5
					EndIf
				EndIf
			EndIf 	
		EndIf
		li=li+1 
	EndDo	
	Return li
EndFunc
****************************************
Procedure NotRsp
	Lparameters lmsg
	stray.TipText="(-) "+lmsg+" is not responding..."
	WriteActLog(stray.TipText+Chr(13)+Chr(10))
	Wait WINDOW "" TIMEOUT 2
	*stray.ShowBalloonTip(Alltrim(stray.TipText),"Proxy inactive:",3,3)
EndProc
****************************************
Function FromCache
	Lparameters ltproxy,ltcountry
	Local lret
	lret=.f.
	Select proxyvpn
	Locate for tp=ltproxy .and. Alltrim(country)==Alltrim(ltcountry)
	If Found()
		lret=.t.
		If tdupdate=Date()
			stray.TipText = Alltrim(tstr)
	  		WriteActLog(stray.TipText+Chr(13)+Chr(10))
	  		Wait WINDOW "" TIMEOUT 2
		Else
			RunWget(ltproxy,ltcountry)
		EndIf
  		*stray.ShowBalloonTip(Alltrim(stray.TipText),"Proxy active:",1,3)	
	Else
		RunWget(ltproxy,ltcountry)
	EndIf
	Return lret	
EndFunc 
****************************************
Procedure StartSet
	If Type("switchset")#"O" .or. (Type("switchset")="O" .and. IsNull(switchset))
		Release switchset
		Public switchset
		Do form switchset name "switchset"
	EndIf
EndProc
****************************************
Procedure StartActLog
	If Type("actlog")#"O" .or. (Type("actlog")="O" .and. IsNull(actlog))
		Release actlog
		Public actlog
		Do form actlog name "actlog"
	EndIf
EndProc
Procedure EndActLog
	If Type("actlog")="O" .and. !IsNull(actlog)
		StrToFile(actlog.e.value,"actlog.log")
		actlog.release()
	EndIf	
EndProc
Procedure WriteActLog
	Lparameters ltext
	If Type("actlog")="O" .and. !IsNull(actlog)
		actlog.e.value=ltext+Chr(13)+Chr(10)+actlog.e.value
	EndIf
EndProc
Procedure ClearActLog
	If Type("actlog")="O" .and. !IsNull(actlog)
		actlog.e.value=""
	EndIf
	StartActLog()
EndProc
****************************************
Procedure StartRun
	If File("actlog.log")
		SafeDel(k_drive+[actlog.log])			
	EndIf
	ClearActLog()
	ClosedAll()
EndProc
****************************************
Function CoreDumb
	px.Run([cmd /c "]+k_drive+PNameDumb+[" -bind-address ]+Bindadd+[ ]+Argdumb,DebugMode,0)
	lret=.f.
	If WaitExe(PNameDumb)<6
		FromCache("D","")		
		lret=.t.
	 EndIf 
	 Return lret
EndFunc
****************************************
Procedure RunDumb
	StartRun()
	WriteActLog([(+) Dumbproxy is starting...])
	If !CoreDumb()
		WriteActLog([(+) Restart Dumbproxy...])
		ClosedAll()
		If !CoreDumb()
			NotRsp([Dumbproxy ])
		EndIf	
	EndIf
	EndActLog()
EndProc
****************************************
Function CoreOpera
Lparameters lcountry
	px.Run([cmd /c "]+k_drive+PNameOpera+[" -bind-address ]+Bindadd+[ -country ]+lcountry+[ ]+ArgOpera,DebugMode,0)
	lret=.f.
	If WaitExe(PNameOpera)<6
		FromCache("O",lcountry)		
		lret=.t.
	 EndIf 
	 Return lret
EndFunc
****************************************
Procedure RunOpera
Lparameters lcountry
	StartRun()
	WriteActLog([(+) Opera proxy is starting...])
	If !CoreOpera(lcountry)
*!*			WriteActLog([(+) Restart proxy Opera...])
*!*			ClosedAll()
*!*			If !CoreOpera(lcountry)
			NotRsp([Opera proxy "]+lcountry+["])
*!*			EndIf	
	EndIf
	EndActLog()
EndProc
****************************************
Function CoreHola
Lparameters lcountry
	px.Run([cmd /c "]+k_drive+PNameHola+[" -bind-address ]+Bindadd+[ -country ]+lcountry+[ ]+ArgHola,DebugMode,0)
	lret=.f.
	If WaitExe(PNameHola)<6
		FromCache("H",lcountry)		
		lret=.t.
	EndIf
	Return lret
EndFunc
****************************************
Procedure RunHola 
Lparameters lcountry
	StartRun()
	WriteActLog([(+) Hola proxy is starting...])
	If !CoreHola(lcountry)
*!*			WriteActLog([(+) Restart proxy Hola...])
*!*			ClosedAll()
*!*			If !CoreHola(lcountry)
			NotRsp([Hola proxy "]+lcountry+["])
*!*			EndIf	
	EndIf
	EndActLog()	
EndProc
****************************************
Function CoreWind
Lparameters lcountry
	If !Empty(lcountry)
		px.Run([cmd /c "]+k_drive+PNameWind+[ -bind-address ]+Bindadd+[ -location ]+lcountry+[ ]+ArgWind,DebugMode,0)
	Else
		px.Run([cmd /c "]+k_drive+PNameWind+[ -bind-address ]+Bindadd+[ ]+ArgWind,DebugMode,0)
	EndIf	
	lret=.f.
	If WaitExe(PNameWind)<6
		FromCache("H",lcountry)		
		lret=.t.
	EndIf
	Return lret
EndFunc
****************************************
Procedure RunWinds
Lparameters lcountry
	If File("wndstate.json")
		StartRun()
		WriteActLog([(+) Windscribe proxy is starting...])
		If !CoreWind(lcountry)
*!*				WriteActLog([(+) Restart proxy Windscribe...])
*!*				ClosedAll()
*!*				If !CoreWind(lcountry)
				NotRsp([Windscribe proxy "]+lcountry+["])
*!*				EndIf	
		EndIf
		EndActLog()	
	Else
		StartRun()
		WriteActLog([(-) A file "wndstate.json" is required to start the Windscribe...])
		Wait WINDOW "" TIMEOUT 2
		EndActLog()	
	EndIf
EndProc
*==============================================================================
Procedure SAbout
	Do case
		Case File(k_drive+"switchvpn64.exe")
			lfile=k_drive+"switchvpn64.exe"
		Case File(k_drive+"switchvpn32.exe")
			lfile=k_drive+"switchvpn32.exe"
		Otherwise
			lfile=""
	EndCase
	If !Empty(lfile)		
		Public vermas(1)
		Agetfileversion("vermas",lfile)
		lstr="Program @2022-2025 by Sergiy Grytsjuk"+Chr(13)+Chr(10)+;
		"Version: "+Alltrim(vermas(4))+Chr(13)+Chr(10)+;
		"Download at: https://www.dropbox.com/scl/fi/ib06ukmdqey2pzl2jejh0/SwitchVpnEXE.zip?rlkey=4h424xqtedtq5qbzoc40kac0w&st=grmflc0h&dl=1"+Chr(13)+Chr(10)+;
		""+Chr(13)+Chr(10)+;
		"Snawoot (Vladislav Yarmak) site: https://github.com/Snawoot"
		Release vermas
		StrToFile(lstr,"actlog.log")
		ClearActLog()
	EndIf
EndProc
*==============================================================================
Function delfile  
Lparameters lpath
Declare INTEGER DeleteFile IN kernel32 STRING lpFileName 
= DeleteFile (Alltrim(m->lpath))
Clear Dlls "DeleteFile"
EndFunc	 
****************************************
Function SafeDel
Lparameters fsfile
Local lfret	
lfret=.f.
	FOR i=1 TO 5
		try
			=delfile(fsfile)
		CATCH
		ENDTRY
		If File(fsfile)
			WAIT WINDOW "" TIMEOUT 1 
		ELSE
			lfret=.t.
			exit
		ENDIF
	ENDFOR		
EndFunc 
Function FileSize
	Lparameters fsfile
	Local lnFileHandle, lnFileSize
	lnFileHandle = FOPEN(fsfile)
	lnFileSize   = FSEEK(lnFileHandle,0,2)
	= FCLOSE(lnFileHandle)
	Return lnFileSize 
EndFunc

*==============================================================================
Procedure RunWget
	Lparameters ltproxy,ltcountry
	Local cXML,lxmlfile,lxmldel,CRLF,li,li2,allrow,cString,lresult,lstr,lstr2,lstr3
	Local tpp,tdn,tip,tcou
	lxmlfile=["]+k_drive+[wget.txt"]
	lxmldel=k_drive+[wget.txt]
	If File(lxmlfile)
   		SafeDel(lxmldel)
	EndIf
	lstr=[cmd /c "]+k_drive+[wget.exe" -e https_proxy=]+Bindadd+[ -O wget.txt https://browserleaks.com/ip]
	px.Run(lstr,0,1)
	If File(lxmlfile) .and. FileSize(lxmlfile)>0
		cXML = FILETOSTR(lxmlfile)
		CRLF=CHR(13)+CHR(10)
		allrow=GETWORDCOUNT(cXML, CRLF)
		Store "" to tpp,tdn,tip,tcou,tcit
		FOR li = 1 TO allrow
			cString = GETWORDNUM(cXML, li, CRLF)
			DO CASE 
	    		CASE "<tr><td>IP Address</td><td>"$cString
					cString = GETWORDNUM(cXML, li, CRLF)
					lstr2=Substr(cString,Atc("wball",cString)+7)
					lstr3=Left(lstr2,At("<",lstr2)-1)			
					tip=Alltrim(lstr3)
					tip="IP: "+Iif(Empty(tip),"Undefined",tip)
					*
					li2=li+3
					cString = GETWORDNUM(cXML, li2, CRLF)
					lstr2=Substr(cString,Atc("wball",cString)+7)
					lstr3=Left(lstr2,At("<",lstr2)-1)			
					tcou=Alltrim(lstr3)
					tcou="Country: "+Iif(Empty(tcou),"Undefined",tcou)
					li2=li+5
					cString = GETWORDNUM(cXML, li2, CRLF)
					lstr2=Substr(cString,At(">",cString,4)+1)
					tdn=Left(lstr2,At("<",lstr2)-1)
					tdn="City: "+Iif(Empty(tdn),"Undefined",tdn)
					li2=li+6
					cString = GETWORDNUM(cXML, li2, CRLF)
					lstr2=Substr(cString,At(">",cString,4)+1)
					tpp=Left(lstr2,At("<",lstr2)-1)
					tpp="ISP: "+Iif(Empty(tdn),"Undefined",tpp)
					exit
	    	EndCase
	    EndFor
	    lresult=tip+Chr(13)+Chr(10)+tcou+Chr(13)+Chr(10)+tdn+Chr(13)+Chr(10)+tpp
		Do case
			Case ltproxy="O"
				lresult="(+) Opera proxy is active:"+Chr(13)+Chr(10)+lresult	
			Case ltproxy="H"
				lresult="(+) Hola proxy is active:"+Chr(13)+Chr(10)+lresult	
			Case ltproxy="W"
				lresult="(+) Windscribe proxy is active:"+Chr(13)+Chr(10)+lresult	
			Case ltproxy="D"
				lresult="(+) Dumbproxy is active:"+Chr(13)+Chr(10)+lresult	
		EndCase 
		Select proxyvpn
		Locate for tp=ltproxy .and. Alltrim(country)==Alltrim(ltcountry)
		If !Found()
			Append Blank
		EndIf
		Replace tp with ltproxy, country with ltcountry
		Replace tstr with lresult, tdupdate with Date()
		If !Empty(lresult)
			stray.TipText = Alltrim(lresult)
			WriteActLog(stray.TipText+Chr(13)+Chr(10))
			Wait WINDOW "" TIMEOUT 2
	  		*stray.ShowBalloonTip(Alltrim(stray.TipText),"Proxy active:",1,3)	
	  	Else
			*stray.ShowBalloonTip("Error: Invalid file to analyze, see wget.inv","No information",3,3)
			Copy File ((["]+k_drive+[wget.txt"])) to (["]+k_drive+[wget.inv"])
			WriteActLog("Error: Invalid file to analyze, see wget.inv")
			Wait WINDOW "" TIMEOUT 2
		EndIf  		
	EndIf
    If File(lxmldel)
   		SafeDel(lxmldel)
	EndIf	
EndProc
*====================================================================
Function  infoerro 
Parameters  err,ername,erline
Priv ername,erline,erx,ers,erl
Priv xq_,xq_2,xq_3,xq_4
Priv fl_sys6,fl_prin,fl_cons,fl_devi
*-----------------
Local errostr,comstr,comat
errostr=Allt(Mess(1))
*------------------
Local errostr,comstr,comat
errostr=Allt(Mess(1))
*-----------------
Local sssmes
sssmes=Alltrim(Message())
*-----------------
erx=ername+'-'+Allt(Mess(1))
ers=Len(erx)
erx=Iif(ers>65,Left(erx,65),erx+Spac(65-ers))
ers=Str(err,4)
erl=Iif(Type('erline')='N',Str(erline,4),'')
xq_="Error"
erx=' #'+Ltri(ers)
xq_="Line"
xq_2="Program"
erromess1=Iif(!Empt(erl),xq_+":"+Ltri(erl)+" ",'')+xq_2+":"+ername
If !Empt(Mess(1))
	erromess2 = "Code:"+Allt(Mess(1))
Else
	erromess2 = "Code:"
Endi
xq_="Message"
If err=1526
	xstr='errmas(1,2)'
	erromess3=xq_+": "+Alltrim(&xstr )
	xstr='errmas(1,5)'
	err=Alltrim(Str(err))+"("+Alltrim(Str(xstr))+")"
Else
	erromess3=xq_+": "+Mess()
	err=Alltrim(Str(err))
Endif
Local gnErrFile
IF FILE('errors.txt')
gnErrFile = FOPEN('errors.txt',12)
ELSE
	gnErrFile = FCREATE('errors.txt')
ENDIF
IF !gnErrFile < 0
	=FSEEK(gnErrFile,0,2)
	=Fputs(gnErrFile , "["+Dtoc(Date())+"]")
	=Fputs(gnErrFile , Alltrim(erromess1))
	=Fputs(gnErrFile , Alltrim(erromess2))
	=Fputs(gnErrFile , Alltrim(erromess3))
	=Fputs(gnErrFile , "¹ error: "+Alltrim(err))
	=Fputs(gnErrFile , "-----------------------------------------------------")
ENDIF
=FCLOSE(gnErrFile )
Wait WINDOW Alltrim(erromess3)+" Look in more detail errors.txt"
Retu To Mast
EndFunc
