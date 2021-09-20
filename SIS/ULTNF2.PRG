#define fr          "ÚÄ¿³ÙÄÀ³ "
SET SCOR OFF
set date brit
CLEAR SCREEN
IF !FILE("MOD.NTX")
	use sipcmod exclusive
	INDEX ON CODITED+descend(DTOS(DENTD))+nnotad TO mod for tipregd=2
	dbcloseall()
ENDIF	
if !fILE("SIPTIEN1.NTX")
	use sipteng exclusive
	index on produto+componente+subconjunt to siptien1
	dbcloseall()
ENDIF	
use sipteng shared
set index TO siptien1	
USE SIPCMOD shared
SET INDEX TO MOD
setcolor("b/w,w+/bg,,,b/w")
DO WHILE .T.
	SETCURSOR(1)
	box(11,14,13,75,fr,127,3,8)  
	nPro := SPACE(14)
	@ 12, 15 SAY "Modelo:" get npro picture "@!" valid(pnota(npro))
	read
	if lastkey()==27
		dbcloseall()
		return(nil)
	endif
enddo

function pnota(pro)
	LOCAL CM,NLIN,X
	select("sipteng")
	seek pro
	if found()
		set device to print
		@ 01,01 say pro
		@ 01,01 say pro
		nlin:=2
		do while pro==sipteng->produto .and. sipteng->(!eof())
			cm := SIPTENG->componente
			if sipcmod->(dbseek(cm))
				@ nlin,01 say cm
				@ nlin,20 say sipcmod->nnotad
				@ nlin,40 say dtoc(sipcmod->dentd)
				X:=(sipcmod->VLTITED/sipcmod->QTDNOTD)
				@ nlin,60 say str(x,10,2)
				nlin++
			endif
			IF NLIN>59
				@ 01,01 say pro
				@ 01,01 say pro
				NLIN:=2
			ENDIF	
			dbskip()
		ENDDO		
	ENDIF	
return(.T.)
