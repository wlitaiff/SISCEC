// Relatorio das pendencias por clientes
// Manaus , 19 de Agosto de 1997
// Roberto Falc∆o Rocha/Waldemir Litaiff Vasconcelos

#include "HAWK.CH"
LOCAL Getlist:={},;
      nCliente,;
		nCli,;
		cCor :=SETCOLOR(),;
	   cTela:=SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
		nCursor := SETCURSOR(),;
		nTot_Sldoc := nTot_Vldoc := nTot_Debit := 0,;
		nTot_Item := 0,;
		nLin ,;
		lImpCli
		
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
	Box(11,01,15,79,fr,127,3,8)
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
	
	SETCURSOR(0)
	IF LASTKEY()=27
		SETCOLOR(cCor)
		RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
		EXIT
	ENDIF
	
	cTela0 := SAVESCREEn(0,0,MAXROW(),MAXCOL())
	
	IF !IMPRES()
		DBCLOSEALL()
		RETURN
	ENDIF
	
	M_MESSAGE([Aguarde, Imprimindo],23)
	
	_Sai := .F.
	nTotal := 0
	aRegistros := {}
	lCab := .t.
	nPage := 1
	nLin  := 0
	nCont := 0
	lImpCli := .T.
	//
	SELECT("CECCREC")
	//
	IF EMPTY(nCliente)
		DBGOTOP()
	ENDIF
	//
   DO WHILE IF(!Empty(nCliente),IF(!EMPTY(dDataF),CECCREC->DTVENCR<=dDataF,.T.) .AND. !CECCREC->(EOF()),!CECCREC->(EOF()) )  // .AND. IF(!EMPTY(dDataF),CECCREC->DTVENCR<=dDataF,.T.) )
		//
		IF INKEY()==27
			IF Para_Impressao()
				EXIT
			ENDIF
		ENDIF		
		//
		IF !EMPTY(dDataI)
			IF DTVENCR<dDataI	
				CECCREC->(DBSKIP())
				LOOP
			ENDIF
		ENDIF		 
		IF !EMPTY(dDataF)
			IF DTVENCR>dDataF	
				CECCREC->(DBSKIP())
				LOOP
			ENDIF
		ENDIF		 
		//
		// Imprimir Cabecalho
		SET DEVICE TO PRINT
		IF lCab 
			Cabecalho(nPage,"CLIENTES PENDENTES NO PERIODO - ("+DTOC(dDataI)+"-"+DTOC(dDataF)+")")
			@07,01 SAY "-------------------CLIENTES--------------------  -EMISSAO-  -DOCUMENTO-  ---VL.DOCTO---  VENCIMENTO  ---VL.PAGO---  ---DEBITO---  BC"
//			            99999=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 99/99/9999  9999999/99    99.999.999,99  99/99/9999  99.999.999,99  9.999.999,99  99
//						   01																49          61            75             90          102            117           131  		  
			@08,01 SAY REPL("-",132)
			nLin := 09
			lCab := .F.
			nPage++
		ENDIF
		//
		If Empty(nCliente)         // Lista todos
         nCli := Ceccrec->CodClir
			SELECT("CECCCLI")
			DBSEEK(nCli)
			SELECT("CECCREC")
      Else 
         nCli := nCliente
      EndIf
		// Preparar para imprimir detalhes 
		IF CECCREC->DTVENCR<=DATE() .AND. CECCREC->STATUSR=" "
			//
			// Imprimir
			If lImpCli
				@ nLin,001 SAY CECCREC->CODCLIR
				@ nLin,007 Say "="
				@ nLin,009 Say CECCCLI->NOMECLC
				lImpCli := .F.
			EndIf
			//
			@ nLin,049 SAY CECCREC->DTEMISR
			@ nLin,061 say CECCREC->DOCDUPR
			@ nlin,075 say CECCREC->VLDOCTR							  pict "@E 99,999,999.99"
			@ nLin,090 say CECCREC->DTVENCR
			@ nLIn,102 say (CECCREC->VLDOCTR)-(CECCREC->SLDOCTR) pict "@E 99,999,999.99"
			@ nLin,117 SAY CECCREC->SLDOCTR							  pict "@E 99,999,999.99"
			@ nLin,131 say CECCREC->CODBANR
			// Calculos de Totais
			nCont++
			nTot_Vldoc += VLDOCTR
			nTot_Sldoc += (CECCREC->VLDOCTR)-(CECCREC->SLDOCTR)
			nTot_Debit += SLDOCTR
			nTot_Item++	
			nLin ++
		ENDIF	
		//
		CECCREC->(DBSKIP())
		//
		If Empty(nCliente) .AND. nCont>0               // Lista todos
			If CECCREC->CODCLIR#nCli 
				nLin ++
				@ NLIN,01 SAY REPL('-',132)
				IF nCont>1
					nLin++
					@ nLin,049 say [TOTAL DO CLIENTE--->>>]
				   @ nLin,075 say nTot_Vldoc pict "@E 99,999,999.99"
				   @ nLin,102 say nTot_Sldoc pict "@E 99,999,999.99"
				   @ nLin,117 say nTot_Debit pict "@E 99,999,999.99"
					nLin++
					@ nLin,01 say repl([-],132)
				ENDIF	
				nTot_Vldoc:=0
				nTot_Sldoc:=0
				nTot_Debit:=0
				nCont:=0
				nLin++
				If nLin > 57
					lCab := .T.
				EndIf
				lImpCli := .T.
			endif
		endif
		If nLin > 57
			lCab := .T.
			lImpCli := .T.
		EndIf
		//
	ENDDO
	//		
	nLin ++
	@ NLIN,01 SAY REPL('-',132)
	IF nCont>1
		nLin++
		@ nLin,049 say [TOTAL DO CLIENTE--->>>]
	   @ nLin,075 say nTot_Vldoc pict "@E 99,999,999.99"
	   @ nLin,102 say nTot_Sldoc pict "@E 99,999,999.99"
	   @ nLin,117 say nTot_Debit pict "@E 99,999,999.99"
		nLin++
		@ nLin,01 say repl([=],132)
	ELSE
		nLin++	
		@ nLin,01 say repl([=],132)
	ENDIF	
	EJECT
	SET DEVICE TO SCREEN
	RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela0)
ENDDO
RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
DBCLOSEALL()
RETURN