// Relat¢rio de estoque valorizado

#define fr "ÚÄ¿³ÙÄÀ³ "

LOCAL cCor := SETCOLOR("B/W,W+/BG,,,B/W"),;
		nCursor := SETCURSOR(1),;
		cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
		dDataI := CTOD("  /  /    "),;
		dDataF := CTOD("  /  /    "),;
		lCab,;
		nLin,;
		nPage,;
		cTelao,;
		nTotV,;
		nTotC,;
		nTV,;
		nTC

// Abre arquivos
ARQNTX("SCECMAT",.F.)		

DBGOTOP()

IF !IMPRES()
	RETURN(NIL)
ENDIF			
cTelao := SAVESCREEN(0,0,MAXROW(),MAXCOL())
M_MESSAGE("Aguarde processando relat¢rio ...",23)
SET DEVICE TO PRINT
lCab := .T.
nPage := 1
nTotV := nTotC := nTV := nTC := 0
DO WHILE SCECMAT->(!EOF())
	IF INKEY()==27
		IF Para_Impressao()
			EXIT
		ENDIF
	ENDIF		
	IF lCab 
		Cabecalho("RELATORIO DE ESTOQUE VALORIZADO",nPage)
		@ 07,01 SAY "MATERIAL          DESCRICAO                                  SALDO         PRECO(VENDA)    TOTAL        PRECO(COMPRA)     TOTAL"
		@ 08,01 SAY REPL("-",132)  
		nLin := 9
		lCab := .F.
		nPage++
	ENDIF
	nTV := ROUND(SCECMAT->PRVENDA*SCECMAT->SALDOATUAL,2)
	nTC := ROUND(SCECMAT->PRCOMPRA*SCECMAT->SALDOATUAL,2)
	nTotV+=nTV
	nTotC+=nTC
	@ nLin,001 SAY SCECMAT->CODIGO
	@ nLin,019 SAY SCECMAT->DESCRICAO
	@ nLin,062 SAY SCECMAT->SALDOATUAL PICTURE "999999.999"
	@ nLin,076 SAY SCECMAT->PRVENDA    PICTURE "9999999.99"
	@ nLin,092 SAY nTV PICTURE "9999999.99"
	@ nLin,105 SAY SCECMAT->PRCOMPRA
	@ nLin,123 SAY nTC PICTURE "9999999.99"
	nLin++
	IF nLin > 60
		lCab := .T.
	ENDIF	
	DBSKIP()
ENDDO
@ nLin,01 SAY REPL("-",132)
@ nLin+1,01 SAY   "TOTAIS:"
@ nLin+2,01 SAY "         A PRECO DE VENDA.:"+TRANS(nTotV,"9999999.99")
@ nLin+3,01 SAY "         A PRECO DE COMPRA:"+TRANS(nTotC,"9999999.99")
EJECT
SET DEVICE TO SCREEN
RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTelao)
DBCLOSEALL()
RETURN(NIL)
