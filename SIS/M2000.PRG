// Waldemir Litaiff Vasconcelos - Phone - (092) 651-2613
// 01/11/95
// Entrada de Mercadorias - Fiscal

// Declara‡”es locais

LOCAL nOldCursor := SETCURSOR()
LOCAL cOldColor  := SETCOR()
LOCAL cOldScreen 

LOCAL cMovimento,;
		dDataEmissao,;
		dDataMovimento,;
		dDataRecebimento,;
		cCfo,;
		nValorNota,;
		nIcmsAlicota,;
		nAlicotaDesconto,;
		nIPIValor,;
		nFrete,;
		nSeguro,;
		nPag,;
		cCodTrib,;
		nCodTributario,;
		lChange,;
		lChange2,;
		nNum,;
		nCodT,;
		nRecord,;
		cScreen1,cScreen2,x,y,;
		EstoqueCusto,cTelao,;
		cUnidade,;
		nQNota,;
		nValor,;
		cOld,;
		nFator,;
		nRegMov,;
		nRegMoa,;
		xLoj,;
	   nTaxa,;
		cMercadoria,;
	   nLoja,;
		cNota,;
		m_Tipmm,;
		c_TipoLancamento,;
		m_resdesc,;
		nCustoMov,;
		precoitem,;
		nCodVendedor,;
		nFormaPaga
		getlist:={}
		
PRIVATE nIcmsValor,;
       nIcmsBase,;
		 nIPIBase,;
		 cSerie,;  
		 nSubSerie,;
		 NFOR,;
		 nResiduo,;
		 nQRecb,;
		 LojAnt,;
		 CusMedio:=0

// Verifica a existˆncia de ¡ndices, nao existindo cria-los 	
IF !ARQNTX("CECCMER",.F.) .OR. ;
	!ARQNTX("CECCMOV",.F.) .OR. ;
	!ARQNTX("CECCLOJ",.F.) .OR. ;
	!ARQNTX("CECCFOR",.F.) .OR. ;
	!ARQNTX("CECCCLI",.F.) .OR. ;
	!ARQNTX("CECCFIS",.F.) .OR. ;
	!ARQNTX("CECTLOJ",.F.) .OR. ;
	!ARQNTX("CECCVEN",.F.) .OR. ;
	!ARQNTX("CECCSET",.F.) 
	DBCLOSEALL()
	RETURN
ENDIF
//   
cOldScreen := Titulo(02,00,23,79,"Movimentacao das Mercadorias - Fiscal","GR+/B","N+/Bg",m->quadro02)
//
// Salvar Tela Anterior e Montar Nova
COLD:=SAVESCREEN(04,04,17,77)	
SETCOR(m->cEdicao) 
BOX(03,04,05,76,m->FR,127,3,8)
COLD1:=SAVESCREEN(03,04,17,77)	
SETCURSOR(1)

nTaxa := 1
lChange := .T.
cMovimento      := "  "
DO WHILE .T.
	IF lChange
		cTipoLancamento := "COMPRA"
		nLanFiscal      := 0
		cNota           := SPACE(10)
		cSerie          := SPACE(1)
		nSubSerie       := 0
		nFor            := 0	
		dDataEmissao    := CTOD("  /  /  ")
		dDataRecebimento:= CTOD("  /  /  ")
		dDataMovimento  := CTOD("  /  /  ")
		cCfo            := 0 
		nValorNota      := 0
		nIcmsAlicota    := 0
		nIcmsValor      := 0
		nAlicotaDesconto:= 0
		nValorDesconto  := 0
		nIcmsBase       := 0
		nIPIValor       := 0
		nIPIBase        := 0
		nFrete          := 0
		nSeguro         := 0
		nPag            := 0
		cCodTrib        := space(1)
		nCodTributario  := 1
		nAnotherDesp    := 0
		m_resdesc       := 0
		nCustoMov       := 0
		precoitem       := 0
		nCodVendedor    := 0
		nFormaPaga      := 0
		lChange := .F.
	ENDIF	
	RESTSCREEN(03,04,05,77,cOld1)
   @ 04,05 SAY "Tipo de Movimento..:"  GET cMovimento  PICTURE "!!" VALID( !EMPTY(cMovimento) .and. ChecaMov(cMovimento,.T.) )
	//,"Movimento n„o Existe - F1 p/ Verificar...",.t.))
	// 	     VALID( (cMovimento="EC" .or. cMovimento="DC" .or. cMovimento="CP") .and. MostraMov(cMovimento) )  
	Read
	IF LASTKEY() = 27
		DBCLOSEALL()
		RESTSCREEN(02,00,23,79,cOldScreen)
		SetCor(cOldColor)
		SETCURSOR(nOldCursor)
		RETURN(NIL)
	ENDIF	
	// Tela para Movimentos Fiscais - Dados da Nota
	If cMovimento # "TR" .and.  cMovimento # "VE" .and. cMovimento # "VD"   
		cTipoLancamento := "COMPRA"
		m_tipmm := "E"
		BOX(06,04,16,76,m->FR,127,3,8)
	   @ 07,05 SAY "N§ Documento:"      GET cNota            PICTURE "@X@!"      VALID(!EMPTY( cNota ) .AND. ShowZeros(@CNOTA))
		@ 07,31 SAY "S‚rie.......:"      GET cSerie           PICTURE "@X@!"      
		@ 07,49 SAY "Sub-s‚rie...:"      GET nSubSerie        PICTURE "99"        
		@ 08,05 SAY "Fornecedor..:"      GET NFOR      PICTURE "99999";
						Valid Existe(NFOR,"Fornecedor n„o existe",.F.,"CECCFOR",1,"SUBSTR(NOMECLF,1,15)","@!",ROW(),COL()+1)
		@ 09,05 SAY "Emiss„o.....:"      GET dDataEmissao     					     VALID(!EMPTY(dDataEmissao) )   
		@ 09,28 SAY "Entrada.:"          GET dDataRecebimento 						  VALID(!EMPTY(dDataRecebimento))  
		@ 09,49 SAY "Lan‡amento Fiscal:" GET nLanFiscal       PICTURE "9999999"   VALID(!EMPTY(nLanFiscal))
		@ 10,05 SAY "Oper. Fiscal:"      GET cCfo             PICTURE "999" 
		@ 10,49 SAY "Cod. Tribut rio:"   GET cCodTrib         picture '!' valid cCodTrib $ "1234567" .and. Tributo(cCodTrib)
		@ 11,05 SAY "Valor Nota..:"      GET nValorNota       PICTURE "@R 999,999,999,999.99" VALID !EMPTY(nValorNota)
		@ 11,49 SAY "%Desc. ICM:" 			GET nAlicotaDesconto PICTURE "99.99"     //WHEN nCodTributario=1 
		@ 12,05 SAY "%ICMS.......:"      GET nIcmsAlicota     PICTURE "@R 99.99" VALID CALCULA(nAlicotaDesconto,nValorNota,nIPIValor,nIcmsAlicota,nCodTributario,nIcmsBase)
		@ 12,25 SAY "B.Icms.:"           GET nIcmsBase        PICTURE "@R 9999999,999.99" when nCodTributario=4 VALID CALCULA(nAlicotaDesconto,nValorNota,nIPIValor,nIcmsAlicota,nCodTributario,nIcmsBase)
		@ 12,49 SAY "Vl. ICMS:" 			GET nIcmsValor       PICTURE "@R 999,999,999.99" 
		@ 13,05 SAY "Vl. IPI.....:"      GET nIPIValor        PICTURE "@R 999,999,999.99"
		@ 13,49 SAY "Vl. Frete:"         GET nFrete           PICTURE "@R 9999999,999.99"
		@ 14,05 SAY "Vl. Seguro..:"    	GET nSeguro          PICTURE "@R 9999999,999.99"
		@ 14,49 SAY "Outras Desp:"       GET nAnotherDesp     PICTURE "@R 9999999,999.99"
		@ 15,05 SAY "Cond. Pagto.:" 	   GET nPag             PICTURE "99"
		@ 15,49 SAY "Movimento:" 			GET dDataMovimento   VALID(!EMPTY(dDataMovimento))  
		READ
	Else
		//Tela para Vendas Fiscais
		If cMovimento # "TR" 
			m_tipmm := "S"
			cTipoLancamento := "VENDA"
			BOX(06,04,16,76,m->FR,127,3,8)
   		@ 07,05 SAY "N§ Documento:"      GET cNota            PICTURE "@X@!"      VALID(!EMPTY( cNota ) .AND. ShowZeros(@CNOTA))
			@ 07,31 SAY "S‚rie.......:"      GET cSerie           PICTURE "@X@!"      
			@ 07,49 SAY "Sub-s‚rie...:"      GET nSubSerie        PICTURE "99"        
			@ 08,05 SAY "Cliente.....:"      GET nFor      		   PICTURE "99999";
							Valid Existe(NFOR,"Cliente n„o existe",.F.,"CECCCLI",1,"SUBSTR(NOMECLC,1,15)","@!",ROW(),COL()+1)
			@ 09,05 say "Cod.Vendedor:"      GET nCodVendedor     PICTURE "@R 99999" Valid Existe(Str(nCodVendedor),"Vendedor nao Exise",.F.,"CECCVEN",1,"subs(nomven,1,25)","@!",row(),col()+1)
			@ 10,05 SAY "Emiss„o.....:"      GET dDataEmissao     					     VALID(!EMPTY(dDataEmissao) )   
			@ 10,49 SAY "Entrada.:"          GET dDataRecebimento 						  VALID(!EMPTY(dDataRecebimento))  	
			@ 11,05 SAY "Valor Nota..:"      GET nValorNota       PICTURE "@R 999,999,999,999.99" VALID !EMPTY(nValorNota)
			@ 11,49 SAY "%Desc......" 			GET nAlicotaDesconto PICTURE "99.99"     //WHEN nCodTributario=1 
			@ 12,05 SAY "%ICMS.......:"      GET nIcmsAlicota     PICTURE "@R 99.99" VALID CALCULA(nAlicotaDesconto,nValorNota,nIPIValor,nIcmsAlicota,nCodTributario,nIcmsBase)
			@ 12,25 SAY "B.Icms.:"           GET nIcmsBase        PICTURE "@R 9999999,999.99" when nCodTributario=4 VALID CALCULA(nAlicotaDesconto,nValorNota,nIPIValor,nIcmsAlicota,nCodTributario,nIcmsBase)
			@ 12,49 SAY "Vl. ICMS:" 			GET nIcmsValor       PICTURE "@R 999,999,999.99" 
			@ 14,05 SAY "Cond. Pagto.:" 	   GET nPag             PICTURE "99"
			@ 14,28 SAY "Forma Pagto.:"      GET nFormaPaga       PICTURE "99"
			@ 14,49 SAY "Movimento:" 			GET dDataMovimento   VALID(!EMPTY(dDataMovimento))  
			Read
		Else
			//Outros Movimentos - Tramites Internos "TR" ( Saida ou Entrada en Uma Determinada Loja )
			m_tipmm := " "
			cTipoLancamento := "TRANSF"
			BOX(06,04,16,76,m->FR,127,3,8)
   		@ 07,05 SAY "N§ Documento.......:"  GET cNota      PICTURE "@X@!"  VALID(!EMPTY( cNota ) .AND. ShowZeros(@CNOTA))
			@ 08,05 say "Tipo de Lan‡amento.:"  GET M_TIPMM    PICTURE "!" VALID M_TIPMM $ "ESI" .and. MostraTipMov(m_tipmm)
			@ 10,05 SAY "Valor do Documento.:"  GET nValorNota PICTURE "@R 999,999,999,999.99"  //VALID !EMPTY(nValorNota)
			@ 15,45 SAY "Data do Movimento..:" 	GET dDataMovimento   VALID(!EMPTY(dDataMovimento))  
			Read
		EndIf
	EndIf
	//	
	IF LASTKEY() = 27
		DBCLOSEALL()
		RESTSCREEN(02,00,23,79,cOldScreen)
		SetCor(cOldColor)
		SETCURSOR(nOldCursor)
		RETURN(NIL)
	ENDIF	
	//
	IF M_TIPMM == "I" .AND. cMovimento = "TR"
		If ! ( PASS () == ALLTRIM ( Criptografa ( CECCSET -> PASSWDS, "HAWK", .F. ) ) ) 
			M_DISPLAY ( "Usu rio n„o autorizado", 79 )
			LOOP
		Endif	
	EndIf
	//
	IF !Confirma("Confirma cabe‡alho do Documento",23)
		LOOP
	ENDIF
	//
	/* SELECT("CECCFOR")
 	If sCgv=1
	   NFOR = Cfor
	End */
	// Grava cabe‡alho da Nota
	nCodT := 2
	If cMovimento # "TR" .and.  cMovimento # "VE" .and. cMovimento # "VD"   
		If nCodTributario == 1 .or. nCodTributario == 2  //Com Imposto e/ou Desconto de ICMS
  	     	nCodT := 1
		elseif nCodTributario == 3                 //Sem Imposto - Isento 
		   nCodT   := 2
			nIcmsValor:= 0
		elseif nCodTributario == 4                 //Com imposto - syssip Base icms diferente
		   nCodT  := 1
		elseif nCodTributario == 5                 //So IPI
		   nCodT  := 1
		elseif nCodTributario == 6                 //Outros
		   nCodT  := 3
		EndIf
	EndIf
	//
	// Calcular percentual de Despesas
	IF cMovimento # "TR"
		nValorNota := nValorNota	               //Round(nValorNota * nTaxa ,2)
		m_perdesp  := Round((nFrete+nSeguro+nAnotherdesp)/nValorNota,10)
	Endif
	//
	SELECT ( "CECCFIS" )	
	//
	IF cMovimento # "TR"
		IF INCLUI_REGISTRO(.F.)
			LOCK_REGISTRO(.T.)
			ceccfis->CLI_FOR  :=  NFOR
			cecCFIS->NNOTA    :=  cNota
			cecCFIS->SERIE    :=  cSerie
			cecCFIS->SUBSER   :=  nSubSerie
			cecCFIS->DEMI     :=  dDataEmissao
			cecCFIS->DENT     :=  dDataRecebimento
			cecCFIS->VLNOT    :=  nValorNota  
			cecCFIS->CFO      :=  STR(cCfo)
			cecCFIS->CODTRI   :=  nCodT
			cecCFIS->ALIICMS  :=  nAlicotaDesconto
			cecCFIS->ALIDICMS :=  nAlicotaDesconto
			cecCFIS->VLICMS   :=  nIcmsValor
			cecCFIS->VLDICMS  :=  nIcmsValor
			cecCFIS->VLIPI    :=  nIPIValor
			cecCFIS->FRETE    :=  nFrete
			cecCFIS->SEGURO   :=  nSeguro
			cecCFIS->BASICMS  :=  nIcmsBase
			cecCFIS->BASIPI   :=  nIPIBase
			cecCFIS->NLANFIS  :=  nLanFiscal
			cecCFIS->CONPAG   :=  nPag
			ceccfis->forpag   :=  nFormaPaga
			ceccfis->vendedor :=  nCodVendedor
			DBCOMMIT()
			DBUNLOCK()
		ELSE
			M_MESSAGE ( "Opera‡„o cancelada pelo usu rio", 79 )
			LOOP
		ENDIF
	EndIf
	//
	IF cMovimento=="CD" .OR. cMovimento=="VE" .OR.;
	   (cMovimento=="TR" .AND. m_tipmm = "S")
		nFator := -1
	ELSE 
		nFator := 1			
	ENDIF	
	//
	cTelao := SAVESCREEN(0,0,LASTROW(),LASTCOL())
	cScreen2 := SAVESCREEN(04,04,08,76)
	RESTSCREEN(04,04,16,77,cOld)
	@ 10,06 CLEAR TO 10,76
	@ 10,05 SAY If(cMovimento=="TR","Valor do Docto:","Valor da Nota:")
	@ 10,19 SAY nValorNota
	@ 10,45 SAY "ICMS:"
	@ 10,50 SAY nIcmsValor 
	BOX(4,4,09,76,m->fr,127,3,79)
	RESTSCREEN(04,04,08,76,cScreen2)
	cScreen1 := SAVESCREEN(10,4,23,77)
	BOX(11,04,22,76,m->fr,127,3,08)
	@ 11,05 SAY "[Loj]"
	@ 11,10 SAY "[Mercadoria    ]"
	@ 11,26 SAY "[Un.]"
	@ 11,31 SAY "[Qt. Nota    ]"
	@ 11,45 SAY "[Qt. Recebida]"
	@ 11,59 SAY "[Valor Tot. Item]"
	@ 22,05 SAY "[                              ]"
	@ 22,44 SAY "[                              ]"
	lChange2 := .T.
	LocAnt := 0 
	DO WHILE .T.
		IF lChange2 
			nLoja       := 0			
			cMercadoria := SPACE(13)
			cUnidade    := SPACE(3)
			nQNota:=nQRecb:=nValor:=0
			lChange2 := .F.
		ENDIF	
		nQRecb := 0
		@ 12,05 GET nLoja       PICTURE "9999" VALID( Existe(nLoja,"Loja n„o cadastrada",.F.,"cectloj",1,"LEFT(nomlojtl,30)","@!",22,06) .AND. !EMPTY(nLoja) )
		@ 12,11 GET cMercadoria PICTURE "@!"   VALID( Existe(cMercadoria,"Mercadoria n„o cadastrada",.F.,"cecCMer",1,"LEFT(subs(Descrim,1,30),30)","@!",22,45) .AND. !EMPTY(cMercadoria) )
		@ 12,27 GET cUnidade    PICTURE "@!@X" VALID( !EMPTY(cUnidade) )       //.and. ceccmer->Unidade=cUnidade )
		@ 12,32 GET nQNota      PICTURE "999999.999" VALID ( If(M_TIPMM="I",.T.,!EMPTY(nQNota)))     // NotaToReal ( nQNota )
		@ 12,46 GET nQRecb      PICTURE "999999.999" VALID ( !EMPTY(nQRecb) ) when cTipoLancamento=="COMPRA"
				  If(m_tipmm=="TR",nValor=Round(nQnota*(ceccmer->Cmedm,2),2),nValor=0)
		@ 12,60 GET nValor      PICTURE "999999999999.99" VALID ( If(cMovimento="TR",.t.,!EMPTY(nvalor)) )
		READ
		IF LASTKEY()=27
			IF M_QUERY("Confirma o retorno ?",23)
				RESTSCREEN(10,04,23,77,cScreen1)
				RESTSCREEN(0,0,LASTROW(),LASTCOL(),cTelao)
				lChange := .T.
				EXIT
			ENDIF
			LOOP
		ENDIF		
		// Verifica os tipos de movimentos
		EstoqueCusto := CECCMER->SALDOEM
		IF cMovimento # "CP" .AND. M_TIPMM # "I" .AND. nQNota = 0 
	 		M_DISPLAY("Entrada de Custo com Quant. Zero, somente no mov->CP. Verifique!",79)
			LOOP
		ENDIF
		IF cMovimento = "CP" .AND. EstoqueCusto = 0 
			M_DISPLAY("N„o h  saldo em estoque para entrada de custo. Verifique!",79)
			LOOP
		ENDIF	
		IF cTipoLancamento != "COMPRA"  
			nQrecb := nQnota
		ENDIF
		// Grava itens da Nota
		IF !Confirma("Confirma o item?",23)	
			LOOP
		ENDIF	
		// Confirma inclus„o do item
		xloj := nLoja
		Select("ceccmer")
		DbSeek(cMercadoria)
		CusM_An_Cr := cmedm
		m_EstCus   := saldoem                   // estoque do item 
	   m_un       := unidade                   // Unidade 
		m_dsc1     := descrim                   // Descricao do Item
	   m_linha    := codlinm                   // linha 
	   m_div      := coddivm                   // divisao
		m_origem   := origemm
		m_resdesc  := 0
		m_resdebi  := 0 
	   m_despite  := 0
		/**
		 *************************** Gravacao ********************************
		**/
		// Checar confirmacao da entrada dos itens
		 // Calculo para os Itens da Nota
		 If cTipoLancamento == "COMPRA" 
          Select("CECCMER")
        	 m_resdesc := 1-(nAlicotaDesconto/100)       // Residuo para Descontos
	   	 m_resdebi := 0                          // Residuo para Debitar o Desconto 
	   	 m_despite := 0                      // Despesas do Item
			 precoitem := nValor
			 //precoitemu:= Round(nValor/taxa_us,2)
	   	 if nCodTributario == 2     // Itens c/ vl.liq. e/ou so icm/isento/outros
	      	 m_resdebi := Round((1 / m_resdesc),10)
	      	 m_resdebi := Round((m_resdebi * (nIcmsAlicota/100)),10)
         	 m_resdebi := 1 - m_resdebi
	       	 precoitem := nValor
				 //precoitemU:= Round(precoitem/Taxa_us,2)
        	 else                 // Itens c/Desconto de Icm no Rodape e Icm
			    m_resdebi := Round(m_resdesc - (nIcmsAlicota/100),10)  
  		 		 precoitem := Round((m_resdesc * nValor),2)
				 //precoitemU:= Round(precoitem/Taxa_us,2)
        	 end
	   	 //Calculos Comuns dos Itens
	   	 // Despesas do Item
	   	 m_despite := Round((precoitem * m_perdesp),2)
	   	 // IPI
	   	 precoitem += nIPIvalor     // Adiciona IPI ao Preco do Item se Tiver 
			 //precoitemu+= Round(nIPIValor/Taxa_us,2)
			 //** Rateio p/ base de icms informada, dos itens da nota - custo mov.
			 if nCodTributario == 4
			    m_resdebi := Round((nIcmsValor/nValorNota),16)
				 m_resdebi := 1 - m_resdebi
			 end
			 //**/
	       // Custo do Movimento
			 cusmosed := 0
	   	 nCustoMov := Round((nValor * m_resdebi),2)
	   	 nCustoMov += m_despite         //Custo Liq. Mov.( - ICM + Desp.)
	   	 Cusmosed  += nCustoMov          //Custo Mov. Sem Despesas
			 //nCustoMovU:= Round(nCustoMov/Taxa_us,2)
			 /**
			 ********* Final da Preparacao de Compras(Entradas) ********
   		 ***/
		 Else
		 	 If cTipoLancamento == "VENDA"
			    /*** Rotina do movimento de Saidas de materiais (Vendas) ***
     		     **** Calculos dos Itens da Nota
     	   	  ***/
			 	 if nCodt == 1
			   	 m_resdebi := m_resdesc - (m_aliicm/100)  //
			    	 precoitem := Round((m_resdebi * nValor),2)
			 	 else
			   	 precoitem := nValor
			 	 end
			 	 precoitem += nIPIValor
				 nCustoMov := Round(nQnota*(ceccmer->Cmedm),2) * nFator
			 	 //PrecoItemU:= Round(pRecoItem/Taxa_us,2)
			 	 /**
			 	  ********* Final da Preparacao de Vendas (Saidas) ********
			 	  **/
			 End
		 End
		 // Atualizar Movimento do Mes - cecCmov
		 // Pegar Area 
		 Select("CecTloj")
		 //
		 DbSeek(xLoj)
		 //
		 Select("CeccMov")
		 if inclui_registro(.t.)
          if lock_registro(.t.)
			 	 ceccmov->fornecedor:= NFOR
		  		 ceccmov->mercadoria:= cMercadoria
		 		 ceccmov->numdocto := cNota
				 ceccmov->descmerc := m_dsc1
				 ceccmov->serie    := cSerie
				 ceccmov->subserie := nSubSerie
				 ceccmov->origem   := m_origem
		 		 ceccmov->divisao  := m_div
		 		 ceccmov->linha    := m_linha
		 		 ceccmov->datamov  := IF(cMovimento="TR",dDataMovimento,dDataRecebimento)
		       ceccmov->datadocto:= IF(cMovimento="TR",dDataMovimento,dDataEmissao)
				 ceccmov->tipomov  := IF(m_tipmm=="I","A",m_tipmm)
		 		 ceccmov->codmov   := cMovimento
		 		 ceccmov->codloja  := xLoj
				 ceccmov->unidade  := cUnidade
		 		 ceccmov->quantdoc := nQNota*nFator
		 		 ceccmov->quantmov := nQRecb*nFator
				 ceccmov->customov := nCustoMov
				 ceccmov->prevenda := ceccmer->precvem
				 ceccmov->prevendido := IF(cMovimento=="VE",Round(Precoitem/nQNota,2),0)
				 ceccmov->vendedor   := IF(cMovimento=="VE",nCodVendedor,0)
				 ceccmov->alidesitem := nAlicotaDesconto
				 ceccmov->vldescitem := Round(nValor*(nAlicotaDesconto/100),2)
				 ceccmov->alimcsitem := nIcmsAlicota
				 ceccmov->vlicmsitem := Round(nValor*(nIcmsAlicota/100),2) 
				 If cMovimento == "CF".OR. cMovimento == "CD" .OR. cMovimento == "CP"
				  	 ceccmov->custofob := Round(nValor/nQnota,2)
				 	 ceccmov->precompra:= Round(nValor/nQnota,2)
					 ceccmov->despeitem:= m_despite
				 EndIf
				 ceccmov->cusmedant:= cusM_an_Cr
				 ceccmov->salantmov:= m_EstCus
				 ceccmov->prazopag := nPag
				 ceccmov->formapag := nFormaPaga
	 		 end
          dbcommit()
	 		 dbunlock()
			 NREGMOV := RECNO()
 		 end	   
		 // Atualizar movimento acumulado -
		 /**
		 ******************** Calculos para Atualizacao *******************
		 **/
		 //
		 Select("CeccMer")
		 caam:=0
		 If cTipoLancamento == "COMPRA"
	    	 QtdEstoq := Saldoem             // 
			 QtdDispo := Saldoem
	   	 //
     		 caam += nQNota              //Compras Acumuladas apos Inventario
			 //
     	  	 //**Calcular Custo Tot. Item no Estoque p/ Tipo de Custo Utilisado
			 //
        	 ** if sTcu     == 5            //Valorizacao pelo Custo Padrao
  	     	 *   custoitem  := Round(QtdEstoq * csta,2) 
	     	 *	 custoitemu := Round(QtdEstoq * cstaus,2) 
			 *	 nCustoMov   := Round(nQNota  * csta,2)
			 *	 nCustoMovU  := Round(nQNota  * cstaus,2)
  	     	 * elseif sTcu == 6           //Valorizacao pelo Custo Fob
			 *	 custoitem  := Round(QtdEstoq * cfob,2) 
			 *	 custoitemu := Round(QtdEstoq * cfobus,2) 
			 *	 nCustoMov   := PrecoItem
			 *	 nCustoMovU  := PrecoItemU
		 	 * 	 elseif sTcu == 7 
			 *
			 // **** Calculo do custo do estoque
	   	 CustoItem := Round(QtdEstoq * Cmedm,2)      //Valorizacao pelo custo Medio
			 //	 custoitemu := Round(QtdEstoq * cmunitus,2) 
        	 // end
			 CusEstoq  := CustoItem
			 //CusEstoqU := CustoItemU
			 //
			 if nValor == 0               //.and. sTcu == 7
		   	 nCustoMov := PrecoItem                   //Entrada de custo R$
				 //nCustoMovU:= Round(Precoitem/Taxa_us,2)  //   "    "    "   Us$
				 //
				 // ReAtualizar Custos do Movimento
				 Select("CeccMov")
			    Lock_registro(.t.)
			  	 CECCMOV->CUSTOMOV := nCustoMov
				 DBCOMMIT()
				 DBUNLOCK()
		       //
			 End
			 // 
		  	 // Calcular Novos Custos - Fob,Medio e Tot. Area
			 // Pegar Area 
		  	 Select("CecTloj")
			 //
			 DbSeek(xLoj)
			 // Preparar para Calcular Medio
			 // Somar Qtd. e Custo - Estoque e Entradas
			 Select("CeccMer")
			 //
			 QtdTotal := QtdEstoq  + nQNota       // Qt. Estoque + Entrada 
   		 CusTotal := nCustoMov + CusEstoq     //
			 //CusTotalU:= nCustoMovu+ CusEstoqU  //
        	 //
			 CusMedio := 0
			 CusMedioU:= 0
			 CusFob   := 0
			 CusFobU  := 0
			 CusCif   := 0
			 If QtdTotal # 0
			    // Custo Medio
			    CusMedio := Round(CusTotal/QtdTotal,4)
			    //CusMedioU:= Round(CusTotalU/QtdTotal,4)
		    	 // Custo Fob
		 	    CusFob := Round(nCustoMov/nQNota,4)
			    //CusFobU:= Round((nCustoMovu/nQNota),4)
				 CusCif := Round((nValor/nQNota),4)
	       End     			
			 // ver se entra - RCustoMedio ( dDataMovimento, cMercadoria, QtdEstoq, nQNota, CMUNIT, CMUNITUS, nCustoMov, nCustoMovU )
		 Else
			 // Vendas (Saidas) VER - saida pelo faturamento
		 Endif
		 if cTipoLancamento == "COMPRA"
			 // Registrar no movimento custo medio apurado nesta entrada 
			 Select("CeccMov")
			 If Lock_Registri(.t.)
			    ceccmov->customed  := CusMedio
			 Endif
			 dbcommit()
			 dbunlock()
		 EndIf
		 // Atualizar Cadastro de Lojas - CecCloj
		 select("CECCLOJ")
		 If !Dbseek(str(xLoj,4)+cMercadoria)
			 if inclui_registro(.t.)
	          if lock_registro(.t.)
		 			 CECCLOJ->codiloj  := xLoj
		 			 CECCLOJ->mercloj  := cMercadoria
					 CECCLOJ->saldoej  := nQRecb*nFator
   		 		 CECCLOJ->dcucloj  := cNota
					 CECCLOJ->dtucloj  := IF(cMovimento="TR",dDataMovimento,dDataRecebimento)
				 end
	 		 end
			 dbcommit()
			 dbunlock()
		 Else
 			 If lock_registro(.t.)
			    IF(m_tipmm=="I",ceccloj->saldoej := nQRecb*nFator,ceccloj->saldoej += nQRecb*nFator)
				 			 		  ceccloj->dcucloj := cNota
				 					  ceccloj->DTUCLOJ := IF(cMovimento="TR",dDataMovimento,dDataRecebimento)
          Endif
			 DBCOMMIT()
			 DBUNLOCK()
		 Endif
		 // Atualizar Cadastro de Mercadorias - Saldo dos Itens
		 Select("CeccMer")
		 If lock_registro(.t.) 
		    IF(m_tipmm=="I",CECCMER->Saldoem := nQRecb*nFator,CECCMER->Saldoem += nQRecb*nFator)
			 If cMovimento == "CF" .OR. cMovimento == "CD" .OR. cMovimento== "CP"
			    ceccmer->Cmedm    := CusMedio
				 ceccmer->Cfobm    := CusFob
				 ceccmer->Ccifm    := CusCif
				 ceccmer->preccom  := CusCif
 			    ceccmer->Dcultcm  := cNota
				 ceccmer->Dtultcm  := dDataRecebimento
			 EndIf
			 If cMovimento=="VE".OR.cMovimento=="VD"
			    ceccmer->Dtultvm  := dDataMovimento
 			    ceccmer->Dcultvm  := cNota  	
			 EndIf
			 DBCOMMIT()
			 DBUNLOCK()
			 // 
		 End
		SCROLL(12,05,21,74,-1)
	ENDDO
ENDDO	

FUNCTION VerLoj(lLoj)
	IF Existe(nLoja,"Loja n„o cadastrada",.F.,"cecTLoj",1,"LEFT(NOMLOJTL,30)","@!",IF(lLoj,22,ROW()),IF(lLoc,06,COL()))
		DBSETORDER(1)
		RETURN( .T. )
	ENDIF	
RETURN( .F. )

FUNCTION Tributo(lTrib)
	nCodTributario := Val(lTrib)
	return( .t.)
	
//Mostra tipo de lancamento para outras Movimentacoes (TR) - Entrada ou Saida
FUNCTION MostraTipMov(tMovimento)
	@ row(),col()+2 say If(tMovimento=="E","Lan‡amento de Entrada   ",If(tMovimento="S","Lan‡amento de Sa¡da     ","Lan‡amento de Invent rio") )
	Return(.t.)
	
// Fun‡„o que calcula os Icms e Base
FUNCTION Calcula(nIcmsDes,nValNota,nIPIVal,nIcmsAli,nCodTributo,nBaseCal)
	LOCAL nValorDesconto
   nValorDesconto := Round((nValNota*nIcmsDes)/100,2)
   m->nIPIBase       := nValNota-nValorDesconto
   m->nResiduo       := 1-(nIcmsDes/100) 
	If(nCodTributo=4,m->nIcmsBase:=nBaseCal,m->nIcmsBase:=Round(((nValNota-nIPIVal)/nResiduo),2))
	If(nCodTributo=4,m->nIcmsValor:=Round((((nBaseCal-nIpiVal)*nIcmsAli)/100),2),m->nIcmsValor:=Round((nIcmsAli*nIcmsBase)/100,2))
	m->nDescIcms      := Round((nIcmsDes*nIcmsBase)/100,2) 
RETURN(.T.)	
