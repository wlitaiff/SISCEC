// W&R Inform tica Ltda.
// SisCEC - Controle de Estoque Comercial - CECPG005
// Relatorio de Contas a Pagar do Dia - Dias/Fornecedores
// Manaus , 13 de Janeiro  de 1998
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
	dDataI:=dDataF:=Date()               //Ctod([  /  /  ])
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
	IF !IMPRES()
		DBCLOSEALL()
		RETURN
	ENDIF
	//
	M_MESSAGE([Aguarde! Imprimindo...],23)
	//
	Imp_CPagDia(dDataI,dDataF) 
	//
EndDo	
SET SOFTSEEK OFF
RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
DBCLOSEALL()
RETURN

/************************** Funcoes para ImpressÆo ************************/
/**
**/

FUNCTION Imp_CPagDia(dDataInicial,dDataFinal)
LOCAL	_Sai       := .F.,;
		nTotal     := 0,;
		dDia       := 0,;
		lCab       := .T.,;
		nPage      := 1,;
		nLin       := 0,;
		nCont      := 0,;
		lImpDia    
	//
	SET SOFTSEEK ON
	SELECT("CECCPAG")
	DBSETORDER(2)
        DBSEEK(DTOS(dDataInicial))
	lImpDia     := .T.
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
      nFor := CeccPAG->Fornecedor
		SELECT("CECCFOR")                 
		DBSEEK(nFor)							// Acessar dados de Fornecedor
		SELECT("CECCPAG")
		//
		IF !EMPTY(dDataInicial)
			IF VENCIMENTO<dDataInicial	           // Fora do Periodo
				CECCPAG->(DBSKIP())
				If Day(CECCPAG->Vencimento) # dDia
					IF nCont>0
						nLin++
						@ NLIN,00 SAY REPL([Ä],80)
						nLin++
						@ nLin,001 say [TOTAL DO DIA----------->>>]
						@ nLin,066 say nTot_Dia  pict "@E 99,999,999.99"
						nLin++
						@ nLin,00 say repl([Ä],80)
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
			IF VENCIMENTO>dDataF	
				CECCPAG->(DBSKIP())
				If Day(CECCPAG->Vencimento) # dDia
					IF nCont>0
						nLin ++
						@ NLIN,00 SAY REPL([Ä],80)
						nLin++
						@ nLin,001 say [TOTAL DO DIA---------->>>]
						@ nLin,066 say nTot_Dia  pict "@E 99,999,999.99"
						nLin++
						@ nLin,00 say repl([Ä],80)
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
			Cabecalho(nPage,"CONTAS A PAGAR DO DIA - ("+DTOC(dDataI)+"-"+DTOC(dDataF)+")")
			@PROW(),PCOL() SAY CHR(18) 
			@07,01 SAY "DUPLICATA-  RAZAO SOCIAL------------------  EMISSAO--- VENCIMENTO  VALOR TOTAL-"
			//				XXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  99/99/9999 99/99/9999 99.999.999,99
			//				01			   13                              45         56          68  
			@08,00 SAY REPL([Ä],80)
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
			//	     01 / 13 / 45 / 56 / 67
			nLin++
			@ nLin,001 say CECCPAG->DUPLICATA
			@ nLin,013 SAY SUBS(CECCFOR->NOMECLF,1,30)
			@ nlin,045 say CECCPAG->EMISSAO
			@ nlin,056 say CECCPAG->VENCIMENTO
			@ nLin,067 SAY CECCPAG->VALOR    				 PICT "@e 99,999,999.99"
			// Calculos de Totais
			nCont++
			nTot_Vldoc += VALOR
			nToR_Vldoc += VALOR
			nTot_Dia   += VALOR
			nTot_Item++	
			nToR_Item++	
		ENDIF	
		//
		CECCPAG->(DBSKIP())
		//
		If Day(CECCPAG->Vencimento) # dDia
			If nCont>0
				nLin ++
				@ NLIN,00 SAY REPL([Ä],80)
				nLin++
				@ nLin,001 say [TOTAL DO DIA------->>>]
				@ nLin,066 say nTot_Dia  pict "@E 999,999,999.99"
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
	nLin++
	@ nLin,00 say repl([Ä],80)
	nLin++
	@ nLin,01 say [LOCAL/DATA PAGAMENTO |  CONFERIDO POR:  |  AUTORIZADOR POR  | No DO CHEQUE ]
	nLin++
	@ nLin,01 say [                     |                  |                   |              ]
	nLin++
	@ nLin,01 say [Manaus -  ]+DtoC(dDataI)+[ | ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ | ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ | ÄÄÄÄÄÄÄÄÄÄÄÄ ]
	nLin++
	@ nLin,00 say repl([Ä],80)
	nLin++
	@ nLin,40 say [TOTAL GERAL A PAGAR-->>]
	@ nLin,66 say nToR_Vldoc pict "@E 999,999,999.99"
	//
	//Imprimir Valor por Extenso
	nLin++
	nLin++
	@ nLin,10 SAY SUBS( EXTENSO(nTor_Vldoc),01,60)
	nLin++
	@ nLin,10 SAY SUBS( EXTENSO(nTor_Vldoc),61,60)
	//
	EJECT
	SET DEVICE TO SCREEN
	RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela0)
	RETURN(NIL)
