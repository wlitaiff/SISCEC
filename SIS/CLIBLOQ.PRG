// Sistemas de Controle de Estoque Comercial
// W&R Informatica Ltda
// 04 de Dezembro de 1995
// Roberto Falcao Rocha
// Relat¢rio Clientes

#include "HAWK.CH"

LOCAL cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
		cCor := SETCOLOR(),;
		nCursor := SETCURSOR(1),;
		lCab:=.T.,;
		nPage:=0,;
		nLin:=0,;
                cTela2,;
                sLog:=space(10);
							 

SET PROCEDURE TO WRLIB
cls
Desktop("CLIENTES BLOQUEADOS")

IF     	!ARQNTX("CECCCLI",.F.)
	DBCLOSEALL()
	RETURN
ENDIF	
// !ARQNTX(M->sLog,.F.)      .OR.;

DBSETORDER(2)

*IF !IMPRES()
*        DBCLOSEALL()
*        RETURN
*ENDIF
	
// M_MESSAGE("Imprimindo, aguarde ...",23)
   MsgBox("Aguarde, Imprimindo")
	
 SET DEVICE TO PRINT
// @ PROW(),PCOL() SAY CHR(M->sEsc)
	
DBGOTOP()
	
DO WHILE !EOF()

   IF STATUS = "B"  .AND. DELETED()=.F.
	IF INKEY()==27
			IF Para_Impressao()
				EXIT
			ENDIF
		ENDIF						
		IF lCab
			nPage++
                        CliCab(nPage,"RELATORIO DE CLIENTES BLOQUEADOS",;
			"CODIGO NOME                                     ENDERECO                                 TELEFONE             FAX")
			nLin := 9
			lCab := .F.
		ENDIF
		
		@ nLin,01 SAY CECCCLI->CODIGOC
		@ nLin,08 SAY CECCCLI->NOMECLC
		@ nLin,49 SAY CECCCLI->ENDEREC
		@ nLin,90 SAY CECCCLI->TELEFOC
		@ nLin,111 SAY CECCCLI->FAXCLIC
		
		nLin++
		IF nLin>60
			lCab := .T.
		ENDIF
   ENDIF
 DBSKIP()
ENDDO
EJECT	
DBCLOSEALL()
SET DEVICE TO SCREEN
RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
RETURN
	
							  
