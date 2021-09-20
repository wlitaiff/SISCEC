// Sistemas de Controle de Estoque Comercial
// W&R Informatica Ltda
// 15 de Maio de 1996
// Roberto Falcao Rocha
// Analise da Curva ABC (periodo) 

#define fr "ÚÄ¿³ÙÄÀ³ "

LOCAL cCor := SETCOLOR("B/W,W+/BG,,,B/W"),;
		nCursor := SETCURSOR(1),;
		cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
		dDataI := CTOD("  /  /    "),;
		dDataF := CTOD("  /  /    "),;
		nLoja := 0,;
		nFornecedor := 0,;
		nLinha := 0,;
		cOrigem := " ",;
		lCab,;
		nLin,;
		nPage,;
		cTelao,;
		nSaidas := 0,;
		nCurva := 0,;
		nSugestao := 0,;
		nInicio := 0,;
		cSugestao := "N"

// Abre arquivos
IF !ARQNTX(m->sLog,.F.) .OR. ;   
	!ARQNTX("CECTLIN",.F.)  .OR.;
	!ARQNTX("CECCMER",.F.) .OR.;
	!ARQNTX("CECCFOR",.F.) .OR.;
	!ARQNTX("CECTLOJ",.F.) .OR.;
	!ARQNTX("CECCLOJ",.F.) .OR.;
	!ARQNTX("CECTREL",.T.) .OR.;
	!ARQNTX("CECCMOV",.F.) 
	DBCLOSEALL()
	RETURN
ENDIF		 		

DO WHILE .T.
	SELECT("CECTREL")
	ZAP
	SELECT("CECCMOV")
	Box(13,06,21,75,fr,127,3,8)
	@ 14,08 SAY "Data inicial:";
			  GET dDataI;
			  PICTURE "@D"
	@ 15,08 SAY "Data Final..:";
	        GET dDataF;
			  PICTURE "@D";
			  VALID(IF(!EMPTY(dDataI),dDataF>=dDataI,.T.))
	@ 16,08 SAY "Loja........:";
			  GET nLoja PICTURE "9999";
			  VALID IF(EMPTY(nLoja),EVAL({||DISPOUT(" Todas                                                      "),.T.}),;
			        Existe(nLoja,"Loja nÆo cadastrada",.F.,"CECTLOJ",1,"NOMLOJTL","@!",ROW(),COL()+1))
	@ 17,08 SAY "Grupo..:";
			  GET nLinha;
			  PICTURE "@K 9999";
			  VALID IF(EMPTY(nLinha),EVAL({||DISPOUT(" Todas                     "),.T.}),;
			        Existe(nLinha,"Grupo de mercadoria nÆo cadastrada",.F.,"CECTLIN",1,"NOMLIN","@!",ROW(),COL()+1))
					  
	@ 18,08 SAY "Origem.:";
			  GET cOrigem;
			  PICTURE "@K!";
			  VALID cOrigem$"NI " .AND.;
			        IF(EMPTY(cOrigem),EVAL({||DISPOUT(" Todas                    "),.T.}),;
			        EVAL({|x|DISPOUT(IF(x=="N","Nacional","Importado")),.T.}))
					  
	@ 19,08 SAY "Fornecedor:";
			  GET nFornecedor;
			  PICTURE "@K 99999";
			  VALID IF(EMPTY(nFornecedor),EVAL({||DISPOUT(" Todos                                                 "),.T.}),;
			        Existe(nFornecedor,"Fornecedor nÆo cadastrado",.F.,"CECCFOR",1,"NOMECLF","@!",ROW(),COL()+1))				  				 
	@ 20,08 SAY "So sugestao ?";
			  GET cSugestao;
			  PICTURE "@K!";
			  VALID !EMPTY(cSugestao) .AND. cSugestao$"SN"
	
	READ				  
	
	IF LASTKEY()==27
		RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
		SETCURSOR(nCursor)
		SETCOLOR(cCor)
		DBCLOSEALL()
		RETURN
	ENDIF
	
	SELECT("CECCMOV")
	DBSETORDER(3)
	DBGOTOP()
	cTelao := SAVESCREEN(0,0,MAXROW(),MAXCOL())
	M_MESSAGE("Aguarde gerando relat¢rio ...",23)
	DO WHILE !EOF()
		IF INKEY()==27
			IF M_QUERY("Cancela o relat¢rio ?",79)
				EXIT
			ENDIF
		ENDIF		
		CECCMER->(DBSEEK(CECCMOV->MERCADORIA))
		IF EMPTY(nLoja)
			_est := CECCMER->SALDOEM
		ELSE
			CECCLOJ->(DBSEEK(STR(nLoja,4)+CECCMER->CODIGOM))
			_est := CECCLOJ->SALDOEJ
		ENDIF		
		IF TIPOMOV#"S"
				DBSKIP()
				LOOP
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
			IF !EMPTY(cOrigem)
				IF CECCMER->ORIGEMM#cOrigem
					DBSKIP()
					LOOP
				ENDIF
			ENDIF		
			IF !EMPTY(nLinha)
				IF CECCMER->CODLINM#nLinha
					DBSKIP()
					LOOP
				ENDIF
			ENDIF		
			IF !EMPTY(nLoja)
				IF CODLOJA#nLoja
					DBSKIP()
					LOOP
				ENDIF
			ENDIF		
			IF !EMPTY(nFornecedor)
				IF CECCMER->FORNECM#nFornecedor
					DBSKIP()
					LOOP
				ENDIF
			ENDIF		
			if (_est >= ceccmer->estminm) .and. cSugestao=="S"
				DBSKIP()
				LOOP
			ENDIF	
				
				
		cMerc := CECCMOV->MERCADORIA
		nSaidas := 0
		lPri := .T.
		CECCMER->(DBSEEK(CECCMOV->MERCADORIA))
		IF EMPTY(nLoja)
			_est := CECCMER->SALDOEM
		ELSE
			CECCLOJ->(DBSEEK(STR(nLoja,4)+CECCMER->CODIGOM))
			_est := CECCLOJ->SALDOEJ
		ENDIF		
		DO WHILE cMerc == CECCMOV->MERCADORIA .AND. CECCMOV->(!EOF())
			_PARA := .F.
			IF INKEY()==27
				IF m_query("Cancela o relat¢rio ?",79)
					_PARA := .T.
					EXIT
				ENDIF
			ENDIF						
			IF TIPOMOV#"S"
				DBSKIP()
				LOOP
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
			IF !EMPTY(cOrigem)
				IF CECCMER->ORIGEMM#cOrigem
					DBSKIP()
					LOOP
				ENDIF
			ENDIF		
			IF !EMPTY(nLinha)
				IF CECCMER->CODLINM#nLinha
					DBSKIP()
					LOOP
				ENDIF
			ENDIF		
			IF !EMPTY(nLoja)
				IF CODLOJA#nLoja
					DBSKIP()
					LOOP
				ENDIF
			ENDIF		
			IF !EMPTY(nFornecedor)
				IF CECCMER->FORNECM#nFornecedor
					DBSKIP()
					LOOP
				ENDIF
			ENDIF	
			
			if (_est >= ceccmer->estminm) .and. cSugestao=="S"
				DBSKIP()
				LOOP
			ENDIF	
				
			IF lPri 
				nInicio := SALANTMOV
				lPri := .F.				
			ENDIF	
			nSaidas += (QUANTMOV*(-1))
			DBSKIP()
		ENDDO	
		if _para
			EXIT
		ENDIF	
		SELECT("CECTREL")
		append blank
		CECTREL->CODIGO := CECCMER->CODIGOM
		CECTREL->SAIDAS := nSaidas
		CECTREL->CURVA  := IF(NINICIO==0,0,100-ROUND(((nSaidas/nInicio)*100),2)) 
		SELECT("CECCMOV")
		DBSKIP()
	ENDDO
	RESTSCREEN(0,0,LASTROW(),LASTCOL(),cTelao)
	IF !IMPRES()
		LOOP
	ENDIF		
	cTelao := SAVESCREEN(0,0,MAXROW(),MAXCOL())
	M_MESSAGE("Aguarde imprimindo o  relat¢rio ...",23)
	SELECT("CECTREL")
	DBGOTOP()
	lCab := .T.
	nPage := 1	
	SET DEVICE TO PRINT
	@ PROW(),PCOL() SAY CHR(sesc)
	DO WHILE !EOF()
		IF INKEY()==27
			IF PARA_IMPRESSAO()
				EXIT
			ENDIF
		ENDIF		
		IF lCab 
			Cabecalho(nPage,"RELATORIO DE CURVA ABC - ("+DTOC(dDataI)+"-"+DTOC(dDataF)+")")
			@ 07,01 SAY "FORNECEDOR.:"+CECCFOR->NOMECLF
			@ 07,PCOL()+2 SAY "GRUPO.:"+CECTLIN->NOMLIN
			@08,01 SAY "MERCADORIA       DESCRICAO                                UND   O  ESTOQUE      SAIDAS       CURVA      MINIMO      %MINIMO   SUGESTAO"
			@09,01 SAY REPL("-",132)
			nLin := 10
			lCab := .F.
			nPage++
		ENDIF
		CECCMER->(DBSEEK(CECTREL->CODIGO))
		CECCFOR->(DBSEEK(CECCMER->FORNECM))
		CECTLIN->(DBSEEK(CECCMER->CODLINM))
		IF EMPTY(nLoja)
			_est := CECCMER->SALDOEM
		ELSE
			CECCLOJ->(DBSEEK(STR(nLoja,4)+CECCMER->CODIGOM))
			_est := CECCLOJ->SALDOEJ
		ENDIF		
		@ nLin,001 SAY CECTREL->CODIGO
		@ nLin,018 SAY CECCMER->DESCRIM
		@ nLin,059 SAY CECCMER->UNIDADE
		@ nLin,065 SAY CECCMER->ORIGEMM
		@ nLin,068 SAY _est PICTURE "99999.999"
		@ nLin,081 SAY CECTREL->SAIDAS PICTURE "99999.999"
		@ nLin,094 SAY CECTREL->CURVA PICTURE "@R 999.99%"
		@ nLin,105 SAY CECCMER->ESTMINM PICTURE "99999.999"
		@ nLin,115 SAY IF(_EST==0,0,ROUND(100-((CECCMER->ESTMINM/_EST)*100),2)) PICTURE "@R 99999.99%"
		@ nLin,127 SAY IF(_EST<CECCMER->ESTMINM,CECCMER->ESTMINM-_EST,0) PICTURE "99999.999" 
		nLin++
		IF nLin > 60
			lCab := .T.
		ENDIF	
		DBSKIP()
	ENDDO	
	EJECT
	SET DEVICE TO SCREEN
	RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTelao)
ENDDO