// W&R Inform tica Ltda.
// SisCEC - Controle de Estoque Comercial - CECCP010 
// Consulta de Contas a Pagar no periodo - Geral
// Manaus , 14 de Setembro  de 1998
// Waldemir Litaiff Vasconcelos

#include "HAWK.CH"
LOCAL Getlist:={},;
      nFornecedor,;
		nFor,;
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
IF !ARQNTX("CECCFOR",.F.) .or. ;
   !ARQNTX("CECLOGO",.F.) .OR. ;
	!ARQNTX("CECCPAG",.F.)  
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
	SETCURSOR(0)
	IF LASTKEY()=27
		SET SOFTSEEK OFF
		SETCOLOR(cCor)
		RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
		EXIT
	ENDIF
	//
	cTela0 := SAVESCREEn(0,0,MAXROW(),MAXCOL())
	//
	M_MESSAGE([Aguarde! Gerando Consulta...],23)
	//
	Con_PG010(dDataI,dDataF) 
	//
EndDo	
SET SOFTSEEK OFF
RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
DBCLOSEALL()
RETURN

/************************** Funcao para consulta **************************/
/**
**/

FUNCTION Con_PG010(dDataInicial,dDataFinal)
LOCAL	_Sai       := .F.,;
		nTotal     := 0,;
		dDia       := 0,;
		lCab       := .T.,;
		nPage      := 1,;
		nLin       := 0,;
		nCont      := 0,;
		aCPagar    := {}
	//
	SET SOFTSEEK ON
	SELECT("CECCPAG")
	DBSETORDER(2)
	IF EMPTY(dDataInicial)
		DBGOTOP()
	ELSE
		DBSEEK(dDataInicial)
	ENDIF
	//
	nFornecedor:= CeccPAG->Fornecedor
	//
   DO WHILE !EOF()
		//
		IF INKEY()==27
			IF M_QUERY("Cancela a consulta",79)
				_sai := .t.
				EXIT
			ENDIF
		ENDIF
		//
		dDia := Day(ceccpag->Vencimento)
      nFor := CeccPag->Fornecedor
		SELECT("CECCFOR")                 
		DBSEEK(nFor)							// Acessar dados do Fornecedor
		SELECT("CECCPAG")
		//
		dDia := Day(ceccpag->Vencimento)
		//
		IF !EMPTY(dDataInicial)
			IF Vencimento<dDataInicial	           // Fora do Periodo
				CECCPAG->(DBSKIP())
				If Day(CECCPAG->Vencimento) # dDia
					IF nCont>0
						AADD(aCPagar,{"","TOTAL DO DIA..:","","","",nTot_Dia})
						nTot_Vldoc:=0
						nTot_Sldoc:=0
						nTot_Debit:=0
						nTot_Dia  :=0
						nCont:=0
					ENDIF	
					//
				EndIF
				//
				LOOP
			ENDIF
		ENDIF	
		//	 
		IF !EMPTY(dDataFinal)
			IF CECCPAG->Vencimento > dDataFinal
				CECCPAG->(DBSKIP())
				If Day(CECCPAG->Vencimento) # dDia
					IF nCont>0
						AADD(aCPagar,{"","TOTAL DO DIA..:","","","",nTot_Dia})
						nTot_Vldoc:=0
						nTot_Sldoc:=0
						nTot_Debit:=0
						nTot_dia  :=0
						nCont:=0
					ENDIF	
				EndIf
				LOOP
			ENDIF
		ENDIF
			//
			// Preparar para imprimir detalhes 
                        IF CECCPAG->STATUS=" "
				//
				//	Adicionar dados ao Vetor
				AADD(aCPagar,{ceccpag->Fornecedor,subs(CECCFOR->NOMECLF,1,30),CecCPAG->DUPLICATA,ceccPAG->EMISSAO,ceccPAG->VENCIMENTO,ceccPAG->VALOR})
				// Calculos de Totais
				nCont++
				nTot_Vldoc += CecCPag->Valor
				nToR_Vldoc += CecCPag->Valor
				nTot_Dia   += CecCPag->Valor
				nTot_Item++	
				nToR_Item++	
			ENDIF	
			//
			CECCPAG->(DBSKIP())
			//
			If Day(ceccpag->Vencimento) # dDia
				If nCont>0
					AADD(aCPagar,{"","TOTAL DO DIA..:","","","",nTot_Dia})
					nTot_Vldoc:=0
					nTot_Sldoc:=0
					nTot_Debit:=0
					nTot_Dia  :=0
					nCont:=0
				EndIf	
			EndIf
		//
	ENDDO
	//
	AADD(aCPagar,{NIL,"TOTAL GERAL DO PERIODO..:",NIL,NIL,NIL,nToR_VlDoc})
	//
	cCor 	  := SETCOLOR()
	nCursor := SETCURSOR()
	//
	IF _SAI
		RETURN(NIL)
	ENDIF	
	//
	aCab:={"FORNEC.","RAZAO SOCIAL------------------","DOCUMENTO-","EMISSAO---","VENCIMENTO","VALOR TOTAL----"}
	aPic:={"99999","@!","@!","@D","@D","@R 99,999,999.99"}
	HBrowseAR(02,00,24,79,"CONTAS A PAGAR NO PERIODO DE ("+DTOC(dDataI)+" A "+DTOC(dDataF)+")",aCab,aCPagar,aPic)
	//		
	SETCOLOR(cCor)
	SETCURSOR(nCursor)
	//
	RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela0)
	RETURN(NIL)
