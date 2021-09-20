// W&R Inform†tica Ltda.
// SisCEC - Controle de Estoque Comercial - CECPG001 
// Relatorio de Contas a Pagar no periodo - Geral
// Manaus , 13 de Janeiro  de 1998
// Waldemir Litaiff Vasconcelos

#include "HAWK.CH"
LOCAL Getlist:={},;
      nFornecedor,;
		nFor,;
		aClass := {"Data Vencimento","Data Emiss∆o","Cancela"},;
		cCor :=SETCOLOR(),;
	   cTela:=SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
		nCursor := SETCURSOR()
		
PRIVA nTot_Sldoc := nTot_Vldoc := nTot_Debit := 0,;
		nToR_Sldoc := nToR_Vldoc := nToR_Debit := 0,;
		nTot_Item := 0,;
		nToR_Item := 0,;
		nTot_Dia  := 0,;
		nLin 

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
	Box(11,01,14,79,fr,127,3,8)
	SETCOLOR("B/W,W+/BG,,,B/W")
	SETCURSOR(1)
	//
	nFornecedor := nFor := 0
	dDataI:=dDataF:=Ctod([  /  /  ])
	//				  
	@ 12,02 SAY [Data inicial.:];
		     GET dDataI;
			  PICTURE "@D"
	
	@ 13,02 SAY [Data Final...:];
		     GET dDataF;
			  PICTURE "@D";
			  VALID IF(!EMPTY(dDataI),IF(dDataF<dDataI,EVAL({||M_DISPLAY("Data final menor que data inicial",79),.F.}),.T.),.T.)
	READ
	//
	IF LASTKEY()<>27
		nClassificacao:=ALERT("Classificado por...",aClass)
	ENDIF
	//
	SETCURSOR(0)
	IF LASTKEY()=27 .OR. nClassificacao==3
		SET SOFTSEEK OFF
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
	Imp_CPagar(dDataI,dDataF,nClassificacao) 
	//
EndDo	
SET SOFTSEEK OFF
RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
DBCLOSEALL()
RETURN

/************************** Funcoes para Impress∆o ************************/
/**
**/

FUNCTION Imp_CPagar(dDataInicial,dDataFinal,nClass)
LOCAL	_Sai       := .F.,;
		nTotal     := 0,;
		dDia       := 0,;
		lCab       := .T.,;
		nPage      := 1,;
		nLin       := 0,;
		nCont      := 0,;
		lImpDia    ,;
		lImpFor    
	//
	SELECT("CECCPAG")
	IF(nClass==1,DBSETORDER(2),DBSETORDER(4))
   SET SOFTSEEK ON
   DBSEEK(DTOS(dDataInicial))
   SET SOFTSEEK OFF
	lImpDia := .T.
	lImpFor := .T.
	nFornecedor := CeccPAG->Fornecedor
	//
	IF EOF()
		M_MESSAGE([Data Inicial Nao encontrada...],23)
	ENDIF
	//
   DO WHILE !EOF()
		//
		IF INKEY()==27
			IF Para_Impressao()
				EXIT
			ENDIF
		ENDIF
		//
		dDia := Day(ceccpag->vencimento)
		dDia := Day(IF(nClass==1,(ceccPAG->vencimento),(ceccPAG->emissao)))
      nFor := CeccPAG->Fornecedor
		SELECT("CECCFOR")                 
		DBSEEK(nFor)							// Acessar dados de Fornecedor
		SELECT("CECCPAG")
		//
		IF !EMPTY(dDataInicial)
			IF IF(nClass==1,(ceccPAG->vencimento),(ceccPAG->emissao)) < dDataInicial	  // Fora do Periodo
				CECCPAG->(DBSKIP())
				If Day(IF(nClass==1,(ceccPAG->vencimento),(ceccPAG->emissao))) # dDia
					IF nCont>0
						nLin++
						@ NLIN,00 SAY REPL('-',80)
						nLin++
						@ nLin,001 say [TOTAL DO DIA----------->>>]
						@ nLin,064 say nTot_Dia  pict "@E 999,999,999.99"
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
					If nLin > 56
						lCab := .T.
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
			IF IF(nClass==1,(ceccpag->vencimento),(ceccpag->emissao)) > dDataF	
				CECCPAG->(DBSKIP())
				If Day(IF(nClass==1,(ceccpag->vencimento),(ceccpag->emissao))) # dDia   //Day(CECCPAG->Vencimento) # dDia
					IF nCont>0
						nLin ++
						@ NLIN,00 SAY REPL('-',80)
						nLin++
						@ nLin,001 say [TOTAL DO DIA---------->>>]
						@ nLin,064 say nTot_Dia  pict "@E 999,999,999.99"
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
					If nLin > 56
						lCab := .T.
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
			@07,00 SAY "FORNEC.  RAZAO SOCIAL------------------  N.FISCAL--  "+IF(nClass==1,"EMISSAO---","VENCIMENTO")+"  VALOR TOAL----"
			//          99999    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XXXXXXXXXX  99/99/9999   99.999.999,99
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
				@ nLin,001 SAY chr(14)+IF(nClass==1,"DATA VENCIMENTO--->>" + DTOC(CECCPAG->VENCIMENTO)+CHR(18)+" ","DATA EMISSAO--->>" + DTOC(CECCPAG->EMISSAO)+CHR(18)+" " )
				lImpDia := .F.
				nLin++
			EndIf
			//
			//	     01 / 10 / 42 / 54 / 66
			nLin++
			@ nLin,000 SAY If(lImpFor,STR(CECCPAG->Fornecedor,5)+"  "+subs(CECCFOR->NOMECLF,1,30),"")
			@ nLin,041 say CECCPAG->DUPLICATA
			@ nlin,054 say IF(nClass==1,(ceccPAG->EMISSAO),(ceccPAG->VENCIMENTO) )     //CECCPAG->EMISSAO
			@ nLin,064 SAY CECCPAG->VALOR     pict "@E 999,999,999.99"
			// Calculos de Totais
			nCont++
			nTot_Vldoc += VALOR
			nToR_Vldoc += VALOR
			nTot_Dia   += VALOR
			nTot_Item++	
			nToR_Item++	
			lImpFor    := .F.
		ENDIF	
		//
		CECCPAG->(DBSKIP())
		If nFornecedor # CECcPag->Fornecedor
			nFornecedor := CECcPag->Fornecedor
			lImpFor     := .T.
		EndIf
		//
		If Day(IF(nClass==1,(ceccpag->vencimento),(ceccPAG->emissao))) # dDia   //Day(CECCPAG->Vencimento) # dDia
			If nCont>0
				nLin ++
				@ NLIN,00 SAY REPL('-',80)
				nLin++
				@ nLin,001 say [TOTAL DO DIA------->>>]
				@ nLin,064 say nTot_Dia  pict "@E 999,999,999.99"
				nLin++
				@ nLin,00 say repl([-],80)
				nLin++
				nTot_Vldoc:=0
				nTot_Sldoc:=0
				nTot_Debit:=0
				nTot_Dia  :=0
				nCont:=0
			EndIf	
			//
			If nLin > 56
				lCab := .T.
			EndIf
			lImpDia := .T.
		EndIf
		//
		If nLin > 56
			lCab    := .T.
			lImpDia := .T.
		EndIf
		//
	ENDDO
	//		
	// Total Geral
	nLin ++
	@ nLin,00 say repl('-',80)
	nLin++
	@ nLin,01 say [TOTAL GERAL--->>>]
	@ nLin,64 say nToR_Vldoc pict "@E 999,999,999.99"
	nLin++
	@ nLin,00 say repl([=],80)
	//
	EJECT
	SET DEVICE TO SCREEN
	RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela0)
	RETURN(NIL)