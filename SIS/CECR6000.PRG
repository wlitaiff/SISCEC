// Sistemas de Controle de Estoque Comercial
// W&R Informatica Ltda
// 04 de Dezembro de 1995
// Roberto Falcao Rocha
// Relat¢rio Divisoes de mercadoria

#include "HAWK.CH"

LOCAL cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
		cCor := SETCOLOR(),;
		nCursor := SETCURSOR(1),;
		lCab:=.T.,;
		nPage:=0,;
		nLin:=0,;
		cTela2
							 

IF !ARQNTX(m->sLog,.F.)      .OR.;
	!ARQNTX("CECTDIV",.F.) 
	DBCLOSEALL()
	RETURN
ENDIF	

DBSETORDER(2)

IF !IMPRES()
	DBCLOSEALL()
	RETURN
ENDIF
	
M_MESSAGE("Imprimindo, aguarde ...",23)
	
SET DEVICE TO PRINT
@ PROW(),PCOL() SAY CHR(m->sEsc)
	
DBGOTOP()
	
DO WHILE !EOF()
		IF INKEY()==27
			IF Para_Impressao()
				EXIT
			ENDIF
		ENDIF						
		IF lCab
			nPage++
			Cabecalho(nPage,"RELATORIO DE DIVISOES DE MERCADORIAS",;
			"CODIGO DESCRICAO")
			nLin := 9
			lCab := .F.
		ENDIF
		
		@ nLin,01 SAY CECTDIV->CODDIV
		@ nLin,08 SAY CECTDIV->NOMDIV
		nLin++
		
		DBSKIP()
		IF nLin>60
			lCab := .T.
		ENDIF
			
	ENDDO
	
	DBCLOSEALL()
	EJECT
	SET DEVICE TO SCREEN
	RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
	
RETURN							  