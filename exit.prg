If SetSystem="1"
	UnSetsysproxy()
EndIf	
Try
	Use in proxyvpn
Catch
EndTry	
ClosedAll()
On Shutdown 
Release all
Clear events
