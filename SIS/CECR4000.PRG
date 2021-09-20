// Sistemas de Controle de Estoque Comercial
// W&R Informatica Ltda
// 04 de Dezembro de 1995
// Roberto Falcao Rocha
// Relat¢rio Fornecedores

#include "HAWK.CH"

LOCAL cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
		cCor := SETCOLOR(),;
		nCursor := SETCURSOR(1),;
		lCab:=.T.,;
		nPage:=0,;
		nLin:=0,;
		cTela2
							 

IF !ARQNTX(M->sLog,.F.)      .OR.;
	!ARQNTX("CECCFOR",.F.) 
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
@ PROW(),PCOL() SAY CHR(M->sEsc)
	
DBGOTOP()
	
DO WHILE !EOF()
		IF INKEY()==27
			IF Para_Impressao()
				EXIT
			ENDIF
		ENDIF						
		IF lCab
			nPage++
			Cabecalho(nPage,"RELATORIO DE FORNECEDORES",;
			"CODIGO NOME                                     ENDERECO                                 TELEFONE             FAX")
			nLin := 9
			lCab := .F.
		ENDIF
		
		@ nLin,001 SAY CECCFOR->CODIGOF
		@ nLin,008 SAY CECCFOR->NOMECLF
		@ nLin,049 SAY CECCFOR->ENDEREF
		@ nLin,090 SAY CECCFOR->TELEFOF
		@ nLin,111 SAY CECCFOR->FAXCLIF
		
		DBSKIP()
		nLin++
		IF nLin>60
			lCab := .T.
		ENDIF
			
	ENDDO
	EJECT
	DBCLOSEALL()
	SET DEVICE TO SCREEN
	RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
	
RETURN							  