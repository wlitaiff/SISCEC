// Sistemas de Controle de Estoque Comercial
// W&R Informatica Ltda
// 10 de Novembro de 1995
// Roberto Falcao Rocha
// Cadastro de pedidos via balcao e consulta de precos
#INCLUDE "INKEY.CH"
LOCAL cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
		cCor := SETCOLOR(),;
		nCursor := SETCURSOR(0),;
		aDad := {"CODIGOM","REFEREM","DESCRIM","PRECVEM","SALDOEM","UNIDADE",;
					"CAUTELA","CODLINM","FORNECM","ORIGEMM"},;
		aCab := {"Material","Referˆncia","Descri‡Æo","Pre‡o","Estoque","Unidade",;
					"Qtd. Cautela","Grupo","Fornecedor","Origem"},;
		aPic := {"@!","@!","@!","@E@R 9,999,999.99","@R@E 99,999,999.999","@!","9999";
					"99,999,999.999","9999","99999","!"}

// Verificando arquivos
IF !ARQNTX("CECCBAL1",.F.) .OR. ;
	!ARQNTX("CECCBAL2",.F.) .OR. ;
	!ARQNTX("CECTLOJ",.F.) .OR. ;
	!ARQNTX("CECCVEN",.F.) .OR. ;
	!ARQNTX("CECCLOJ",.F.) .OR. ;
	!ARQNTX("CECCSET",.F.) .OR. ;
	!ARQNTX("CECLOGO",.F.) .OR. ;
	!ARQNTX("CECCCLI",.F.) .OR. ;
	!ARQNTX("CECTLIN",.F.) .OR. ;
	!ARQNTX("CECCFOR",.F.) .OR. ;
	!ARQNTX("CECCMER",.F.) 
	DBCLOSEALL()
	RETURN
ENDIF	

DBSETORDER(3)
DBGOTOP()
HBrowseDB( 1,0,24,79,"Cadastro de mercadorias",aCab,aDad,aPic,NIL,,,.F.,"CECM4000")
DBCLOSEAll()
RETURN

FUNCTION CBalcao( oBrowse )
	LOCAL cCor := SETCOR(m->cEdicao),;
			nCursor := SETCURSOR(1),;
			cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
			nReg := RECNO(),;
			nLoja:=0,;
			nVendedor:=0,;
			nTDesconto:=0,;
			cFiscal:=" ",;
			aDescItem[50],;
			aCodigo[50],;
			aPrecoU[50],;
			aReferencia[50],;
			aQuantidade[50],;
			_SAI:=.F.,;
			GetList:={},;
                        nSubTotal:=0

        LOCAL           nTotal:=0,;
			nTotalP := 0,;
			nDesc:=0,;
			nDesc2:=0,;
			nCliente := 1,;
                        nI,nTAXA,nJUROS;
			nX


	IF CECCSET->IMPFIS==0
		nLoja := 1
	ENDIF

	AFILL(aCodigo,SPACE(16))
	AFILL(aReferencia,SPACE(10))
	AFILL(aQuantidade,0)
	AFILL(aPrecoU,0)
	AFILL(aDescItem,0)
	
	IF FILE("NPEDIDO.MEM")
		RESTORE FROM NPEDIDO ADDITIVE
	ELSE
		M->nPed:=0
		SAVE ALL LIKE NPED TO NPEDIDO
	ENDIF		
	_SAI := .f.
	__nDesconto := 0
	nJuros := 0
	cAprazo := "N"
	DO WHILE .T.
		IF !_SAI 
			AFILL(aCodigo,SPACE(16))
			AFILL(aReferencia,SPACE(10))
			AFILL(aQuantidade,0)
			AFILL(aPrecoU,0)
			AFILL(aDescItem,0)
			__nDesconto := 0
			nJuros := 0
			cAprazo := "N"
		ENDIF	
		RESTORE FROM NPEDIDO ADDITIVE
		m->nPed++			
		SAVE ALL LIKE NPED TO NPEDIDO
		nSubTotal := 0
		nTotal := 0
		nTotalP := 0
		nDesc := 0
		nDesc2 := 0
		BOX(03,01,08,79,M->FR,127,3,8)
		@ 04,02 SAY "Pedido No.:"+STRZERO(M->nPed,10)
		@ 05,02 SAY "Loja......:";
		        GET nLoja;
				  PICTURE "@K 9999";
				  VALID !EMPTY(nLoja) .AND.;
				  Existe(nLoja,"Loja nÆo cadastrada",.F.,"CECTLOJ",1,"NOMLOJTL","@!",ROW(),COL()+1)
				  
		@ 06,02 SAY "Vendedor..:";		  
				  GET nVendedor;
				  PICTURE "@K 99999";
				  VALID !EMPTY(nVendedor) .AND.;
				  Existe(STR(nVendedor,5)+STR(nLoja,4),"Vendedor nÆo cadastrado ou nÆo ‚ desta loja",.F.,"CECCVEN",1,"NOMVEN","@!",ROW(),COL()+1)
		
		@ 07,02 SAY "Cliente:";
				  GET nCliente;
				  PICTURE "@K 99999";
				  VALID !EMPTY(nCliente) .AND.;
				  Existe(nCliente,"Cliente nÆo cadastrado",.F.,"CECCCLI",1,"NOMECLC","@!",ROW(),COL()+1) .AND.;
				  EVAL({||__nDesconto:=CECCCLI->DESCONTO,.T.})
		
		READ
		IF LASTKEY()==27
			SETCURSOR(nCursor)
			SETCOLOR(cCor)
			RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
			DBGOTO(nReg)
			oBrowse:refreshAll()
			RETURN(NIL)
		ENDIF			  
		
		IF nCliente > 1
		cAprazo := "N"
		nJuros := 0
		@ 04,63 SAY "· prazo..:";
				  GET cAprazo;
				  PICTURE "!";
				  VALID cAprazo$"NS";
				  WHEN nCliente>1		  
		
		@ 05,63 SAY "Juros....:";
				  GET nJuros;
				  PICTURE "99.99";
				  WHEN cAprazo=="S"		  
		  
		READ
		IF LASTKEY()==27
			SETCURSOR(nCursor)
			SETCOLOR(cCor)
			RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
			DBGOTO(nReg)
			oBrowse:refreshAll()
			RETURN(NIL)
		ENDIF	
		
		//		nTaxa := (100 - ((100 - __nDesconto) * (1 + (nJuros/100))))
		nTaxa := nJuros
		
		ENDIF
		
		BOX(09,00,17,79,M->FR,127,3,8)
		@ 10,01 SAY "[Mercadoria      ][Quant.   ][Preco       ][Total           ]"
		@ 16,01 SAY "[                                                            ]"
		BOX(18,00,23,79,M->FR,127,3,8)
		nI := 1
		_SAI := .F.
		DO WHILE .T.
			@ 11,02 GET aCodigo[nI];
					  PICTURE "@K@!"; 
					  VALID !EMPTY(aCodigo[nI]) .AND.;
					  Existe(aCodigo[nI],"Mercadoria nÆo cadastrada",.F.,"CECCMER",1,"DESCRIM","@!",16,2) 
					  
			@ 11,20 GET aQuantidade[nI];
			        PICTURE "@R@K 99,999.999";
					  VALID !EMPTY(aQuantidade[nI]) .AND.;
					  VEstoque(nLoja,aQuantidade[nI]) .AND. Mostra(aQuantidade[nI],nI,@aReferencia,@aPrecoU,@nSubtotal,@nTotal,@nTotalP) .AND.;
					  IF(CECCCLI->DESCONTO#0,MostraD(@nSubTotal,@nDesc2,@nTotal,aDescItem[nI],aPrecoU[nI],aQuantidade[nI],cAprazo,nTaxa,@nTotalP),.T.) 
					  
			@ 19,04 SAY "Sub-total..........:";
				  GET nSubTotal;
				  PICTURE "@R@K 99,999,999,999.99";
				  WHEN .F.
			
			IF CECCCLI->DESCONTO#0	  
				@ 20,04 SAY "Desconto do Pedido.:";
					  GET nDesc2;
					  PICTURE "@K@R 99,999,999,999.99";
					  WHEN .F.	  
				  
				@ 21,04 SAY "Total … vista......:";
			   	  GET nTotal;
				  	  PICTURE "@K@R 99,999,999,999.99";
				  	  WHEN .F.		 
					   
				IF cAprazo="S"
					@ 22,04 SAY "Total a prazo......:";
				   	  GET nTotalP;
					  	  PICTURE "@K@R 99,999,999,999.99";
					  	  WHEN .F.		  	  
				ENDIF
						  
			ENDIF
				  
			READ		  
			IF LASTKEY()#27
				nI ++ 
			ENDIF	
			IF LASTKEY()=27 .OR. IF(nI==51,EVAL({||M_DISPLAY("LIMITE DE ITENS ESGOTADO",79),.T.}),.F.)
				IF !M_QUERY("Confirma os dados !",23)
					RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
					_sai := .T.
					EXIT
				ELSE
					IF (nI-1) == 0
						M_DISPLAY("Este pedido nao possue itens, verifique !!!",79)	
						_sai := .T.
					ENDIF	
					EXIT
				ENDIF	
			ENDIF	
			SCROLL(11,02,15,76,-1)		  
		ENDDO			  
		IF _SAI
			DBSETORDER(3)			
			LOOP
		ENDIF	
		
		@ 21,04 SAY "Total..............:";
		     GET nTotal;
			  PICTURE "@K@R 99,999,999,999.99";
			  WHEN .F.		 
		
		READ		   
		
 		SELECT("CECCBAL1")	
		IF Confirma("Confirma a inclusao deste pedido",23)
			IF Inclui_Registro(.T.)
				Lock_Registro(.T.)
				CECCBAL1->LOJA     := nLoja
				CECCBAL1->PEDIDO   := M->nPed
				CECCBAL1->VENDEDOR := nVendedor
				CECCBAL1->SUBTOTAL   := nSubTotal
				CECCBAL1->VDESCONTO := nDesc2
				CECCBAL1->TOTAL := nTotal
				CECCBAL1->CLIENTE := nCliente
				DBUNLOCK()
				DBCOMMIT()
			ELSE
				LOOP	
			ENDIF	
		ELSE
			_SAI := .T.
			LOOP	
		ENDIF
		
		SELECT("CECCBAL2")
		CECCMER->(DBSETORDER(1))
		FOR nX:=1 TO (nI-1)
			IF aQuantidade[nX] > 0
			   Inclui_Registro(.T.)
				Lock_Registro(.T.)
				CECCBAL2->PEDIDO:=M->nPed
				CECCBAL2->LOJA:=nLoja
				CECCBAL2->MERCADORIA:=aCodigo[nX]
				CECCBAL2->REFERENCIA:=aReferencia[nX]
				CECCBAL2->QTD:=aQuantidade[nX]
				CECCMER->(DBSEEK(aCodigo[nX]))
				CECCBAL2->PRECOU:=aPrecoU[nX]
				CECCBAL2->PRECOT:=ROUND(aPrecoU[nX]*aQuantidade[nX],2)
				CECCBAL2->DESCONTO := aDescItem[nX]
				CECCBAL2->(DBUNLOCK())
			ENDIF	
		NEXT
		CECCBAL2->(DBCOMMIT())
			
		SELECT("CECCMER")	
		DBSETORDER(3)
		
		IF CECCSET->IMPPED=1
			IF M_QUERY("Imprime o pedido ?",23)
				IPedido(M->nPed)
			ENDIF	
		ENDIF	
		
	ENDDO
RETURN(NIL)	

FUNCTION Mostra(nQt,nI,aReferencia,aPrecoU,nSubTotal,nTotal,nTotalP,cAprazo)
	LOCAL nValor
	@ ROW(),32 SAY CECCMER->PRECVEM
	@ ROW(),48 SAY nValor:=ROUND(CECCMER->PRECVEM*nQt,2)
	aPrecoU[nI] := CECCMER->PRECVEM
	nSubTotal += nValor
	IF CECCCLI->DESCONTO=0
		nTotal += nValor
	ENDIF	
RETURN(.T.)

FUNCTION MostraD(nSubTotal,nDesc,nTotal,nDesconto,nPreco,nQt,aPrazo,nTaxa,nTotalP)
	LOCAL nValor
	IF LASTKEY()==K_ENTER .OR. INKEY()==K_ENTER
		nValor := ROUND(nPreco*nQt,2)
		nDesc+=(nValor * (CECCCLI->DESCONTO/100))
		nTotal:=nSubTotal - nDesc
		nTotalP:=(nTotal * (1+(nTaxa/100)))
	ENDIF	
RETURN(.T.)

FUNCTION Vestoque(nLoja,nQt)
	IF !CECCLOJ->(DBSEEK(STR(nLoja,4)+CECCMER->CODIGOM)) .OR.;
		CECCLOJ->SALDOEJ < nQt
		M_DISPLAY("Saldo insuficiente",79)
		M_DISPLAY("O saldo existente ‚ "+STR(CECCLOJ->SALDOEJ,10,3),79)
	ENDIF		
RETURN(.T.)	

FUNCTION IPedido(nPed)
	LOCAL cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
			nCursor:=SETCURSOR(0),;
			nArea := SELECT(),;
			nPage:=0,;
			lCab := .T.,;
			nLin:=0,;
			cLoja,;
			cCliente,;
			cVendedor
	
	IF !IMPRES()
		RETURN(NIL)
	ENDIF			
	
	M_MESSAGE("Aguarde imprimindo pedido",23)
	
	CECCMER->(DBSETORDER(1))
	
	SELECT("CECCBAL1")
	DBSEEK(STR(nPed,10))
	
	SELECT("CECTLOJ")
	CECTLOJ->(DBSEEK(CECCBAL1->LOJA))
	cLoja := CECTLOJ->NOMLOJTL
	
	SELECT("CECCVEN")
	CECCVEN->(DBSEEK(STR(CECCBAL1->VENDEDOR,5)))
	cVendedor := CECCVEN->NOMVEN
	
	SELECT("CECCCLI")
	CECCCLI->(DBSEEK(CECCBAL1->CLIENTE))
	CECCCLI->(LOCK_REGISTRO(.T.))
	CECCCLI->DTUCOMP := DATE()
	CECCCLI->(DBUNLOCK())
	cCliente  := CECCCLI->NOMECLC
	cCGC      := CECCCLI->CGCCPFC
	cSuframa  := CECCCLI->INSCSUF
	cEndereco := CECCCLI->ENDEREC
	cInscEst  := CECCCLI->INSESTC
	cTelefone := CECCCLI->TELEFOC
	
	SELECT("CECCBAL2")
	DBSEEK(STR(nPed,10))
	SET DEVICE TO PRINT		
	@ PROW(),PCOL() SAY CHR(m->sEsc)
	nDesc2 := 0
	DO WHILE nPed==CECCBAL2->PEDIDO .AND. !EOF()
		IF lCab
			nPage ++
			Cabecalho(nPage,"    P E D I D O    - N§ "+STRZERO(nPed,10))
			lCab := .F.
                        @ 07,01 SAY chr(15)+"Loja....:"+ALLTRIM(STR(CECCBAL1->LOJA,4))+"-"+ALLTRIM(cLoja)
                        @ 08,01 SAY chr(15)+"Vendedor:"+ALLTRIM(STR(CECCBAL1->VENDEDOR,5))+"-"+ALLTRIM(cVendedor)
			@ 09,01 SAY chr(14)+"Cliente.:"+ALLTRIM(STR(CECCBAL1->CLIENTE,5))+"-"+ALLTRIM(cCliente)
                        @ 10,01 SAY chr(15)+"Endereco:"+ALLTRIM(cEndereco)+" - Fone.:"+ALLTRIM(cTelefone)
                        @ 11,01 SAY chr(15)+"CGC:"+TRANS(cCGC,"@r 99.999.999/9999-99")+" - Insc. Est.:"+ALLTRIM(cInscEst)+" - Suframa.:"+ALLTRIM(cSuframa)
			@ 12,01 SAY chr(15)+REPL("-",132)
			@ 13,01 SAY "MERCADORIA       DESCRICAO                                     QUANTIDADE      UNIDADE      UNITARIO          TOTAL          DESCONTO"
			@ 14,01 SAY REPL("-",132)
			nLin := 15
		ENDIF
		CECCMER->(DBSETORDER(1))
		CECCMER->(DBSEEK(CECCBAL2->MERCADORIA))
		@ nLin,001 SAY CECCBAL2->MERCADORIA
		@ nLin,018 SAY CECCMER->DESCRIM
		@ nLin,080 SAY CECCMER->UNIDADE
		@ nLin,064 SAY CECCBAL2->QTD
		@ nLin,093 SAY CECCBAL2->PRECOU PICTURE "@R 9,999,999.99" 	
		@ nLin,111 SAY CECCBAL2->PRECOT PICTURE "@R 99,999,999.99" 	
		@ nLin,126 SAY CECCBAL2->DESCONTO PICTURE "@R 99,999.99"
		nLin++
		nDesc2+=CECCBAL2->DESCONTO
		IF nLin>60
			@ nLin,01 SAY PADC("S E M   V A L O R   F I S C A L",132,"*")
			@ nLin,01 SAY PADC("S E M   V A L O R   F I S C A L",132,"*")
			lCab := .T.
		ENDIF	
		DBSKIP()
	ENDDO		
	@ nLin,01 SAY REPL("-",132)
	nLin++
	@ nLin,91 SAY "Sub-Total........:"
	@ nLin,109 SAY CECCBAL1->SUBTOTAL PICTURE "@R 99,999,999.99"
	nLin++
	@ nLin,91 SAY "Desconto do Itens:"
	@ nLin,109 SAY nDesc2 PICTURE "@R 99,999,999.99"
	nLin++
	@ nLin,91 SAY "Desconto do Cupom:"
	@ nLin,109 SAY CECCBAL1->VDESCONTO PICTURE "@R 99,999,999.99"
	nLin++
	@ nLin,91 SAY "Total............:"
	@ nLin,109 SAY CECCBAL1->TOTAL    PICTURE "@R 99,999,999.99"
	@ nLin+1,01 SAY REPL("-",132)		
	@ nLin+3,01 SAY PADC("S E M   V A L O R   F I S C A L",132,"*")
	@ nLin+3,01 SAY PADC("S E M   V A L O R   F I S C A L",132,"*")
	EJECT
	SET DEVICE TO SCREEN
	CECCMER->(DBSETORDER(3))
	SELECT(nArea)
	RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
RETURN(NIL)	
			
FUNCTION VDesc(PDesconto,nSubTotal,nDesconto)
	LOCAL bVolta := {||M_DISPLAY("Desconto maior que o permitido",79),.F.}
RETURN(IF(nDesconto>ROUND(nSubTotal * (PDesconto/100),2) .AND.;
          Pass()#ALLTRIM(Criptografa ( CECCSET -> PASSWDS, "HAWK",.F.)),;
			 EVAL(bVolta),.T.))	
