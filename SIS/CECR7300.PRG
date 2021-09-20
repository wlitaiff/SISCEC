// Sistemas de Controle de Estoque Comercial
// W&R Informatica Ltda
// 03 de Maio de 1996
// Roberto Falcao Rocha
// Analise de vendas (periodo) anal°tico

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
		nCliente := 0,;
        nVendedor := 0,;
        nGrupo := 0

// Abre arquivos
IF !ARQNTX(m->sLog,.F.) .OR. ;   
	!ARQNTX("CECCMER",.F.) .OR.;
	!ARQNTX("CECCVEN",.F.) .OR.;
	!ARQNTX("CECCCLI",.F.) .OR.;
	!ARQNTX("CECTLOJ",.F.) .OR.;
    !ARQNTX("CECTLIN",.F.) .OR.;
	!ARQNTX("CECCMOV",.F.) 
	DBCLOSEALL()
	RETURN
ENDIF		 		

DO WHILE .T.
	Box(16,06,23,75,fr,127,3,8)
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
	@ 21,08 SAY "Cliente.....:";
			  GET nCliente PICTURE "99999";
			  VALID IF( EMPTY(nCliente), EVAL({||DISPOUT(" Todos                                                      "),.T.}),;
			        Existe(nCliente,"Cliente n∆o cadastrado",.F.,"CECCCLI",1,"NOMECLC","@!",ROW(),COL()+1))
    @ 22,08 SAY "Grupo.......:";
                GET nGrupo PICTURE "@K@R@E 9,999";
                VALID IF( EMPTY(nGrupo), EVAL({||DISPOUT(" Todos                                                      "),.T.}),;
					  Existe(nGrupo,"Grupo nÑo cadastrado",.F.,"CECTLIN",1,"NOMLIN","@!",ROW(),COL()+1))
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
	
	IF !IMPRES()
		LOOP
	ENDIF			
	cTelao := SAVESCREEN(0,0,MAXROW(),MAXCOL())
	M_MESSAGE("Aguarde processando relat¢rio ...",23)
	SET DEVICE TO PRINT
	@ PROW(),PCOL() SAY CHR(sesc)
	lCab := .T.
	nPage := 1
	nDescontos:=0
	XTotalVendido:=0
	nTotalVenda:=0
	lDoc := .T.
	nLin := 0
	lCli := .T.
	//
	DO WHILE IF(!EMPTY(dDataF),CECCMOV->DATAMOV<=dDataF,.T.) .AND. !EOF()
		IF INKEY()==27
			IF Para_Impressao()
				EXIT
			ENDIF
		ENDIF		
		IF CODMOV#"VE" .AND. CODMOV#"CV"
			DBSKIP()
			LOOP
		ENDIF	
		IF !EMPTY(nLoja)
			IF CECCMOV->CODLOJA#nLoja
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
		IF !EMPTY(nCliente)
			IF CECCMOV->FORNECEDOR#nCliente
				DBSKIP()
				LOOP
			ENDIF	
		ENDIF	

        IF !EMPTY(nGrupo)
           IF CECCMOV->LINHA#nGrupo
			  DBSKIP()
			  LOOP
		   ENDIF	
		ENDIF	

		IF lCab 
			Cabecalho(nPage,"RELATORIO DE VENDAS - ("+DTOC(dDataI)+"-"+DTOC(dDataF)+")")
			@07,01 SAY "DATA       DOCUMENTO  MERCADORIA       DESCRICAO                      QTY.     PRECO   TOTAL     PRECO   TOTAL    %DESC DESCONTO VEND."		
			@08,01 SAY "                                                                              VENDA            VENDIDO                               "                                
			@09,01 SAY REPL("-",132)
			nLin := 10
			lCab := .F.
			nPage++
		ENDIF
		//
		IF lDoc
			CECCCLI->(DBSEEK(CECCMOV->FORNECEDOR))
			@ nLin,001 say "CLIENTE..:"+STR(CECCMOV->FORNECEDOR)+"  = "+CECCCLI->NOMECLC
			nLin++
			@ nLin,001 SAY CECCMOV->DATAMOV
			@ NLIN,012 SAY CECCMOV->NUMDOCTO
			chave := numdocto+serie+str(subserie,2)
			nVVenda := 0
			nVVendido := 0
			nVDesconto := 0
			lDoc := .F.
		ENDIF	
		//
		IF CECCMOV->CODMOV=="CV"	
			nLin++
			@ nLin,001 SAY "NOTA CANCELADA"
			@ nLin,001 say "NOTA CANCELADA"
		ENDIF		
		//
		@ nLin,023 SAY CECCMOV->MERCADORIA
		@ nLin,040 SAY SUBST(CECCMOV->DESCMERC,1,30)
		@ nLin,071 SAY (CECCMOV->QUANTMOV * -1)   PICTURE "9999.999"
		@ nLin,080 SAY CECCMOV->PREVENDA PICTURE "9999.99"
		@ nLin,088 SAY Round( (CECCMOV->QUANTMOV*-1) * (CECCMOV->PREVENDA),2)  PICTURE "99999.99"
		@ nLin,097 SAY CECCMOV->PREVENDIDO PICTURE "9999.999"
		@ nLin,106 SAY Round( (CECCMOV->QUANTMOV*-1) * (CECCMOV->PREVENDIDO),2)  PICTURE "99999.99"
		@ nLin,115 SAY ALIDESITEM  PICTURE "99.99"
		@ nLin,121 SAY XDESC:=(ROUND(VLDESCITEM*(QUANTMOV*-1),3))  PICTURE "9999.999"
		@ nLin,130 SAY VENDEDOR    PICTURE "99"
		CECCVEN->(DBSEEK(STR(ceccmov->VENDEDOR,5)+STR(ceccmov->codloja,4)))
		IF ceccmov->ALIDESITEM>ceccven->maxdes
			@ nlin,133 say "***"
			@ nlin,133 say "***"
		endif
		nLin++
		XTotalVendido += Round( (CECCMOV->QUANTMOV*-1) * (CECCMOV->PREVENDIDO),2)
		nTotalVenda   += Round( (CECCMOV->QUANTMOV*-1) * (CECCMOV->PREVENDA),2)    
		nVVenda += Round( (CECCMOV->QUANTMOV*-1) * (CECCMOV->PREVENDA),2)    
		nVVendido += Round( (CECCMOV->QUANTMOV*-1) * (CECCMOV->PREVENDIDO),2)
		nVDesconto += XDESC
		IF nLin > 60
			lCab := .T.
		ENDIF	
		DBSKIP()
		if chave#(numdocto+serie+str(subserie,2))  .OR. IF(!EMPTY(dDataI),DATAMOV<dDataI,.F.) .OR. IF(!EMPTY(dDataF),DATAMOV>dDataF,.F.)
			@ nLin,01 SAY "TOTAL DO DOCUMENTO:"
			@ nLin,88 say nvvendA picture "99999.99"
			@ nlin,106 say nvvenDIDO picture "99999.99"
			@ nLIN,121 SAY NVDESCONTO PICTURE "9999.999"
			@ nLin,01 SAY "TOTAL DO DOCUMENTO:"
			@ nLin,88 say nvvendA picture "99999.99"
			@ nlin,106 say nvvendIDO picture "99999.99"
			@ nLIN,121 SAY NVDESCONTO PICTURE "9999.999"
			NLIN += 1
			@ NLIN,01 SAY REPL("-",132)
			nLin += 1
			NVVENDA := 0
			NVVENDIDO := 0
			NVDESCONTO := 0
			lDoc := .T.
		ENDIF	
	ENDDO
	nDESCONTOS := nTOTalvenda - Xtotalvendido
	@ NLIN,01 SAY REPL("-",132)
	nLin++
	FOR N=1 TO 2
		@ nLin,001 say "TOTAL DAS VENDAS NO PERIODO:"
		@ nLin,88 say NTOTALVENDA picture "99999.99"
		@ nlin,106 say XTOTALVENDIDO picture "99999.99"
		@ nLIN,121 SAY NDESCONTOS PICTURE "9999.999"
	NEXT
	EJECT
	SET DEVICE TO SCREEN
	RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTelao)
ENDDO	  



Function CECR7310()
///
// Sistemas de Controle de Estoque Comercial
// W&R Informatica Ltda
// 03 de Maio de 1996
// Waldemir Litaiff Vasconcelos
// Analise de vendas (periodo) sintÇtico

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
		nCliente  := 0,;
                nVendedor := 0,;
		nVMVendido:= 0,;
		nVMDesconto:=0,;
                nTotDesconto:=0,;
                nGrupo := 0,;
		nMes 

// Abre arquivos
IF !ARQNTX(m->sLog,.F.) .OR. ;   
	!ARQNTX("CECCMER",.F.) .OR.;
	!ARQNTX("CECCVEN",.F.) .OR.;
	!ARQNTX("CECCCLI",.F.) .OR.;
	!ARQNTX("CECTLOJ",.F.) .OR.;
    !ARQNTX("CECTLIN",.F.) .OR.;
	!ARQNTX("CECCMOV",.F.) 
	DBCLOSEALL()
	RETURN
ENDIF		 		

DO WHILE .T.
	Box(16,06,23,75,fr,127,3,8)
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
	@ 21,08 SAY "Cliente.....:";
			  GET nCliente PICTURE "99999";
			  VALID IF( EMPTY(nCliente), EVAL({||DISPOUT(" Todos                                                      "),.T.}),;
			        Existe(nCliente,"Cliente n∆o cadastrado",.F.,"CECCCLI",1,"NOMECLC","@!",ROW(),COL()+1))
    @ 22,08 SAY "Grupo.......:";
                GET nGrupo PICTURE "@K@R@E 9,999";
                VALID IF( EMPTY(nGrupo), EVAL({||DISPOUT(" Todos                                                      "),.T.}),;
					  Existe(nGrupo,"Grupo nÑo cadastrado",.F.,"CECTLIN",1,"NOMLIN","@!",ROW(),COL()+1))
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
	
	IF !IMPRES()
		LOOP
	ENDIF			
	cTelao := SAVESCREEN(0,0,MAXROW(),MAXCOL())
	M_MESSAGE("Aguarde processando relat¢rio ...",23)
	SET DEVICE TO PRINT
	@ PROW(),PCOL() SAY CHR(sesc)
	lCab := .T.
	nPage := 1
	nDescontos:=0
	XTotalVendido:=0
	nTotalVenda:=0
	nVMVendido :=0
	nVMDesconto := 0
        nTotDesconto := 0
	lDoc := .T.
	nLin := 0
	lCli := .T.
	//
	DO WHILE IF(!EMPTY(dDataF),CECCMOV->DATAMOV<=dDataF,.T.) .AND. !EOF()
		IF INKEY()==27
			IF Para_Impressao()
				EXIT
			ENDIF
		ENDIF		
		IF CODMOV#"VE" .AND. CODMOV#"CV"
			DBSKIP()
			LOOP
		ENDIF	
		IF !EMPTY(nLoja)
			IF CECCMOV->CODLOJA#nLoja
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
		IF !EMPTY(nCliente)
			IF CECCMOV->FORNECEDOR#nCliente
				DBSKIP()
				LOOP
			ENDIF	
		ENDIF	

        IF !EMPTY(nGrupo)
           IF CECCMOV->LINHA#nGrupo
			  DBSKIP()
			  LOOP
		   ENDIF	
		ENDIF	

		IF lCab 
			Cabecalho(nPage,"RELATORIO DE VENDAS - ("+DTOC(dDataI)+"-"+DTOC(dDataF)+")")
                        @07,01 SAY "CLIENTE  RAZAO SOCIAL                            VENDEDOR"
                        @08,01 SAY "EMISSAO    NOTA FISCAL   MERCADORIA       DESCRICAO                      QUANTIDADE   PRECO UNIT.  TOTAL          %DESC.  DESCONTO  "
                        @09,01 SAY REPL("-",132)
			nLin := 10
			lCab := .F.
			nPage++
		ENDIF
		//
		IF lDoc
			CECCCLI->(DBSEEK(CECCMOV->FORNECEDOR))
                        CECCVEN->(DBSEEK(STR(ceccmov->VENDEDOR,5)+STR(ceccmov->codloja,4)))
                        @ nLin,001 say STR(CECCMOV->FORNECEDOR)+"     "+CECCCLI->NOMECLC
                        @ nLin,050 say STR(CECCMOV->VENDEDOR)  +"     "+CECCVEN->NOMVEN
			nLin++
			@ nLin,001 SAY CECCMOV->DATAMOV
			@ NLIN,012 SAY CECCMOV->NUMDOCTO
			chave := numdocto+serie+str(subserie,2)
			nVVenda := 0
			nVVendido := 0
			nVDesconto := 0
			lDoc := .F.
		ENDIF	
		//
		IF CECCMOV->CODMOV=="CV"	
			nLin++
			@ nLin,001 SAY "NOTA CANCELADA"
			@ nLin,001 say "NOTA CANCELADA"
		ENDIF		
		//
		        @ nLin,026 SAY CECCMOV->MERCADORIA
                @ nLin,043 SAY SUBST(CECCMOV->DESCMERC,1,30)
                @ nLin,074 SAY (CECCMOV->QUANTMOV * -1)   PICTURE "@E 999,999.999"
                //@ nLin,080 SAY CECCMOV->PREVENDA PICTURE "9999.99"
                //@ nLin,088 SAY Round( (CECCMOV->QUANTMOV*-1) * (CECCMOV->PREVENDA),2)  PICTURE "99999.99"
                @ nLin,086 SAY CECCMOV->PREVENDIDO PICTURE "@E 9,999,999.99"
                @ nLin,100 SAY Round( (CECCMOV->QUANTMOV*-1) * (CECCMOV->PREVENDIDO),2)  PICTURE "@E 9,999,999.99"
                @ nLin,115 SAY ALIDESITEM  PICTURE "@E 99.99"
                @ nLin,123 SAY XDESC:=(ROUND(VLDESCITEM*(QUANTMOV*-1),3))  PICTURE "@E 999,999.99"
                //@ nLin,130 SAY VENDEDOR    PICTURE "99"
                //IF ceccmov->ALIDESITEM>ceccven->maxdes
                //        @ nlin,133 say "***"
                //        @ nlin,133 say "***"
                //endif
		nLin++
		XTotalVendido += Round( (CECCMOV->QUANTMOV*-1) * (CECCMOV->PREVENDIDO),2)
		nTotalVenda   += Round( (CECCMOV->QUANTMOV*-1) * (CECCMOV->PREVENDA),2)    
		nVVenda += Round( (CECCMOV->QUANTMOV*-1) * (CECCMOV->PREVENDA),2)    
		nVVendido += Round( (CECCMOV->QUANTMOV*-1) * (CECCMOV->PREVENDIDO),2)
                nVMVendido += Round( (CECCMOV->QUANTMOV*-1) * (CECCMOV->PREVENDIDO),2)
		nVDesconto += XDESC
                nVMDesconto+= XDESC
                nTotDesconto+= XDESC
                nMes:=Month(DATAMOV)
                //
		IF nLin > 60
			lCab := .T.
		ENDIF	
		DBSKIP()
		if chave#(numdocto+serie+str(subserie,2))  .OR. IF(!EMPTY(dDataI),DATAMOV<dDataI,.F.) .OR. IF(!EMPTY(dDataF),DATAMOV>dDataF,.F.)
			@ nLin,01 SAY "TOTAL DO DOCUMENTO:"
                        //@ nLin,88 say nvvendA picture "99999.99"
                        @ nlin,100 say nvvenDIDO picture "@E 9,999,999.99"
                        @ nLIN,123 SAY NVDESCONTO PICTURE "@E 999,999.99"
                        //
			@ nLin,01 SAY "TOTAL DO DOCUMENTO:"
                        //@ nLin,88 say nvvendA picture "99999.99"
                        @ nlin,100 say nvvendIDO picture "@E 9,999,999.99"
                        @ nLIN,123 SAY NVDESCONTO PICTURE "@E 999,999.99"
			NLIN += 1
			@ NLIN,01 SAY REPL("-",132)
			nLin += 1
			NVVENDA := 0
			NVVENDIDO := 0
			NVDESCONTO := 0
			lDoc := .T.
		ENDIF
                IF nMes#MONTH(DATAMOV) .OR. EOF()
                        @ nLin,01 SAY "TOTAL DO MES..:"
                        //
                        @ nlin,100 say nvMvenDIDO       picture "@E 9,999,999.99"
                        @ nLIN,123 SAY NVMDESCONTO      PICTURE "@E 999,999.99"
                        //
                        @ nLin,01 SAY "TOTAL DO MES..:"
                        //
                        @ nlin,100 say nvMvendIDO      picture "@E 9,999,999.99"
                        @ nLIN,123 SAY NVMDESCONTO     PICTURE "@E 999,999.99"
			NLIN += 1
			@ NLIN,01 SAY REPL("-",132)
			nLin += 1
                        //
                        NVMVENDIDO := 0
                        NVMDESCONTO := 0
                        lCab := .T.
                ENDIF        

	ENDDO
        //
        nLin++
        @ nLin,01 say REPL("-",132)
        nLin++
        //
        For n=1 To 2
                @ nLin,001 SAY "TOTAL DO MES..:"
                @ nlin,100 say nvMvenDIDO       picture "@E 9,999,999.99"
                @ nLIN,123 SAY NVMDESCONTO      PICTURE "@E 999,999.99"
        Next
        nLin ++
        //
	nDESCONTOS := nTOTalvenda - Xtotalvendido
        //
	@ NLIN,01 SAY REPL("-",132)
	nLin++
	FOR N=1 TO 2
		@ nLin,001 say "TOTAL DAS VENDAS NO PERIODO:"
                //@ nLin,088 say NTOTALVENDA      picture "99999.99"
                @ nlin,100 say XTOTALVENDIDO    picture "@E 9,999,999.99"
                @ nLIN,123 SAY nTotDesconto     PICTURE "@E 999,999.99"
	NEXT
	EJECT
	SET DEVICE TO SCREEN
	RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTelao)
ENDDO	  



