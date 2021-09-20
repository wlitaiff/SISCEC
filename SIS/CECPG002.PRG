// W&R Inform†tica Ltda.
// SisCEC - Controle de Estoque Comercial - CECPG001 
// Relatorio de Contas a Pagar no periodo - Fornecedor
// Manaus , 13 de Janeiro  de 1998
// Waldemir Litaiff Vasconcelos

#include "HAWK.CH"
LOCAL Getlist:={},;
      nFornecedor,;
		cCor :=SETCOLOR(),;
	   cTela:=SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
		nCursor := SETCURSOR()
		
PRIVA nTot_Sldoc := nTot_Vldoc := nTot_Debit := 0,;
		nToR_Sldoc := nToR_Vldoc := nToR_Debit := 0,;
		nTot_Item := 0,;
		nToR_Item := 0,;
		nTot_Dia  := 0,;
		nTot_For  := 0,;
		nLin ,;
		lImpFor
		
// Abrir Arquivos
IF !ARQNTX("CECCFOR",.F.) .OR. ;
   !ARQNTX("CECLOGO",.F.) .OR. ;
	!ARQNTX("CECCPAG",.F.)  
	!ARQNTX("CECCPTF",.F.)  
	DBCLOSEALL()
	RETURN
ENDIF
//
DO WHILE .T.
	Box(11,01,15,79,fr,127,3,8)
	SETCOLOR("B/W,W+/BG,,,B/W")
	SETCURSOR(1)
	nFornecedor := 0
	dDataI:=dDataF:=Ctod([  /  /  ])
	//			
	@ 12,02 SAY [Fornecedor.:]; 
	        GET nFornecedor; 
			  PICTURE "@K 99999";          // EVAL({||DISPOUT("TODOS "),.T.}),
			  VALID Existe(nFornecedor,[Fornecedor n∆o cadastrado],.F.,'CECCFOR',1,'NOMECLF','@!',ROW(),COL()+2) .AND.;
			        Existe(STRZERO(nFornecedor,5),[Fornecedor n∆o possui lanáamentos],.F.,"CECCPAG",1) 
					  
	@ 13,02 SAY [Data inicial.:];
		     GET dDataI;
			  PICTURE "@D"
	
	@ 14,02 SAY [Data Final...:];
		     GET dDataF;
			  PICTURE "@D";
			  VALID IF(!EMPTY(dDataI),IF(dDataF<dDataI,EVAL({||M_DISPLAY("Data final menor que data inicial",79),.F.}),.T.),.T.)
	READ
	//	  
	SETCURSOR(0)
	IF LASTKEY()=27
		SET SOFTSEEK OFF	
		DBSETORDER(1)
		SETCOLOR(cCor)
		RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
		EXIT
	ENDIF
	//
	cTela0 := SAVESCREEn(0,0,MAXROW(),MAXCOL())
	//
	IF !IMPRES()
		DBCLOSEALL()
		RETURN
	ENDIF
	//
	M_MESSAGE([Aguarde! Imprimindo...],23)
	//
	Imp_CPagFor(nFornecedor,dDataI,dDataF) 
	//
EndDo	
RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
DBCLOSEALL()
RETURN

/************************** Funcoes para Impress∆o ************************/
/**
**/

FUNCTION Imp_CPagFor(CodFornecedor,dDataInicial,dDataFinal)
LOCAL	_Sai       := .F.,;
		nTotal     := 0,;
		dDia       := 0,;
		lCab       := .T.,;
		nPage      := 1,;
		nLin       := 0,;
		nCont      := 0,;
		lImpDia        ,;
		lImpFor
		//
	
	SET SOFTSEEK ON	
	SELECT("CECCPAG")
	DBSETORDER(2)
	DBSEEK(DtoS(dDataInicial)+StrZero(CodFornecedor,5))
	lImpDia := .T.
	lImpFor := .T.
	//
   DO WHILE CodFornecedor==CECCPAG->Fornecedor .and. !EOF()
		//
		IF INKEY()==27
			IF Para_Impressao()
				EXIT
			ENDIF
		ENDIF
		//
		dDia := Day(CECcPag->Vencimento)
      //
		SELECT("CECCFOR")                 
		DBSEEK(CodFornecedor)							// Acessar dados de Fornecedor
		SELECT("CECCPAG")
		//
		IF !EMPTY(dDataInicial)
			IF VENCIMENTO<dDataInicial	           // Fora do Periodo
				CECCPAG->(DBSKIP())
				If Day(CECCPAG->Vencimento) # dDia
					IF nCont>0
						nLin++
						@ NLIN,00 SAY REPL('-',80)
						nLin++
						@ nLin,001 say [TOTAL DO DIA----------->>>]
						@ nLin,066 say nTot_Dia  pict "@E 99,999,999.99"
						nLin++
						@ nLin,00 say repl([-],80)
						nLin++
						nTot_Vldoc:=0
						nTot_Sldoc:=0
						nTot_Debit:=0
						nTot_Dia  :=0
						nCont:=0
					ENDIF	
					//
					If nLin > 57
						lCab := .T.
						lImpFor := .T.
					EndIf
					lImpDia := .T.
					//
				EndIF
				//
				LOOP
			ENDIF
		ENDIF		 
		//
		IF !EMPTY(dDataF)
			IF VENCIMENTO>dDataF	
				CECCPAG->(DBSKIP())
				If Day(CECCPAG->Vencimento) # dDia
					IF nCont>0
						nLin ++
						@ NLIN,00 SAY REPL('-',80)
						nLin++
						@ nLin,001 say [TOTAL DO DIA---------->>>]
						@ nLin,066 say nTot_Dia  pict "@E 99,999,999.99"
						nLin++
						@ nLin,00 say repl([-],80)
						nLin++
						nTot_Vldoc:=0
						nTot_Sldoc:=0
						nTot_Debit:=0
						nTot_dia  :=0
						nCont:=0
					ENDIF	
					//
					If nLin > 57
						lCab := .T.
						lImpFor := .T.
					EndIf
					lImpDia := .T.
				EndIf
				//
				LOOP
			ENDIF
		ENDIF		 
		//
		// Imprimir Cabecalho
		SET DEVICE TO PRINT
		IF lCab 
			Cabecalho(nPage,"CONTAS A PAGAR NO PERIODO - ("+DTOC(dDataI)+"-"+DTOC(dDataF)+")")
			@PROW(),PCOL() SAY CHR(18) 
			@07,01 SAY "FORNEC.  RAZAO SOCIAL------------------  N.FISCAL--  EMISSAO---  VALOR TOAL----"
			//          99999    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XXXXXXXXXX  99/99/9999  999.999.999,99
			//			   01			10                              42          54          66
			@08,00 SAY REPL("-",80)
			nLin := 09
			lCab := .F.
			nPage++
		ENDIF
		//
		// Preparar para imprimir detalhes 
		IF CECCPAG->STATUS=" "
			//
			// Imprimir
			If lImpdia
				nLin++
				@ nLin,000 SAY CHR(15)+ ""
				@ nLin,001 SAY chr(14)+"DATA VENCIMNETO--->>" + DTOC(CECCPAG->VENCIMENTO)+CHR(18)+" "
				lImpDia := .F.
				nLin++
			EndIf
			//
			//	     01 / 10 / 42 / 54 / 66
			nLin++
			@ nLin,001 SAY If(lImpFor,STR(CECCPAG->Fornecedor,5)+"  "+SUBS(CECCFOR->NOMECLF,1,30),"")
			@ nLin,042 say CECCPAG->DUPLICATA
			@ nlin,054 say CECCPAG->EMISSAO
			@ nLin,066 SAY CECCPAG->VALOR      pict "@E 99,999,999.99"
			// Calculos de Totais
			nCont++
			nTot_Vldoc += VALOR
			nToR_Vldoc += VALOR
			nTot_Dia   += VALOR
			nTot_Item++	
			nToR_Item++	
			lImpFor := .F.
		ENDIF	
		//
		CECCPAG->(DBSKIP())
		//
		If Day(CECCPAG->Vencimento) # dDia
			IF nCont>0
				nLin ++
				@ NLIN,00 SAY REPL('-',80)
				nLin++
				@ nLin,001 say [TOTAL DO DIA------->>>]
				@ nLin,066 say nTot_Dia  pict "@E 99,999,999.99"
				nLin++
				@ nLin,00 say repl([-],80)
				nLin++
				nTot_Vldoc:=0
				nTot_Sldoc:=0
				nTot_Debit:=0
				nTot_Dia  :=0
				nCont:=0
			ENDIF	
			//
			If nLin > 57
				lCab := .T.
				lImpFor := .T.
			EndIf
			lImpDia := .T.
		EndIf
		//
		If nLin > 57
			lCab    := .T.
			lImpDia := .T.
			lImpFor := .T.
		EndIf
		//
	ENDDO
	//		
	// Total Geral
	nLin ++
	@ NLIN,00 SAY REPL('-',80)
	nLin++
	@ nLin,01 say [TOTAL GERAL DO FORNECEDOR--->>>]
	@ nLin,66 say nToR_Vldoc pict "@E 99,999,999.99"
	nLin++
	@ nLin,00 say repl([=],80)
	//
	EJECT
	SET DEVICE TO SCREEN
	RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela0)
	RETURN(NIL)