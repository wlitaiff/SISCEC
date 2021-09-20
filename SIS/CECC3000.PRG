// Sistemas de Controle de Estoque Comercial
// W&R Informatica Ltda
// 09 de Maio de 1996
// Roberto Falcao Rocha
// Vendas / Vendedor

#define fr "⁄ƒø≥Ÿƒ¿≥ "

LOCAL cCor := SETCOLOR("B/W,W+/BG,,,B/W"),;
		nCursor := SETCURSOR(1),;
		cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
		dDataI := CTOD("  /  /    "),;
		dDataF := CTOD("  /  /    "),;
		nLoja := 0,;
		lCab,;
		nLin,;
		nPage,;
		lTem,;
		cTelao,;
		nDescontos:=0,;
		XTotalVendido:=0,;
		nTotalVenda:=0,;
		nVendedor := 0,;
		aVendas := {}

// Abre arquivos
IF !ARQNTX("CECCMER",.F.) .OR.;
	!ARQNTX("CECCVEN",.F.) .OR.;
	!ARQNTX("CECTLOJ",.F.) .OR.;
	!ARQNTX("CECCMOV",.F.) 
	DBCLOSEALL()
	RETURN
ENDIF		 		

DO WHILE .T.
	Box(16,06,21,75,fr,127,3,8)
	@ 17,08 SAY "Data inicial:";
			  GET dDataI;
			  PICTURE "@D"
	@ 18,08 SAY "Data Final..:";
	        GET dDataF;
			  PICTURE "@D";
			  VALID(IF(!EMPTY(dDataI),dDataF>=dDataI,.T.))
	@ 19,08 SAY "Loja........:";
			  GET nLoja PICTURE "9999";
			  VALID IF(EMPTY(nLoja),EVAL({||DISPOUT(" Todas                                                      "),.T.}),;
			        Existe(nLoja,"Loja n∆o cadastrada",.F.,"CECTLOJ",1,"NOMLOJTL","@!",ROW(),COL()+1))
	@ 20,08 SAY "Vendedor....:";
			  GET nVendedor PICTURE "99999";
			  VALID IF(EMPTY(nVendedor),EVAL({||DISPOUT(" Todos                                                      "),.T.}),;
			        Existe(STR(nVendedor,5)+IF(!EMPTY(nLoja),STR(nLoja,4),""),"Vendedor n∆o cadastrado",.F.,"CECCVEN",1,"NOMVEN","@!",ROW(),COL()+1))				  
	READ
	IF LASTKEY()==27
		RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
		SETCURSOR(nCursor)
		SETCOLOR(cCor)
		DBCLOSEALL()
		RETURN
	ENDIF
	
	SELECT("CECCMOV")
	DBSETORDER(8)
	IF EMPTY(dDataI)
		DBGOTOP()
	ELSE
		DBSEEK(DTOS(dDataI),.T.)	
		IF DATAMOV<dDataI .OR. IF(!EMPTY(dDataF),DATAMOV>dDataF,.F.)
			M_DISPLAY("Periodo nao encontrado",79)
			LOOP
		ENDIF
	ENDIF			
	cTelao := SAVESCREEN(0,0,MAXROW(),MAXCOL())
	nTotReal := 0
	nToTComp := 0
	nTotDelt := 0
	M_MESSAGE("Aguarde gerando consulta ...",23)
	_sai := .f.
	AVENDAS := {}
	DO WHILE IF(!EMPTY(dDataF),CECCMOV->DATAMOV<=dDataF,.T.) .AND. !EOF()
		IF INKEY()==27
			IF M_QUERY("Cancela a consulta",79)
				_sai := .t.
				EXIT
			ENDIF
		ENDIF		
		IF CECCMOV->CODMOV#"CV" .AND. CECCMOV->CODMOV#"VE"
			DBSKIP()
			LOOP
		ENDIF	
		IF !EMPTY(nLoja)
			IF nLoja#CECCMOV->CODLOJA
				DBSKIP()
				LOOP
			ENDIF
		ENDIF		
		IF !EMPTY(nVendedor)
			IF CECCMOV->VENDEDOR#nVendedor
				DBSKIP()
				LOOP
			ENDIF	
		ENDIF	
				
		x:=ASCAN(aVendas,{|aVet| aVet[1]+aVet[2]==STRZERO(CODLOJA,4)+STRZERO(VENDEDOR,5)})
		IF x==0
			AADD(aVendas,{STRZERO(CODLOJA,4),STRZERO(VENDEDOR,5),TOTVEND,PRECOMPRA * (-QUANTMOV),TOTVEND - (PRECOMPRA * (-QUANTMOV)) })
		ELSE
			aVendas[x,3] += TOTVEND 
			aVendas[x,4] += PRECOMPRA  * (-QUANTMOV )
			aVendas[x,5] := aVendas[x,3] - aVendas[x,4]
		ENDIF	
		nToTReal += TOTVEND 
		nToTComp += PRECOMPRA  * (-QUANTMOV )
		nTotDelt := nToTReal - nToTComp
		DBSKIP()
	ENDDO	
	AADD(aVendas,{NIL,"TOTAL",nToTReal,nToTComp,nToTDelt})
	RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTelao)
	
	IF _SAI
		LOOP
	ENDIF	
	
	cCor := SETCOLOR()
	NcURSOR := SETCURSOR()
	aCab := { "Loja     ", "Vendedor    ", "Valor das vendas", "Valor de compra", "Delta" }
				 
	aPic := { "@!", "@!", "@R 99,999,999,999.99", "@R 99,999,999,999.99", "@R 99,999,999,999.99" }
				 
	cObs:="Valor total das vendas : R$ "+TRANS(nToTReal,"@E@R 99,999,999,999.99")  			 
	
	HBrowseAR(02,00,24,79,"VENDAS / VENDEDORES :"+ DTOC(dDataI)+"-"+dtoc(ddataf),aCab,aVendas,aPic)
	
	SETCOLOR(ccor)
	setcursor(ncursor)
		
ENDDO	