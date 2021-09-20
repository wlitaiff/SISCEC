// W&R Inform tica Ltda.
// SisCEC - Controle de Estoque Comercial - CECCR010 
// Consulta de Contas a Receber no periodo - Geral
// Manaus , 25 de Abril  de 1998
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
	M_MESSAGE([Aguarde! Gerando Consulta...],23)
	//
	Con_CRecebe(dDataI,dDataF) 
	//
EndDo	
SET SOFTSEEK OFF
RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
DBCLOSEALL()
RETURN

/************************** Funcao para consulta **************************/
/**
**/

FUNCTION Con_CRecebe(dDataInicial,dDataFinal)
LOCAL	_Sai       := .F.,;
		nTotal     := 0,;
		dDia       := 0,;
		lCab       := .T.,;
		nPage      := 1,;
		nLin       := 0,;
		nCont      := 0,;
		lImpDia    := .f.
		lImpCli    := .f.
		aCReceber  := {}
	//
	SET SOFTSEEK ON
	SELECT("CECCREC")
	DBSETORDER(2)
	IF EMPTY(dDataInicial)
		DBGOTOP()
	ELSE
		DBSEEK(dDataInicial)
	ENDIF
	//
	nCliente:= CeccREC->CodCliR
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
		dDia := Day(ceccrec->DtVencR)
      nCli := CeccREC->CodClir
		SELECT("CECCCLI")                 
		DBSEEK(nCli)							// Acessar dados do cliente
		SELECT("CECCREC")
		//
		dDia := Day(ceccrec->DtVencR)
		//
		IF !EMPTY(dDataInicial)
			IF DtVencr<dDataInicial	           // Fora do Periodo
				CECCREC->(DBSKIP())
				If Day(CECCREC->DtVencr) # dDia
					IF nCont>0
						AADD(aCReceber,{"","TOTAL DO DIA..:","","","",nTot_Dia})
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
			IF dtvencr>dDataFinal
				CECCREC->(DBSKIP())
				If Day(CECCREC->dtvencr) # dDia
					IF nCont>0
						AADD(aCReceber,{"","TOTAL DO DIA..:","","","",nTot_Dia})
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
                        IF CECCREC->STATUSR=" "
				//
				//	Adicionar dados ao Vetor
				AADD(aCReceber,{ceccrec->Codclir,subs(CECCCLI->NOMECLC,1,30),ceccrec->DOCDUPR,ceccrec->DTEMISR,ceccrec->DTVENCR,ceccrec->VLDOCTR})
				// Calculos de Totais
				nCont++
				nTot_Vldoc += vldoctr
				nToR_Vldoc += vldoctr
				nTot_Dia   += vldoctr
				nTot_Item++	
				nToR_Item++	
			ENDIF	
			//
			ceccrec->(DBSKIP())
			//
			If Day(ceccrec->DtVencr) # dDia
				If nCont>0
					AADD(aCReceber,{"","TOTAL DO DIA..:","","","",nTot_Dia})
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
	AADD(aCReceber,{NIL,"TOTAL GERAL DO PERIODO..:",NIL,NIL,NIL,nToR_VlDoc})
	//
	cCor 	  := SETCOLOR()
	nCursor := SETCURSOR()
	//
	IF _SAI
		RETURN(NIL)
	ENDIF	
	//
	aCab:={"CLIENTE","RAZAO SOCIAL------------------","N.FISCAL--","EMISSAO---","VENCIMENTO","VALOR TOTAL----"}
	aPic:={"99999","@!","@!","@D","@D","@R 99,999,999.99"}
	HBrowseAR(02,00,24,79,"CONTAS A RECEBER NO PERIODO DE ("+DTOC(dDataI)+" A "+DTOC(dDataF)+")",aCab,aCReceber,aPic)
	//		
	SETCOLOR(cCor)
	SETCURSOR(nCursor)
	//
	RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela0)
	RETURN(NIL)
