// Sistemas de Controle de Estoque Comercial - Modulo de Livro Fiscal
// W&R Informatica Ltda
// 03 de Setembro de 1996
// Waldemir Litaiff Vasconcelos (WLV)
// Apura‡Æo do ICMS - Entrada e Saidas - ( CecCfis )

LOCAL cTela     := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
		cCor      := SETCOLOR(),;
		nCursor   := SETCURSOR(),;
		lCabec    := .F.,;
		lBuffree  := "",;
		lHavPrint := .F.
		
LOCAL dMes_Periodo,;
		cCgc_Firma,;
		cNome_Firma,;
		cInsEst_Firma,;
		cCodCfo,;
		nDiaDocto,;
		nFolha,;
		nColuna 		// Controle do Relatorio (Cabe‡alho, linha, coluna, dados da empresa)

LOCAL nVlrFContabil,;
		nVlrFBaseCalc,;
		nVlrFImpostoD,;
		nVlrFIsento,;
		nVlrFOutros			        // Totais por Opera‡Æo Fiscal
		
LOCAL	nSubTContabil[3],;
		nSubTBaseCalc[3],;
		nSubTImpostoD[3],;
		nSubTIsento[3],;
		nSubTFOutros[3],;          // Sub-Totais por estados das Oper‡äes Fiscais
		aOtherCreditos[3]
LOCAL	nTotGContabil,;
		nTotGBaseCalc,;
		nTotgImpostoD,;
		nTotGIsento,;
		nTotGOutros              // Totais Geral das Opera‡eos (da Apura‡Æo)
		
PUBLIC nLinha
		
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
nLinha     := 13       // Ref. a Ultima linha do cabec.
nColuna    := 116      // 1. Posicao
dMesPeriodo:= Date()
dDat_Inicio:= Date()
dDat_Final := CtoD('  /  /    ')
DbSetOrder(5)
DO WHILE .T.
	Box(16,06,19,75,fr,127,3,8)
	SETCURSOR(1)
	// ReInicializar Var_Mem.
	nDiaDocto  := 0
	cCodCfo    := SPACE(05)
	//
	nVlrFContabil := 0
	nVlrFBaseCalc := 0
	nVlrFImpostoD := 0
	nVlrFIsento   := 0
	nVlrFOutros   := 0
	//
	AFILL(nSubTContabil,0)
	AFILL(nSubTBaseCalc,0)
	AFILL(nSubTImpostoD,0)
	AFILL(nSubTIsento,0)
	AFILL(nSubTFOutros,0)
	AFILL(aOtherCreditos,0)
	//
	nTotGContabil := 0
	nTotGBaseCalc := 0
	nTotgImpostoD := 0
	nTotGIsento   := 0
	nTotGOutros   := 0 
	nOtherCreditos := 0
	//	
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
	IF !IMPRES()
		LOOP
	ENDIF
	//			
	dbgotop()
	nDiaDocto  := Day(DSAI)
	cTelao     := SAVESCREEN(0,0,MAXROW(),MAXCOL())
	//
	M_MESSAGE("Listando Apura‡Æo do I.C.M.S, Aguarde!",23)
	SET DEVICE TO PRINT
	SET CENTURY OFF
	@ prow(),pcol() say CHR(sEsc)
	//
	NfOLHA := 1
	_Cabec(cNome_Firma,cCgc_Firma,cInsEst_Firma,nFolha,dDat_Inicio,dDat_Final)
	LCABEC := .T.
	Do While Val(CFO) < 400 .AND. !EOF()
		IF !EMPTY(DDAT_FINAL)
			IF DATAS>DDAT_FINAL
				DBSKIP()
				LOOP
			ENDIF	
		ENDIF	
		
		IF !EMPTY(DDAT_INICIO)
			IF DATAS<DDAT_INICIO
				DBSKIP()
				LOOP
			ENDIF
		ENDIF		
		
		//
		If lCabec
			Caceb_AEntra(cNome_Firma,cCgc_Firma,cInsEst_Firma,nFolha,dDat_Inicio,dDat_Final)
			lCabec := .F.
		EndIf
		// Processo
		lHavPrint := .T.
		nDiaDocto := Day(DENT)
		cCodCfo   := CFO
		xalix := aliicms
		If Val(cCodCfo) < 200
			nIndFis   := 1      // do Estado
		ElseIf Val(cCodCfo) < 300
			nIndFis   := 2      // de outros estados
		Else 
			nIndFis   := 3		  // do exterior
		EndIF
		//
		// Detalhes
		nVlrFContabil := 0
		nVlrFBaseCalc := 0
		nVlrFImpostoD := 0
		nVlrFIsento   := 0
		nVlrFOutros   := 0
		nOtherCreditos := 0
		Do While cCodCfo==CFO .AND. !EOF()
			IF !EMPTY(DDAT_FINAL)
				IF DATAS>DDAT_FINAL
					DBSKIP()
					LOOP
				ENDIF	
			ENDIF	
		
			IF !EMPTY(DDAT_INICIO)
				IF DATAS<DDAT_INICIO
					DBSKIP()
					LOOP
				ENDIF
			ENDIF	
			
			If !(CECCFIS->CANCELADA) 
				if codtri=5
					aOtherCreditos[nIndFis] += VLNOT
					nOtherCreditos+=VLNOT
					dbskip()
					loop
				endif	
				if codtri=6
					dbskip()
					loop
				endif		
				nVlrFContabil += BASICMS
				nVlrFBaseCalc += BASICMS
				nVlrFImpostoD += VLICMS
				nVlrFIsento   := 0
				nVlrFOutros   += ICMSFONTE
				//	
				nSubTContabil[nIndFis] += BASICMS
				nSubTBaseCalc[nIndFis] += BASICMS
				
				nSubTIsento[nIndFis]  := 0
				nSubTFOutros[nIndFis]  += ICMSFONTE
				//
				nTotGContabil += BASICMS
				nTotGBaseCalc += BASICMS
				nTotgImpostoD += VLICMS
				nTotGIsento   := 0
				nTotGOutros   += ICMSFONTE
			EndIf
			xalix := aliicms
			DBSKIP()
		EndDo			
		//		
		nLInha ++
		// Imprimir
		@ nLinha,001 Say "|"
		@ nLinha,010 Say "|"
		@ nLinha,012 Say cCodCfo pict "@R 9.99"
		@ nLinha,017 Say "|"	
		@ nLinha,018 Say nVlrFContabil pict "@R@E 9,999,999.99"
		@ nLinha,030 say "|"
		@ nLinha,031 Say nVlrFBaseCalc pict "@R@E 99,999,999,999.99"
		@ nLinha,048 Say "|"
		nvlrfimpostod := round(nvlrfbasecalc * (xalix/100),2)
		@ nLinha,051 Say nVlrFImpostoD pict "@R@E 99,999,999,999.99"
		@ nLinha,068 Say "|"
		@ nLinha,079 Say nVlrFIsento pict "@R@E 99,999,999,999.99"
		@ nLinha,96 SAY "|"
		@ nLinha,97 Say nVlrFOutros pict "@R@E 999,999,999.99"
		nSubTImpostoD[nIndFis] += nvlrfimpostod
		@ nLinha,111 say "|"
		@ nLinha,118 Say nOtherCreditos pict "@R@E 999,999,999.99"
		@ nLinha,132 say "|"
		
		// Totalizador
		// Controle de Pagina
		If nLinha=58 
			@ nLinha+1,001 say Repl("=",132)	
			@ nLinha+2,001 say lBuffree
			lCabec:=.T.
			nFolha++
			_Cabec(cNome_Firma,cCgc_Firma,cInsEst_Firma,nFolha,dDat_Inicio,dDat_Final)
		EndIf
	EndDo
	nLinha++
	@ nLinha,001 Say repl("-",132)
	nLinha++
	@ nLinha,001 Say "| SUBTOTAIS ENTRADAS                                                                                                               |"
	nLinha++
	@ nLinha,001 Say repl("-",132)
	nLinha++
	@ nLinha,001 Say "|1.00 DO ESTADO |            |                 |                   |                           |              |                    |"
	@ nLinha,018 Say nSubTContabil[1]  pict "@R@E 9,999,999.99"
	@ nLinha,031 Say nSubTBaseCalc[1]  pict "@R@E 99,999,999,999.99"
	@ nLinha,051 Say nSubTImpostoD[1]  pict "@R@E 99,999,999,999.99"
	@ nLinha,097 Say nSubTFOutros[1]  pict "@R@E 999,999,999.99"
	@ nLinha,118 Say aOtherCreditos[1] pict "@R@E 999,999,999.99"
	//
	nLinha++
	@ nLinha,001 Say "|2.00 DE OUTROS |            |                 |                   |                           |              |                    |"
	nLinha++
	@ nLinha,001 Say "|     ESTADOS   |            |                 |                   |                           |              |                    |"
	@ nLinha,018 Say nSubTContabil[2]  pict "@R@E 9,999,999.99"
	@ nLinha,031 Say nSubTBaseCalc[2]  pict "@R@E 99,999,999,999.99"
	@ nLinha,051 Say nSubTImpostoD[2]  pict "@R@E 99,999,999,999.99"
	@ nLinha,097 Say nSubTFOutros[2]  pict "@R@E 999,999,999.99"
	@ nLinha,118 Say aOtherCreditos[2] pict "@R@E 999,999,999.99"
	//
	nLinha++
	@ nLinha,001 Say "|3.00 DO EXTE-  |            |                 |                   |                           |              |                    |"
	nLinha++
	@ nLinha,001 Say "|     RIOR      |            |                 |                   |                           |              |                    |"
	@ nLinha,018 Say nSubTContabil[3]  pict "@R@E 9,999,999.99"
	@ nLinha,031 Say nSubTBaseCalc[3]  pict "@R@E 99,999,999,999.99"
	@ nLinha,051 Say nSubTImpostoD[3]  pict "@R@E 99,999,999,999.99"
	@ nLinha,097 Say nSubTFOutros[3]  pict "@R@E 999,999,999.99"
	@ nLinha,118 Say aOtherCreditos[3] pict "@R@E 999,999,999.99"
	//
	nLinha++
	@ nLinha,001 Say REPL("-",132)
	nLinha++
	@ nLinha,001 Say "|   TOTAIS      |            |                 |                   |                           |              |                    |"
	@ nLinha,018 Say nTotGContabil  pict "@R@E 9,999,999.99"
	@ nLinha,031 Say nTotGBaseCalc  pict "@R@E 99,999,999,999.99"
	nTotGImpostoD := nsubtimpostod[1] + nsubtimpostod[2] + nsubtimpostod[3]
	@ nLinha,051 Say nTotGImpostoD  pict "@R@E 99,999,999,999.99"
	@ nLinha,097 Say nTotGOutros  pict "@R@E 999,999,999.99"
	@ nLinha,118 Say aOtherCreditos[1]+aOtherCreditos[2]+aOtherCreditos[3] pict "@R@E 999,999,999.99"
	//
	xTotalzao := nTotGImpostoD + aOtherCreditos[1]+aOtherCreditos[2]+aOtherCreditos[3]
	@ nLinha+1,001 say Repl("=",132)
	// Procedimento para  S A I D A S
	Apura_Saida(xTotalzao)
	@ nLinha+2,001 say lBuffree
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

Function Caceb_AEntra(cFirma,cCgc,cInsEst,nFolha,dDat_Inicio,dDat_final)
// Cabe‡alho do Livro de Entrada
@ 07,001 Say "-------------------------------------------------------E N T R A D A S--------------------------------------------------------------"
@ 08,001 Say "|  CODIFICACAO  |            |                                       ICMS-VALORES FISCAIS                                          |"
@ 09,001 Say "|---------------|  VALORES   |-----------------------------------------------------------------------------------------------------|"
@ 10,001 Say "|        |      |            | OPERACOES COM CREDITO DO IMPOSTO    |OPERACOES SEM CREDITO DE IMPOSTO          |       OUTROS       |"
@ 11,001 Say "|CONTABIL|FISCAL| CONTABEIS  |-------------------------------------|------------------------------------------|                    |"
@ 12,001 Say "|        |      |            | BASE DE CALCULO | IMPOSTO CREDITADO | ISENTAS OU NAO TRIBUTADAS | ICM NA FONTE |      CREDITOS      |"
@ 13,001 Say "|--------|------|------------|-----------------|-------------------|---------------------------|--------------|--------------------|"
Return(Nil)


Function _Cabec(cFirma,cCgc,cInsEst,nFolha,dDat_Inicio,dDat_final)
// Cabe‡alho do Livro de Entrada
@ 01,001 Say "------------------------------------------------------------------------------------------------------------------------------------" 
@ 02,001 Say "|                                               REGISTRO DE APURACAO DO I.C.M.S                                                    |"
@ 03,001 Say "| FIRMA.....:"+cFirma
@ 03,132 Say "|"
@ 04,001 Say "| INSC. EST.:"+cInsEst+Space(06)+"CGC(MF).:"+Trans(cCgc,'@R 99.999.999/9999-99')
@ 04,132 SAY "|"
@ 05,001 Say "| FOLHA.....:"+Trans(nFolha,'@E@R 999,999')+Space(19)+"MES OU PERIODO/ANO.:"+DispMonth(dDat_Inicio)+"/"+Trans(year(dDat_Inicio),'@E@R 9,999')
@ 05,001 Say "|"+space(76)+If(Month(dDat_Final)>Month(dDat_Inicio)," A  "+DispMonth(dDat_Final)+"/"+Trans(year(dDat_Final),'@E@R 9,999'),"")
@ 05,132 Say "|"
@ 06,001 Say "------------------------------------------------------------------------------------------------------------------------------------"
Return(Nil)

Function Apura_Saida(nTotE)
	LOCAL _nVlrFContabil,;
			_nVlrFBaseCalc,;
			_nVlrFImpostoD,;
			_nVlrFIsento,;
			_nVlrFOutros        // Totais por Opera‡Æo Fiscal
		
LOCAL	_nSubTContabil[3],;
		_nSubTBaseCalc[3],;
		_nSubTImpostoD[3],;
		_nSubTIsento[3],;
		_nSubTFOutros[3],;
		_aOtherDebitos[3]      // Sub-Totais por estados das Oper‡äes Fiscais
	
LOCAL	_nTotGContabil,;
		_nTotGBaseCalc,;
		_nTotgImpostoD,;
		_nTotGIsento,;
		_nTotGOutros       // Totais Geral das Opera‡eos (da Apura‡Æo)

	
	//
	_nVlrFContabil := 0
	_nVlrFBaseCalc := 0
	_nVlrFImpostoD := 0
	_nVlrFIsento   := 0
	_nVlrFOutros   := 0
	_nOtherDebitos := 0
	//
	AFILL(_nSubTContabil,0)
	AFILL(_nSubTBaseCalc,0)
	AFILL(_nSubTImpostoD,0)
	AFILL(_nSubTIsento,0)
	AFILL(_nSubTFOutros,0)
	AFILL(_aOtherDebitos,0)
	//
	_nTotGContabil := 0
	_nTotGBaseCalc := 0
	_nTotgImpostoD := 0
	_nTotGIsento   := 0
	_nTotGOutros   := 0 
	//
	DbSeek("500  ",.T.)
	nLInha ++
	nLinha ++
	@ nLinha,001 Say "---------------------------------------------------------S A I D A S----------------------------------------------------------------"
	nLinha ++
	@ nLinha,001 Say "|  CODIFICACAO  |            |                                       ICMS-VALORES FISCAIS                                          |"
	nLinha ++
	@ nLinha,001 Say "|---------------|  VALORES   |-----------------------------------------------------------------------------------------------------|"
	nLinha ++
	@ nLinha,001 Say "|        |      |            | OPERACOES COM DEBITO DO IMPOSTO     |OPERACOES SEM DEBITO DE IMPOSTO           |      OUTROS        |"
	nLinha ++
	@ nLinha,001 Say "|CONTABIL|FISCAL| CONTABEIS  |-------------------------------------|------------------------------------------|                    |" 
	NLinha ++
	@ nLinha,001 Say "|        |      |            | BASE DE CALCULO | IMPOSTO DEBITADO  | ISENTAS OU NAO TRIBUTADAS | ICM NA FONTE |      DEBITOS       |"
	nLinha ++
	@ nLinha,001 Say "|--------|------|------------|-----------------|-------------------|---------------------------|--------------|--------------------|"
	//
	Do While Val(CFO) > 499 .AND. Val(CFO) < 800 .AND. !EOF()
		IF !EMPTY(DDAT_FINAL)
			IF DATAS>DDAT_FINAL
				DBSKIP()
				LOOP
			ENDIF	
		ENDIF	
		
		IF !EMPTY(DDAT_INICIO)
			IF DATAS<DDAT_INICIO
				DBSKIP()
				LOOP
			ENDIF
		ENDIF		
		// Processo
		lHavPrint := .T.
		cCodCfo   := CFO
		xalix := aliicms
		If Val(cCodCfo) < 600
			nIndFis   := 1      // do Estado
		ElseIf Val(cCodCfo) < 700
			nIndFis   := 2      // de outros estados
		Else 
			nIndFis   := 3		  // do exterior
		EndIF
		//
		// Detalhes
		Do While cCodCfo==CFO .AND. !EOF()
			IF !EMPTY(DDAT_FINAL)
			IF DATAS>DDAT_FINAL
				DBSKIP()
				LOOP
			ENDIF	
		ENDIF	
		
		IF !EMPTY(DDAT_INICIO)
			IF DATAS<DDAT_INICIO
				DBSKIP()
				LOOP
			ENDIF
		ENDIF		
			If !(CECCFIS->CANCELADA) 
				if codtri=6
					_aOtherDebitos[nIndFis]+=VLNOT
					_nOtherDebitos += VLNOT
					DBSKIP()
					LOOP
				ENDIF	
				if codtri=5
					dbskip()
					loop
				endif	
				_nVlrFContabil += BASICMS
				_nVlrFBaseCalc += BASICMS
				_nVlrFImpostoD += VLICMS
				_nVlrFIsento   := 0
				_nVlrFOutros   += icmsfonte
				
				//	
				_nSubTContabil[nIndFis] += BASICMS
				_nSubTBaseCalc[nIndFis] += BASICMS
				_nSubTIsento[nIndFis]   := 0
				_nSubTFOutros[nIndFis]  += icmsfonte
				//
				_nTotGContabil += BASICMS
				_nTotGBaseCalc += BASICMS
				_nTotgImpostoD += VLICMS
				_nTotGIsento   := 0
				_nTotGOutros   += icmsfonte
			EndIf
			xalix := aliicms
			DBSKIP()
		EndDo			
		//		
		// Imprimir
		nLInha++
		@ nLinha,001 Say "|"
		@ nLinha,010 Say "|"
		@ nLinha,012 Say cCodCfo pict "@R 9.99"
		@ nLinha,017 Say "|"	
		@ nLinha,018 Say _nVlrFContabil pict "@R@E 9,999,999.99"
		@ nLinha,030 say "|"
		@ nLinha,031 Say _nVlrFBaseCalc pict "@R@E 99,999,999,999.99"
		@ nLinha,048 Say "|"
		_nvlrfimpostod := round(_nvlrfbasecalc * (xalix /100),2)
		_nSubTImpostoD[nIndFis] += _nvlrfimpostod
		@ nLinha,051 Say _nVlrFImpostoD pict "@R@E 99,999,999,999.99"
		@ nLinha,068 Say "|"
		@ nLinha,079 Say _nVlrFIsento pict "@R@E 99,999,999,999.99"
		@ nLinha,96 SAY "|"
		@ nLinha,97 Say _nVlrFOutros pict "@R@E 999,999,999.99"
		@ nLinha,111 say "|"
		@ nLinha,118 Say _nOtherDebitos PICT "@r@e 999,999,999.99"
		@ nLinha,132 say "|"
		_nVlrFContabil :=0
		_nVlrFBaseCalc :=0
		_nVlrFImpostoD :=0
		_nVlrFIsento   := 0
		_nVlrFOutros   := 0
		_nOtherDebitos := 0
		//	
		//
	EndDo
	nLinha++
	@ nLinha,001 Say REPL("-",132)
	nLinha++
	@ nLinha,001 Say "| SUBTOTAIS SAIDAS                                                                                                                 |"
	nLinha++
	@ nLinha,001 Say REPL("-",132)
	nLinha++
	@ nLinha,001 Say "|5.00 PARA O    |            |                 |                   |                           |              |                    |"
	nLinha++
	@ nLinha,001 Say "|     ESTADO    |            |                 |                   |                           |              |                    |"
	@ nLinha,018 Say _nSubTContabil[1]  pict "@R@E 9,999,999.99"
	@ nLinha,031 Say _nSubTBaseCalc[1]  pict "@R@E 99,999,999,999.99"
	@ nLinha,051 Say _nSubTImpostoD[1]  pict "@R@E 99,999,999,999.99"
	@ nLinha,097 Say _nSubTFOutros[1]  pict "@R@E 999,999,999.99"
	@ nLinha,118 Say _aOtherDebitos[1]  pict "@R@E 999,999,999.99"
				
	//
	nLinha++
	@ nLinha,001 Say "|6.00 PARA      |            |                 |                   |                           |              |                    |"
	nLinha++
	@ nLinha,001 Say "|OUTROS ESTADOS |            |                 |                   |                           |              |                    |"
	@ nLinha,018 Say _nSubTContabil[2]  pict "@R@E 9,999,999.99"
	@ nLinha,031 Say _nSubTBaseCalc[2]  pict "@R@E 99,999,999,999.99"
	@ nLinha,051 Say _nSubTImpostoD[2]  pict "@R@E 99,999,999,999.99"
	@ nLinha,097 Say _nSubTFOutros[2]  pict "@R@E 999,999,999.99"
	@ nLinha,118 Say _aOtherDebitos[2]  pict "@R@E 999,999,999.99"
	//
	
	nLinha++
	@ nLinha,001 Say "|7.00 PARA O    |            |                 |                   |                           |              |                    |"
	nLinha++
	@ nLinha,001 Say "|EXTERIOR       |            |                 |                   |                           |              |                    |"
	@ nLinha,018 Say _nSubTContabil[3]  pict "@R@E 9,999,999.99"
	@ nLinha,031 Say _nSubTBaseCalc[3]  pict "@R@E 99,999,999,999.99"
	@ nLinha,051 Say _nSubTImpostoD[3]  pict "@R@E 99,999,999,999.99"
	@ nLinha,097 Say _nSubTFOutros[3]  pict "@R@E 999,999,999.99"
	@ nLinha,118 Say _aOtherDebitos[3]  pict "@R@E 999,999,999.99"
	//
	nLinha++
	@ nLinha,001 Say REPL("-",132)
	nLinha++
	@ nLinha,001 Say "|   TOTAIS      |            |                 |                   |                           |              |                    |"
	@ nLinha,018 Say _nTotGContabil  pict "@R@E 9,999,999.99"
	@ nLinha,031 Say _nTotGBaseCalc  pict "@R@E 99,999,999,999.99"
	_nTotGImpostoD := _nsubtimpostod[1] + _nsubtimpostod[2] + _nsubtimpostod[3]
	@ nLinha,051 Say _nTotGImpostoD  pict "@R@E 99,999,999,999.99"
	@ nLinha,097 Say _nTotGOutros  pict "@R@E 999,999,999.99"
	@ nLinha,118 Say _aOtherDebitos[1]+_aOtherDebitos[2]+_aOtherDebitos[3] pict "@R@E 999,999,999.99"
	//
	nLinha++
	@ nLinha,001 say Repl("=",132)
	nLinha++
	xxx := nTotE - (_nTotGImpostoD + _aOtherDebitos[1]+_aOtherDebitos[2]+_aOtherDebitos[3] )
	if xxx > 0
		@ nLinha,01 SAY "CREDITO DE IMPOSTO...:"+TRANS(XXX,"@R@E 99,999,999,999.99")
		nLinha++
		@ nLinha,001 say Repl("=",132)
	ENDIF
	IF XXX < 0
		@ nLinha,01 SAY "IMPOSTO A RECOLHER...:"+TRANS(ABS(XXX),"@R@E 99,999,999,999.99")				
		nLinha++
		@ nLinha,001 say Repl("=",132)
	ENDIF	
	Return(nil)