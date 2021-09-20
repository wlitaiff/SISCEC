// Sistemas de Controle de Estoque Comercial - Modulo de Livro Fiscal
// W&R Informatica Ltda
// 29 de Agosto de 1996
// Waldemir Litaiff Vasconcelos
// Livro Fiscal de Entrada - ( CecCfis )

LOCAL cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
		cCor := SETCOLOR(),;
		nCursor := SETCURSOR(),;
		lCabec  := .F.,;
		lBuffree:= "",;
		lHavPrint:=.F.,;
		vBasFisc[3],;
		nVlTotIcms
		
Local dDat_Inicio,;
		dDat_Final,;
		dMes_Periodo,;
		cCgc_Firma,;
		cNome_Firma,;
		cInsEst_Firma,;
		nCod_Tri,;
		nFolha,;
		nLinha

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
nLinha     := 13     // Ref. a Ultima linha do cabec.
dMesPeriodo:= Date()
dDat_Inicio:= Date()
dDat_Final := CtoD('  /  /    ')
DbSetOrder(3)
DO WHILE .T.
	Box(16,06,19,75,fr,127,3,8)
	SETCURSOR(1)
	AFILL(vBasFisc,0)
	nVlTotIcms :=0
	dDat_Final := CtoD('  /  /    ')
	lCabec     := .T.
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
		IF CECCFIS->DENT>dDat_Final .OR. CECCFIS->(EOF())
			M_DISPLAY("Per¡odo sem Lan‡amento",79)
			Loop
		ENDIF
	ENDIF		
	IF !IMPRES()
		LOOP
	ENDIF
	//			
	cTelao := SAVESCREEN(0,0,MAXROW(),MAXCOL())
	M_MESSAGE("Listando Registro de Entrada, Aguarde!",23)
	SET DEVICE TO PRINT
	SET CENTURY OFF
	nVlNot := 0
	@ prow(),pcol() say CHR(sEsc)
	Do While If(!EMPTY(DENT),(DENT<=dDat_Final),.T.) .and. !eof()
	if codtri>4
		DBSKIP()
		LOOP
	ENDIF	
	//
	If lCabec
		Caceb_Entrada(cNome_Firma,cCgc_Firma,cInsEst_Firma,nFolha,dDat_Inicio,dDat_Final)
		lCabec := .F.
	EndIf
	//Processo
	lHavPrint:= .T.
	CECCFOR->( DbSeek(CECCFIS->CLI_FOR) )
	// Detalhe
	nLInha ++
	// Imprimir
	@ nLinha,001 Say "|"
	@ nLinha,003 Say TRANS(Day( (CECCFIS->DENT) ),'99')+"/"+TRANS(Month( (CECCFIS->DENT) ),'99')
	@ nLinha,010 say "|"
	@ nLinha,011 Say "NF"
	@ nLinha,013 say "|"
	@ nLinha,014 Say CECCFIS->SERIE+"/"+TRANS((CECCFIS->SUBSER),'99')
	@ nLinha,019 Say "|"
	@ nLinha,020 Say INT( VAL( (CECCFIS->NNOTA) ) ) PICTURE "999999"
	@ nLinha,026 Say "|"
	@ nLinha,027 Say CECCFIS->DEMI PICT "@D"
	@ nLinha,036 say "|"
	@ nLinha,037 Say CECCFOR->ESTADOF
	@ nLinha,039 say "|"
	@ nLinha,040 Say (CECCFOR->CGCCPFF) PICT "@R 99.999.999/9999-99"
	@ nLinha,058 Say "|"
	@ nLinha,059 Say CECCFIS->VLNOT PICT "@R@E 999,999.99"
	@ nLinha,069 Say "|"
	@ nLinha,070 Say " "   //CONTABIL - CODIFICACAO
	@ nLinha,078 Say "|"
	@ nLinha,080 Say CECCFIS->CFO PICT "@!"
	@ nLinha,085 SAY "|"
	@ nLinha,087 Say CECCFIS->CODTRI PICT "9"
	@ nLinha,089 Say "|"
	@ nLinha,090 Say CECCFIS->BASICMS PICT "@R@E 9999,999.99"
	@ nLinha,101 Say "|"
	@ nLinha,102 Say CECCFIS->ALIICMS PICT "@R@E 99.99"
	@ nLinha,107 SAY "|"
	@ nLinha,109 Say CECCFIS->VLICMS  PICT "@R@E 999,999.99"
	@ nLinha,119 say "|"
	@ nLinha,120 Say " " //OBS.
	@ nLinha,132 say "|"
	// Totalizador
	nCod_Tri := (CECCFIS->CODTRI)
	If nCod_Tri > 3
		nCod_Tri := 3
	EndIf
	If nCod_Tri > 0 .and. nCod_Tri < 4
		vBasFisc[nCod_Tri] += (CECCFIS->BASICMS)
	EndIF
	If nCod_Tri == 1
		nVlTotIcms+= (CECCFIS->VLICMS)
	EndIf
	If nCod_Tri == 1
		nVlnOT += (CECCFIS->VLNOT)
	EndIf
	DbSkip()
	// Controle de Pagina
	If nLinha=58 
		@ nLinha+1,001 say Repl("=",132)	
		@ nLinha+2,001 say lBuffree
		lCabec:=.T.
		nLInha:=13
	EndIf
	EndDo
	If lHavPrint
	For i=1 to 3
		if i=1
			@ nLinha+1,001 Say "|        |  |     |      |         |  |                  |          |        |      |   |           |     |           |            |"
			@ nLinha+1,052 SAY "TOTAL:"
			@ nLinha+1,059 SAY NVLNOT PICTURE "@R@E 999,999.99"
			@ nLinha+1,079 Say "TOTAL:" 
			@ nlinha+1,087 Say I PICT "9"
			@ nLinha+1,090 Say vBasFisc[i] PICT "@R@E 9999,999.99"
			@ nLinha+1,109 Say nVlTotIcms PICT "@R@E 999,999.99"
		else
			@ nLinha+i,001 Say "|        |  |     |      |         |  |                  |          |        |      |   |           |     |           |            |"
			@ nlinha+i,087 Say I PICT "9"
			@ nLinha+i,090 Say vBasFisc[i] PICT "@R@E 9999,999.99"
		endif
	Next
	nLinha+=i
	@ nLinha+0,001 say Repl("=",132)
	@ nLinha+1,001 say lBuffree
	EndIf
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

Function Caceb_Entrada(cFirma,cCgc,cInsEst,nFolha,dDat_Inicio,dDat_final)
// Cabe‡alho do Livro de Entrada
nFolha++
@ 01,01 Say " ---------------------------------------------------------------------------------------------------------------------------------- " 
@ 02,01 Say "|                               REGISTRO DE ENTRADAS                                 |          CODIGO DE VALORES FISCAIS          |"
@ 03,01 Say "| FIRMA.....:"+cFirma
@ 03,86 Say  																												 "|---------------------------------------------|"
@ 04,01 Say "| INSC. EST.:"+cInsEst+Space(06)+"CGC(MF).:"+Trans(cCgc,'@R 99.999.999/9999-99')+Space(19)+"|1-OP. COM CREDITO DE IMPOSTO                 |"
@ 05,01 Say "| FOLHA.....:"+Trans(nFolha,'@E@R 999,999')+Space(19)+"MES OU PERIODO/ANO.:"+DispMonth(dDat_Inicio)+"/"+Trans(year(dDat_Inicio),'@E@R 9,999')
@ 05,86 Say 																												 "|2-OP. S/ CRED. DE IMP. ISENTAS/NAO TRIBUTADAS|"
@ 06,01 Say "|"+space(58)+If(dDat_Final>dDat_Inicio,DispMonth(dDat_Final)+"/"+Trans(year(dDat_Final),'@E@R 9,999'),"")
@ 06,86 Say 															                         					 "|3-OP. SEM CREDITO DE IMPOSTO-OUTRAS          |"
@ 07,01 Say "|----------------------------------------------------------------------------------------------------------------------------------|"
@ 08,01 Say "|  DATA  |           DOCUMENTOS FISCAIS                  |          |  CODIFICACAO  |   |    ICMS VALORES FISCAIS     |            |"
@ 09,01 Say "|   DE   |-----------------------------------------------|  VALOR   |---------------|COD|-----------------------------|            |"
@ 10,01 Say "| ENTRADA|  |SERIE|      |  DATA   |  |     CODIGO       |          |        |      |   |   BASE    |     |           | OBSERVACAO |"
@ 11,01 Say "|"+" "+TRANS(YEAR(dDat_Inicio),'@E@R 99,999')
@ 11,10 Say          "|ES| SUB |NUMERO|   DO    |UF|       DO         | CONTABIL |CONTABIL|FISCAL|(a)|    DE     |ALIQ.|  IMPOSTO  |            |"
@ 12,01 Say "|DIA/MES |  |SERIE|      |DOCUMENTO|  |    EMITENTE      |          |        |      |   | CALCULO   |  %  |           |            |"
@ 13,01 Say "|--------|--|-----|------|---------|--|------------------|----------|--------|------|---|-----------|-----|-----------|------------|"
Return(Nil)