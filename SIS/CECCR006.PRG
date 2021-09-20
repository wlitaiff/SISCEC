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
IF !ARQNTX("CECCCLI",.F.) .OR. ;
   !ARQNTX("CECLOGO",.F.) .OR. ;
	!ARQNTX("CECCREC",.F.) .OR. ;
	!ARQNTX("CECCPGT",.F.)  
	DBCLOSEALL()
	RETURN
ENDIF
//
DO WHILE .T.
	Box(11,01,14,79,fr,127,3,8)
	SETCOLOR("B/W,W+/BG,,,B/W")
	SETCURSOR(1)
	//
	nCliente := nCli := 0
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
	Imp_DupReceb(dDataI,dDataF) 
	//
EndDo	
SET SOFTSEEK OFF
RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
DBCLOSEALL()
RETURN

/************************** Funcao de ImpressÆo ************************/
/**
**/

FUNCTION Imp_DupReceb(dDataInicial,dDataFinal)
LOCAL	_Sai       := .F.,;
		nTotal     := 0,;
		lCab       := .T.,;
		nPage      := 1,;
		nLin       := 0,;
		nCont      := 0,;
		lImpCli    := .T.
		//
		
	SELECT("CECCPGT")
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
      nFor := Ceccpgt->codclip
		SELECT("CECCCLI")                 
		DBSEEK(nCli)							// Acessar dados de Cliente
		SELECT("CECCPGF")
		//
		IF !EMPTY(dDataInicial)
			IF CECCPGT->PAGAMENTO<dDataInicial	           // Fora do Periodo
				CECCPGT->(DBSKIP())
				If CECCPGT->CODCLIP#nCli
					IF nCont>0
						nLin++
						@ NLIN,00 SAY REPL('-',80)
						nLin++
						@ nLin,001 say [TOTAL DO CLIENTE--->>>]
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
				CECCPGT->(DBSKIP())
				If CECCPGT->CODCLIP#nCli
					IF nCont>0
						nLin ++
						@ NLIN,00 SAY REPL([-],80)
						nLin++
						@ nLin,001 say [TOTAL DO CLIENTE--->>>]
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
				EndIf
				//
				LOOP
			ENDIF
		ENDIF		 
		//
		// Imprimir Cabecalho
		SET DEVICE TO PRINT
		IF lCab 
			Cabecalho(nPage,"DUPLICATAS RECEBIDAS NO PERIODO - ("+DTOC(dDataI)+" A "+DTOC(dDataF)+")")
			@PROW(),PCOL() SAY CHR(18) 
			@07,01 SAY "DT.PAGTO--  -DOCUMENTO-  ---VALOR---  HISTORICO"
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
		If lImpCli
			nLin++
			@ nLin,000 SAY CHR(15)+ ""
			@ nLin,001 SAY chr(14)+"Cliente..:"+STR(CECCPGT->CODCLIP,5)+"="+CECCCLI->NOMECLC+chr(18)+""
			lImpCli := .F.
			nLin++
		EndIf
		//
		//				01			   13           26           39
		nLin++
		@ nLin,01 say CECCPGT->DTPAGAP
		@ nLin,13 say CECCPGT->DOCDUPP
		@ nlin,26 say CECCPGT->VLPAGAP  	 	PICT "@e 9999,999.99"
		@ nLin,39 SAY SUBS(CECCPGT->HISTORICO,1,40)
		// Calculos de Totais
		nCont++
		nTot_Vldoc += VLPAGAP 
		nTot_Item++	
		nToR_Vldoc += VLPAGAP
		nToR_Item++	
		//
		CECCPGT->(DBSKIP())
		//
		If CECCPGT->CODCLIP#nCli
			IF nCont>0
				nLin ++
				@ NLIN,00 SAY REPL([Ä],80)
				nLin++
				@ nLin,001 say [TOTAL DO CLIENTE--->>>]
			   @ nLin,026 say nTot_Vldoc pict "@E 9999,999.99"
				nLin++
				@ nLin,00 say repl([Ä],80)
				nLin++
				nTot_Vldoc:=0
				nCont:=0
			ENDIF	
			//
			nFor := CECCPGT->CODCLIP
			If nLin > 54
				lCab := .T.
			EndIf
			lImpCli := .T.
		EndIf
		//
		If nLin > 54
			lCab    := .T.
			lImpCli := .T.
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