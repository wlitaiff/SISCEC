// W&R Inform†tica Ltda.
// SisCEC - Controle de Estoque Comercial - CECPG001 
// Relatorio de Contas a Pagar no periodo - CLInecedor
// Manaus , 13 de Janeiro  de 1998
// Waldemir Litaiff Vasconcelos

#include "HAWK.CH"
LOCAL Getlist:={},;
      nCliente,;
		cCor :=SETCOLOR(),;
	   cTela:=SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
		nCursor := SETCURSOR()
		
PRIVA nTot_Sldoc := nTot_Vldoc := nTot_Debit := 0,;
		nToR_Sldoc := nToR_Vldoc := nToR_Debit := 0,;
		nTot_Item := 0,;
		nToR_Item := 0,;
		nTot_Dia  := 0,;
		nTot_Cli  := 0,;
		nLin ,;
		lImpCli
		
// Abrir Arquivos
IF !ARQNTX("CECCCLI",.F.) .OR. ;
   !ARQNTX("CECLOGO",.F.) .OR. ;
	!ARQNTX("CECCREC",.F.)  
	DBCLOSEALL()
	RETURN
ENDIF
//
DO WHILE .T.
	Box(11,01,15,79,fr,127,3,8)
	SETCOLOR("B/W,W+/BG,,,B/W")
	SETCURSOR(1)
	nCliente := 0
	dDataI:=dDataF:=Ctod([  /  /  ])
	//			
	@ 12,02 SAY [CLIENTE..:]; 
	        GET nCliente; 
			  PICTURE "@K 99999";          // EVAL({||DISPOUT("TODOS "),.T.}),
			  VALID Existe(nCliente,[Cliente n∆o cadastrado],.F.,'CECCCLI',1,'NOMECLC','@!',ROW(),COL()+2) .AND.;
			        Existe(STRZERO(nCliente,5),[Cliente n∆o possui lanáamentos],.F.,"CECCREC",1) 
					  
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
	Imp_CCRecebe(nCliente,dDataI,dDataF) 
	//
EndDo	
RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
DBCLOSEALL()
RETURN

/************************** Funcoes para Impress∆o ************************/
/**
**/

FUNCTION Imp_CCRecebe(CodCliente,dDataInicial,dDataFinal)
LOCAL	_Sai       := .F.,;
		nTotal     := 0,;
		dDia       := 0,;
		lCab       := .T.,;
		nPage      := 1,;
		nLin       := 0,;
		nCont      := 0,;
		lImpDia        ,;
		lImpCli
		//
	
	SET SOFTSEEK ON	
	SELECT("CECCREC")
	DBSETORDER(1)
	lImpDia := .T.
	lImpCli := .T.
	SET SOFTSEEK OFF
	//
   DO WHILE CodCliente=CECCREC->CodCliR .AND. !EOF()
		//
		IF INKEY()==27
			IF Para_Impressao()
				EXIT
			ENDIF
		ENDIF
		//
		dDia := Day(CECcREC->DtVencR)
      //
		SELECT("CECCCLI")                 
		DBSEEK(CodCliente)							// Acessar dados de Cliente
		SELECT("CECCREC")
		SET DEVICE TO PRINT
		//
		IF !EMPTY(dDataInicial)
			IF DtVencR<dDataInicial	           // cliente do Periodo
				CECCREC->(DBSKIP())
				If Day(CECCREC->DtVencR) # dDia
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
						lImpCLI := .T.
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
			IF DtVencR>dDataF	
				CECCREC->(DBSKIP())
				If Day(CECCREC->DtVencR) # dDia
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
						lImpCLI := .T.
					EndIf
					lImpDia := .T.
				EndIf
				//
				LOOP
			ENDIF
		ENDIF		 
		//
		// Imprimir Cabecalho
	
		IF lCab 
			Cabecalho(nPage,"CONTAS A PAGAR NO PERIODO - ("+DTOC(dDataI)+"-"+DTOC(dDataF)+")")
			@PROW(),PCOL() SAY CHR(18) 
			@07,01 SAY "CLIENTE  RAZAO SOCIAL------------------  N.FISCAL--  EMISSAO---  VALOR TOAL----"
			//          99999    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XXXXXXXXXX  99/99/9999  999.999.999,99
			//			   01			10                              42          54          66
			@08,00 SAY REPL("-",80)
			nLin := 09
			lCab := .F.
			nPage++
		ENDIF
		//
		// Preparar para imprimir detalhes 
		IF CECCREC->STATUSR=" "
			//
			// Imprimir
			If lImpdia
				nLin++
				@ nLin,000 SAY CHR(15)+ ""
				@ nLin,001 SAY chr(14)+"DATA VENCIMNETO--->>" + DTOC(CECCREC->DTVENCR)+CHR(18)+" "
				lImpDia := .F.
				nLin++
			EndIf
			//
			//	     01 / 10 / 42 / 54 / 66
			nLin++
			@ nLin,001 SAY If(lImpCli,STR(CECCREC->CodCliR,5)+"  "+SUBS(CECCCLI->NOMECLC,1,30),"")
			@ nLin,042 say CECCREC->DOCDUPR
			@ nlin,054 say CECCREC->DTEMISR
			@ nLin,066 SAY CECCREC->VLDOCTR      pict "@E 99,999,999.99"
			// Calculos de Totais
			nCont++
			nTot_Vldoc += VLDOCTR
			nToR_Vldoc += VLDOCTR
			nTot_Dia   += VLDOCTR
			nTot_Item++	
			nToR_Item++	
			lImpCLI := .F.
		ENDIF	
		//
		CECCREC->(DBSKIP())
		//
		If Day(CECCREC->DTVENCR) # dDia
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
				lImpCLI := .T.
			EndIf
			lImpDia := .T.
		EndIf
		//
		If nLin > 57
			lCab    := .T.
			lImpDia := .T.
			lImpCLI := .T.
		EndIf
		//
	ENDDO
	//		
	// Total Geral
	nLin ++
	@ NLIN,00 SAY REPL('-',80)
	nLin++
	@ nLin,01 say [TOTAL GERAL DO CLINECEDOR--->>>]
	@ nLin,66 say nToR_Vldoc pict "@E 99,999,999.99"
	nLin++
	@ nLin,00 say repl([=],80)
	//
	EJECT
	SET DEVICE TO SCREEN
	RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela0)
	RETURN(NIL)