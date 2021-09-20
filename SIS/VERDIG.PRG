FUNCTION Vd(cCod)
LOCAL cFrag
IF sDig==1
	cFrag:=SUBSTR(sipcmat->cdmt,LEN(ALLTRIM(sipcmat->cdmt)))
	ALERT(cFrag)
	ALERT(SUBSTR(cCod,LEN(ALLTRIM(cCod))))
	IF !cFrag==SUBSTR(cCod,LEN(ALLTRIM(cCod)))
		ALERT('D¡gito Incorreto !')
		RETURN(.F.)
	ENDIF
ENDIF
RETURN(.T.)
