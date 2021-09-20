// W&R Inform†tica Ltda.
// SYSCEC 
// Relatorio das pendencias por clientes
// Manaus , 19 de Agosto de 1997
// Waldemir Litaiff Vasconcelos

#include "HAWK.CH"
LOCAL Getlist:={},;
      nCliente,;
		nCli,;
		cCor :=SETCOLOR(),;
	   cTela:=SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
		nCursor := SETCURSOR()
		
PRIVA nTot_Sldoc := nTot_Vldoc := nTot_Debit := 0,;
		nToR_Sldoc := nToR_Vldoc := nToR_Debit := 0,;
		nTot_Item := 0,;
		nToR_Item := 0,;
		nLin ,;
		lImpCli

SET PROCEDURE TO BPLIB
SET DATE BRITISH
// Abrir Arquivos
IF !ARQNTX("CECCCLI",.F.) .OR. ;
   !ARQNTX("CECLOGO",.F.) .OR. ;
	!ARQNTX("CECCREC",.F.)  
	!ARQNTX("CECCPTG",.F.)  
	DBCLOSEALL()
	RETURN
ENDIF
//
nCliente := 0
DO WHILE .T.
     *   Box(11,01,15,79,fr,127,3,8)
	SETCOLOR("B/W,W+/BG,,,B/W")
	SETCURSOR(1)
	nCliente := nCli := 0
	dDataI:=dDataF:=Ctod([  /  /  ])
	@ 12,02 SAY [Cliente.:]; 
	        GET nCliente; 
			  PICTURE "@K 99999"; 
			  VALID IF(EMPTY(nCliente),EVAL({||DISPOUT("TODOS "),.T.}),;
			  		  Existe(nCliente,[Cliente n∆o cadastrado],.F.,'CECCCLI',1,'NOMECLC','@!',ROW(),COL()+2) .AND.;
			        Existe(STRZERO(nCliente,5),[Cliente n∆o possui lanáamentos],.F.,"CECCREC",1) )
					  
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
*        IF !IMPRES()
*                DBCLOSEALL()
*                RETURN
*        ENDIF
*        //
*       * M_MESSAGE([Aguarde! Imprimindo...],23)
	//
	If( EMPTY(nCliente),Imp_TodosClientes(nCliente,dDataI,dDataF),Imp_UmCliente(nCliente,dDataI,dDataF) )
	//
EndDo	
RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
DBCLOSEALL()
RETURN

/************************** Funcoes para Impress∆o ************************/
/**
**/

FUNCTION Imp_TodosClientes(Cliente,dDataInicial,dDataFinal)
LOCAL	_Sai       := .F.,;
		nTotal     := 0,;
		lCab       := .T.,;
		nPage      := 1,;
		nLin       := 0,;
		nCont      := 0,;
		lImpCli    := .T.
		//
		
	SELECT("CECCREC")
        SET ORDER TO 4
	DBGOTOP()
	//
   DO WHILE !EOF()
		//
		IF INKEY()==27
                     *   IF Para_Impressao()
				EXIT
                     *   ENDIF
		ENDIF
		//
      nCli := Ceccrec->CodClir
		SELECT("CECCCLI")                 
		DBSEEK(nCli)							// Acessar dados de Cliente
		SELECT("CECCREC")
		//
		IF !EMPTY(dDataInicial)
                        IF DTEMISR<dDataInicial            // Fora do Periodo
				CECCREC->(DBSKIP())
				If CECCREC->CODCLIR#nCli 
					IF nCont>0
						nLin++
						@ NLIN,00 SAY REPL('-',80)
						nLin++
						@ nLin,001 say [TOTAL DO CLIENTE--->>>]
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
						If nLin > 52
							lCab := .T.
						EndIf
						lImpCli := .T.
					ENDIF	
					//
				EndIF
				//
				LOOP
			ENDIF
		ENDIF		 
		//
		IF !EMPTY(dDataF)
                        IF DTEMISR>dDataF 
				CECCREC->(DBSKIP())
				If CECCREC->CODCLIR#nCli 
					IF nCont>0
						nLin ++
						@ NLIN,00 SAY REPL('-',80)
						nLin++
						@ nLin,001 say [TOTAL DO CLIENTE--->>>]
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
						If nLin > 52
							lCab := .T.
						EndIf
						lImpCli := .T.
					ENDIF	
					//
				EndIf
				//
				LOOP
			ENDIF
		ENDIF		 
		//
		// Imprimir Cabecalho
		SET DEVICE TO PRINT
		IF lCab 
			Cabecalho(nPage,"CLIENTES PENDENTES NO PERIODO - ("+DTOC(dDataI)+"-"+DTOC(dDataF)+")")
			@PROW(),PCOL() SAY CHR(18) 
			@07,01 SAY "-EMISSAO-  -DOCUMENTO-  --VL.DOCTO--  VENCIMENTO  --VL.PAGO--  ---DEBITO---  BC"
			//          99/99/9999  9999999/99   999.999,99   99/99/9999  999.999,99    999.999,99   99
			//			   01				13           27           39          51            65           78
			@08,00 SAY REPL("-",80)
			nLin := 09
			lCab := .F.
			nPage++
		ENDIF
		//
		// Preparar para imprimir detalhes 
                IF CECCREC->DTEMISR<=DATE() .AND. CECCREC->STATUSR=" "
			//
			// Imprimir
			If lImpCli
				nLin++
				@ nLin,000 SAY CHR(15)+ ""
				@ nLin,001 SAY chr(14)+"CLIENTE..:"+STR(CECCREC->CODCLIR,5)+"="+CECCCLI->NOMECLC+chr(18)+""
				lImpCli := .F.
				nLin++
			EndIf
			//
			//			01				13           27           39          51            65           78
			nLin++
			@ nLin,001 SAY CECCREC->DTEMISR
			@ nLin,013 say CECCREC->DOCDUPR
			@ nlin,027 say CECCREC->VLDOCTR							  pict "@E 999,999.99"
			@ nLin,039 say CECCREC->DTVENCR
			@ nLIn,051 say (CECCREC->VLDOCTR)-(CECCREC->SLDOCTR) pict "@E 999,999.99"
			@ nLin,065 SAY CECCREC->SLDOCTR							  pict "@E 999,999.99"
			@ nLin,078 say CECCREC->CODBANR
			// Calculos de Totais
			nCont++
			nTot_Vldoc += VLDOCTR
			nTot_Sldoc += (CECCREC->VLDOCTR)-(CECCREC->SLDOCTR)
			nTot_Debit += SLDOCTR
			nTot_Item++	
			nToR_Vldoc += VLDOCTR
			nToR_Sldoc += (CECCREC->VLDOCTR)-(CECCREC->SLDOCTR)
			nToR_Debit += SLDOCTR
			nToR_Item++	
		ENDIF	
		//
		CECCREC->(DBSKIP())
		//
		If CECCREC->CODCLIR#nCli 
			IF nCont>0
				nLin ++
				@ NLIN,00 SAY REPL('-',80)
				nLin++
				@ nLin,001 say [TOTAL DO CLIENTE--->>>]
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
			If nLin > 52
				lCab := .T.
			EndIf
			lImpCli := .T.
		EndIf
		//
		If nLin > 52
			lCab    := .T.
			lImpCli := .T.
		EndIf
		//
	ENDDO
	//		
	// Total Geral
	nLin ++
	@ NLIN,00 SAY REPL('-',80)
	nLin++
	@ nLin,01 say [TOTAL GERAL--->>>]
   @ nLin,24 say nToR_Vldoc pict "@E 99,999,999.99"
   @ nLin,48 say nToR_Sldoc pict "@E 99,999,999.99"
   @ nLin,62 say nToR_Debit pict "@E 99,999,999.99"
	nLin++
	@ nLin,00 say repl([=],80)
	//
	EJECT
	SET DEVICE TO SCREEN
	RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela0)
	DBSETORDER(1)
	RETURN(NIL)
	
	
*FUNCTION Imp_UmClientes(Cliente,dDataInicial,dDataFinal)
*        LOCAL   _Sai       := .F.,;
*                        nTotal     := 0,;
*                        lCab       := .T.,;
*                        nPage      := 1,;
*                        nLin       := 0,;
*                        nCont      := 0,;
*                        lImpCli    := .T.
*                        //
*         
*        SELECT("CECCREC")
*        //
*        DBSEEK(STRZERO(Cliente,5))
*        //
*   DO WHILE IF(!EMPTY(dDataFinal),CECCREC->DTVENCR<=dDataFinal,.T.) .AND. CECCREC->CODCLIR=Cliente .AND. !CECCREC->(EOF())
*                //
*                IF INKEY()==27
*                        IF Para_Impressao()
*                                EXIT
*                        ENDIF
*                ENDIF
*                //
*                IF !EMPTY(dDataInicial)
*                        IF DTVENCR<dDataInicial 
*                                CECCREC->(DBSKIP())
*                                //
*                                If nLin > 54
*                                        lCab    := .T.
*                                        lImpCli := .T.
*                                EndIf
*                                //
*                                LOOP
*                        ENDIF
*                ENDIF            
*                //
*                IF !EMPTY(dDataFinal)
*                        IF DTVENCR>dDataFinal 
*                                CECCREC->(DBSKIP())
*                                //
*                                If nLin > 54
*                                        lCab    := .T.
*                                        lImpCli := .T.
*                                EndIf
*                                //
*                                LOOP
*                        ENDIF
*                ENDIF            
*                //
*                // Imprimir Cabecalho
*                SET DEVICE TO PRINT
*                IF lCab 
*                        Cabecalho(nPage,"CLIENTES PENDENTES NO PERIODO - ("+DTOC(dDataI)+"-"+DTOC(dDataF)+")")
*                        @PROW(),PCOL() SAY CHR(18) 
*                        @07,01 SAY "-EMISSAO-  -DOCUMENTO-  --VL.DOCTO--  VENCIMENTO  --VL.PAGO--  ---DEBITO---  BC"
*                        //          99/99/9999  9999999/99   999.999,99   99/99/9999  999.999,99    999.999,99   99
*                        //                         01                           13           27           39          51            65           78
*                        @08,00 SAY REPL("-",80)
*                        nLin := 09
*                        lCab := .F.
*                        nPage++
*                ENDIF
*                //
*                // Preparar para imprimir detalhes 
*                IF CECCREC->DTVENCR<=DATE() .AND. CECCREC->STATUSR=" "
*                        //
*                        // Imprimir
*                       If lImpCli
*                                nLin++
*                                @ nLin,000 SAY CHR(15)+ ""
*                                @ nLin,001 SAY CHR(14)+"CLIENTE..:"+STR(CECCREC->CODCLIR,5)+"="+CECCCLI->NOMECLC+CHR(18)+""
*                                lImpCli := .F.
*                                nLin++
*                        EndIf
*                        //
*                        //                      01                              13           27           39          51            65           78
*                        nLin++
*                        @ nLin,001 SAY CECCREC->DTEMISR
*                        @ nLin,013 say CECCREC->DOCDUPR
*                        @ nlin,027 say CECCREC->VLDOCTR                                                   pict "@E 999,999.99"
*                        @ nLin,039 say CECCREC->DTVENCR
*                        @ nLIn,051 say (CECCREC->VLDOCTR)-(CECCREC->SLDOCTR) pict "@E 999,999.99"
*                        @ nLin,065 SAY CECCREC->SLDOCTR                                                   pict "@E 999,999.99"
*                        @ nLin,078 say CECCREC->CODBANR
*                        // Calculos de Totais
*                        nCont++
*                        nTot_Vldoc += VLDOCTR
*                        nTot_Sldoc += (CECCREC->VLDOCTR)-(CECCREC->SLDOCTR)
*                        nTot_Debit += SLDOCTR
*                        nTot_Item++ 
*                        nToR_Vldoc += VLDOCTR
*                        nToR_Sldoc += (CECCREC->VLDOCTR)-(CECCREC->SLDOCTR)
*                        nToR_Debit += SLDOCTR
*                        nToR_Item++ 
*                ENDIF 
*                //
*                CECCREC->(DBSKIP())
*                //
*                If nLin > 54
*                        lCab := .T.
*                        lImpCli := .T.
*                EndIf
		//
*        ENDDO
*        //       
*        nLin ++
*        @ NLIN,00 SAY REPL('-',80)
*        nLin++
*        @ nLin,01 say [TOTAL DO CLIENTE--->>>]
*   @ nLin,24 say nToR_Vldoc pict "@E 99,999,999.99"
*   @ nLin,48 say nToR_Sldoc pict "@E 99,999,999.99"
*   @ nLin,62 say nToR_Debit pict "@E 99,999,999.99"
*        nLin++
*        @ nLin,00 say repl([=],80)
*        //
*        EJECT
*        SET DEVICE TO SCREEN
*        RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela0)
*        RETURN(NIL)
