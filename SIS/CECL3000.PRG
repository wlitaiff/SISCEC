// Sistemas de Controle de Estoque Comercial - Modulo de Livro Fiscal
// W&R Informatica Ltda
// 29 de Agosto de 1996
// Waldemir Litaiff Vasconcelos
// Livro Fiscal de Saidas - ( CecCfis )

Local cTela     := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
		cCor      := SETCOLOR(),;
		nCursor   := SETCURSOR(),;
		lCabec    := .F.,;
		lBuffree  := "",;
		lHavPrint := .F.
		
LOCAL dDat_Inicio,;
		dDat_Final,;
		dMes_Periodo,;
		cCgc_Firma,;
		cNome_Firma,;
		cInsEst_Firma,;
		nCod_Tri,;
		nDiaDocto,;
		nFolha,;
		nLinha,;
		nColuna,;
		nTotBaseca,;
		nTotImpost,;
		nTotIsento,;
		nTotOutros,;
		nVlContabil,;
		nVlBaseCalc,;
		nVlImpostoD,;
		cNumDocto,;
		cSerieSub,;
		nAliquota,;
		dDadosSaida,;
		dNotasCanc_

// Verificando arquivos
IF !ARQNTX("CECCFIS",.F.) .OR.;
	!ARQNTX("CECCSET",.F.) .OR.;
	!ARQNTX("CECCCLI",.F.) .OR.; 
	!ARQNTX("CECCFOR",.F.) 
	DBCLOSEALL()
	RETURN
ENDIF	

// Dados da Empresa
cNome_Firma  := Criptografa ( CECCSET -> NOMEMPS, "HAWK", .F. ) // Nome da empresa
cCgc_Firma   := Criptografa ( CECCSET -> NUMCGCS, "HAWK", .F. ) // CGC
cInsEst_Firma:= Criptografa ( CECCSET -> INSESTS, "HAWK", .F. ) // Inscricao estadual
//
SELECT("CECCFIS")
//
lCabec     := .T.
lBuffree   := ""
lHavPrint  := .F.
nFolha     :=  0
nLinha     := 14       // Ref. a Ultima linha do cabec.
nColuna    := 116      // 1. Posicao
dMesPeriodo:= Date()
dDat_Inicio:= Date()
dDat_Final := CtoD('  /  /    ')
DbSetOrder(4)
DO WHILE .T.
	Box(16,06,19,75,fr,127,3,8)
	SETCURSOR(1)
	// ReInicializar Var_Mem.
	dDadosSaida:= {}
	dNotasCanc_:= {}
	nTotBaseca := nTotImpost:=nTotIsento:=nTotOutros:=0
	nDiaDocto  := 0
	nVlContabil:= 0
	nVlBaseCalc:= 0
	nVlImpostoD:= 0
	cUltDocto  := 0
	cPriDocto  := 0
	nAliquota  := 0
	cSerieSub  := ""
	dDat_Final := CtoD('  /  /    ')
	lCabec     := .T.
	//
	@ 17,08 SAY "Mes Inicial:" GET dDat_Inicio PICTURE "@D"
	@ 18,08 SAY "Mes Final..:" GET dDat_Final  VALID If(!EMPTY(dDat_Final),(dDat_final>=dDat_Inicio),.T.)
	Read
	IF LASTKEY()==27
		RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
		SETCURSOR(nCursor)
		SETCOLOR(cCor)
		DBCLOSEALL()
		RETURN(NIL)
	ENDIF
	//
	dbgotop()
	IF !EMPTY(dDat_Inicio)
		DBSEEK(dDat_Inicio,.T.)
	ENDIF
	IF !EMPTY(dDat_Final)
		IF CECCFIS->DSAI>dDat_Final .OR. CECCFIS->(EOF())
			M_DISPLAY("Per¡odo sem Lan‡amento",79)
			Loop
		ENDIF
	ENDIF		
	IF !IMPRES()
		LOOP
	ENDIF
	//			
	XTOTIMPOST := 0
	nDiaDocto  := Day(DSAI)
	cPriDocto  := NNOTA
	dNotasCanc_:= {}
	nfontet := 0
	cTelao     := SAVESCREEN(0,0,MAXROW(),MAXCOL())
	//
	M_MESSAGE("Listando Registro de Saida, Aguarde!",23)
	SET DEVICE TO PRINT
	SET CENTURY OFF
	@ prow(),pcol() say CHR(sEsc)
	xtotalx := 0
	//
	Do While If(!EMPTY(DSAI),(DSAI<=dDat_Final),.T.) .and. !eof()
		if codtri>4
			DBSKIP()
			LOOP
		ENDIF	
		//
		If lCabec
			nFolha++
			Caceb_Saida(cNome_Firma,cCgc_Firma,cInsEst_Firma,nFolha,dDat_Inicio,dDat_Final)
			lCabec := .F.
		EndIf
		// Processo
		lHavPrint := .T.
		nDiaDocto := Day(DSAI)
		cSerieSub2 := serie+strzero(subser,2)
		cPriDocto := Alltrim(str(Int(Val(NNOTA))))
		cSerieSub  := SERIE+"/"+STRZERO(SUBSER,2)
		cCfo       := CFO
		nAliquota  := ALIICMS
		nVlContabil:= 0
		nVlBaseCalc:= 0
		nVlImpostoD:= 0
		nFonte := 0
		CECCCLI->( DbSeek(CECCFIS->CLI_FOR) )
		// Detalhe
		NULTNOTA:=NNOTA
		Do While nDiaDocto==Day(DSAI) .and. cSerieSub2==serie+strzero(subser,2) .and. CCFO==CFO .AND. !eof() .AND. (VAL(NNOTA)==VAL(nULTNOTA)+1 .OR. VAL(NNOTA)==VAL(nULTNOTA))
			If (CECCFIS->CANCELADA) 
				AADD(dNotasCanc_,Alltrim(STR(INT(Val(NNOTA)))))
				nULTNOTA:=NNOTA
				cUltDocto  := Alltrim(str(Int(Val(NNOTA))))
			Else
				nVlContabil+= BASICMS
				nVlBaseCalc+= BASICMS
				nVlImpostoD+= VLICMS
				nTotBaseca += BASICMS
				nTotImpost += VLICMS
				nFonte += icmsfonte
				nTotIsento += 0
				nTotOutros += 0
				cUltDocto  := Alltrim(str(Int(Val(NNOTA))))
				nULTNOTA:=NNOTA
			EndIf
			DBSKIP()
		EndDo			
		//		
		nLInha ++
		// Imprimir
		@ nLinha,001 Say "|"
		@ nLinha,002 Say "NF"
		@ nLinha,004 say "|"
		@ nLinha,005 Say cSerieSub
		@ nLinha,010 Say "|"	
		@ nLinha,011 Say IF(cPriDocto#cUltDocto,cPriDocto+"-"+cUltDocto,cPriDocto)
		@ nLinha,022 Say "|"
		@ nLinha,023 Say nDiaDocto pict "99"
		@ nLinha,025 say "|"
		@ nLinha,026 Say nVLcontabil pict "@R@E 999,999.99"
		@ nLinha,036 say "|"
		@ nLinha,043 Say "|"
		@ nLinha,044 Say cCfo pict "@!"
		@ nLinha,050 Say "|"
		@ nLinha,051 Say nVlBaseCalc pict "@R@E 999,999.99"
		@ nLinha,061 Say "|"
		@ nLinha,062 Say nAliquota   pict "@R@E 99.99"
		@ nLinha,067 SAY "|"
		XXICMS := ROUND(NVLBASECALC * (NALIQUOTA/100),2)
		xtotalx += nvlcontabil
		XTOTIMPOST += XXICMS
		@ nLinha,068 Say XXICMS pict "@R@E 9,999.99"
		//nVlImpostoD 
		@ nLinha,076 Say "|"
		@ nLinha,077 Say ""
		@ nLinha,89 Say "|"
		@ nLinha,90 Say nFonte picture "9999,999.99"
		@ nLinha,101 Say "|"
		nFonteT += nFonte
		nColuna := 102
		for nIndice := 1 to Len(dNotasCanc_)
			@ nLinha,nColuna Say dNotasCanc_[nIndice]+if(nIndice#len(dnotascanc_),","," ")
			nColuna += Len(dNotasCanc_[nIndice]) + 1
		Next
		if len(dNotasCanc_)>0
			@ nLinha,nColuna say "CANC"
		ENDIF	
		DNOTASCANC_:={}
		@ nLinha,132 say "|"
		// Totalizador
		// Controle de Pagina
		If nLinha=60 
			@ nLinha+1,001 say Repl("=",132)	
			@ nLinha+2,001 say lBuffree
			lCabec:=.T.
			nLInha:=14
		EndIf
	EndDo
	nLinha++
	@ nLinha,001 Say REPL("-",132)
	FOR X:=1 TO 2
		@ nLinha+1,001 Say "TOTAIS ===>>>"
		@ nLinha+1,026 say xTotalx PICTURE "@R@E 999,999.99"
		@ nLinha+1,051 say nTotBaseCa  pict "@R@E 999,999.99"
		@ nLinha+1,066 say XTotImpost  pict "@R@E 999,999.99"
		@ nLinha+1,090 say nFonteT  PICT "@r@e 9999,999.99"
	NEXT	
	@ nLinha+2,001 say Repl("=",132)
	@ nLinha+3,001 say lBuffree
	//
	SET DEVICE TO SCREEN
	RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
	//
EndDo
RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
SETCURSOR(nCursor)
SETCOLOR(cCor)
SET CENTURY ON
DBCLOSEALL()
RETURN(NIL)		
	
// Funcoes 

Function Caceb_Saida(cFirma,cCgc,cInsEst,nFolha,dDat_Inicio,dDat_final)
// Cabe‡alho do Livro de Entrada
@ 01,001 Say "------------------------------------------------------------------------------------------------------------------------------------" 
@ 02,001 Say "|                                                     REGISTRO DE SAIDAS                                                           |"
@ 03,001 Say "| FIRMA.....:"+cFirma
@ 03,132 Say "|"
@ 04,001 Say "| INSC. EST.:"+cInsEst+Space(06)+"CGC(MF).:"+cCgc
@ 04,132 SAY "|"
@ 05,001 Say "| FOLHA.....:"+Trans(nFolha,'@E@R 999,999')+Space(19)+"MES OU PERIODO/ANO.:"+DispMonth(dDat_Inicio)+"/"+Trans(year(dDat_Inicio),'@E@R 9,999')
@ 05,001 Say "|"+space(76)+If(Month(dDat_Final)>Month(dDat_Inicio)," A"+DispMonth(dDat_Final)+"/"+Trans(year(dDat_Final),'@E@R 9,999'),"")
@ 05,132 Say "|"
@ 06,001 Say "|----------------------------------------------------------------------------------------------------------------------------------|"
@ 07,001 Say "|                       |          |             |    I.C.M.S  -  V A L O R E S   F I S C A I S     |                              |"
@ 08,001 Say "|  DOCUMENTOS  FISCAIS  |          | CODIFICACAO |--------------------------------------------------|          OBSERVACOES         |"
@ 09,001 Say "|                       |  VALOR   |             |OPER. C/ DEB. DO IMPOSTO |OPER. S/ DEB. DO IMPOSTO|                              |"
@ 10,001 Say "|-----------------------|          |-------------|-------------------------|------------------------|------------------------------|"
@ 11,001 Say "|  |SERIE|           |D |          |      |      |  BASE    |     |IMPOSTO |  ISENTOS   |  ICM NA   |                              |"
@ 12,001 Say "|ES| SUB |  NUMEROS  |I | CONTABIL |CONTAB|FISCAL|   DE     |ALIQ.|        |  OU  NAO   |           |                              |"
@ 13,001 Say "|  |SERIE|           |A |          |      |      | CALCULO  |  %  |DEBITADO| TRIBUTADAS |   FONTE   |                              |"
@ 14,001 Say "|--|-----|-----------|--|----------|------|------|----------|-----|--------|------------|-----------|------------------------------|"
Return(Nil)