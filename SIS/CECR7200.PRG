// Relat¢rio das compras no periodo

#define fr "ÚÄ¿³ÙÄÀ³ "

LOCAL cCor := SETCOLOR("B/W,W+/BG,,,B/W"),;
		nCursor := SETCURSOR(1),;
		cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
		dDataI := CTOD("  /  /    "),;
		dDataF := CTOD("  /  /    "),;
		nLoja := 0,;
		lCab,;
		nLin,;
		nPage,;
		lTem,;
		cTelao

// Abre arquivos
ARQNTX(m->sLog,.F.)  
ARQNTX("CECCMER",.F.)
ARQNTX("CECTLOJ",.F.)
ARQNTX("CECCFOR",.F.)
ARQNTX("CECCMOV",.F.) 		

DO WHILE .T.
	Box(16,06,20,75,fr,127,3,8)
	@ 17,08 SAY "Data inicial:" GET dDataI PICTURE "@D"
	@ 18,08 SAY "Data Final..:" GET dDataF PICTURE "@D" VALID(dDataF>=dDataI)
	@ 19,08 SAY "Loja........:";
			  GET nLoja;
			  PICTURE "9999";
			  VALID IF(EMPTY(nLoja),EVAL({||DISPOUT(" Todas                                                      "),.T.}),;
			        Existe(nLoja,"Loja nÆo cadastrada",.F.,"CECTLOJ",1,"NOMLOJTL","@!",ROW(),COL()+1)) 
					  
	READ
	IF LASTKEY()==27
		RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
		SETCURSOR(nCursor)
		SETCOLOR(cCor)
		DBCLOSEALL()
		RETURN(NIL)
	ENDIF
	SELECT("CECCMOV")
	DBSETORDER(6)
	IF !EMPTY(dDataI)
		DBSEEK(DTOS(dDataI),.T.)
	ENDIF
	IF !EMPTY(dDataF)
		IF CECCMOV->DATAMOV>dDataF .OR. CECCMOV->(EOF())
			M_DISPLAY("Per¡odo nÆo encontrado",79)
			LOOP
		ENDIF
	ENDIF		
	IF !IMPRES()
		LOOP
	ENDIF			
	cTelao := SAVESCREEN(0,0,MAXROW(),MAXCOL())
	M_MESSAGE("Aguarde processando relat¢rio ...",23)
	SET DEVICE TO PRINT
	@ prow(),pcol() say CHR(sEsc)
	lCab  := .T.
	nPage :=  1
	lTem  := .F.
	DO WHILE IF(!EMPTY(dDataF),CECCMOV->DATAMOV<=dDataF,.T.) .AND. CECCMOV->(!EOF())
		IF INKEY()==27
			IF Para_Impressao()
				EXIT
			ENDIF
		ENDIF		
		IF CECCMOV->CODMOV#"CF".AND.CECCMOV->CODMOV#"CD".AND.CECCMOV->CODMOV#"CP"
			DBSKIP()
			LOOP
		ENDIF	
		
		IF !Empty(nLoja)
			IF CODLOJA#nLoja
				DBSKIP()
				LOOP
			ENDIF	
		ENDIF
			
		lTem := .T.
		IF lCab 
			Cabecalho(nPage,"RELATORIO DAS COMPRAS - ("+DTOC(dDataI)+"-"+DTOC(dDataF)+")",;
					   "DATA------  MERCADORIA------  DESCRICAO----------------------- FORN. QUANTIDADE--  PRC-COMPRA  TOTAL COMPRA PRECO MEDIO  TOTAL MEDIO")
//         																	   99999 999999,999UN  999.999,99  9999.999,99  999.999,999  9999,999.99                       
//	         13                31                               64    70        80  84          96           109          122               
			nLin := 9
			lCab := .F.
			nPage++
		ENDIF
//99999 999999,999UN  999.999,99  9999.999,99  999.999,999  9999,999.99
//64    70        80  84          96           109          122               
		// ************    Detalhes     **************
		CECCMER->(DBSEEK(CECCMOV->MERCADORIA))
		@ nLin,001 SAY CECCMOV->DATAMOV
		@ nLin,013 SAY CECCMOV->MERCADORIA
		@ nLin,031 SAY SUBS(CECCMER->DESCRIM,1,32)
		@ nLin,064 SAY CECCMOV->FORNECEDOR PICT "99999"
		@ nLin,070 SAY CECCMOV->QUANTMOV PICTURE "@E 999999,999"
		@ nLin,080 SAY CECCMOV->UNIDADE
		@ nLin,084 SAY CECCMOV->PRECOMPRA  PICTURE "@E 999,999.99"
		@ nLin,096 SAY CECCMOV->CUSTOFOB   PICTURE "@E 9999,999.99"
		@ nLin,109 SAY CECCMOV->CUSTOMED   PICTURE "@E 999,999.999"
		@ nLin,122 SAY CECCMOV->CUSTOMOV   PICTURE "@E 9999,999.99"
		nLin++
		IF nLin > 60
			lCab := .T.
		ENDIF	
		DBSKIP()
	ENDDO
	EJECT
	SET DEVICE TO SCREEN
	RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTelao)
	IF !lTem
		M_DISPLAY("Nao foram encontradas entradas de materiais nesse per¡odo",79)
	ENDIF						
ENDDO	