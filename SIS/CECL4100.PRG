// Sistemas de Controle de Estoque Comercial - Modulo de Livro Fiscal
// W&R Informatica Ltda
// 03 de Setembro de 1996
// Waldemir Litaiff Vasconcelos (WLV)
// Apura‡Æo do ICMS - Entrada e Saidas - ( CecCfis )

LOCAL cTela     := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
		cCor      := SETCOLOR(),;
		nCursor   := SETCURSOR(0),;
		lCabec    := .F.,;
		lBuffree  := "",;
		lHavPrint := .F.
		
LOCAL dDat_Inicio,;
		dDat_Final,;
		dMes_Periodo,;
		cCgc_Firma,;
		cNome_Firma,;
		cInsEst_Firma,;
		cCodCfo,;
		nDiaDocto,;
		nFolha,;
		nLinha,;
		nColuna 		// Controle do Relatorio (Cabe‡alho, linha, coluna, dados da empresa)

LOCAL nVlrFContabil,;
		nVlrFBaseCalc,;
		nVlrFImpostoD,;
		nVlrFIsento,;
		nVlrFOutros        // Totais por Opera‡Æo Fiscal
		
LOCAL	nSubTContabil[3],;
		nSubTBaseCalc[3],;
		nSubTImpostoD[3],;
		nSubTIsento[3],;
		nSubTFOutros[3]      // Sub-Totais por estados das Oper‡äes Fiscais
	
LOCAL	nTotGContabil,;
		nTotGBaseCalc,;
		nTotgImpostoD,;
		nTotGIsento,;
		nTotGOutros       // Totais Geral das Opera‡eos (da Apura‡Æo)
		
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
nLinha     := 12       // Ref. a Ultima linha do cabec.
nColuna    := 116      // 1. Posicao
dMesPeriodo:= Date()
dDat_Inicio:= Date()
dDat_Final := CtoD('  /  /    ')
DbSetOrder(5)
DO WHILE .T.
	Box(16,06,19,75,fr,127,3,8)
	SETCURSOR(nCursor)
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
	//
	nTotGContabil := 0
	nTotGBaseCalc := 0
	nTotgImpostoD := 0
	nTotGIsento   := 0
	nTotGOutros   := 0 
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
	nDiaDocto  := Day(DSAI)
	cTelao     := SAVESCREEN(0,0,MAXROW(),MAXCOL())
	//
	M_MESSAGE("Listando Apura‡Æo do I.C.M.S, Aguarde!",23)
	SET DEVICE TO PRINT
	SET CENTURY OFF
	@ prow(),pcol() say CHR(sEsc)
	//
	Do While Val(CFO) < 400 .AND. !EOF()
		//
		If lCabec
			Caceb_AEntra(cNome_Firma,cCgc_Firma,cInsEst_Firma,nFolha,dDat_Inicio,dDat_Final)
			lCabec := .F.
		EndIf
		// Processo
		lHavPrint := .T.
		nDiaDocto := Day(DENT)
		cCodCfo   := CFO
		If Val(cCodCfo) < 200
			nIndFis   := 1      // do Estado
		ElseIf Val(cCodCfo) < 300
			nIndFis   := 2      // de outros estados
		Else 
			nIndFis   := 3		  // do exterior
		EndIF
		//
		// Detalhes
		Do While cCodCfo==CFO .AND. !EOF()
			If !(CECCFIS->CANCELADA) 
				nVlrFContabil += VLNOT
				nVlrFBaseCalc += BASICMS
				nVlrFImpostoD += VLICMS
				nVlrFIsento   := 0
				nVlrFOutros   := 0
				//	
				nSubTContabil[nIndFis] += VLNOT
				nSubTBaseCalc[nIndFis] += BASICMS
				nSubTImpostoD[nIndFis] += VLICMS
				nSubTIsento[nIndFis]   := 0
				nSubTFOutros[nIndFis]  := 0
				//
				nTotGContabil += VLNOT
				nTotGBaseCalc += BASICMS
				nTotgImpostoD += VLICMS
				nTotGIsento   := 0
				nTotGOutros   := 0
			EndIf
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
		@ nLinha,038 Say nVlrFBaseCalc pict "@R@E 99,999,999,999.99"
		@ nLinha,055 Say "|"
		@ nLinha,063 Say nVlrFImpostoD pict "@R@E 99,999,999,999.99"
		@ nLinha,080 Say "|"
		@ nLinha,092 Say nVlrFIsento pict "@R@E 99,999,999,999.99"
		@ nLinha,109 SAY "|"
		@ nLinha,114 Say nVlrFOutros pict "@R@E 99,999,999,999.99"
		@ nLinha,132 say "|"
		// Totalizador
		// Controle de Pagina
		If nLinha=58 
			@ nLinha+1,001 say Repl("=",132)	
			@ nLinha+2,001 say lBuffree
			lCabec:=.T.
			nLInha:=12
		EndIf
	EndDo
	nLinha++
	@ nLinha,001 Say "|       |       |            |                        |                        |                            |                      |"
	nLinha++
	@ nLinha,001 Say "| SUBTOTAIS ENTRADAS         |                        |                        |                            |                      |"
	nLinha++
	@ nLinha,001 Say "|1.00 DO ESTADO |            |                        |                        |                            |                      |"
	@ nLinha,018 Say nSubTContabil[1]  pict "@R@E 9,999,999.99"
	@ nLinha,038 Say nSubTBaseCalc[1]  pict "@R@E 99,999,999,999.99"
	@ nLinha,063 Say nSubTImpostoD[1]  pict "@R@E 99,999,999,999.99"
	//
	nLinha++
	@ nLinha,001 Say "|2.00 DE OUTROS |            |                        |                        |                            |                      |"
	nLinha++
	@ nLinha,001 Say "|     ESTADOS   |            |                        |                        |                            |                      |"
	@ nLinha,018 Say nSubTContabil[2]  pict "@R@E 9,999,999.99"
	@ nLinha,038 Say nSubTBaseCalc[2]  pict "@R@E 99,999,999,999.99"
	@ nLinha,063 Say nSubTImpostoD[2]  pict "@R@E 99,999,999,999.99"
	//
	nLinha++
	@ nLinha,001 Say "|3.00 DO EXTE-  |            |                        |                        |                            |                      |"
	nLinha++
	@ nLinha,001 Say "|     RIOR      |            |                        |                        |                            |                      |"
	@ nLinha,018 Say nSubTContabil[3]  pict "@R@E 9,999,999.99"
	@ nLinha,038 Say nSubTBaseCalc[3]  pict "@R@E 99,999,999,999.99"
	@ nLinha,063 Say nSubTImpostoD[3]  pict "@R@E 99,999,999,999.99"
	//
	nLinha++
	@ nLinha,001 Say "|               |            |                        |                        |                            |                      |"
	nLinha++
	@ nLinha,001 Say "|   TOTAIS      |            |                        |                        |                            |                      |"
	@ nLinha,018 Say nTotGContabil  pict "@R@E 9,999,999.99"
	@ nLinha,038 Say nTotGBaseCalc  pict "@R@E 99,999,999,999.99"
	@ nLinha,063 Say nTotGImpostoD  pict "@R@E 99,999,999,999.99"
	//
	@ nLinha+1,001 say Repl("=",132)
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
	
// Fun‡äes 
Function Caceb_AEntra(cFirma,cCgc,cInsEst,nFolha,dDat_Inicio,dDat_final)
// Cabe‡alho do Livro de Entrada
nFolha++
@ 01,001 Say "+----------------------------------------------------------------------------------------------------------------------------------+" 
@ 02,001 Say "|                                               REGISTRO DE APURACAO DO I.C.M.S                                                    |"
@ 03,001 Say "| FIRMA.....:"+cFirma
@ 03,132 Say "|"
@ 04,001 Say "| INSC. EST.:"+cInsEst+Space(06)+"CGC(MF).:"+Trans(cCgc,'@R 99.999.999/9999-99')
@ 04,132 SAY "|"
@ 05,001 Say "| FOLHA.....:"+Trans(nFolha,'@E@R 999,999')+Space(19)+"MES OU PERIODO/ANO.:"+DispMonth(dDat_Inicio)+"/"+Trans(year(dDat_Inicio),'@E@R 9,999')
@ 05,001 Say "|"+space(76)+If(Month(dDat_Final)>Month(dDat_Inicio)," A  "+DispMonth(dDat_Final)+"/"+Trans(year(dDat_Final),'@E@R 9,999'),"")
@ 05,132 Say "|"
@ 06,001 Say "|------------------------------------------------------ENTRADAS--------------------------------------------------------------------|"
@ 07,001 Say "|  CODIFICACAO  |            |                                       ICMS-VALORES FISCAIS                                          |"
@ 08,001 Say "|---------------|  VALORES   |-----------------------------------------------------------------------------------------------------|"
@ 09,001 Say "|        |      |            |        OPERACOES COM CREDITO DO IMPOSTO         |         OPERACOES SEM CREDITO DE IMPOSTO          |"
@ 10,001 Say "|CONTABIL|FISCAL| CONTABEIS  |-------------------------------------------------|---------------------------------------------------|"
@ 11,001 Say "|        |      |            |     BASE DE CALCULO    |   IMPOSTO CREDITADO    | ISENTAS OU NAO TRIBUTADAS  |       OUTRAS         |"
@ 12,001 Say "|--------|------|------------|------------------------|------------------------|----------------------------|----------------------|"
Return(Nil)