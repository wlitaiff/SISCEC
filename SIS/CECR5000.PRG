// Sistemas de Controle de Estoque Comercial
// W&R Informatica Ltda
// 04 de Dezembro de 1995
// Roberto Falcao Rocha
// Relat¢rio Linha de mercadorias

#include "HAWK.CH"

LOCAL cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
		cCor := SETCOLOR(),;
		nCursor := SETCURSOR(1),;
		lCab:=.T.,;
		nPage:=0,;
		nLin:=0,;
		cTela2
							 

IF !ARQNTX(m->sLog,.F.)      .OR.;
	!ARQNTX("CECTLIN",.F.) 
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
			Cabecalho(nPage,"RELATORIO DE LINHAS DE MERCADORIAS",;
			"CODIGO DESCRICAO")
			nLin := 9
			lCab := .F.
		ENDIF
		
		@ nLin,01 SAY CECTLIN->CODLIN
		@ nLin,08 SAY CECTLIN->NOMLIN
		
		DBSKIP()
		nLin++
		IF nLin>60
			lCab := .T.
		ENDIF
			
	ENDDO
	
	EJECT
	SET DEVICE TO SCREEN
	RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
	DBCLOSEALL()
	
RETURN							  