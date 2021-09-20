// Sistemas de Controle de Estoque Comercial
// W&R Informatica Ltda
// 04 de Maio de 1998
// Waldemir Litaiff Vasconcelos
// Estoque com preco de venda

#define fr "ÚÄ¿³ÙÄÀ³ "

LOCAL cCor := SETCOLOR("B/W,W+/BG,,,B/W"),;
		nCursor := SETCURSOR(1),;
		cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
		dDataI := CTOD("  /  /    "),;
		dDataF := CTOD("  /  /    "),;
		nLoja := 0,;
		lCab,;
		nLinha := 0,;
		cOrigem := SPACE(1),;
   	nFornecedor:=0,;
		nPage,;
		lTem,;
		cTelao,;
		XTotalVendido:=0,;
		nTotalVenda:=0,;
		aEstoques := {}

// Abre arquivos
IF !ARQNTX("CECCMER",.F.) .OR.;
	!ARQNTX("CECTLIN",.F.) .OR.;
	!ARQNTX("CECCFOR",.F.) .OR.;
	!ARQNTX("CECCLOJ",.F.) .OR.;
	!ARQNTX("CECTLOJ",.F.)
	DBCLOSEALL()
	RETURN
ENDIF		 		

DO WHILE .T.
	Box(16,06,21,75,fr,127,3,8)
	@ 17,08 SAY "Grupo..:";
			  GET nLinha;
			  PICTURE "@K 9999";
			  VALID IF(EMPTY(nLinha),EVAL({||DISPOUT(" Todas                     "),.T.}),;
			        Existe(nLinha,"Grupo de mercadoria nÆo cadastrada",.F.,"CECTLIN",1,"NOMLIN","@!",ROW(),COL()+1))
					  
	@ 18,08 SAY "Origem.:";
			  GET cOrigem;
			  PICTURE "@K!";
			  VALID cOrigem$"NI " .AND.;
			        IF(EMPTY(cOrigem),EVAL({||DISPOUT(" Todas                    "),.T.}),;
			        EVAL({|x|DISPOUT(IF(x=="N","Nacional","Importado")),.T.}))
					  
	@ 19,08 SAY "Fornecedor:";
			  GET nFornecedor;
			  PICTURE "@K 99999";
			  VALID IF(EMPTY(nFornecedor),EVAL({||DISPOUT(" Todos                                                 "),.T.}),;
			        Existe(nFornecedor,"Fornecedor nÆo cadastrado",.F.,"CECCFOR",1,"NOMECLF","@!",ROW(),COL()+1))				  				 
	
	@ 20,08 SAY "Loja......:";
			  GET nLoja;
			  PICTURE "@K 9999";
			  VALID IF(EMPTY(nLoja),EVAL({||DISPOUT(" Todas                                                      "),.T.}),;
			        Existe(nLoja,"Loja nÆo cadastrada",.F.,"CECTLOJ",1,"NOMLOJTL","@!",ROW(),COL()+1) .AND.;
					  Existe(STR(nLoja,4),"Loja nÆo possui mercadorias em estoque",.F.,"CECCLOJ",1))				  				  
	
	READ
	
	IF LASTKEY()==27
		RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
		SETCURSOR(nCursor)
		SETCOLOR(cCor)
		DBCLOSEALL()
		RETURN
	ENDIF
	
	SELECT("CECCMER")
	DBGOTOP()
	//
	cTelao   := SAVESCREEN(0,0,MAXROW(),MAXCOL())
	nTotReal := 0
	nToTComp := 0
	nTotDelt := 0
	M_MESSAGE("Aguarde gerando consulta ...",23)
	_sai := .f.
	aEstoques := {}
	DO WHILE !EOF()
		IF INKEY()==27
			IF M_QUERY("Cancela a consulta",79)
				_sai := .t.
				EXIT
			ENDIF
		ENDIF	
		//	
		IF !Empty(nFornecedor)
		   IF CECCMER->FORNECEDOR#nFornecedor 
				DBSKIP()
				LOOP
			ENDIF	
		ENDIF
		//
		IF !Empty(nLinha)
		   IF CECCMER->CODLINM#nLinha
				DBSKIP()
				LOOP
			ENDIF	
		ENDIF
		//
		IF !Empty(cOrigem)
		   IF CECCMER->ORIGEMM#cOrigem
				DBSKIP()
				LOOP
			ENDIF	
		ENDIF
		//
		/*IF !EMPTY(nLoja)
			IF nLoja#CECCMOV->CODLOJA
				DBSKIP()
				LOOP
			ENDIF
		ENDIF		*/
				
		//x:=ASCAN(aVendas,{|aVet| aVet[1]+aVet[2]==STRZERO(CODLOJA,4)+STRZERO(VENDEDOR,5)})
		//IF x==0
		
		//	AADD(aEstoques,{CODIGOM,DESCRIM,UNIDADE,SALDOEM,PRECVEM,ROUND(PRECVEM * SALDOEM,2) })
		
		//ELSE
		//	aVendas[x,3] += TOTVEND 
		//	aVendas[x,4] += PRECOMPRA  * (-QUANTMOV )
		//	aVendas[x,5] := aVendas[x,3] - aVendas[x,4]
		//ENDIF	
		
		nToTReal += ROUND(PRECVEM * SALDOEM,2) 
		
		DBSKIP()
	ENDDO	
	AADD(aEstoques,{NIL,"TOTAL DO ESTOQUE...:",NIL,NIL,NIL,nToTReal})
	RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTelao)
	
	IF _SAI
		LOOP
	ENDIF	
	
	cCor := SETCOLOR()
	nCursor := SETCURSOR()
	
	aCab := { "CODIGO  ", "DESCRICAO", "UNID.","ESTOQUE ","PRECO VENDA","TOTAL DO ITEM" }
				 
	aPic := { "@!", "@!","@!", "@R 999,999,999.999", "@R 999,999,999.99", "@R 99,999,999,999.99" }
				 
	cObs:="Valor total do Estoque..: R$ "+TRANS(nToTReal,"@E@R 99,999,999,999.99")  			 
	
	HBrowseAR(02,00,24,79,"SALDO DE ESTOQUE :",aCab,aEstoques,aPic)
	
	SETCOLOR(ccor)
	setcursor(ncursor)
		
ENDDO	