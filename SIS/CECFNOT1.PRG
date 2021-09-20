// Sistemas de Controle de Estoque Comercial
// W&R Informatica Ltda
// 28 de 	Marco de 1995
// Roberto Falcao Rocha
// Baixas de mercadorias por pedidos usando impressora fiscal

LOCAL cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
		cCor := SETCOLOR(),;
		nCursor := SETCURSOR(0),;
		aDad := {"TIPO","PEDIDO","LOJA","CLIENTE","VENDEDOR","SUBTOTAL","VDESCONTO","VDESC2","TOTAL","DATAATD","NOTA","SERIE","SUBSERIE","USUARIO"},;
		aCab := {"Tipo","Pedido","Loja","Cliente","Vendedor","Sub-Total","Desconto%","Desconto R$","Total","Atendimento","Nota","Serie","Sub-serie","Responsavel"},;
		aPic := {"@!","9999999999","9999","99999","99999","9999999.99","9999999.99","9999999.99","9999999.99","@D","@!","@!","99","@!"},;
                _cPag:= ""
		

// Verificando arquivos
IF !ARQNTX("CECCBAL1",.F.) .OR. ;
	!ARQNTX("CECCBAL2",.F.) .OR. ;
	!ARQNTX("CECTLOJ",.F.)  .OR. ;
	!ARQNTX("CECCVEN",.F.)  .OR. ;
	!ARQNTX("CECCLOJ",.F.)  .OR. ;
	!ARQNTX("CECCSET",.F.)  .OR. ;
	!ARQNTX("CECCCLI",.F.)  .OR. ;
	!ARQNTX("CECCBOL",.F.)  .OR. ;
	!ARQNTX("CECCMER",.F.) 
	
	DBCLOSEALL()
	RETURN
ENDIF	

SELECT("CECCSET")
DBGOTOP()
SELECT("CECCBAL1")
DBGOTOP()
HBrowseDB( 1,0,24,79,"Cadastro de pedidos/balcao",aCab,aDad,aPic,NIL,,,.F.,"CECF1000")
DBCLOSEAll()
RETURN

FUNCTION PBalcao2( oBrowse )
	LOCAL cCor := SETCOR(m->cEdicao),;
			nCursor := SETCURSOR(1),;
			cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
			nReg := RECNO(),;
			cNotas := SPACE(10),;
			cSerie := SPACE(1),;
			dData := CTOD("  /  /  "),;
			nSubserie := 0,;			
			Getlist:={},;
			lAchou,;
			nPedido:=0,;
			nLoja:=0
			
	xOpcao := Alert("Pesquisa por:",{"Pedidos","Notas","Cancela"})
	
	IF xOpcao == 3
		RETURN(NIL)
	ENDIF	
	
	IF xOpcao == 1
		DISPBOX(05,03,08,75,M->FR)
		@ 06,04 SAY "No. Pedido:";
				  GET nPedido;
				  PICTURE "@K 9999999999";
				  VALID !EMPTY(nPedido)
			  
		@ 07,04 SAY "Loja......:";
				  GET nLoja;
				  PICTURE "@K 9999";
				  VALID lAchou:=Existe(STR(nPedido,10)+STR(nLoja,4),"Pedido nÆo encontrado",.F.,,1,,,,,.T.) 
	ELSE
	
		DISPBOX(05,03,10,75,M->FR)
		@ 06,04 SAY "No. da nota.:";
			  GET cNotas;
			  PICTURE "@K@!";
			  VALID ShowZeros(@cNotas)
			  
	@ 07,04 SAY "Serie.......:";
			  GET cSerie;
			  PICTURE "@K@!"
			  
	@ 08,04 SAY "Sub-serie...:";
			  GET nSubSerie;
			  PICTURE "@K 99"
			  
	@ 09,04 SAY "Data...:";
			  GET dData;
			  PICTURE "@D";
			  VALID lAchou := Existe(cNotas+cSerie+STR(nSubSerie,2)+DTOS(dData),"Nota n„o cadastrada",.F.,,3,,,,,.T.) 					  
			  
	ENDIF			  
			  
	READ		  
		
	SETCURSOR(nCursor)
	SETCOLOR(cCor)
	RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)	
	
	IF LASTKEY()==27
		DBGOTO(nReg)
		oBrowse:refreshAll()
		RETURN(NIL)
	ENDIF	
	
	IF !lAchou
		DBGOTO(nReg)
	ENDIF
		
	oBrowse:refreshAll()
RETURN(NIL)

FUNCTION Atende2()
LOCAL cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
		cCor := SETCOLOR(),;
		cArqSubNtx := Space(12),;
		nCursor := SETCURSOR(0),;
		aDad := {"PEDIDO","LOJA","MERC2","DESCRICAO","QTD","PRECOU","PRECOT","DESCONTO"},;
		aCab := {"Pedido","Loja","Mercadoria","Descricao","Quantidade","Unit rio","Total","DESCONTO"},;
		aPic := {"9999999999","9999","@!","@!","999999.999","9999999.99","9999999.99","999999.99"}
	
	// Montar Arquivo de Indice Temporario para a SUBNTX
	cArqSubNtx := "SUBI"+cSubNtx       
	cArqSubNtx:=cArqSubNtx+".NTX"
	//m_display(cArqSubNtx,79)
	
	SELECT("CECCBAL2")
	SET INDEX TO
        SUBNTX("CECIBAL2.NTX",cArqSubNtx,STR(CECCBAL1->PEDIDO,10),STR(CECCBAL1->PEDIDO,10),"***",.F.,-1)
        DBSETINDEX(cArqSubNtx)
	HBrowseDB(6,0,24,79,"Itens do pedido "+ALLTRIM(STR(CECCBAL1->PEDIDO,10)),aCab,aDad,aPic,NIL,,,{"MERC2","DESCRICAO"},"ATENDE")
	CECCBAL2->(DBCLOSEAREA())
	ARQNTX("CECCBAL2")
	SELECT("CECCBAL1")
RETURN(NIL)




FUNCTION ConfirmaP3()
	LOCAL nDesc,;
			cTela:=SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
			nCursor:=SETCURSOR(0),;
			lManaus := .T.			
			lPessoa := .F.
			lTipo   := .F.
                        nCliente:=0
                        Nome:=space(40)
                        CGC:=SPACE(20)
                        IE:=SPACE(20)
                        END:=SPACE(40)
                        CIDADE:=SPACE(30)
                        UF:=SPACE(2)
                        ob1:=space(130)
                        ob2:=space(130)
                        obanco:=space(100)
                        nNota:=0

	PRIVATE MES       
	
	IF !Confirma("Confirma o pedido ?",23)
		RETURN(NIL)
	ENDIF	

	_cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL())

        lTipo := M_QUERY(" venda  SIMPLES REMESSA ?",23)

	SETCURSOR(1)
	_nPed := 0
	SETCOLOR(M->CEDICAO)
        
        _Obs := SPACE(120)
        _Ob  := SPACE(120)

//        _Obs:="Razao Social, CGC, I.E.                                                              " 
	_Transp := "O MESMO"+SPACE(23)

        IF lTIPO
             nCliente:=0
             BOX(06,01,08,79,M->FR,127,3,8)
             @ 07,02 SAY "Cliente [OBS: Pagara a Fatura]:";
                          GET nCliente;
                          PICTURE "@K 99999";
                          VALID !EMPTY(nCliente) .AND.;
                          Existe(nCliente,"Cliente nÆo cadastrado",.F.,"CECCCLI",1,"NOMECLC","@!",ROW(),COL()+1) // .AND.;
                          // EVAL({||__nDesconto:=CECCCLI->DESCONTO,.T.}) .AND. VerificaCautelas(nCliente,@___Sai)     //.AND.;

             Read

             CECCCLI->(DBSEEK(nCliente))
             NOME:=ALLTRIM(CECCCLI->NOMECLC)
             CGC:=ALLTRIM(CECCCLI->CGCCPFC) 
             IE:=ALLTRIM(CECCCLI->INSESTC)
             _OBS:=NOME+", CGC: "+CGC+", I.E.: "+IE 

             END:=ALLTRIM(CECCCLI->ENDEREC) 
             CIDADE:=ALLTRIM(CECCCLI->CIDADEC)
             UF:=ALLTRIM(CECCCLI->ESTADOC)
             _OB:=END+", "+CIDADE+" - "+UF 

        ELSE
             nCliente:=0
             BOX(06,01,08,79,M->FR,127,3,8)
             @ 07,02 SAY "Cliente [OBS: Sera Entregue]:";
                          GET nCliente;
                          PICTURE "@K 99999";
                          VALID !EMPTY(nCliente) .AND.;
                          Existe(nCliente,"Cliente nÆo cadastrado",.F.,"CECCCLI",1,"NOMECLC","@!",ROW(),COL()+1) // .AND.;
                          // EVAL({||__nDesconto:=CECCCLI->DESCONTO,.T.}) .AND. VerificaCautelas(nCliente,@___Sai)     //.AND.;

             Read

             CECCCLI->(DBSEEK(nCliente))
             NOME:=ALLTRIM(CECCCLI->NOMECLC)
             CGC:=ALLTRIM(CECCCLI->CGCCPFC) 
             IE:=ALLTRIM(CECCCLI->INSESTC)
             _OBS:=NOME+", CGC: "+CGC+", I.E.: "+IE 

             END:=ALLTRIM(CECCCLI->ENDEREC) 
             CIDADE:=ALLTRIM(CECCCLI->CIDADEC)
             UF:=ALLTRIM(CECCCLI->ESTADOC)
             _OB:=END+", "+CIDADE+" - "+UF 

        Endif
        BOX(06,09,08,75,M->FR,127,3,8)
	@ 07,10 SAY "Transportadora:" GET _Transp
	READ
	SETCURSOR(0)
	RESTSCREEN(0,0,MAXROW(),MAXCOL(),_cTela)
	IF LASTKEY()==27
		RETURN(NIL)
	ENDIF	
	//
	_cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL())
	SETCURSOR(1)
	SETCOLOR(M->CEDICAO)
	BOX(05,09,08,75,M->FR,127,3,8)
	xData := DATE()
	xData2 := DATE()
	@ 06,10 SAY "Data de emissÆo:" GET xData PICTURE "@D"	VALID !EMPTY(xData)
	@ 07,10 SAY "Data da saida..:" GET xData2 PICTURE "@D" VALID !EMPTY(xData2)
	READ
	RESTSCREEN(0,0,MAXROW(),MAXCOL(),_cTela)
	SETCURSOR(0)
	IF LASTKEY()==27
		RETURN(NIL)
	ENDIF	
	//
	lManaus := M_QUERY("Nota para Manaus ?",23)
	//
	If !lManaus
		lPessoa := M_QUERY(" Pessoa F¡sica ?",23)
	EndIf
	//
	lFonte := IF(CECCBAL1->REVENDA="S",M_QUERY("Incide ICM na fonte",23),.F.)
	//
	SELECT("CECCBAL2")
	CECCBAL2->(DBGOTOP())
	CECCMER->(DBSEEK(CECCBAL2->MERCADORIA))
	IF (CECCMER->CODLINM>=3900 .AND. CECCMER->CODLINM<=3904).OR. CECCMER->CODLINM=3300 .OR. CECCMER->CODLINM=9999 
		lFonte := .F.
	ENDIF
	SELECT("CECCBAL1")	
	//
	lPrazo := IF(CECCBAL1->APRAZO="S",.T.,.F.)
	lPrazoAvista := .F.
	//
	_nVal := 0
	IF lFonte
		CECCBAL1->(LOCK_REGISTRO(.T.))
		_nVal := ROUND((CECCBAL1->TOTAL*(8.5/100)),2)
		CECCBAL1->TOTAL := CECCBAL1->TOTAL + _nVal
		CECCBAL1->(DBUNLOCK())
	ENDIF	
	//
	IF lPrazo .or. lPrazoAvista
		SETCURSOR(1)
		nVezes := 0
		SETCOLOR(M->CEDICAO)
		BOX(04,09,07,75,M->FR,127,3,8)
		nBanco := 0
		@ 05,10 SAY "Banco..........:" GET nBanco PICTURE "99" VALID (nBanco>=1 .AND. nBanco<=3) .AND.;
		        EVAL({||DEVPOS(ROW(),COL()+2),DISPOUT(IF(nBanco=1,"BRADESCO",IF(nBanco=2,"BAMERINDUS","CARTEIRA"))),.T.})
                @ 06,10 SAY "Quantas vezes ?:" GET nVezes PICTURE "99"  VALID nVezes=1 // .AND. nVezes<=4
		READ
		IF nVezes>0
			aDatas := {}
			dData := CTOD("  /  /    ")
			BOX(08,09,14,75,M->FR,127,3,8)
			dData := xData+30
			xDias := 0
			@ 09,10 SAY [Data de emissao.:]+DTOC(xData)
			FOR x:=1 TO nVezes
				@ 10,10 Say ALLTRIM(STRzero(X,2))+"o. Vencimento.:" GET xDias PICTURE "@r 999 dias" VALID !EMPTY(xDias) .AND. ShowData(xData,xDias,@dData)
				READ
				IF LASTKEY()==27
					RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
					SETCURSOR(nCursor)
					SETCOLOR(cCor)
					RETURN(NIL)
				ENDIF
				AADD(aDatas,dData)
				IF x=nVezes
					IF !Confirma('Confirma este vencimentos',23)
						x:=0
						BOX(08,09,14,75,M->FR,127,3,8)
						@ 09,10 SAY [Data de emissao.:]+DTOC(xData)
						aDatas := {}
					ENDIF	
				ELSE	
					SCROLL(10,10,13,74,-1)
				ENDIF	
			NEXT	
		ENDIF	
		cNota  := STRZERO(CECCSET->ULTNF+1,10)
                nNota  := CECCSET->ULTNF+1
		nSelo  := STRZERO(CECCSET->ULTFIS+1,8)
		SELECT("CECCBOL")
		_Valor := ROUND(CECCBAL1->TOTAL / nVezes,2)
		_Arred := 0
		IF (_Valor * nVezes)#CECCBAL1->TOTAL
			_Arred := CECCBAL1->TOTAL - (_Valor * nVezes)
		ENDIF	
		_aValores := {}

	ENDIF
        
	//
	SELECT("CECCBAL2")
	//
        IF lTIPO
             nCliente:=0
             BOX(06,01,08,79,M->FR,127,3,8)
             @ 07,02 SAY "Cliente [Sera Entregue]:";
                          GET nCliente;
                          PICTURE "@K 99999";
                          VALID !EMPTY(nCliente) .AND.;
                          Existe(nCliente,"Cliente nÆo cadastrado",.F.,"CECCCLI",1,"NOMECLC","@!",ROW(),COL()+1) // .AND.;
                          // EVAL({||__nDesconto:=CECCCLI->DESCONTO,.T.}) .AND. VerificaCautelas(nCliente,@___Sai)     //.AND.;

             Read
        Endif

        IF !M_QUERY("Confirma a Impressao ?",23)
           Return(NIL)
        ENDIF

	M_MESSAGE("Aguarde imprimindo nota fiscal ...", 23)
	//
	SET DEVICE TO PRINT
	@ PROW(),PCOL() SAY CHR(15)
	@ PROW(),PCOL() SAY CHR(27)+CHR(67)+CHR(69)
	cNota  := STRZERO(CECCSET->ULTNF+1,10)
        nNota  := CECCSET->ULTNF+1
	nSelo  := STRZERO(CECCSET->ULTFIS+1,8)
	cSerie := "F"
	nSub   := 0
	_Total_Bruto := 0
	@01,091 SAY "X"
	@01,127 SAY cNota
        @06,006 SAY IF(lTipo,"SIMPLES REMESSA","VENDA A ORDEM" )
	IF lTipo
		@06,053 SAY "5.99"
	ELSE
                @06,053 SAY "6.12"
	ENDIF
	//
        IF !lTIPO
           CECCCLI->(DBSEEK(CECCBAL1->CLIENTE))
        ELSE
           CECCCLI->(DBSEEK(nCliente))
        ENDIF

        if !ltipo
          @09,014 SAY CECCCLI->NOMECLC+"CODIGO:"+STRZERO(CECCBAL1->CLIENTE,5)
        Else
          @09,014 SAY CECCCLI->NOMECLC+"CODIGO:"+STRZERO(nCLIENTE,5)
        endif

        @09,095 SAY CECCCLI->CGCCPFC  PICTURE "@R 99.999.999/9999-99"
        @09,126 SAY XDATA
        @11,006 SAY CECCCLI->ENDEREC 
        @11,105 SAY CECCCLI->CEPCLIC PICTURE "@R 99999-999"  
*        @11,126 SAY XDATA2
        @13,006 SAY CECCCLI->CIDADEC
        @13,061 SAY CECCCLI->TELEFOC
        @13,084 SAY CECCCLI->ESTADOC
        @13,095 SAY CECCCLI->INSESTC
*        @13,126 SAY TIME()
        if !lTipo
         @16,06   SAY "C/APRES."
        Endif
*        IF lPrazo
*                NCOL := 06
*             IF !lTipo
*                FOR X:=1 TO NVEZES
*                       @16,NCOL SAY ADATAS[X]
*                        NCOL := NCOL + 18
*                        @16,NCOL SAY CECCBAL1->TOTAL PICT "@R@E 999,999.99"
*                        NCOL := NCOL + 18
*                NEXT
*             EndIf
*        ENDIF            
	//
	@18,15 SAY SUBS( EXTENSO(CECCBAL1->TOTAL),1,110)
	//
	CECCBAL2->(DBGOTOP())
	nLin := 22
	_nDesc := 0
	DO WHILE CECCBAL2->PEDIDO == CECCBAL1->PEDIDO .AND. !CECCBAL2->(EOF())
		CECCMER->(DBSEEK(CECCBAL2->MERCADORIA))
		IF CECCBAL2->MERCADORIA#CECCBAL2->MERC2
			@nLin,00 SAY CECCBAL2->MERC2
		ELSE
			@nLin,00 SAY CECCBAL2->MERCADORIA
		ENDIF		
		@ NLIN,17 SAY CECCBAL2->DESCRICAO
		DO CASE
			CASE (CECCMER->CODLINM>=3900 .AND. CECCMER->CODLINM<=3904) .OR. CECCMER->CODLINM=3300 .OR. CECCMER->CODLINM=9999 
				@nLin,66 SAY "06"
                        CASE CECCMER->CODLINM=2900 .OR. CECCMER->CODLINM=2901 .OR. CECCMER->CODLINM=300
				IF lFonte
					@nLin,66 SAY "21"
				ELSE
					@nLin,66 SAY "20"
				ENDIF		
			CASE CECCMER->CODLINM=2700
				IF lFonte
					@nLin,66 SAY "11"	
				ELSE
					@nLin,66 SAY "10"
				ENDIF			
			OTHERWISE
				IF lFonte
					@nLin,66 SAY "01"		
				ELSE
					@nLin,66 SAY "00"		
				ENDIF		
		ENDCASE		
		//
		**
		*IF !EMPTY(CECCBAL2->DESCRICAO)
		*	@ NLIN,070 SAY "PC"
		*ELSE
			@nLin,070 SAY CECCMER->UNIDADE
		*ENDIF	
		**
		
		@nLin,075 SAY CECCBAL2->QTD
		@nLin,085 SAY CECCBAL2->PRECOU   PICT "@R@E 99,999,999.99"
		@nLin,102 SAY CECCBAL2->PRECOT   PICT "@R@E 99,999,999.99"

                IF lTipo
                  IF !((CECCMER->CODLINM>=3900 .AND. CECCMER->CODLINM<=3904) .OR. CECCMER->CODLINM=3300 .OR. CECCMER->CODLINM=9999)
			@nLin,117 SAY IF(lManaus,IF(CECCMER->CODLINM=2700,"12","17"),If(lPessoa,"17","12") )
                  ELSE
                         @nLin,117 SAY [00]
                  ENDIF
                

                  IF lFonte
                         @ nlin,124 SAY [8.5]
                  ELSE
			@ nlin,124 SAY [0.0]			
                  ENDIF
                ENDIF

		_nDesc+=CECCBAL2->DESCONTO
		_Total_Bruto += CECCBAL2->PRECOT
		nLin++
		CECCBAL2->(DBSKIP())
	ENDDO	
	//
	IF CECCBAL1->VDESCONTO>0
                @ 35,085 SAY [Total bruto......:]
                @ 35,103 SAY _Total_Bruto PICTURE "@R@E 99,999,999.99"
                @ 36,085 SAY "Desconto "+STR(CECCBAL1->PERCDESC,5,2)+"%..:"
                @ 36,103 SAY CECCBAL1->VDESCONTO PICTURE "@R@E 99,999,999.99"
	ENDIF
	//
	IF CECCBAL1->VDESC2>0
		@ 41,085 SAY "Desconto em R$...:"
		@ 41,103 SAY CECCBAL1->VDESC2 PICTURE "@R@E 99,999,999.99"
	ENDIF
	//
        obanco:="Pagamento atraves do BANCO BRADESCO - AGENCIA: 0482-0 - C/C.: 046519-4"
        IF ltipo
           ob1:="Referente a nossa venda A ORDEM pela nossa N. Fiscal "+STRZERO(nNota + 1,10)+" , nos termos do Art. 220 do Dec. 11.773/89-RICMS. Emitida contra:"        
        ELSE
           ob1:="Emissao se destina a simples faturamento, nos termos do Art. 220 do Dec. 11.773/89-RICMS." 
           ob2:="A mercadoria sera entregue atraves da nossa N.F. "+STRZERO(nNota - 1,10)+" de "+DTOC(xData)+" , no seguinte endereco:"
        END
        
        If ltipo
           @ 40,02 SAY  OB1
           @ 41,02 SAY "Empresa: "+_OBS
           @ 42,02 SAY "Endereco: "+_OB
        Else
           @ 37,02 SAY  OBanco
           @ 39,02 SAY  OB1
           @ 40,02 SAY  OB2
           @ 41,02 SAY "Empresa: "+_OBS
           @ 42,02 SAY "Endereco: "+_OB
        Endif

	//
        IF ltipo
           IF !( (CECCMER->CODLINM>=3900 .AND. CECCMER->CODLINM<=3904) .OR. CECCMER->CODLINM=3300 .OR. CECCMER->CODLINM=9999)
                  ___aliquota := IF(lManaus,IF(CECCMER->CODLINM=2700,12/100,17/100),If(lPessoa,17/100,12/100) )
                  @ 44,13  SAY CECCBAL1->TOTAL - _nVal
           ELSE
		___aliquota := 0
           ENDIF    
           @ 44,39  SAY xIcms := (ROUND(((CECCBAL1->TOTAL - _nVal)*___aliquota),2))
           @ 44,68  SAY IF(_nVal>0,CECCBAL1->TOTAL - _nVal," ")
           @ 44,96  SAY _nVal
        ENDIF
	@ 44,123 SAY CECCBAL1->TOTAL - _nVal
	@ 46,13  SAY 0.00
	@ 46,39  SAY 0.00
	@ 46,68  SAY 0.00
	@ 46,96  SAY 0.00
     *   IF lTIPO
        @ 46,123 SAY CECCBAL1->TOTAL
     *   ENDIF
	//
	@ 49,006 SAY _Transp
        @ 59,96 say "NF:"+CNOTA
        @ 64,86 say "SERIE "+ceccset->selo+" "+nSelo+"  NF:"+CNOTA
	@ 67,127 SAY CNOTA
	EJECT
	EJECT
	
	SET DEVICE TO SCREEN
	
	RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
	
		
		
	
	// Nota fiscal
	CECCSET->(LOCK_REGISTRO(.T.))
	CECCSET->ULTNF += 1
	CECCSET->ULTFIS += 1
	CECCSET->(DBUNLOCK())
	
	
	DBCOMMITALL()
	
	SELECT("CECCBAL2")
	DBGOTOP()
	RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
RETURN(NIL)	

	

FUNCTION ShowData(xData,xDias,dData)
	dData := xData +xDias
	@ ROW(),COL()+2 SAY [Data.:]+DTOC(dData)
RETURN(.T.)	
