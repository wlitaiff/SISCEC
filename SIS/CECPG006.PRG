// W&R Inform tica Ltda.
// SisCEC - Controle de Estoque Comercial - CECPG006
// Relatorio de duplicatas Pagas - Periodo/Fornecedor
// Manaus , 29 de Janeiro de 1999
// Waldemir Litaiff Vasconcelos

#include "HAWK.CH"
LOCAL Getlist:={},;
      nFornecedor,;
		nFor		  ,;
		cCor  := SETCOLOR(),;
	   cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
		nCursor := SETCURSOR()
		
PRIVA nTot_Sldoc := nTot_Vldoc := nTot_Debit := 0,;
		nToR_Sldoc := nToR_Vldoc := nToR_Debit := 0,;
		nTot_Item  := 0,;
		nToR_Item  := 0,;
		nTot_Dia   := 0,;
		nLin 

// Abrir Arquivos
IF !ARQNTX("CECCFOR",.F.) .OR. ;
   !ARQNTX("CECLOGO",.F.) .OR. ;
	!ARQNTX("CECCPAG",.F.) .OR. ;
	!ARQNTX("CECCPGF",.F.)  
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
	Imp_DupPagas(dDataI,dDataF) 
	//
EndDo	
SET SOFTSEEK OFF
RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
DBCLOSEALL()
RETURN

/************************** Funcao de ImpressÆo ************************/
/**
**/

FUNCTION Imp_DupPagas(dDataInicial,dDataFinal)
LOCAL	_Sai       := .F.,;
		nTotal     := 0,;
		lCab       := .T.,;
		nPage      := 1,;
		nLin       := 0,;
		nCont      := 0,;
		lImpFor    := .T.
		//
		
	SELECT("CECCPGF")
	//
	DBSETORDER(2)
   SET SOFTSEEK ON
   DBSEEK(DTOS(dDataInicial))
   SET SOFTSEEK OFF
	//
	IF EOF()
		M_MESSAGE([Data Inicial nao Encontrada!...],23)
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
      nFor := Ceccpgf->Fornecedor
		SELECT("CECCFOR")                 
		DBSEEK(nFor)							// Acessar dados de Fornecedor
		SELECT("CECCPGF")
		//
		IF !EMPTY(dDataInicial)
			IF CECCPGF->PAGAMENTO<dDataInicial	           // Fora do Periodo
				CECCPGF->(DBSKIP())
				If CECCPGF->FORNECEDOR#nFor
					IF nCont>0
						nLin++
						@ NLIN,00 SAY REPL('-',80)
						nLin++
						@ nLin,001 say [TOTAL DO Fornecedor--->>>]
					   @ nLin,026 say nTot_Vldoc pict "@E 9999,999.99"
						nLin++
						@ nLin,00 say repl([-],80)
						nLin++
						nTot_Vldoc:=0
						nTot_Sldoc:=0
						nTot_Debit:=0
						nCont:=0
					ENDIF	
					//
					If nLin > 54
						lCab := .T.
					EndIf
					lImpCli := .T.
					//
				EndIF
				//
				LOOP
			ENDIF
		ENDIF		 
		//
		IF !EMPTY(dDataF)
			IF PAGAMENTO>dDataF	
				CECCPGF->(DBSKIP())
				If CECCPGF->FORNECEDOR#nFor
					IF nCont>0
						nLin ++
						@ NLIN,00 SAY REPL([-],80)
						nLin++
						@ nLin,001 say [TOTAL DO Fornecedor--->>>]
					   @ nLin,026 say nTot_Vldoc pict "@E 9999,999.99"
						nLin++
						@ nLin,00 say repl([-],80)
						nLin++
						nTot_Vldoc:=0
						nTot_Sldoc:=0
						nTot_Debit:=0
						nCont:=0
					ENDIF	
					//
					If nLin > 54
						lCab := .T.
					EndIf
					lImpFor := .T.
				EndIf
				//
				LOOP
			ENDIF
		ENDIF		 
		//
		// Imprimir Cabecalho
		SET DEVICE TO PRINT
		IF lCab 
			Cabecalho(nPage,"DUPLICATAS PAGAS NO PERIODO - ("+DTOC(dDataI)+" A "+DTOC(dDataF)+")")
			@PROW(),PCOL() SAY CHR(18) 
			@07,01 SAY "DT.PAGTO--  -DOCUMENTO-  --VL.PAGO--  HISTORICO"
			//          99/99/9999   9999999/99  9999.999,99  
			//				01			   13           26           39
			@08,00 SAY REPL([Ä],80)
			nLin := 09
			lCab := .F.
			nPage++
		ENDIF
		//
		// Preparar para imprimir detalhes 
		//IF CECCPAG->STATUS="*"
		//
		// Imprimir
		If lImpFor
			nLin++
			@ nLin,000 SAY CHR(15)+ ""
			@ nLin,001 SAY chr(14)+"Fornecedor..:"+STR(CECCPGF->FORNECEDOR,5)+"="+CECCFOR->NOMECLF+chr(18)+""
			lImpFor := .F.
			nLin++
		EndIf
		//
		//				01			   13           26           39
		nLin++
		@ nLin,01 say CECCPGF->PAGAMENTO
		@ nLin,13 say CECCPGF->DUPLICATA
		@ nlin,26 say CECCPGF->VALOR  	 	PICT "@e 9999,999.99"
		@ nLin,39 SAY SUBS(CECCPGF->HISTORICO,1,40)
		// Calculos de Totais
		nCont++
		nTot_Vldoc += VALOR 
		nTot_Item++	
		nToR_Vldoc += VALOR
		nToR_Item++	
		//
		CECCPGF->(DBSKIP())
		//
		If CECCPGF->FORNECEDOR#nFor
			IF nCont>0
				nLin ++
				@ NLIN,00 SAY REPL([Ä],80)
				nLin++
				@ nLin,001 say [TOTAL DO FORNECEDOR--->>>]
			   @ nLin,026 say nTot_Vldoc pict "@E 9999,999.99"
				nLin++
				@ nLin,00 say repl([Ä],80)
				nLin++
				nTot_Vldoc:=0
				nCont:=0
			ENDIF	
			//
			nFor := CECCPGF->FORNECEDOR
			If nLin > 54
				lCab := .T.
			EndIf
			lImpFor := .T.
		EndIf
		//
		If nLin > 54
			lCab    := .T.
			lImpFor := .T.
		EndIf
		//
	ENDDO
	//		
	// Total Geral
	nLin ++
	@ NLIN,00 SAY REPL([Ä],80)
	nLin++
	@ nLin,01 say [TOTAL GERAL--->>>]
   @ nLin,23 say nToR_Vldoc pict "@E 99,999,999.99"
	nLin++
	@ nLin,00 say repl([Ä],80)
	//
	EJECT
	SET DEVICE TO SCREEN
	RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela0)
	RETURN(NIL)

