// Sistemas de Controle de Estoque Comercial
// W&R Informatica Ltda
// 03 de Maio de 1996
// Roberto Falcao Rocha
// Analise de vendas (periodo) sint‚tico

#define fr "ÚÄ¿³ÙÄÀ³ "

LOCAL cCor := SETCOLOR("B/W,W+/BG,,,B/W"),;
		nCursor := SETCURSOR(1),;
		cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
		dDataI := CTOD("  /  /    "),;
		dDataF := CTOD("  /  /    "),;
		nLoja := 0,;
		nVend := 0,;
		lCab,;
		nLin,;
		nPage,;
		lTem,;
		cTelao,;
		nDescontos:=0,;
		XTotalVendido:=0,;
		nTotalVenda:=0,;
		nVendedor := 0

// Abre arquivos
IF !ARQNTX(m->sLog,.F.) .OR. ;   
	!ARQNTX("CECTDIV",.F.)  .OR.;
	!ARQNTX("CECCMER",.F.) .OR.;
	!ARQNTX("CECCVEN",.F.) .OR.;
	!ARQNTX("CECTLOJ",.F.) .OR.;
	!ARQNTX("CECCMOV",.F.) 
	DBCLOSEALL()
	RETURN
ENDIF		 		

DO WHILE .T.
	Box(16,06,21,75,fr,127,3,8)
	@ 17,08 SAY "Data inicial:";
			  GET dDataI;
			  PICTURE "@D"
	@ 18,08 SAY "Data Final..:";
	        GET dDataF;
			  PICTURE "@D";
			  VALID(IF(!EMPTY(dDataI),dDataF>=dDataI,.T.))
	@ 19,08 SAY "Loja........:";
			  GET nLoja PICTURE "9999";
			  VALID IF(EMPTY(nLoja),EVAL({||DISPOUT(" Todas                                                      "),.T.}),;
			        Existe(nLoja,"Loja nÆo cadastrada",.F.,"CECTLOJ",1,"NOMLOJTL","@!",ROW(),COL()+1))
	
	@ 20,08 SAY "Vendedor....:";
			  GET nVend PICTURE "99999";
			  VALID IF(EMPTY(nVend),EVAL({||DISPOUT(" Todos                                                      "),.T.}),;
			        Existe(STR(nVend,5)+IF(!EMPTY(nLoja),STR(nLoja,4),""),"Vendedor nÆo cadastrado",.F.,"CECCVEN",1,"NOMVEN","@!",ROW(),COL()+1))				  
	READ				  
	
	IF LASTKEY()==27
		RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
		SETCURSOR(nCursor)
		SETCOLOR(cCor)
		DBCLOSEALL()
		RETURN
	ENDIF
	
	SELECT("CECCMOV")
	DBSETORDER(7)
	cChave := IF(EMPTY(nLoja),"",STR(nLoja,4))
	IF !DBSEEK("VE"+cChave)
		M_DISPLAY("Nao existem vendas nessa loja",79)
		LOOP
	ENDIF
	DBSEEK("CV"+cChave,.T.)
	IF !IMPRES()
		LOOP
	ENDIF			
	cTelao := SAVESCREEN(0,0,MAXROW(),MAXCOL())
	M_MESSAGE("Aguarde processando relat¢rio ...",23)
	SET DEVICE TO PRINT
	@ PROW(),PCOL() SAY CHR(sesc)
	lCab := .T.
	nPage := 1
	DO WHILE CECCMOV->CODMOV>="CV" .AND. CECCMOV->CODMOV<="VE" .AND. CECCMOV->(!EOF())
		IF INKEY()==27
			IF Para_Impressao()
				EXIT
			ENDIF
		ENDIF		
		IF lCab 
			Cabecalho(nPage,"RELATORIO SINTETICO DE VENDAS - ("+DTOC(dDataI)+"-"+DTOC(dDataF)+")")
			@07,01 SAY "MERCADORIA       DESCRICAO                                QUANTIDADE"
			@08,01 SAY REPL("-",132)
			nLin := 9
			lCab := .F.
			nPage++
		ENDIF
		cMerc := CECCMOV->MERCADORIA
		nQuant := 0
		cDesc := DESCMERC
		DO WHILE cMerc == CECCMOV->MERCADORIA .AND. CECCMOV->(!EOF())
			_PARA := .F.
			IF INKEY()==27
				IF Para_Impressao()
					_PARA := .T.
					EXIT
				ENDIF
			ENDIF		
			IF (CECCMOV->CODMOV#"VE" .AND. CECCMOV->CODMOV#"CV") 
				DBSKIP()
				LOOP
			ENDIF	
			IF !EMPTY(nLoja)
				IF CECCMOV->CODLOJA#nLoja
					DBSKIP()
					LOOP
				ENDIF
			ENDIF						
			IF !EMPTY(dDataI)
				IF DATAMOV<dDataI
					DBSKIP()
					LOOP
				ENDIF
			ENDIF		
			IF !EMPTY(dDataF)
				IF DATAMOV>dDataF
					DBSKIP()
					LOOP
				ENDIF
			ENDIF		
			IF !EMPTY(nVend)
				IF VENDEDOR#nVend
					DBSKIP()
					LOOP
				ENDIF
			ENDIF				
			nQuant += (QUANTMOV*(-1))
			DBSKIP()
		ENDDO	
		IF _PARA
			EXIT
		ENDIF	
		IF nQuant>0
			@ nLin,001 SAY cMerc
			@ nLin,018 SAY cDesc
			@ nLin,059 SAY nQuant PICTURE "999999.999"
			nLin++
		ENDIF	
		IF nLin > 60
			lCab := .T.
		ENDIF	
	ENDDO
	EJECT
	SET DEVICE TO SCREEN
	RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTelao)
ENDDO