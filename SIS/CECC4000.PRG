// Consultas pendencias de clientes
// Manaus , 18 de Agosto de 1997
// Roberto Falc∆o Rocha

#include "HAWK.CH"
LOCAL Getlist:={},;
      nCliente,;
		cCor :=SETCOLOR(),;
	   cTela:=SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
		nCursor := SETCURSOR()

// Abrir Arquivos
IF !ARQNTX("CECCCLI",.F.) .OR. ;
	!ARQNTX("CECCREC",.F.)  
	DBCLOSEALL()
	RETURN
ENDIF

//
nCliente := 0
DO WHILE .T.
	Box(11,01,15,79,fr,127,3,8)
	SETCOLOR("B/W,W+/BG,,,B/W")
	SETCURSOR(1)
	nCliente := 0
	dDataI:=dDataF:=Ctod([  /  /  ])
	@ 12,02 SAY [Cliente.:]; 
	        GET nCliente; 
			  PICTURE "@K 99999"; 
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
	DO WHILE CECCREC->CODCLIR == nCliente .AND. !CECCREC->(EOF())
		IF LASTKEY()=27
			SETCOLOR(cCor)
			RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
			_Sai := .T.
			EXIT
		ENDIF
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
		IF CECCREC->DTVENCR<=DATE() .AND. CECCREC->STATUSR=" "
			AADD(aRegistros,{DTVENCR,DOCDUPR,VLDOCTR,SLDOCTR,CODBANR})
			nTotal += SLDOCTR
		ENDIF	
		CECCREC->(DBSKIP())
	ENDDO
	
	
	RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela0)
	
	IF LEN(aRegistros)#0
		AADD(aRegistros,{NIL,"TOTAL",NIL,nTotal,NIL})
	
		aCab := { "Vencimento","Documento","Valor total","Saldo devedor","Banco"}
		aPic := { "@D","@!","@r@e 9,999,999.99","@r@e 9,999,999.99","99"}

		HBrowseAR(02,00,24,79,"Pendàncias: DE "+DTOC(dDataI)+" A "+DTOC(dDataF)+" : Cliente :"+STRZERO(nCliente,5)+"-"+ALLTRIM(CECCCLI->NOMECLC),aCab,aRegistros,aPic)
	ELSE
		M_DISPLAY("Este cliete n∆o possui pendàncias",23)	
	ENDIF

	RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
	
ENDDO
DBCLOSEALL()
RETURN

