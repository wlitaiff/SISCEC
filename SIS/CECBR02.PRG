// W&R Inform tica Ltda.
// SisCEC - Controle de Estoque Comercial - CECPG001 
// Relatorio de Contas a Receber no periodo - Geral
// Manaus , 19 de Janeiro  de 1998
// Waldemir Litaiff Vasconcelos

#include "HAWK.CH"
LOCAL Getlist:={},;
      nCliente,;
		nCli,;
		cCor :=SETCOLOR(),;
	   cTela:=SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
		nCursor := SETCURSOR()
		
PRIVA nTot_Sldoc := nTot_Vldoc := nTot_Debit := 0,;
                nToR_Sldoc := nToR_Vldoc :=TBra :=TBam := TCar := nToR_Debit := 0,;
		nTot_Item := 0,;
		nToR_Item := 0,;
                nBra_dia  := 0,;
                nBam_dia  := 0,;
                nCar_dia  := 0,;
		nTot_Dia  := 0,;
		nLin 

// Abrir Arquivos
IF !ARQNTX("CECCCLI",.f.) .or. ;
   !ARQNTX("CECLOGO",.F.) .OR. ;
	!ARQNTX("CECCREC",.F.)  
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
	IF !IMPRES()
		DBCLOSEALL()
		RETURN
	ENDIF
	//
	M_MESSAGE([Aguarde! Imprimindo...],23)
	//
	Imp_CRecebe(dDataI,dDataF) 
	//
EndDo	
SET SOFTSEEK OFF
RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
DBCLOSEALL()
RETURN

/************************** Funcoes para ImpressÆo ************************/
/**
**/

FUNCTION Imp_CRecebe(dDataInicial,dDataFinal)
LOCAL	_Sai       := .F.,;
		nTotal     := 0,;
		dDia       := 0,;
		lCab       := .T.,;
		nPage      := 1,;
		nLin       := 0,;
		nCont      := 0,;
		lImpDia    ,;
		lImpCli    
	//
	SET SOFTSEEK ON
	SELECT("CECCREC")
	DBSETORDER(2)
	DBSEEK(dDataInicial)
	lImpDia := .T.
	lImpCli := .T.
	nCliente:= CeccREC->CodCliR
	//
   DO WHILE !EOF()
		//
		IF INKEY()==27
			IF Para_Impressao()
				EXIT
			ENDIF
		ENDIF
		//
		dDia := Day(ceccrec->DtVencR)
      nCli := CeccREC->CodClir
		SELECT("CECCCLI")                 
		DBSEEK(nCli)							// Acessar dados do cliente
		SELECT("CECCREC")
		//
		IF !EMPTY(dDataInicial)
			IF DtVencr<dDataInicial	           // Fora do Periodo
				CECCREC->(DBSKIP())
				If Day(CECCREC->DtVencr) # dDia
					IF nCont>0
						nLin++
						@ NLIN,00 SAY REPL('-',80)
						nLin++
                                                @ nLin,01 say "TOTAL DO DIA------------>>>"
                                                @ nLin,66 say nTot_Dia  pict "@E 99,999,999.99"
						nLin++
                                                @ nLin,01 say "TOTAL BRADESCO....[1] -->>>"
                                                @ nLin,66 say nBra_Dia pict "@E 999,999,999.99"
                                                nLin++
                                                @ nLin,01 say "TOTAL BAMERINDUS..[2] -->>>"
                                                @ nLin,66 say nBam_Dia pict "@E 999,999,999.99"
                                                nLin++
                                                @ nLin,01 say "TOTAL CARTEIRA....[3] -->>>"
                                                @ nLin,66 say nCar_dia pict "@E 999,999,999.99"
                                                nLin++
						@ nLin,00 say repl([-],80)
						nLin++
						nTot_Vldoc:=0
						nTot_Sldoc:=0
						nTot_Debit:=0
						nTot_Dia  :=0
                                                nBra_Dia  :=0
                                                nBam_Dia  :=0
                                                nCar_Dia  :=0
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
			IF dtvencr>dDataF	
				CECCREC->(DBSKIP())
				If Day(CECCREC->dtvencr) # dDia
					IF nCont>0
						nLin ++
						@ NLIN,00 SAY REPL('-',80)
						nLin++
                                                @ nLin,001 say "TOTAL DO DIA----------->>>"
						@ nLin,066 say nTot_Dia  pict "@E 99,999,999.99"
						nLin++
                                                @ nLin,01 say "TOTAL BRADESCO....[1] -->>>"
                                                @ nLin,66 say nBra_Dia pict "@E 999,999,999.99"
                                                nLin++
                                                @ nLin,01 say "TOTAL BAMERINDUS..[2] -->>>"
                                                @ nLin,66 say nBam_Dia pict "@E 999,999,999.99"
                                                nLin++
                                                @ nLin,01 say "TOTAL CARTEIRA....[3] -->>>"
                                                @ nLin,66 say nCar_Dia pict "@E 999,999,999.99"
                                                nLin++
						@ nLin,00 say repl([-],80)
						nLin++
						nTot_Vldoc:=0
						nTot_Sldoc:=0
						nTot_Debit:=0
						nTot_dia  :=0
                                                nBra_Dia  :=0
                                                nBam_Dia  :=0
                                                nCar_Dia  :=0
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
			Cabecalho(nPage,"CONTAS A RECEBER NO PERIODO - ("+DTOC(dDataI)+"-"+DTOC(dDataF)+")")
			@PROW(),PCOL() SAY CHR(18) 
                        @07,01 SAY "CLIENTE RAZAO SOCIAL------------------ N.FISCAL--  EMISSAO--- VALOR TOTAL-----BC"
                        //          99999   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXX  99/99/9999  99.999.999,99
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
			@ nLin,001 SAY If(lImpCli,STR(ceccrec->Codclir,5)+"  "+subs(CECCCLI->NOMECLC,1,30),"")
			@ nLin,042 say ceccrec->DOCDUPR
			@ nlin,054 say ceccrec->DTEMISR 
			@ nLin,066 SAY ceccrec->VLDOCTR     pict "@E 99,999,999.99"
                        @ nLin,079 SAY ceccrec->CODBANR
			// Calculos de Totais
			nCont++
			nTot_Vldoc += vldoctr
			nToR_Vldoc += vldoctr

                        IF ceccrec->CODBANR=1
                             TBra += vldoctr
                             nBra_Dia += vldoctr
                        ENDIF
                        IF ceccrec->CODBANR=2
                             TBam += vldoctr
                             nBam_Dia += vldoctr
                        ENDIF
                        IF  ceccrec->CODBANR=3
                             TCar += vldoctr
                             nCar_Dia += vldoctr
                        ENDIF

			nTot_Dia   += vldoctr
			nTot_Item++	
			nToR_Item++	
			lImpCli    := .F.
		ENDIF	
		//
		ceccrec->(DBSKIP())
		If nCliente # ceccrec->CodCliR
			nCliente := ceccrec->CodCliR
			lImpcli  := .T.
		EndIf
		//
		If Day(ceccrec->DtVencr) # dDia
			If nCont>0
				nLin ++
				@ NLIN,00 SAY REPL('-',80)
				nLin++
                                @ nLin,001 say "TOTAL DO DIA-------->>>"
				@ nLin,066 say nTot_Dia  pict "@E 99,999,999.99"
				nLin++
                                @ nLin,01 say "TOTAL BRADESCO....[1] -->>>"
                                @ nLin,66 say nBra_Dia pict "@E 999,999,999.99"
                                nLin++
                                @ nLin,01 say "TOTAL BAMERINDUS..[2] -->>>"
                                @ nLin,66 say nBam_Dia pict "@E 999,999,999.99"
                                nLin++
                                @ nLin,01 say "TOTAL CARTEIRA....[3] -->>>"
                                @ nLin,66 say nCar_Dia pict "@E 999,999,999.99"
                                nLin++
				@ nLin,00 say repl([-],80)
				nLin++
				nTot_Vldoc:=0
				nTot_Sldoc:=0
				nTot_Debit:=0
				nTot_Dia  :=0
                                nBra_Dia  :=0
                                nBam_Dia  :=0
                                nCar_Dia  :=0
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
        @ nLin,01 say "TOTAL GERAL ------------>>>"
	@ nLin,66 say nToR_Vldoc pict "@E 999,999,999.99"
        nLin++
        @ nLin,01 say "TOTAL BRADESCO....[1] -->>>"
        @ nLin,66 say TBra pict "@E 999,999,999.99"
        nLin++
        @ nLin,01 say "TOTAL BAMERINDUS..[2] -->>>"
        @ nLin,66 say TBam pict "@E 999,999,999.99"
        nLin++
        @ nLin,01 say "TOTAL CARTEIRA....[3] -->>>"
        @ nLin,66 say TCar pict "@E 999,999,999.99"

	nLin++
	@ nLin,00 say repl([=],80)
	//
	EJECT
	SET DEVICE TO SCREEN
	RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela0)
	RETURN(NIL)
