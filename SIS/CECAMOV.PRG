// Create date - 12/12/95
// An lise de Movimento (GERAL)
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
		nLoc,;
		nTiP,;
		nNomeMov,;
		tMov,;
		sOpSai 
		
LOCAL	nQTO:=;
		nCSO:=;
		nPRO:=;
		nQTE:=;
		nCSE:=;
		nPRE:=;
		nQTM:=;
		nCSM:=;
		nPRM:=;
		nTQO:=;
		nTCO:=;
		nTPO:=0
		
LOCAL lAllMov := .F.
LOCAL lImpMov := .F.
LOCAL lTotOri := .T.
LOCAL nItens  := 0		
// Inicializa vetores		
nLin     := 0
// Cria arquivos de ¡ndices caso n„o existam
// Verifica a existˆncia de ¡ndices, nao existindo cria-los 	
IF !ARQNTX("CECCMER",.F.) .OR. ;
	!ARQNTX("CECCMOV",.F.) .OR. ;
	!ARQNTX("CECCLOJ",.F.) .OR. ;
	!ARQNTX("CECCFOR",.F.) .OR. ;
	!ARQNTX("CECCCLI",.F.) .OR. ;
	!ARQNTX("CECTLOJ",.F.) 
	DBCLOSEALL()
	RETURN
ENDIF

// Seta as cores
cor        := Setcor()
nOldCursor := SETCURSOR(1)
cOldScreen := SAVESCREEN(0,0,LASTROW(),LASTCOL())
SetCor("B/W,W+/Bg,,,B/W")
DO WHILE .T.
	nQTO:=nCSO:=nPRO:=nQTE:=nCSE:=nPRE:=nQTM:=nCSM:=nPRM:=nTQO:=nTCO:=nTPO:=0
   lAllMov := .F.
   lImpMov := .F.
   tMov    := "EC"
	sOpSai := "N"
	fdDt1:=fdDt2:=CTOD("  /  /    ")
	cTelad := SAVESCREEN(16,12,24,76)
	Box(16,12,20,75,fr,127,03,08)
	@ 17,14 SAY "Tipo de Movimento.:" GET tMov  PICTURE "99" VALID(IF(!EMPTY(tMov),ChecaMov(tMov),"Movimento n„o Existe - F1 p/ Verificar...",))   //Todos()))
	@ 18,14 SAY "Data Inicial......:" GET fdDt1 PICTURE "@D"
	@ 19,14 SAY "Data Final........:" GET fdDt2 PICTURE "@D"  Valid(If(!Empty(fdDt1).and.!Empty(fdDt2),ValidaData(fdDt1,fdDt2),Todos()))
	READ
	IF LASTKEY() == 27
		RESTSCREEN( 0,0,LASTROW(),LASTCOL(),cOldScreen )
		SETCURSOR(nOldCursor)
		SetCor(cor)
		DBCLOSEALL()
		RETURN(NIL)
	ENDIF
	// Posiciona no 1o registro que contem o movimento solicitado
	SELECT ( "CECCMOV" )	
	//
	If tMov == "  "
	   lAllMov := .T.
	   DbGoTop()
	Else
	   nMov    := tMov     // Se nao informou o tipo de movimento lista todos
	   lAllMov := .F. 
		If !DbSeek(STR(tMov,2))
			M_Display("Codigo sem movimento, verifique!",79)
			RESTSCREEN(16,12,24,76,cTelad)			
			Loop
		Endif
	Endif
	// inicializa variavel de cabe‡alho com verdadeiro
	lHeader := .T.
	lTotOri := .T.
	// Inicializa numera‡„o de p gina
	nPage := 0
	// Seta impressora
	IF ! ( Impres() )
		LOOP
	ENDIF	
	//
	SET DEVICE TO PRINT
	@ PROW(),PCOL() SAY CHR(sEsc)
	M_Message("Aguarde! imprimindo An lise do movimento...",23)
	//
	DO WHILE !EOF() 
		IF INKEY()=27
			IF Para_Impressao()
				EXIT
			ENDIF
		ENDIF		
		IF !EMPTY(FdDT1) .AND. !EMPTY(FdDT2)    // GERAL - LISTA TODO O MOVIMENTO
		   IF  (DATAMOV > fdDt2) .OR. (DATAMOV < fdDt1) 
		   	DBSKIP()
		   	LOOP
		   ENDIF	
		ENDIF
		//
		nPar := MERCADORIA
		nOri := ORIGEM
		nTip := TIPOMOV
		nLoc := CODLOJA
		nMov := CODMOV
		//
		IF lHeader
		   lImpMov := .T.
			nPage ++
			vLen := "PAGINA :"+STRZERO(nPage,4)
		   vDat := "DATA :"+DTOC(DATE())
			vHor := "HORA :"+TIME() 
		   @ 01,001 SAY &sLog->l1
			@ 01,PCOL()+3 SAY sNom
			@ 01,133-LEN(vLen)  say vLen
			@ 02,001 SAY &sLog->l2
			@ 03,001 SAY &sLog->l3
			@ 03,133-len(VdAT) say vdat
			@ 04,001 SAY &sLog->l4
			@ 04,33 SAY CHR(27)+"W"+CHR(1)+"ANALISE DO MOVIMENTO DE ESTOQUE "+CHR(27)+"W"+CHR(0)
			@ 05,001 SAY &sLog->l5
			@ 05,133-LEN(vHor) SAY vHor
			@ PROW(),PCOL() SAY CHR(27)+CHR(50)
			@ 06,001 SAY REPL("-",132)
			@ 07,01 SAY "DATA---- No.DOC---- MERCADORIA---- DESCRICAO---------------------------------------- O QUANTIDADE LC CUSTO----R$---- PRECO----R$----"
			@ 08,01 SAY REPL("-",132)
			FOR i = 1 TO 2
				@ 09,01 SAY "MOVIMENTO>    >                           LOCAL>    >"
				SELECT("CECTLOJ")
				DBSEEK(nLoc)
				@ 09,49 SAY nLoc
				@ 09,54 SAY DSC
			NEXT	
			nLin    := 10
			lHeader := .F.
		ENDIF
		//
		SELECT ( "CECCMOV" )
		//
		nPar := CODIGOM
		nOri := ORIGM
		nTip := TIPOM
		nLoc := LOCALM
		nMov := CODMOVM
		//
		SELECT("CECCMER")
		DBSEEK(nPar)
		//
		SELECT ( "CECCMOV" )	
		//
		nQTO += QTDRE
		nPRO += PRECOMPRA
		nCSO += CUSTOMED
		nQTE += QTDRE
		nPRE += PRECOMPRA
		nCSE += CUSTOMOV
		nQTM += QTDRE
		nPRM += PRECOMPRA
		nCSM += CUSTOMOV
		nTQO += QTDRE
		nTPO += PRECOMPRA
		nTCO += PRECOMPRA
		nItens ++
		//	
		@ nLin,001 SAY DTOC(DATAMOV)
		@ nLin,010 SAY NUMDOCTO
		@ nLin,021 SAY MERCADORIA
		@ nLin,036 SAY CECCMER->DESCRIM
		@ nLin,086 SAY nOri      PICTURE "@B"
		@ nLin,088 SAY QUANTMOV  PICTURE "@E 99,999,999"
		@ nLin,099 SAY CODLOJA
		@ nLin,102 SAY CUSTOMOV  PICTURE "@E 9999,999,999.99" 
		@ nLin,118 SAY PRECOMPRA PICTURE IF(sOpSai="N","@E 9999,999,999.99","@!")
		// Resumo do custo
		//  R$
		// Proximo registro
		DBSKIP()
		nLin ++
		IF nLin > 59
			 lHeader := .T.
		ENDIF
		IF  nMov # codmov .AND. !EOF()   //.or. (lAllMov=.F. .and. fdDt2#ctod("  /  /    ") .and. datam > fdDt2)
			FOR I = 1 TO 2 
				@ nLin,001 SAY "TOTAIS DA ORIGEM ==>"
				@ nLin,086 SAY nQTO  PICTURE "@E 999,999,999"
				@ nLin,099 SAY nCSO  PICTURE "@E 999,999,999,999.99"
				@ nLin,115 SAY nPRO  PICTURE "@E 999,999,999,999.99"
			NEXT	
			nQTO:=nCSO:=nPRO:=0
			nLin++
			FOR I = 1 TO 2
				@ nLin,001 SAY "TOTAIS DO ESTOQUE ==>"
				@ nLin,086 SAY nQTE  PICTURE "@E 999,999,999"
				@ nLin,099 SAY nCSE  PICTURE "@E 999,999,999,999.99"
				@ nLin,115 SAY nPRE  PICTURE "@E 999,999,999,999.99"
			NEXT	
			nQTE:=nCSE:=nPRE:=0
			nLin++
			FOR I = 1 TO 2
				@ nLin,001 SAY "TOTAIS DO MOVIMENTO ==>"
				@ nLin,086 SAY nQTM  PICTURE "@E 999,999,999"
				@ nLin,099 SAY nCSM  PICTURE "@E 999,999,999,999.99"
				@ nLin,115 SAY nPRM  PICTURE "@E 999,999,999,999.99"
			NEXT	
			nQTM:=nCSM:=nPRM:=0
			nLin++
			@ Nlin,1 say padc(" <RESUMO POR ORIGEM DO MOVIMENTO : "+STR(nMov,2)+ " ="+ALLTRIM(nNomeMov)+"> ",132,"*") 
      	nLin++
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
 			NEXT*/
			//AFILL(RESORI,0)
			//AFILL(RESORIU,0)
		   nlin++
			// Quebar pagina
			lHeader := .T.
			If !lAllMov = .T.
		   	Exit
			Endif
		ENDIF
		//	
		IF (nLoc#LOCALM) .AND. !EOF() .and. nMov = CODMOVM
		   FOR I = 1 TO 2
				@ nLin,001 SAY "TOTAIS DA ORIGEM ==>"
				@ nLin,086 SAY nQTO  PICTURE "@E 999,999,999"
				@ nLin,099 SAY nCSO  PICTURE "@E 999,999,999,999.99"
				@ nLin,115 SAY nPRO  PICTURE "@E 999,999,999,999.99"
			NEXT	
			nQTO:=nCSO:=nPRO:=0
			nLin++
			FOR I = 1 TO 2
				@ nLin,001 SAY "TOTAIS DO ESTOQUE ==>"
				@ nLin,086 SAY nQTE  PICTURE "@E 999,999,999"
				@ nLin,099 SAY nCSE  PICTURE "@E 999,999,999,999.99"
				@ nLin,115 SAY nPRE  PICTURE "@E 999,999,999,999.99"
			NEXT	
			nQTE:=nCSE:=nPRE:=0
			nLin++
			//
			nLoc := LOCALM
			nMov := CODMOVM
			FOR I = 1 TO 2
				@ nLin,01 SAY "MOVIMENTO>    >                           LOCAL>    >"
				SELECT("CECTLOJ")
				DBSEEK( nLoc )
				@ nLin,49 SAY nLoc
				@ nLin,54 SAY DSC
			NEXT	
			//
			SELECT ( "CECCMOV" )
			nLin++
		ENDIF
		IF nOri # origem .AND. nLoc = localm .AND. nMov = codmovm .AND. !eof() .and. lTotOri = .T.
		   FOR I = 1 TO 2
				@ nLin,001 SAY "TOTAIS DA ORIGEM ==>"
				@ nLin,086 SAY nQTO  PICTURE "@E 999,999,999"
				@ nLin,099 SAY nCSO  PICTURE "@E 999,999,999,999.99"
				@ nLin,115 SAY nPRO PICTURE "@E 999,999,999,999.99"
			NEXT	
			nQTO:=nCSO:=nPRO:=0
			nLin++
		ENDIF
		IF nLin>59
			lHeader := .T.
		ENDIF			
	ENDDO	
	// Total geral
	IF !lAllMov
			FOR I = 1 TO 2 
				@ nLin,001 SAY "TOTAIS DA ORIGEM ==>"
				@ nLin,086 SAY nQTO  PICTURE "@E 999,999,999"
				@ nLin,099 SAY nCSO  PICTURE "@E 999,999,999,999.99"
				@ nLin,115 SAY nPRO  PICTURE "@E 999,999,999,999.99"
			NEXT	
			nQTO:=nCSO:=nPRO:=0
			nLin++
			FOR I = 1 TO 2
				@ nLin,001 SAY "TOTAIS DO ESTOQUE ==>"
				@ nLin,086 SAY nQTE  PICTURE "@E 999,999,999"
				@ nLin,099 SAY nCSE  PICTURE "@E 999,999,999,999.99"
				@ nLin,115 SAY nPRE  PICTURE "@E 999,999,999,999.99"
			NEXT	
			nQTE:=nCSE:=nPRE:=0
			nLin++
			FOR I = 1 TO 2
				@ nLin,001 SAY "TOTAIS DO MOVIMENTO ==>"
				@ nLin,086 SAY nQTM  PICTURE "@E 999,999,999"
				@ nLin,099 SAY nCSM  PICTURE "@E 999,999,999,999.99"
				@ nLin,115 SAY nPRM  PICTURE "@E 999,999,999,999.99"
			NEXT	
			nQTM:=nCSM:=nPRM:=0
			nLin++
			@ Nlin,1 say padc(" <RESUMO POR ORIGEM DO MOVIMENTO : "+STR(nMov,2)+ " ="+ALLTRIM("nNomeMov")+"> ",132,"*") 
      	nLin++
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
	ENDIF
	//
	If lAllMov = .T.
		nLin++
		FOR I = 1 TO 2
			@ nLin,001 SAY "TOTAL GERAL ==> "+STR(nItens,6)+" ITENS"
			@ nLin,086 SAY nTQO  PICTURE "@E 999,999,999"
			@ nLin,099 SAY nTCO  PICTURE "@E 999,999,999,999.99"
			@ nLin,115 SAY nTPO  PICTURE "@E 999,999,999,999.99"
		NEXT	
		nLin++
	   // Resumo
		nLin++
		@ Nlin,1 say padc(" <RESUMO GERAL POR ORIGEM> ",132,"*") 
	   nLin++
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
	Endif
	// Reinicializar variaveis
	// ***********************
	/*AFILL(RESORI,0)	
	AFILL(RESORIU,0)
	AFILL(RESORIR,0)
	AFILL(RESORIUR,0)
   /* 
	EJECT
	// Seta o v¡deo
	SET DEVICE TO SCREEN
	RESTSCREEN( 0,0,LASTROW(),LASTCOL(),cOldScreen )
ENDDO

FUNCTION ChecaMov(tMov)
	Do Case
		Case tMov == "EC"
			@ row(),col()+2 say "Entrada por Compra Fiscal             "
			Return( .t. ) 
		Case tMov == "DC"
			@ row(),col()+2 say "Devolucao de Compra Fiscal           "
			Return( .t. ) 
		Case tMov == "CP"
			@ row(),col()+2 say "Complemento de Preco - Entra so Valor"
			Return( .t. ) 
		Case tMov == "VE"
			@ row(),col()+2 say "Saida por Venda Fiscal               "
			Return( .t. ) 
	   Case tMov == "DV"
			@ row(),col()+2 say "Devolucao de Saida Fiscal            "
			Return( .t. ) 
		Case tMov == "TR"
			@ row(),col()+2 say "Transferencias - Movimentos Internos "
			Return( .t. ) 
		Case tMov == "TT"
			@ row(),col()+2 say "Lista Todos os Movimentos            "
			Return( .t. ) 
		Otherwase
			Return( .F. ) 
	EndCase