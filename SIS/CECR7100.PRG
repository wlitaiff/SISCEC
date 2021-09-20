// Create date - 12/12/95
// An lise dos Movimento (GERAL OU POR MOVIMENTO)
// Create by   - W.L.V - 
// Update date - 12/12/95
// Declara‡”es locais

LOCAL VER
LOCAL cOldScreen,;
		nOldCursor
LOCAL lHeader,;
		cMonthYear,;
      nPage,;
      nLin,;
		cor,;
		fdDt1,;
		fdDt2,;
		telcad,;
		nOri,;
		nMov,;
		nLoj,;
		nTiP,;
		nNomeMov,;
		tMov,;
		cTipoMovimento
		
LOCAL	nQTO:=;
		nCSO:=;
		nPRO:=;
		nQTE:=;
		nCSE:=;
		nPRE:=;
		nQTM:=;
		nCSM:=;
		nPRM:=;
		nQTER:=;
		nCSER:=;
		nPRER:=;
		nQTMR:=;
		nCSMR:=;
		nPRMR:=;
		nTQO:=;
		nTCO:=;
		nTPO:=0
		
LOCAL lAllMov := .F.
LOCAL lImpMov := .F.
LOCAL nItens  := 0		
// Inicializa vetores		
nLin     := 0
// Cria arquivos de ¡ndices caso n„o existam
// Verifica a existˆncia de ¡ndices, nao existindo cria-los 	
IF !ARQNTX("CECCMER",.F.) .OR. ;
	!ARQNTX("CECCMOV",.F.) .OR. ;
	!ARQNTX( m->sLog ,.F.) .OR. ; 
	!ARQNTX("CECCLOJ",.F.) .OR. ;
	!ARQNTX("CECCFOR",.F.) .OR. ;
	!ARQNTX("CECCCLI",.F.) .OR. ;
	!ARQNTX("CECCSET",.F.) .OR. ;
	!ARQNTX("CECTLOJ",.F.) 
	DBCLOSEALL()
	RETURN
ENDIF
//
//SET RELATION TO CECCMOV->FORNECEDOR INTO CECCFOR,;
//					 CECCMOV->CODLOJA    INTO CECTLOJ
					 
// Seta as cores
cor        := Setcor()
nOldCursor := SETCURSOR(1)
cOldScreen := SAVESCREEN(0,0,LASTROW(),LASTCOL())
SetCor("B/W,W+/Bg,,,B/W")
DO WHILE .T.
   SELECT("CECCMOV")
	DBSETORDER(2)
	nQTO:=nCSO:=nPRO:=nQTE:=nCSE:=nPRE:=nQTM:=nCSM:=nPRM:=nTQO:=nTCO:=nTPO:=0
   lAllMov := .F.
   lImpMov := .F.
   tMov    := "  "
	cTipo := SPACE(1)
	fdDt1:=fdDt2:=CTOD("  /  /    ")
	nLoja:=0
	cTelad := SAVESCREEN(16,12,24,76)
	Box(16,12,22,75,fr,127,03,08)
	@ 17,14 SAY "Movimento.........:" GET tMov  PICTURE "!!" VALID( IF(!EMPTY(tMov),ChecaMov(tMov,.T.),Todos()) )
	@ 18,14 say "Tipo do movimento.:" GET cTipo PICTURE "!" VALID cTipo$"ESI " .AND. MostraTipMov(cTipo) 
	@ 19,14 SAY "Data Inicial......:" GET fdDt1 PICTURE "@D"
	@ 20,14 SAY "Data Final........:" GET fdDt2 PICTURE "@D"  Valid(If(!Empty(fdDt1).and.!Empty(fdDt2),ValidaData(fdDt1,fdDt2),Todos()))
	@ 21,14 SAY "Loja..............:" GET nLOja PICTURE "9999";
	VALID IF(EMPTY(nLoja),EVAL({||DISPOUT(" Todas                                                      "),.T.}),;
			        Existe(nLoja,"Loja nÆo cadastrada",.F.,"CECTLOJ",1,"NOMLOJTL","@!",ROW(),COL()+1))

	READ
	IF LASTKEY() == 27
		RESTSCREEN( 0,0,LASTROW(),LASTCOL(),cOldScreen )
		SETCURSOR(nOldCursor)
		SetCor(cor)
		DBCLOSEALL()
		RETURN(NIL)
	ENDIF
	IF cTipo=="I"
		If ! ( PASS () == ALLTRIM ( Criptografa ( CECCSET -> PASSWDS, "HAWK", .F. ) ) ) 
			M_DISPLAY ( "Usu rio n„o autorizado", 79 )
			LOOP
		Endif	
	EndIf
	// Posiciona no 1o registro que contem o movimento solicitado
	SELECT ( "CECCMOV" )	
	//
	IF EMPTY(FDDT1)
		DBGOTOP()
	ELSE
		DBSEEK(DTOS(FDDT1),.T.)	
		IF IF(!EMPTY(FDDT2),DATAMOV>FDDT2,.F.)
			M_DISPLAY("Periodo nao encontrado",79)
			LOOP
		ENDIF
	ENDIF			
	// Inicializa variavel de cabe‡alho com verdadeiro
	lHeader := .T.
	// Inicializa numera‡„o de p gina
	nPage := 0
	// Seta impressora
	IF ! ( Impres() )
		Loop
	ENDIF	
	//
	SET DEVICE TO PRINT
	@ PROW(),PCOL() SAY CHR(sEsc)
	M_Message("Aguarde! imprimindo An lise do movimento...",23)
	//
	SELECT("CECCMOV")
	DO WHILE IF(!EMPTY(FDDT2),CECCMOV->DATAMOV<=FDDT2,.T.) .AND. !EOF()
		IF INKEY()=27
			IF Para_Impressao()
				EXIT
			ENDIF
		ENDIF		
		//
		IF !EMPTY(tMov)
			IF CODMOV#tmov
				DBSKIP()
				LOOP
			ENDIF
		ENDIF
		//			
		IF !EMPTY(cTipo)
			IF TIPOMOV#IF(cTipo=="I","A",cTipo)
				DBSKIP()
				LOOP
			ENDIF
		ENDIF				
		//
		/*IF !EMPTY(nLoja)
			IF nLoja#CODLOJA
				DBSKIP()
				LOOP
			ENDIF
		ENDIF*/
		//
		nPar := MERCADORIA
		nOri := ORIGEM
		nTip := TIPOMOV
		nLoj := CODLOJA
		nMov := CODMOV
		nFor := FORNECEDOR
		//
		SELECT("CECTLOJ")
		DBSEEK(nLoj)
		//
		SELECT("CECCMOV")
		IF lHeader
			nPage ++
			CABECALHO(nPage,"ANALISE DO MOVIMENTO DE ESTOQUE ",;
         "DATA------ No.DOC---- MERCADORIA----- DESCRICAO---------------------------------------- O QUANTIDADE--  CUSTO----R$---- PRECO----R$--")
			cTipoMovimento := AllTrim( ChecaMov(nMov,.F.) )
			FOR i = 1 TO 2
				@ 09,01 SAY 'MOVIMENTO..: '+nMov+' = '+cTipoMovimento+' - LOJA..:'+;
				        TRANS((CECCMOV->CODLOJA),'9999')+' = '+(CECTLOJ->NOMLOJTL)
			NEXT	
			nLin    := 11
			lHeader := .F.
		ENDIF
		//
		SELECT("CECCMER")
		DBSEEK(nPar)
		//
		SELECT ( "CECCMOV" )	
		//
		nQTE += QUANTMOV         // TOTAL DAS LOJAS
		nPRE += PREVENDA        //     
		nCSE += CUSTOMOV
		//
		nQTM += QUANTMOV			 // TOTAL DOS MOVIMENTOS
		nPRM += PREVENDA
		nCSM += CUSTOMOV
		//
		nQTER += QUANTMOV         // TOTAL DAS LOJAS GERAL
		nPRER += PREVENDA        //     
		nCSER += CUSTOMOV
		//
		nQTMR += QUANTMOV			 // TOTAL DOS MOVIMENTOS GERAL
		nPRMR += PREVENDA
		nCSMR += CUSTOMOV
		//
		nTQO += QUANTMOV         // TOTAL GERAL
		nTPO += PREVENDA
		nTCO += CUSTOMOV
		nItens ++
		//	
		@ nLin,001 SAY DTOC(DATAMOV)
		@ nLin,012 SAY NUMDOCTO
		@ nLin,023 SAY MERCADORIA
		@ nLin,040 SAY CECCMER->DESCRIM
		@ nLin,090 SAY ORIGEM    
		@ nLin,092 SAY QUANTMOV  PICTURE "@E 9999,999.999"
		//@ nLin,106 SAY CUSTOMOV  PICTURE "@E 9999,999,999.99" 
		@ nLin,122 SAY PREVENDA PICTURE "@E 99,999,999.99"
		// Resumo do custo
		//  R$
		// Proximo registro
		SELECT("CECCMOV")
		DBSKIP()
		nLin ++
		IF nLin > 59
			 lHeader := .T.
		ENDIF
		/*IF  nMov # codmov .OR. nLoj # codloja
			FOR I = 1 TO 2
				@ nLin,001 SAY "TOTAL DA LOJA =============>"
				@ nLin,090 SAY nQTE  PICTURE "@E 9999,999.999"
				//@ nLin,106 SAY nCSE  PICTURE "@E 9999,999,999.99"
				@ nLin,122 SAY nPRE  PICTURE "@E 99,999,999.99"
			NEXT	
			nQTE:=nCSE:=nPRE:=0
			if nMov # codmov
				nLin++
				FOR I = 1 TO 2
					@ nLin,001 SAY "TOTAIS DO MOVIMENTO =======>"
					@ nLin,090 SAY nQTM  PICTURE "@E 9999,999.999"
					//@ nLin,106 SAY nCSM  PICTURE "@E 999,999,999.99"
					@ nLin,122 SAY nPRM  PICTURE "@E 99,999,999.99"
				NEXT	
				nQTM:=nCSM:=nPRM:=0
				lHeader := .T.
				If !lAllMov = .T.    // NAO SAO TODOS OS MOVIMENTOS
			   	Exit
				Endif
				NLIN++
				FOR i = 1 TO 2
					@ NlIN,01 SAY 'MOVIMENTO..: '+nMov+' = '+cTipoMovimento+' - LOJA..:'+;
				   TRANS((CECCMOV->CODLOJA),'9999')+' = '+(CECTLOJ->NOMLOJTL)
				NEXT	
			EndIf
		ENDIF*/
		//	
		IF nLin>59
			lHeader := .T.
		ENDIF			
	ENDDO	
	// Total geral
	//IF !lAllMov
			nLin++
			nLin++
			FOR I = 1 TO 2
				@ nLin,001 SAY "TOTAL GERAL DAS LOJAS ======>"
				@ nLin,090 SAY nQTER  PICTURE "@E 9999,999.999"
				//@ nLin,106 SAY nCSER  PICTURE "@E 9999,999,999.99"
				@ nLin,122 SAY nPRER  PICTURE "@E 99,999,999.99"
			NEXT	
			nQTER:=nCSER:=nPRER:=0
			nLin++
			FOR I = 1 TO 2
				@ nLin,001 SAY "TTL GERAL DE MOV. NAS LOJAS=>"
				@ nLin,090 SAY nQTMR  PICTURE "@E 9999,999.999"
				//@ nLin,106 SAY nCSMR  PICTURE "@E 9999,999,999.99"
				@ nLin,122 SAY nPRMR  PICTURE "@E 99,999,999.99"
			NEXT	
			nQTMR:=nCSMR:=nPRMR:=0
			*********** FAZERRRRRRRRRRRRRRRRRR ******************
			//nLin++
			//@ Nlin,1 say padc(" <RESUMO POR ORIGEM DO MOVIMENTO : "+STR(nMov,2)+ " ="+ALLTRIM("nNomeMov")+"> ",132,"*") 
      	//nLin++
			// Resumo da origem
 			/*for i=1 to 99
    			IF RESORI[i]#0 .OR. RESORIU[i]#0 
      			nlin++
	   			SIPTORI->(DBSEEK(I))
      			@ nlin,001 say "ORIGEM : "+alltrim(SIPTORI->DESC)+" --> "
					@ nlin,045 say RESORI[I]  PICTURE "@E 999,999,999,999.99"
					@ nlin,065 say " R$"
					@ nlin,075 say RESORIU[I]  PICTURE "@E 999,999,999,999.99"
					@ nlin,095 say "US$"
    			endif	  
 			NEXT
			AFILL(RESORI,0)
			AFILL(RESORIU,0)*/
		   nlin++
	//ENDIF
	//
	//If lAllMov = .T.
		nLin++
		nLin++
		FOR I = 1 TO 2
			@ nLin,001 SAY "TOTAL GERAL ==============>  "+STR(nItens,6)+" ITENS"
			@ nLin,090 SAY nTQO  PICTURE "@E 9999,999.999"
			//@ nLin,106 SAY nTCO  PICTURE "@E 9999,999,999.99"
			@ nLin,122 SAY nTPO  PICTURE "@E 99,999,999.99"
		NEXT	
		nLin++
	   // Resumo
		//nLin++
		//@ Nlin,1 say padc(" <RESUMO GERAL POR ORIGEM> ",132,"*") 
	   //nLin++
		// Resumo da origem
	 	/*for i=1 to 99
   		IF RESORIR[i]#0 .or. RESORIUR[i]#0
   			nlin++
				SIPTORI->(DBSEEK(I))
	   		@ nlin,001 say "ORIGEM : "+alltrim(SIPTORI->DESC)+" --> "
		   	@ nlin,045 say RESORIR[I]  PICTURE "@E 999,999,999,999.99"
				@ nlin,065 say " R$"
				@ nlin,075 say RESORIUR[I]  PICTURE "@E 999,999,999,999.99"
				@ nlin,095 say "US$"
			endif	  
		NEXT*/
	//Endif
	// Reinicializar variaveis
	// ***********************
	EJECT
	// Seta o v¡deo
	SET DEVICE TO SCREEN
	RESTSCREEN( 0,0,LASTROW(),LASTCOL(),cOldScreen )
ENDDO
