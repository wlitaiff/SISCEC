// Sistemas de Controle de Estoque Comercial
// W&R Informatica Ltda
// 10 de Novembro de 1995
// Roberto Falcao Rocha
// Cadastro de pedidos via balcao e consulta de precos
#INCLUDE "INKEY.CH"
LOCAL cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
		cCor := SETCOLOR(),;
		nCursor := SETCURSOR(0),;
		aDad := {"CODIGOM","DESCRIM","PRECVEM","PRECVEM2","SALDOEM","UNIDADE",;
					"CODLINM","FORNECM","ORIGEMM","REFEREM"},;
		aCab := {"Material","Descri‡Æo","Pre‡o a Vista","Pre‡o Faturado","Estoque","Unidade",;
					"Grupo","Fornecedor","Origem","Referˆncia"},;
		aPic := {"@!","@!","@E@R 999,999.99","@E@R 999,999.99","@R@E 9,999,999.999","@!","9999","9999",;
					"!","9999999999999"}

// Verificando arquivos
IF !ARQNTX("CECCBAL1",.F.) .OR. ;
	!ARQNTX("CECCBAL2",.F.) .OR. ;
	!ARQNTX("CECTLOJ",.F.) .OR. ;
	!ARQNTX("CECCREC",.F.) .OR. ;
	!ARQNTX("CECCVEN",.F.) .OR. ;
	!ARQNTX("CECCLOJ",.F.) .OR. ;
	!ARQNTX("CECCPAS",.F.) .OR. ;
	!ARQNTX("CECCSET",.F.) .OR. ;
	!ARQNTX("CECLOGO",.F.) .OR. ;
	!ARQNTX("CECCCLI",.F.) .OR. ;
	!ARQNTX("CECTLIN",.F.) .OR. ;
	!ARQNTX("CECCFOR",.F.) .OR. ;
	!ARQNTX("CECCMER",.F.) 
	DBCLOSEALL()
	RETURN
ENDIF   

DBSETORDER(1)
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
         nTAXA,;
			nVendedor:=0,;
			nTDesconto:=0,;
			cFiscal:=" ",;
			aDescItem[150],;
			aGrupo[150],;
			aCodigo[150],;
			aApaga[150],;
			aCodANT[150],;
			aDesc[150],;
			aPrecoU[150],;
			aReferencia[150],;
			aQuantidade[150],;
			aQtdANT[150],;
			_SAI:=.F.,;
			lAltera   := .F.,;
			nItems := 0,;
			cRevenda := 'N',;
			bAltera   := {||GetData(@nCliente,@nVendedor,@cAprazo,@cRevenda,;
							    @aCodigo,@aDesc,@aReferencia,@aQuantidade,;
								 @aPrecoU,@aDescItem,@aGrupo,@lAltera,@nItems,@aCodAnt,@aQtdAnt,@aApaga),.T.},;
			GetList:={},;
			nSubTotal:=0,;
			nTotal:=0,;
			nTotalP := 0,;
			nDesc:=0,;
			nDesc2:=0,;
			nCliente := 1,;
			nI,;
			nX
	
	//IF CECCSET->IMPFIS==0
		nLoja := 1
	//ENDIF 
	
	AFILL(aCodigo,SPACE(16))
	AFILL(aApaga,SPACE(1))
	AFILL(aCodANT,SPACE(16))
	AFILL(aDesc,SPACE(40))
	AFILL(aReferencia,SPACE(13))
	AFILL(aQuantidade,0)
	AFILL(aQTDANT,0)
	AFILL(aPrecoU,0)
	AFILL(aDescItem,0)
	AFILL(aGrupo,0)
	//
   IF FILE("NPEDIDO.MEM")  // Para atualizar o numero, deve-se deletar o NPEDIDO.MEM
		RESTORE FROM NPEDIDO ADDITIVE
	ELSE
   	M->nPed := 0    		// Quando quiser atualizar o numero dos Pedidos. Atribua os novos valores nesta linha. Valor deful 0.
      SAVE ALL LIKE NPED TO NPEDIDO
	ENDIF           
	_SAI        := .f.
	__nDesconto := 0
	nJuros   := 0
	cAprazo  := "S"
	CREVENDA := 'N'
	//
	cTelas := SAVESCREEN(0,0,MAXROW(),MAXCOL())
	DO WHILE .T.
		IF !_SAI 
			AFILL(aCodigo,SPACE(16))
			AFILL(aApaga,SPACE(1))
			AFILL(aCodAnt,SPACE(16))
			AFILL(aDesc,SPACE(40))
			AFILL(aReferencia,SPACE(13))
			AFILL(aQuantidade,0)
			AFILL(aQtdAnt,0)
			AFILL(aPrecoU,0)
			AFILL(aDescItem,0)
			AFILL(aGrupo,0)
			//
			__nDesconto := 0
			nJuros  := 0
			cAprazo := "S"
		ENDIF   
		RESTORE FROM NPEDIDO ADDITIVE
		m->nPed++                       
		SAVE ALL LIKE NPED TO NPEDIDO
		nSubTotal := 0
		nTotal    := 0
		nTotalP   := 0
		nDesc     := 0
		nDesc2    := 0
		lPedido   := lCautela := lCotacao := SPACE(1)
		RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTelas)
		BOX(02,01,04,79,M->FR,127,3,8)
		//
		DO WHILE .T.
			lDesconto := .F.
			SET CONFIRM OFF
			@ 03,02 SAY "PEDIDO"  GET lPedido  PICTURE "!" VALID lPedido $"X "
			@ 03,11 SAY "CAUTELA" GET lCautela PICTURE "!" VALID lCautela$"X " WHEN EMPTY(lPedido)
			@ 03,22 SAY "COTA€ÇO" GET lCotacao PICTURE "!" VALID lCotacao$"X " WHEN EMPTY(lPedido) .AND. EMPTY(lCautela)
			READ
			IF LASTKEY()==27
				SETCURSOR(nCursor)
				SETCOLOR(cCor)
				RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
				DBGOTO(nReg)
				oBrowse:refreshAll()
				RETURN(NIL)
			ENDIF
			IF !EMPTY(lPedido) .OR. !EMPTY(lCautela) .OR. !EMPTY(lCotacao)
				RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTelas)
				EXIT
			ENDIF   
		ENDDO
		SET CONFIRM ON  
		temCredito := .T.
		BOX(03,01,08,79,M->FR,127,3,8)
		@ 05,02 SAY "Loja......:" + TRANS(nLoja , [@E@R 9,999] )
		IF !EMPTY(lPedido)
			cTexto := "Pedido No..:"
		ENDIF   
		IF !EMPTY(lCautela)
			cTexto := "Cautela No.:"
		ENDIF
		IF !EMPTY(lCotacao)
         cTexto := "Cota‡Æo No.:"
		ENDIF
		___Sai := .T.
		lAltera := .F.
		@ 04,02 SAY cTexto;
				  GET M->nPed;
				  PICTURE "9999999999";
                      VALID !Existe(str(M->nPed,10),SUBST(cTexto,1,7)+" j  existe",.T.,"CECCBAL1",1)
							 /***
                      * IF(Existe(str(M->nPed,10),SUBST(cTexto,1,7)+" j  existe",.T.,"CECCBAL1",1),;
                      * IF(M_QUERY("Deseja alterar ?",23),;
                      * IF(CECCBAL1->ATENDIDO,EVAL({||M_DISPLAY([Pedido ja foi atendido, nÆo pode ser alterado],23),.F.}),EVAL(bAltera)),.F.),.T.)
							 ***/
		@ 06,02 SAY "Vendedor..:";                
				  GET nVendedor;
				  PICTURE "@K 99999";
				  VALID !EMPTY(nVendedor) .AND.;
				  Existe(STR(nVendedor,5)+STR(nLoja,4),"Vendedor nÆo cadastrado ou nÆo ‚ desta loja",.F.,"CECCVEN",1,"NOMVEN","@!",ROW(),COL()+1)
		
		@ 07,02 SAY "Cliente:";
				  GET nCliente;
				  PICTURE "@K 99999";
				  VALID !EMPTY(nCliente) .AND.;
              Existe(nCliente,"Cliente nÆo cadastrado",.F.,"CECCCLI",1,"NOMECLC","@!",ROW(),COL()+1) .AND. IF(CECCCLI->STATUS<>"B",.T.,Bloqueado("Cliente Bloqueado...")) .AND.;
				  EVAL({||__nDesconto:=CECCCLI->DESCONTO,.T.}) .AND. VerificaCautelas(nCliente,@___Sai)     //.AND.;
				  //VerificaCliente(nCliente,@temCredito,@___SAI) 
		
		READ
		IF LASTKEY()==27 .AND. ___Sai
			SETCURSOR(nCursor)
			SETCOLOR(cCor)
			RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
			DBGOTO(nReg)
			oBrowse:refreshAll()
			RETURN(NIL)
		ENDIF                     
		//
		
		IF CECCCLI->DESCONTO#0
			lDesconto := .T.
		ENDIF   
		IF nCliente > 1
			cAprazo := "S"  
			nJuros := 0
			@ 04,60 SAY "E a prazo?..:";
					  GET cAprazo;
					  PICTURE "!";
                 VALID IF(temCredito,cAprazo$"NS",cAprazo="N") .AND. IF(cAprazo="S" .AND. CECCCLI->STATUS="A",Bloqueado("Cliente Autorizado apenas para Compra A Vista..."),.T.) ;  
					  WHEN nCliente>1                 
			
			@ 05,60 SAY "E Revenda...:";
					  GET cRevenda;
					  PICTURE "!";
					  VALID cRevenda$[SN]             
			  
			READ
			IF LASTKEY()==27
				SETCURSOR(nCursor)
				SETCOLOR(cCor)
				RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
				DBGOTO(nReg)
				oBrowse:refreshAll()
				RETURN(NIL)
			ENDIF   
			// nTaxa := (100 - ((100 - __nDesconto) * (1 + (nJuros/100))))
			nTaxa := 0
		ELSE
			cAprazo := "N"  
		ENDIF
		//
		BOX(09,00,17,79,M->FR,127,3,8)
		@ 10,01 SAY "[Mercadoria      ][Quant.   ][Preco       ][Total           ][Elimina]"
		@ 16,01 SAY "[                                                            ]"
		@ 15,65 SAY  [Grupo]
		@ 16,65 SAY "[     ]"
		BOX(18,00,23,79,M->FR,127,3,8)
		nI := 1
		_SAI := .F.
		DO WHILE .T.
			@ 11,02 GET aCodigo[nI];
					  PICTURE "@K@!"; 
					  VALID !EMPTY(aCodigo[nI]) .AND. VerificaGrupo(aCodigo,nI) .AND.;
					  ((Existe(aCodigo[nI],"Mercadoria nÆo cadastrada",.F.,"CECCMER",1,"DESCRIM","@!",16,2) .AND. ColocaDesc(@aDesc,nI,@aGrupo,aCodigo[ni],aCodAnt[ni])) .AND.;
					  IF(CECCMER->CODLINM=100 .OR. CECCMER->CODLINM=9999,Rotativo(@aDesc,nI,@aGrupo),.T.))
					  
			@ 11,20 GET aQuantidade[nI];
					  PICTURE "@R@K 99,999.999";
					  VALID !EMPTY(aQuantidade[nI]) .AND.;
					  IF(!EMPTY(lCotacao),.T.,VEstoque(nLoja,aQuantidade[nI])) .AND. Mostra(aQuantidade[nI],nI,@aReferencia,@aPrecoU,@nSubtotal,@nTotal,@nTotalP,cAPrazo,ACODIGO[NI],ACODANT[NI]) .AND.;
					  IF(CECCCLI->DESCONTO#0,MostraD(@nSubTotal,@nDesc2,@nTotal,aDescItem[nI],aPrecoU[nI],aQuantidade[nI],cAprazo,nTaxa,@nTotalP,@nTDesconto),.T.) 
			
			@ 11,63 GET aApaga[nI];
					  PICTURE "!";                                 
					  VALID aApaga[nI]$" X" .AND. IF(aApaga[nI]="X",AjustaValores(@nSubTotal,@nDesc2,@nTotal,aPrecoU[nI],aQuantidade[nI],nTaxa,@nTotalP,@nTDesconto),.T.);
					  WHEN lAltera            
					  
			@ 19,04 SAY "Sub-total..........:";
				  	  GET nSubTotal;
				  	  PICTURE "@R@K 99,999,999,999.99";
				  	  WHEN .F.
			//
			IF CECCCLI->DESCONTO#0
				@ 20,04 SAY "Desconto "+STR(CECCCLI->DESCONTO,5,2)+"%....:";
					  GET nDesc2;
					  PICTURE "@K@R 99,999,999,999.99";
					  WHEN .F.        
				@ 21,04 SAY "Desconto em R$.....:";
					  GET nDesc;
					  PICTURE "@K@R 99,999,999,999.99";
					  WHEN .F.                
				@ 22,04 SAY "Total..............:";
				  	  GET nTotal;
					  PICTURE "@K@R 99,999,999,999.99";
					  WHEN .F.               
					   
				//IF cAprazo="S"
				//@ 22,04 SAY "Total a prazo......:";
				//        GET nTotalP;
				//                PICTURE "@K@R 99,999,999,999.99";
				//                WHEN .F.                        
				//ENDIF
			ENDIF
			READ              
			//
			IF LASTKEY()#27
				nI ++ 
			ENDIF   
			IF LASTKEY()=27 .OR. IF(nCliente=1,IF(nI==151,eVAL({||M_DISPLAY("LIMITE DE ITENS ESGOTADO",79),.T.}),.F.),IF(nI==17,EVAL({||M_DISPLAY("LIMITE DE ITENS ESGOTADO",79),.T.}),.F.))
				IF !M_QUERY("Confirma os dados?",23)
					RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
					_sai := .T.
					EXIT
				ELSE
					nApaga := 0
					IF lAltera
						IF nItems>(nI-1)
							IF M_QUERY("Ainda existem itens neste pedido, deseja elimina-los ?",79)
								FOR ___x:=nI TO nItems
									aApaga[___x] := "X"
								NEXT
								nI := nItems + 1
							ELSE
								RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
								_sai := .T.
								EXIT    
							ENDIF
						ENDIF                   
						FOR ___x:=1 TO (nI-1)
							IF aApaga[___x]="X"
								nApaga++
							ENDIF
						NEXT            
					ENDIF                   
					IF (nI-1) == 0 .OR. (nI-1)=nApaga
						M_DISPLAY("Este pedido nao possue itens, verifique !!!",79)     
						_sai := .T.
					ENDIF   
					EXIT
				ENDIF   
			ENDIF   
			SCROLL(11,02,15,76,-1)            
		ENDDO   
		//
		IF _SAI 
			DBSETORDER(3)                   
			LOOP
		ENDIF
		//
		xDesc := [ ]
		IF nCliente==1
			@ 19,02 GET xDesc PICTURE '!' 
			READ
		ENDIF                   
		//
		IF xDesc==[X]
			@ 19,50 SAY [DESCONTO %] GET __nDesconto PICTURE [@E@K 99.99]
			READ
			nDesc2 := ROUND((nSubTotal * (__nDesconto/100)),2)
			@ 20,04 SAY "Desconto "+STR(__nDesconto,5,2)+"%....:";
					  GET nDesc2;
					  PICTURE "@K@R 99,999,999,999.99";
					  WHEN .F.        
			nTotal := nSubTotal - nDesc2              
			lDesconto := .T.
		ENDIF   
		//
		IF lDesconto
			@ 21,04 SAY "Desconto em R$.....:";
					  GET nDesc;
					  PICTURE "@K@R 99,999,999,999.99";
					  VALID Desconto(nDesc,nDesc2,@nTotal,@nTDesconto,nSubTotal);
					  WHEN lDesconto
		ENDIF           
		//
		@ 22,04 SAY "Total..............:";
		     	  GET nTotal;
			  	  PICTURE "@K@R 99,999,999,999.99";
			  	  WHEN .F.               
		
		READ               
		//
		IF Confirma(IF(lAltera,"Confirma a altera‡Æo","Confirma a inclusao deste pedido"),23)

       Do While .T.
          cPass := ALLTRIM(PASS())
		  	 SELECT("CECCPAS")
			 DBSETORDER(2)
          IF !DBSEEK(cPass)  .or. LASTKEY() = 27 .or. empty(cPass) .or. LEN(cPass) = 1
             M_DISPLAY("Usuario nao autorizado",79)
             If M_QUERY("Deseja Continuar",23)
                Loop
             Else
             	 _Sai := .T.
                Exit
             Endif
			 ELSE
				cUsuario := Criptografa(CECCPAS->NOME,"HAWK",.F.)
            Exit
			 ENDIF
       Enddo

			IF _SAI
                                SELECT("CECCMER")
				DBSETORDER(3)                   
				LOOP
			ENDIF   
			SELECT("CECCBAL1")      
			IF !lAltera
				Inclui_Registro(.T.)
			ENDIF   
			Lock_Registro(.T.)
			CECCBAL1->LOJA      := nLoja
			CECCBAL1->PEDIDO    := M->nPed
			CECCBAL1->VENDEDOR  := nVendedor
			CECCBAL1->SUBTOTAL  := nSubTotal
			CECCBAL1->VDESCONTO := nDesc2
			CECCBAL1->VDESC2    := nDesc
			CECCBAL1->TOTAL     := nTotal
			CECCBAL1->CLIENTE   := nCliente
			CECCBAL1->USUARIO   := cUsuario
			CECCBAL1->PERCDESC  := __nDesconto
			CECCBAL1->TIPO := IF(!EMPTY(lPedido),"P",IF(!EMPTY(lCautela),"C"," "))
			CECCBAL1->REVENDA := cRevenda
			CECCBAL1->APRAZO  := cAprazo
         CECCBAL1->DATAEM  := date()
			CECCBAL1->(DBUNLOCK())
			CECCBAL1->(DBCOMMIT())
		ELSE
			_SAI := .T.
			LOOP    
		ENDIF   
		
		SELECT("CECCBAL2")
		CECCMER->(DBSETORDER(1))
		FOR nX:=1 TO (nI-1)
			IF aQuantidade[nX] > 0
				IF nX>nItems .OR. !lAltera
				   Inclui_Registro(.T.)
				ENDIF   
				Lock_Registro(.T.)
				IF lAltera .AND. aApaga[nX]="X"
					CECCMER->(DBSEEK(aCodAnt[nX]))
					CECCMER->(LOCK_REGISTRO(.T.))
					IF !EMPTY(lPedido)
						CECCMER->QTDPED -= aQtdAnt[nX]
					ENDIF
					IF !EMPTY(lCautela)
						CECCMER->CAUTELA -= aQtdAnt[nX]
					ENDIF           
					CECCBAL2->(DBDELETE())
					CECCBAL2->(DBUNLOCK())
				ELSE    
					CECCBAL2->PEDIDO:=M->nPed
					CECCBAL2->LOJA:=nLoja
					CECCBAL2->MERCADORIA:=aCodigo[nX]
					CECCBAL2->MERC2     :=aCodigo[nX]
					CECCBAL2->DESCRICAO := aDesc[nX]
					CECCBAL2->GRUPO := AGRUPO[NX]
				///IF(EMPTY(aDesc[nX]),CECCMER->DESCRIM,aDesc[nX])
					CECCBAL2->REFERENCIA:=aReferencia[nX]
					CECCBAL2->QTD:=aQuantidade[nX]
					IF !Laltera
						CECCMER->(DBSEEK(aCodigo[nX]))
						CECCMER->(LOCK_REGISTRO(.T.))
						IF !EMPTY(lPedido)
							CECCMER->QTDPED += CECCBAL2->QTD
						ENDIF
						IF !EMPTY(lCautela)
							CECCMER->CAUTELA += CECCBAL2->QTD
						ENDIF
					ELSE
						IF aCodigo[nX]=aCodAnt[nX]
							CECCMER->(DBSEEK(aCodAnt[nX]))
							CECCMER->(LOCK_REGISTRO(.T.))
							IF !EMPTY(lPedido)
								CECCMER->QTDPED -= aQtdAnt[nX]
								CECCMER->QTDPED += CECCBAL2->QTD
							ENDIF
							IF !EMPTY(lCautela)
								CECCMER->CAUTELA -= aQtdAnt[nX]
								CECCMER->CAUTELA += CECCBAL2->QTD
							ENDIF   
						ELSE
							CECCMER->(DBSEEK(aCodAnt[nX]))
							CECCMER->(LOCK_REGISTRO(.T.))
							IF !EMPTY(lPedido)
								CECCMER->QTDPED -= aQtdAnt[nX]
							ENDIF
							IF !EMPTY(lCautela)
								CECCMER->CAUTELA -= aQtdAnt[nX]
							ENDIF           
							CECCMER->(DBSEEK(aCodigo[nX]))
							CECCMER->(LOCK_REGISTRO(.T.))
							IF !EMPTY(lPedido)
								CECCMER->QTDPED += aQuantidade[nX]
							ENDIF
							IF !EMPTY(lCautela)
								CECCMER->CAUTELA += aQuantidade[nX]
							ENDIF           
						ENDIF
					ENDIF   
					CECCMER->(DBUNLOCK())
					CECCBAL2->PRECOU:=aPrecoU[nX]
					CECCBAL2->PRECOT:=ROUND(aPrecoU[nX]*aQuantidade[nX],2)
					CECCBAL2->DESCONTO := aDescItem[nX]
					CECCBAL2->(DBUNLOCK())
				ENDIF   
				IF lAltera .AND. nX<=nItems
					CECCBAL2->(DBSKIP())
				ENDIF   
			ENDIF   
		NEXT
		CECCBAL2->(DBCOMMIT())
			
		SELECT("CECCMER")       
		DBSETORDER(3)
		
		IF CECCSET->IMPPED=1
			IF !EMPTY(lPedido)
				IF M_QUERY("Imprime o pedido ?",23)
					IPedido(M->nPed,1,cUsuario)
				ENDIF   
			ENDIF   
			IF !EMPTY(lCautela)
				IF M_QUERY("Imprime a cautela ?",23)
					IPedido(M->nPed,2,cUsuario)
				ENDIF   
			ENDIF   
			IF !EMPTY(lCotacao)
				IF M_QUERY("Imprime a cotacao ?",23)
					IPedido(M->nPed,3,cUsuario)
				ENDIF   
			ENDIF   
		ENDIF   
		
	ENDDO
RETURN(NIL)     

FUNCTION Bloqueado(Msg)
  M_DISPLAY(Msg,79)
Return(.F.)

FUNCTION Mostra(nQt,nI,aReferencia,aPrecoU,nSubTotal,nTotal,nTotalP,cAprazo,CODIGO,CODANT)
	LOCAL nValor,xPre
	xPre := aPrecoU[nI]
	IF CECCMER->(!EOF())
		IF XPRE=0 .OR. CODIGO<>CODANT
			IF cAprazo#"S"
				xPre := CECCMER->PRECVEM
			ELSE
				xPre := CECCMER->PRECVEM2
			ENDIF           
			//( aPrecoU[nI]#0 .AND. CODIGO<>CODANT )
			if (ceccmer->codlinm=100) .or. (ceccmer->codlinm=9999) 
				xPre := aPrecoU[nI]
			endif   
		ENDIF   
		@ 11,32 GET xPre PICTURE "999999.999" VALID !EMPTY(xPre)
		Read
	ELSE
		DO WHILE .T.
			@ 11,32 GET xPre PICTURE "999999.999" VALID !EMPTY(xPre)
			READ
			IF xPre==0
				LOOP
			ELSE
				EXIT    
			ENDIF   
		ENDDO
	ENDIF   
	//
	@ 11,48 SAY nValor:=ROUND(xPre*nQt,2)
	aPrecoU[nI] := xPre
	nSubTotal   += nValor
	//
	IF CECCCLI->DESCONTO=0
		nTotal += nValor
	ENDIF   
RETURN(.T.)

FUNCTION MostraD(nSubTotal,nDesc,nTotal,nDesconto,nPreco,nQt,aPrazo,nTaxa,nTotalP,nTDesconto)
	LOCAL nValor
	IF LASTKEY()==K_ENTER .OR. INKEY()==K_ENTER
		nValor := ROUND(nPreco*nQt,2)
		nDesc+=round((nValor * (CECCCLI->DESCONTO/100)),2)
		nTotal:=nSubTotal - nDesc
		nTotalP:=(nTotal * (1+(nTaxa/100)))
		nTDesconto := nDesc
	ENDIF   
RETURN(.T.)


FUNCTION AjustaValores(nSubTotal,nDesc,nTotal,nPreco,nQt,nTaxa,nTotalP,nTDesconto)
	LOCAL nValor
	nValor:=ROUND(nPreco*nQt,2)
	nSubTotal -= nValor
	IF CECCCLI->DESCONTO=0
		nTotal -= nValor
	ELSE            
		nDesc-=round((nValor * (CECCCLI->DESCONTO/100)),2)
		nTotal:=nSubTotal - nDesc
		nTotalP:=(nTotal * (1+(nTaxa/100)))
		nTDesconto := nDesc
	ENDIF   
RETURN(.T.)

FUNCTION Desconto(nDesc,nDesc2,nTotal,nTDesconto,nSubTotal)
	nTDesconto := nDesc + round(nDesc2,2)
	nTotal     := nSubTotal - nTDesconto
RETURN(.T.)

FUNCTION VEstoque(nLoja,nQt)
   LOCAL cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL())
   LOCAL lStatus:=.T.
	//
	IF CECCMER->CODLINM<>100 .AND. CECCMER->CODLINM<>9999
		IF CECCMER->(!EOF())
			IF !CECCLOJ->(DBSEEK(STR(nLoja,4)+CECCMER->CODIGOM)) .OR.;
            IF(SubS(sNom,1,3)="MCI",(CECCLOJ->SALDOEJ - (CECCMER->CAUTELA) - (CECCMER->QTDPED)),(CECCLOJ->SALDOEJ - (CECCMER->CAUTELA) ) ) < nQt
				// ERA     -->  IF(sNom=="MCI",(CECCLOJ->SALDOEJ - (CECCMER->CAUTELA) - (CECCMER->QTDPED)),(CECCLOJ->SALDOEJ - (CECCMER->CAUTELA) - (CECCMER->QTDPED))) < nQt
            lStatus:=IF(sNom=="MCI",.T.,.F.)     // MCI aceita estoque negativo
				SETCURSOR(0)
				M_DISPLAY("Saldo insuficiente!!!",79)
				BOX(10,10,15,60,M->FR,127,3,8)
            nSaldoDis := IF(SubS(sNom,1,3)="MCI",( CECCLOJ->SALDOEJ - (CECCMER->CAUTELA) - (CECCMER->QTDPED) ),( CECCLOJ->SALDOEJ - (CECCMER->CAUTELA) ) )
				// ERA --> nSaldoDis := ( CECCLOJ->SALDOEJ - (CECCMER->CAUTELA) - (CECCMER->QTDPED) )
				@ 11,12 SAY [SALDO ATUAL...........:] + TRANS(CECCLOJ->SALDOEJ, [@E@R 999,999.999])
				@ 12,12 SAY [CAUTELAS PENDENTES....:] + TRANS(CECCMER->CAUTELA, [@E@R 999,999.999])
        		@ 13,12 SAY [PEDIDOS NAO ATENDIDOS.:] + TRANS(CECCMER->QTDPED,  [@E@R 999,999.999])
            @ 14,12 SAY [SALDO DISPONIVEL......:] + TRANS(nSaldoDis,        [@E@R 999,999.999])
				INKEY(0)
				RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
				SETCURSOR(1)
			ENDIF           
		ENDIF
	ENDIF
RETURN(lStatus)     

FUNCTION IPedido(nPed,tipo,Usuario)
	LOCAL cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
			nCursor:=SETCURSOR(0),;
			nArea := SELECT(),;
			nPage:=0,;
			lCab := .T.,;
			nLin:=0,;
			cLoja,;
         vTexto,;
			cCliente,;
			cVendedor,;
         cObs1:=space(65),;
         cObs2:=space(75)
			
	BOX(02,01,05,79,M->FR,127,3,8)
        cObs1:="CLIENTE ESPERANDO NO BALCAO                                                                   "
        SETCURSOR(1)
        @ 03,03 SAY "Obs..:" Get cObs1 pict "@S60"
        @ 04,03 say ".....:" get cObs2 pict "@S60"
	Read
        SETCURSOR(0)

	RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTelas)
	
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
	**/
	SELECT("CECCVEN")
	CECCVEN->(DBSEEK(STR(CECCBAL1->VENDEDOR,5)))
	cVendedor := CECCVEN->NOMVEN
	**/
	cVendedor := Usuario
	
	SELECT("CECCCLI")
	CECCCLI->(DBSEEK(CECCBAL1->CLIENTE))
	CECCCLI->(LOCK_REGISTRO(.T.))
	CECCCLI->DTUCOMP := DATE()
	CECCCLI->(DBUNLOCK())
	cCliente := CECCCLI->NOMECLC
	cCGC := CECCCLI->CGCCPFC
	cSuframa := CECCCLI->INSCSUF
	cEndereco := CECCCLI->ENDEREC
	cInscEst := CECCCLI->INSESTC
	cTelefone := CECCCLI->TELEFOC
	
	SELECT("CECCBAL2")
	DBSEEK(STR(nPed,10))
	SET DEVICE TO PRINT             
	@ PROW(),PCOL() SAY CHR(m->sEsc)
	nDesc2 := 0
	DO WHILE nPed==CECCBAL2->PEDIDO .AND. !EOF()
		IF lCab
			nPage ++
			IF TIPO == 1
            vTexto:="OBRIGADO PELA PREFERENCIA"
				cCab := " PEDIDO NR"
			ENDIF
			IF TIPO == 2
            vTexto:="OBS: APOS 48H SERA CONSIDERADA PEDIDO DE COMPRA"
            cCab := "CAUTELA NR"
			ENDIF
			IF TIPO == 3
            vTexto:="OBRIGADO PELA PREFERENCIA"
            cCab := "COTACAO NR"
			ENDIF                   
         Cabecalho(nPage,cCab+" - "+STRZERO(nPed,10))
			lCab := .F.
         @ 07,01 SAY chr(18)+vTexto
         @ 08,01 SAY chr(15)+"Loja....:"+ALLTRIM(STR(CECCBAL1->LOJA,4))+"-"+ALLTRIM(cLoja)
         @ 09,01 SAY chr(15)+"Vendedor:"+ALLTRIM(STR(CECCBAL1->VENDEDOR,5))+"-"+ALLTRIM(cVendedor)
         @ 10,01 SAY chr(14)+"Cliente.:"+ALLTRIM(STR(CECCBAL1->CLIENTE,5))+"-"+ALLTRIM(cCliente)
         @ 11,01 SAY chr(15)+"Endereco:"+ALLTRIM(cEndereco)+" - Fone.:"+ALLTRIM(cTelefone)
         @ 12,01 SAY chr(15)+"CGC:"+TRANS(cCGC,"@r 99.999.999/9999-99")+" - Insc. Est.:"+ALLTRIM(cInscEst)+" - Suframa.:"+ALLTRIM(cSuframa)+chr(15)+" "
         @ 13,01 SAY chr(15)+REPL("-",132)
         @ 14,01 SAY "MERCADORIA       DESCRICAO                                     QUANTIDADE      UNIDADE      UNITARIO          TOTAL          DESCONTO"
         @ 15,01 SAY REPL("-",132)
         vTexto:=" "
         nLin := 16
		ENDIF
		CECCMER->(DBSETORDER(1))
		CECCMER->(DBSEEK(CECCBAL2->MERCADORIA))
		@ nLin,01 SAY CECCBAL2->MERC2
		@ nLin,18 SAY CECCBAL2->DESCRICAO
		IF (CECCBAL2->DESCRICAO)#(CECCMER->DESCRIM)
			@ nLin,80 SAY [PC]
		ELSE    
			@ nLin,80 SAY CECCMER->UNIDADE
		ENDIF   
		@ nLin,64 SAY CECCBAL2->QTD
		@ nLin,93 SAY CECCBAL2->PRECOU PICTURE "@R 9,999,999.99"        
		@ nLin,111 SAY CECCBAL2->PRECOT PICTURE "@R 99,999,999.99"      
		@ nLin,126 SAY CECCBAL2->DESCONTO PICTURE "@R 99,999.99"
		nLin++
		nDesc2+=CECCBAL2->DESCONTO
		IF nLin>59
                       
			@ nLin,01    SAY PADC("S E M   V A L O R   F I S C A L",132,"*")
			@ nLin,01    SAY PADC("S E M   V A L O R   F I S C A L",132,"*")
                        @ nLin+02,01 SAY chr(18)+PADR("OBS: "+cObs1,80,"*")
                        @ nLin+03,01 SAY chr(18)+PADR(cObs2,80,"*")
			lCab := .T.
		ENDIF   
		DBSKIP()
	ENDDO           
	@ nLin,01 SAY REPL("-",132)
	nLin++
	@ nLin,91 SAY "Sub-Total........:"
	@ nLin,109 SAY CECCBAL1->SUBTOTAL PICTURE "@R 99,999,999.99"
	IF CECCBAL1->VDESCONTO#0
		nLin++
		@ nLin,91 SAY "Desconto "+STR(CECCBAL1->PERCDESC,5,2)+"%..:"
		@ nLin,109 SAY CECCBAL1->VDESCONTO PICTURE "@R 99,999,999.99"
	ENDIF
	IF CECCBAL1->VDESC2#0   
		nLin++
		@ nLin,91 SAY "Desconto em R$...:"
		@ nLin,109 SAY CECCBAL1->VDESC2 PICTURE "@R 99,999,999.99"
	ENDIF   
	nLin++
	@ nLin,91   SAY "Total............:"
	@ nLin,109  SAY CECCBAL1->TOTAL    PICTURE "@R 99,999,999.99"
	@ nLin+1,01 SAY REPL("-",132)           
	@ nLin+3,01 SAY PADC("S E M   V A L O R   F I S C A L",132,"*")
	@ nLin+3,01 SAY PADC("S E M   V A L O R   F I S C A L",132,"*")
        @ nLin+5,01 SAY chr(18)+PADR("OBS: "+cObs1,80,"*")
        @ nLin+6,01 SAY chr(18)+PADR(cObs2,80,"*")
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
			 EVAL(bVolta),.T.))     
			 
FUNCTION VMercadoria(cCodigo)
	LOCAL aCab:={"Codigo","Mercadoria"} ,;
	   aDad:={"CODIGOM","DESCRIM"} ,;
			aPic:={"@!","@!"},;
			xOrd,;
			xArea := SELECT(),;
			nCursor := SETCURSOR(),;
			CcOR := SETCOLOR()
			
	SELECT("CECCMER")
	xOrd := INDEXORD()
	DBSETORDER(1)
	DBSEEK(ALLTRIM(cCodigo),.T.)
	HBrowseDB(ROW()+1,0,23,79,"Tabela de mercadorias",aCab,aDad,aPic,,,.F.)
	DBSETORDER(xOrd)
	SELECT(xArea)
	SETCOLOR(CCOR)
	SETCURSOR(NCURSOR)
RETURN(.T.)     
	
FUNCTION Rotativo(Descricao,nI,gRUPO)
	@ 16,02 GET DESCRICAO[ni] PICTURE "@!"
	@ 16,66 GET GRUPO[NI] PICTURE "99999"
	READ
RETURN(.T.)

FUNCTION ColocaDesc(Descricao,nI,grupo,CODIGO,CODANT)
	IF DESCRICAO[NI]=SPACE(40) .OR. CODIGO<>CODANT
		DESCRICAO[ni]:=(CECCMER->DESCRIM)
	ENDIF
	IF GRUPO[NI]=0  .OR. CODIGO<>CODANT
		grupo[ni] := (CECCMER->CODLINM)
	ENDIF   
	@ 16,66 SAY if(grupo[ni]=0,CECCMER->CODLINM,grupo[ni])
RETURN(.T.)     
		
FUNCTION VerificaGrupo(aCodigos,nI)
   l06 := .F.  
	l27 := .F.
	lOutro := .F.
	FOR X:=1 TO nI
      DBSETORDER(1)
		CECCMER->(DBSEEK(ACODIGOS[X]))
      IF (CECCMER->CODLINM>=3900 .AND. CECCMER->CODLINM<=3904) .OR. CECCMER->CODLINM==3300  .OR. CECCMER->CODLINM=9999
			l06 := .T.
			IF l27 .OR. lOutro
				M_DISPLAY("Nao pode mistrurar produtos de aliquotas de ICMS diferente",79)
				RETURN(.F.)
			ENDIF   
		ELSEIF CECCMER->CODLINM=2700
			l27 := .T.
			IF l06 .OR. lOutro
				M_DISPLAY("Nao pode mistrurar produtos de aliquotas de ICMS diferente",79)
				RETURN(.F.)
			ENDIF   
		ELSE    
			lOutro := .T.
			IF l06 .OR. l27
				M_DISPLAY("Nao pode mistrurar produtos de aliquotas de ICMS diferente",79)
				RETURN(.F.)
			ENDIF           
		ENDIF   
	NEXT
RETURN(.T.)     

function VerificaCliente(nCliente,TEMCREDITO,___sAI)
	LOCAL cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
		cCor := SETCOLOR(),;
		nCursor := SETCURSOR(0),;
		aCab := {"Duplicata","EmissÆo","Vencto","Valor","Saldo"},;
		aPic := {[@!],[@d],[@d],[@R@E 9,999,999.99],[@R@E 9,999,999.99]},;
		nArea := SELECT(),;
		aDebitos:={}
		
	___sai := .F.   
	CECCREC->(DBSEEK(STRZERO(nCliente,5)))
	lTem := .F.
	nTotal := 0
	DO WHILE nCliente==(CECCREC->CODCLIR) .AND. !(CECCREC->(EOF())) 
		IF CECCREC->DTVENCR<=DATE() .AND. CECCREC->STATUSR#"*"
			AADD(aDebitos,{CECCREC->DOCDUPR,CECCREC->DTEMISR,CECCREC->DTVENCR,CECCREC->VLDOCTR,CECCREC->SLDOCTR})
			nTotal += CECCREC->SLDOCTR
			lTem := .T.
		ENDIF
		CECCREC->(DBSKIP())
	ENDDO           
	IF lTem
		AADD(aDebitos,{"TOTAL",NIL,NIL,NIL,nTotal})
		M_DISPLAY("Este cliente possiu debitos pendentes",79)
		HBrowseAr( 8, 0, 24, 79, "Duplicatas devidas", aCab, aDebitos , aPic )
		IF M_QUERY("Deseja liberar novas compras a prazo ?",23)
			IF Pass()#ALLTRIM(Criptografa ( CECCSET -> PASSWDS, "HAWK",.F.))
				M_DISPLAY("Usuario nao autorizado",79)
				TEMCREDITO := .F.
				SETCURSOR(NCURSOR)
				SETCOLOR(cCor)
				return(.T.)
			ENDIF
			TEMCREDITO := .T.
			SETCURSOR(NCURSOR)
			SETCOLOR(cCor)
			RETURN(.T.)
		ELSE
			TEMCREDITO := .F.
			SETCURSOR(NCURSOR)
			SETCOLOR(cCor)  
			RETURN(.T.)     
		ENDIF           
	ENDIF   
	SETCURSOR(NCURSOR)
	SETCOLOR(cCor)
RETURN(.T.)                     


FUNCTION GetData(nCliente,nVendedor,cAprazo,cRevenda,;
					  aCodigo,aDesc,aReferencia,aQuantidade,;
					  aPrecoU,aDescItem,aGrupo,lAltera,nItems,ACodAnt,aQtdAnt,aApaga)
	AFILL(aCodigo,SPACE(16))
	AFILL(aDesc,SPACE(40))
	AFILL(aReferencia,SPACE(13))
	AFILL(aQuantidade,0)
	AFILL(aPrecoU,0)
	AFILL(aDescItem,0)
	AFILL(aGrupo,0)                           
	AFILL(aApaga,[ ])
	lAltera  := .T.
	nCliente := CECCBAL1->CLIENTE 
	nVendedor:= CECCBAL1->VENDEDOR
	cAprazo  := CECCBAL1->APRAZO
	cRevenda := CECCBAL1->REVENDA
	CECCBAL2->(DBSEEK(STR(CECCBAL1->PEDIDO,10)))
	nItems := 0
	DO WHILE CECCBAL2->PEDIDO == CECCBAL1->PEDIDO .AND. CECCBAL2->(!EOF())
		nItems ++
		aCodigo[nITems]     := CECCBAL2->MERCADORIA
		aCodAnt[nItems]     := CECCBAL2->MERCADORIA
		aDesc[nItems]       := CECCBAL2->DESCRICAO
		aReferencia[nItems] := CECCBAL2->REFERENCIA
		aQuantidade[nItems] := CECCBAL2->QTD
		aQTDANT[nItems]     := CECCBAL2->QTD
		aPrecoU[nItems]     := CECCBAL2->PRECOU
		aDescItem[nItems]   := CECCBAL2->DESCONTO
		aGrupo[nItems]      := CECCBAL2->GRUPO                            
		CECCBAL2->(DBSKIP())
	ENDDO
	CECCBAL2->(DBSEEK(STR(CECCBAL1->PEDIDO,10)))
RETURN(.T.)             

FUNCTION VerificaCautelas(nCliente,___Sai)
LOCAL cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
		cCor := SETCOLOR(),;
		cArqSubNtx := Space(12),;
		nCursor := SETCURSOR(0),;
                aDad := {"TIPO","PEDIDO","VENDEDOR","SUBTOTAL","VDESCONTO","VDESC2","TOTAL"},;
                aCab := {"TIPO","Cautela","Vendedor","Sub-Total","Desconto%","Desconto R$","Total"},;
                aPic := {"999","9999999999","99999","9999999.99","9999999.99","9999999.99","9999999.99"},;
		nOrd := CECCBAL1->(INDEXORD()),;
		nPed := CECCBAL1->PEDIDO,;
		nArea := SELECT()
		___Sai := .F.
	//
   CECCBAL1->(DBSETORDER(6))      
	CECCBAL1->(DBSEEK(STR(nCliente,5)+"C"))
	lTem := .F.
   DO WHILE CECCBAL1->CLIENTE=nCliente .AND. CECCBAL1->(!EOF())
      IF CECCBAL1->ATENDIDO=.F. 
			lTem := .T.
			Exit
		ENDIF
		CECCBAL1->(DBSKIP())
	ENDDO           
	IF lTem
		cArqSubNtx := Space(12)
		//
		// Montar Arquivo de Indice Temporario para a SUBNTX
		cArqSubNtx := "PEDI"+cSubNtx       
		cArqSubNtx:=cArqSubNtx+".NTX"
		//m_display(cArqSubNtx,79)
		//
		SELECT("CECCBAL1")
		SET INDEX TO
		SUBNTX("CECIBAL7.NTX",cArqSubNtx,STR(CECCBAL1->CLIENTE,5),STR(CECCBAL1->CLIENTE,5),"***",.F.,-1)
		DBSETINDEX(cArqSubNtx)
		HBrowseDB(8,0,24,79,"Cautelas pendentes",aCab,aDad,aPic,NIL,,,.F.,"CAUTELASPENDENTES")
		CECCBAL1->(DBCLOSEAREA())
		ARQNTX("CECCBAL1")
		SELECT(nArea)
	ENDIF
	CECCBAL1->(DBSETORDER(nOrd))
	CECCBAL1->(DBSEEK(STR(nPed,10)))
	SETCOLOR(cCor)
	SETCURSOR(1)
RETURN(.T.)     

FUNCTION Itens()
LOCAL cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
		cCor := SETCOLOR(),;
		cArqSubNtx := Space(12),;
		nCursor := SETCURSOR(0),;
		aDad := {"PEDIDO","MERC2","DESCRICAO","QTD","PRECOU","PRECOT","DESCONTO"},;
		aCab := {"CAUTELA","Mercadoria","Descricao","Quantidade","Unit rio","Total","DESCONTO"},;
		aPic := {"9999999999","@!","@!","999999.999","9999999.99","9999999.99","999999.99"}
	
	// Montar Arquivo de Indice Temporario para a SUBNTX
	
	cArqSubNtx := "ITEI"+cSubNtx       
	cArqSubNtx :=cArqSubNtx+".NTX"
	//m_display(cArqSubNtx,79)
	
	SELECT("CECCBAL2")
	SET INDEX TO
	SUBNTX("CECIBAL2.NTX",cArqSubNtx,STR(CECCBAL1->PEDIDO,10),STR(CECCBAL1->PEDIDO,10),"***",.F.,-1)
	DBSETINDEX(cArqSubNtx)
	HBrowseDB(8,0,24,79,"Itens da cautela "+ALLTRIM(STR(CECCBAL1->PEDIDO,10)),aCab,aDad,aPic,NIL,,,.f.,"CAUTELASPENDENTES")
	CECCBAL2->(DBCLOSEAREA())
	ARQNTX("CECCBAL2")
	SELECT("CECCBAL1")
	SETCURSOR(NCURSOR)
	SETCOLOR(CCOR)
RETURN(NIL)
