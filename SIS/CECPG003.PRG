// W&R Inform tica Ltda.
// SYSCEC 
// Relatorio das pendencias geral
// Manaus , 23 de Janeiro de 1998
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
		nLin ,;
		lImpFor
		
// Abrir Arquivos
IF !ARQNTX("CECCFOR",.F.) .OR. ;
   !ARQNTX("CECLOGO",.F.) .OR. ;
	!ARQNTX("CECCPAG",.F.)  
	DBCLOSEALL()
	RETURN
ENDIF
//
DO WHILE .T.
	Box(11,01,15,79,fr,127,3,8)
	SETCOLOR("B/W,W+/BG,,,B/W")
	SETCURSOR(1)
	nFornecedor := nFor := 0						  //       EVAL({||DISPOUT("TODOS "),.T.}),;
	dDataI:=dDataF:=Ctod([  /  /  ])
	/*@ 12,02 SAY [Fornecedor.:]; 
	        GET nFornecedor;           
			  PICTURE "@K 99999";          
			  VALID Existe(nFornecedor,[Fornecedor nÆo cadastrado],.F.,'CECCFOR',1,'NOMECLF','@!',ROW(),COL()+2) .AND.;
			        Existe(STRZERO(nFornecedor,5),[Fornecedor nÆo possui lan‡amentos],.F.,"CECCPAG",1) 
	*/				  
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
	Imp_PenGeral(dDataI,dDataF)
	//
EndDo	
RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
DBCLOSEALL()
RETURN

/************************** Funcoes para ImpressÆo ************************/
/**
**/

FUNCTION Imp_PenGeral(dDataInicial,dDataFinal)
LOCAL	_Sai       := .F.,;
		nTotal     := 0,;
		lCab       := .T.,;
		nPage      := 1,;
		nLin       := 0,;
		nCont      := 0,;
		lImpFor    := .T.
		//
		
	SELECT("CECCPAG")
	DBGOTOP()
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
      nFor := Ceccpag->Fornecedor
		SELECT("CECCFOR")                 
		DBSEEK(nFor)							// Acessar dados de Fornecedor
		SELECT("CECCPAG")
		//
		IF !EMPTY(dDataInicial)
			IF CECCPAG->VENCIMENTO<dDataInicial	           // Fora do Periodo
				CECCPAG->(DBSKIP())
				If CECCPAG->FORNECEDOR#nFor
					IF nCont>0
						nLin++
						@ NLIN,00 SAY REPL('-',80)
						nLin++
						@ nLin,001 say [TOTAL DO Fornecedor--->>>]
					   @ nLin,027 say nTot_Vldoc pict "@E 999,999.99"
			   		@ nLin,051 say nTot_Sldoc pict "@E 999,999.99"
					   @ nLin,065 say nTot_Debit pict "@E 999,999.99"
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
			IF VENCIMENTO>dDataF	
				CECCPAG->(DBSKIP())
				If CECCPAG->FORNECEDOR#nFor
					IF nCont>0
						nLin ++
						@ NLIN,00 SAY REPL([-],80)
						nLin++
						@ nLin,001 say [TOTAL DO Fornecedor--->>>]
					   @ nLin,027 say nTot_Vldoc pict "@E 999,999.99"
					   @ nLin,051 say nTot_Sldoc pict "@E 999,999.99"
					   @ nLin,065 say nTot_Debit pict "@E 999,999.99"
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
			Cabecalho(nPage,"PENDENCIAS A FORNECEDORES DE - ("+DTOC(dDataI)+" A "+DTOC(dDataF)+")")
			@PROW(),PCOL() SAY CHR(18) 
			@07,01 SAY "-EMISSAO-  -DOCUMENTO-  --VL.DOCTO--  VENCIMENTO  --VL.PAGO--  ---DEBITO---  BC"
			//          99/99/9999  9999999/99   999.999,99   99/99/9999  999.999,99    999.999,99   99
			//			   01				13           27           39          51            65           78
			@08,00 SAY REPL([Ä],80)
			nLin := 09
			lCab := .F.
			nPage++
		ENDIF
		//
		// Preparar para imprimir detalhes 
		IF CECCPAG->VENCIMENTO<=DATE() .AND. CECCPAG->STATUS=" "
			//
			// Imprimir
			If lImpFor
				nLin++
				@ nLin,000 SAY CHR(15)+ ""
				@ nLin,001 SAY chr(14)+"Fornecedor..:"+STR(CECCPAG->FORNECEDOR,5)+"="+CECCFOR->NOMECLF+chr(18)+""
				lImpFor := .F.
				nLin++
			EndIf
			//
			//			01				13           27           39          51            65           78
			nLin++
			@ nLin,001 SAY CECCPAG->EMISSAO
			@ nLin,013 say CECCPAG->DUPLICATA
			@ nlin,027 say CECCPAG->VALOR  							pict "@E 999,999.99"
			@ nLin,039 say CECCPAG->VENCIMENTO
			@ nLIn,051 say (CECCPAG->VALOR)-(CECCPAG->DEBITO)  pict "@E 999,999.99"
			@ nLin,065 SAY CECCPAG->DEBITO  							pict "@E 999,999.99"
			@ nLin,078 say CECCPAG->BANCO 
			// Calculos de Totais
			nCont++
			nTot_Vldoc += VALOR 
			nTot_Sldoc += (CECCPAG->VALOR)-(CECCPAG->DEBITO)
			nTot_Debit += DEBITO
			nTot_Item++	
			nToR_Vldoc += VALOR
			nToR_Sldoc += (CECCPAG->VALOR)-(CECCPAG->DEBITO)
			nToR_Debit += DEBITO
			nToR_Item++	
		ENDIF	
		//
		CECCPAG->(DBSKIP())
		//
		If CECCPAG->FORNECEDOR#nFor
			IF nCont>0
				nLin ++
				@ NLIN,00 SAY REPL([Ä],80)
				nLin++
				@ nLin,001 say [TOTAL DO FORNECEDOR--->>>]
			   @ nLin,027 say nTot_Vldoc pict "@E 999,999.99"
			   @ nLin,051 say nTot_Sldoc pict "@E 999,999.99"
			   @ nLin,065 say nTot_Debit pict "@E 999,999.99"
				nLin++
				@ nLin,00 say repl([Ä],80)
				nLin++
				nTot_Vldoc:=0
				nTot_Sldoc:=0
				nTot_Debit:=0
				nCont:=0
			ENDIF	
			//
			nFor := CECCPAG->FORNECEDOR
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
   @ nLin,24 say nToR_Vldoc pict "@E 99,999,999.99"
   @ nLin,48 say nToR_Sldoc pict "@E 99,999,999.99"
   @ nLin,62 say nToR_Debit pict "@E 99,999,999.99"
	nLin++
	@ nLin,00 say repl([Ä],80)
	//
	EJECT
	SET DEVICE TO SCREEN
	RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela0)
	RETURN(NIL)
	