// Sistemas de Controle de Estoque Comercial
// W&R Informatica Ltda
// 15 de Maio de 1996
// Roberto Falcao Rocha
// Analise da Curva ABC (periodo) 

#define fr "ÚÄ¿³ÙÄÀ³ "

LOCAL cCor := SETCOLOR("B/W,W+/BG,,,B/W"),;
		nCursor := SETCURSOR(1),;
		cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
		dDataI := CTOD("  /  /  "),;
		dDataF := CTOD("  /  /  "),;
		nLoja := 0,;
		nFornecedor := 0,;
		nLinha := 0,;
		nDivisao := 0,;
		cOrigem := " ",;
		lCab,;
		nLin,;
		nPage,;
		cTelao,;
		nSaidas := 0,;
		nCurva := 0,;
		nSugestao := 0,;
		nInicio := 0,;
		nLinha := 0,;
		nDivisao := 0,;
		nFornecedor := 0,;
		cOrigem := " "

// Abre arquivos
IF !ARQNTX(m->sLog,.F.) .OR. ;   
	!ARQNTX("CECTDIV",.F.)  .OR.;
	!ARQNTX("CECTLIN",.F.)  .OR.;
	!ARQNTX("CECCMER",.F.) .OR.;
	!ARQNTX("CECCFOR",.F.) .OR.;
	!ARQNTX("CECTLOJ",.F.) .OR.;
	!ARQNTX("CECCMOV",.F.) 
	DBCLOSEALL()
	RETURN
ENDIF		 		

DO WHILE .T.
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
	@ 17,04 SAY "Linha..:";
			  GET nLinha;
			  PICTURE "@K 9999";
			  VALID IF(EMPTY(nLinha),EVAL({||DISPOUT(" Todas                     "),.T.}),;
			        Existe(nLinha,"Linha de mercadoria nÆo cadastrada",.F.,"CECTLIN",1,"NOMLIN","@!",ROW(),COL()+1))
					  
	@ 18,04 SAY "DivisÆo:";
			  GET nDivisao;
			  PICTURE "@K 9999";
			  VALID IF(EMPTY(nDivisao),EVAL({||DISPOUT(" Todas                   "),.T.}),;
			        Existe(nDivisao,"DivisÆo de mercadoria nÆo cadastrada",.F.,"CECTDIV",1,"NOMDIV","@!",ROW(),COL()+1))				  
					  
	@ 19,04 SAY "Origem.:";
			  GET cOrigem;
			  PICTURE "@K!";
			  VALID cOrigem$"NI " .AND.;
			        IF(EMPTY(cOrigem),EVAL({||DISPOUT(" Todas                    "),.T.}),;
			        EVAL({|x|DISPOUT(IF(x=="N","Nacional","Importado")),.T.}))
					  
	@ 20,04 SAY "Fornecedor:";
			  GET nFornecedor;
			  PICTURE "@K 99999";
			  VALID IF(EMPTY(nFornecedor),EVAL({||DISPOUT(" Todos                                                 "),.T.}),;
			        Existe(nFornecedor,"Fornecedor nÆo cadastrado",.F.,"CECCFOR",1,"NOMECLF","@!",ROW(),COL()+1))				  				 
	
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
	M_MESSAGE("Aguarde processando relat¢rio ...",23)
	DO WHILE !EOF()
		IF INKEY()==27
			IF m_query("Deseja cancelar o relatorio",79)
				EXIT
			ENDIF
		ENDIF		
		cMerc := CECCMOV->MERCADORIA
		nSaidas := 0
		lPri := .T.
		CECCMER->(DBSEEK(MERCADORIA))
		DO WHILE cMerc == CECCMOV->MERCADORIA .AND. CECCMOV->(!EOF())
			_PARA := .F.
			IF INKEY()==27
				IF m_query("Deseja cancelar a impressao",79)
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
			IF !EMPTY(nDivisao)
				IF CECCMER->CODDIVM#nDivisao
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
		INCLUI_REGISTRO(.T.)
		LOCK_REGISTRO(.T.)
		CECTREL->CODIGO := CECCMER->CODIGOM
		CECTREL->SAIDAS := nSaidas
		CECTREL->CURVA  := nCurva
		@ nLin,099 SAY nCurva  PICTURE "999"
		@ nLin,110 SAY CECCMER->UNIDADE
		@ nLin,115 SAY CECCMER->UNIDADE
		@ nLin,124 SAY CECCMER->UNIDADE
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