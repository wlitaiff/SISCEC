// Consultas pendencias `a Fornecedor
// Manaus , 14 de Setembro de 1998
// Waldemir Litaiff Vasconcelos

#include "HAWK.CH"
LOCAL Getlist      :={},;
      nFornecedor,;
		cCor         :=SETCOLOR(),;
	   cTela        :=SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
		nCursor      := SETCURSOR()

// Abrir Arquivos
IF !ARQNTX("CECCFOR",.F.) .OR. ;
	!ARQNTX("CECCPAG",.F.)  
	DBCLOSEALL()
	RETURN
ENDIF

//
nFornecedor := 0
DO WHILE .T.
	Box(11,01,15,79,fr,127,3,8)
	SETCOLOR("B/W,W+/BG,,,B/W")
	SETCURSOR(1)
	nFornecedor := 0
	dDataI:=dDataF:=Ctod([  /  /  ])
	@ 12,02 SAY [Fornecedor.:]; 
	        GET nFornecedor; 
			  PICTURE "@K 99999"; 
			  VALID Existe(nFornecedor,[Fornecedor n∆o cadastrado],.F.,'CECCFOR',1,'NOMECLF','@!',ROW(),COL()+2) .AND.;
			        Existe(STRZERO(nFornecedor,5),[Fornecedor n∆o possui lanáamentos],.F.,"CECCPAG",1)
					  
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
	
	M_MESSAGE([Aguarde, montando consulta],23)
	
	_Sai := .F.
	nTotal := 0
	aRegistros := {}
	DO WHILE CECCPAG->FORNECEDOR == nFornecedor .AND. !CECCPAG->(EOF())
		IF LASTKEY()=27
			SETCOLOR(cCor)
			RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
			_Sai := .T.
			EXIT
		ENDIF
		IF !EMPTY(dDataI)
			IF DTVENCR<dDataI	
				CECCPAG->(DBSKIP())
				LOOP
			ENDIF
		ENDIF		 
		IF !EMPTY(dDataF)
			IF DTVENCR>dDataF	
				CECCPAG->(DBSKIP())
				LOOP
			ENDIF
		ENDIF		 
		IF CECCPAG->VENCIMENTO<=DATE() .AND. CECCPAG->STATUS=" "
			AADD(aRegistros,{VENCIMENTO,DUPLICATA,VALOR,DEBITO,BANCO})
			nTotal += DEBITO
		ENDIF	
		CECCPAG->(DBSKIP())
	ENDDO
	
	
	RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela0)
	
	IF LEN(aRegistros)#0
		AADD(aRegistros,{NIL,"TOTAL",NIL,nTotal,NIL})
	
		aCab := { "Vencimento","Documento","Valor total","Saldo devedor","Banco"}
		aPic := { "@D","@!","@r@e 9,999,999.99","@r@e 9,999,999.99","99"}

		HBrowseAR(02,00,24,79,"Pendàncias: DE "+DTOC(dDataI)+" A "+DTOC(dDataF)+" : Fornecedor :"+STRZERO(nFornecedor,5)+"-"+ALLTRIM(CECCFOR->NOMECLF),aCab,aRegistros,aPic)
		
	ELSE
		M_DISPLAY("N∆o Existem Pendencias para este Fornecedor!",23)	
	ENDIF

	RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
	
ENDDO
DBCLOSEALL()
RETURN