#define fr          "ÚÄ¿³ÙÄÀ³ "
SET SCOR OFF
set date brit
CLEAR SCREEN
IF !FILE("MOD.NTX")
	use sipcmod shared
	INDEX ON CODITED+descend(DTOS(DENTD))+nnotad TO mod for tipregd=2
	dbcloseall()
ENDIF	
USE SIPCMOD shared
SET INDEX TO MOD
setcolor("b/w,w+/bg,,,b/w")
DO WHILE .T.
	SETCURSOR(1)
	box(11,14,13,75,fr,127,3,8)  
	nPro := SPACE(14)
	@ 12, 15 SAY "Componente:" get npro picture "@!" valid(pnota(npro))
	read
	if lastkey()==27
		dbcloseall()
		return(nil)
	endif
enddo

function pnota(pro)
	seek pro
	if found()
		SAVE SCREEN
		X:=(VLTITED/QTDNOTD)
		m_display("Ultima nota : "+nnotad+" - "+dtoc(dentd)+STR(X,10,2),23)	
		RESTORE SCREEN
		SETCURSOR(1)
		return(.t.)
	else	
		SAVE SCREEN
		m_display("Nao houve entrada",79)
		RESTORE SCREEN
		SETCURSOR(1)
	endif	
return(.f.)
