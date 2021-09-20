// Sistemas de Controle de Estoque Comercial
// W&R Informatica Ltda
// 28 de 	Marco de 1995
// Roberto Falcao Rocha
// Baixas de mercadorias por pedidos usando impressora fiscal

LOCAL cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
		cCor := SETCOLOR(),;
		nCursor := SETCURSOR(0),;
                aDad := {"TIPO","PEDIDO","LOJA","CLIENTE","VENDEDOR","SUBTOTAL","VDESCONTO","VDESC2","TOTAL","DATAATD","DATAEM","NOTA","SERIE","SUBSERIE","APRAZO","REVENDA","USUARIO","FUSUARIO"},;
                aCab := {"Tipo","Pedido","Loja","Cliente","Vendedor","Sub-Total","Desconto%","Desconto R$","Total","Atendimento","Emissao","Nota","Serie","Sub-serie","E Aprazo","Revenda","Responsavel","Faturista"},;
                aPic := {"@!","9999999999","9999","99999","99999","9999999.99","9999999.99","9999999.99","9999999.99","@D","@D","@!","@!","99","@!","@!","@!","@!"},;
		_cPag := ""
		

// Verificando arquivos
IF !ARQNTX("CECCBAL1",.F.) .OR. ;
	!ARQNTX("CECCBAL2",.F.) .OR. ;
	!ARQNTX("CECTLOJ",.F.)  .OR. ;
	!ARQNTX("CECCVEN",.F.)  .OR. ;
   !ARQNTX("CECCPAS",.F.)  .OR. ;
	!ARQNTX("CECCLOJ",.F.)  .OR. ;
	!ARQNTX("CECCFIS",.F.)  .OR. ;
	!ARQNTX("CECCSET",.F.)  .OR. ;
	!ARQNTX("CECCCLI",.F.)  .OR. ;
	!ARQNTX("CECCMOV",.F.)  .OR. ;
	!ARQNTX("CECCBOL",.F.)  .OR. ;
	!ARQNTX("CECCREC",.F.)  .OR. ;
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
	cArqSubNtx:="SUBI"+cSubNtx       
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

FUNCTION ConfirmaP2()
        LOCAL nDesc,;
			nNum,;
			cTela:=SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
			nCursor:=SETCURSOR(),;
			GetList:={}
			
	PRIVATE MES       
	
	IF CECCBAL1->ATENDIDO	
		M_DISPLAY("Pedido ja foi atendido",79)
		RETURN(NIL)
	ENDIF
	//
   IF (CECCBAL1->TIPO) == " "  
       M_DISPLAY("Cotacao nao pode ser atendida, Transfore em Pedido de Compra",79)
	RETURN(NIL)
	ENDIF	
	//
	IF !Confirma("Confirma o pedido ?",23)
		RETURN(NIL)
	ENDIF	
	
	SETCURSOR(1)
	
	DECLARE AMODALIDADE[10]
	DECLARE AVALOR[10]
	afill(amodalidade,0)
	afill(aVALOR,0)
	_cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL())
	SETCOLOR(M->CEDICAO)
	BOX(05,09,08,75,M->FR,127,3,8)
	
	FOR X:=1 TO 10
	
	@ 06,010 SAY "Tipo de pagamento.:";
			  GET amodalidade[x];
			  PICTURE "99";
	    	  VALID !empty(amodalidade[x])
			  
	@ 07,10 SAY "Valor..............:";
			  GET aValor[x];
			  PICTURE "@K 999,999.99";
			  VALID !EMPTY(aValor[x])
	READ
	//
	IF LASTKEY()==27
		IF X=1
			RESTSCREEN(0,0,MAXROW(),MAXCOL(),_cTela)
			RETURN(NIL)
		ENDIF	
		EXIT	
	ENDIF
	
	NEXT
	
	ASOMA := 0
	FOR X:=1 TO 10
		ASOMA += AVALOR[X]
	NEXT			
	IF ASOMA < CECCBAL1->TOTAL
		M_DISPLAY("Valor menor que o total da nota. Verifique !!!",79)
		SELECT("CECCBAL2")
		DBGOTOP()
		RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
		RETURN(NIL)
	ENDIF	
	
	SETCURSOR(nCursor)
	cTelao := SAVESCREEN(0,0,MAXROW(),MAXCOL())
	M_MESSAGE("Aguarde imprimindo cumpom fiscal ...", 23)
	SET DEVICE TO PRINT
	SET PRINTER TO IFSWEDA
	@ PROW(),PCOL() SAY CHR(27)+".28}"
	arq = FOPEN("IFSWEDA.PRN")
	status = freadstr(arq,128)
	fclose(arq)
	IF SUBST(STATUS,2,1)="-"
		SET PRINTER TO
		SET DEVICE TO SCREEN
		RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTelao)
		M_DISPLAY("CUPOM CANCELADO",79)
		M_DISPLAY("MOTIVO:"+SUBST(STATUS,1,50),79)
		RETURN(NIL)
	ENDIF	
	IF SUBST(status,18,1) == "F"
		SET PRINTER TO
		SET DEVICE TO SCREEN
		RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTelao)
		M_DISPLAY("Redu‡ao diaria nÆo foi feita, opera‡Æo cancelada",79)
		RETURN(NIL)
	ENDIF	
	@ PROW(),PCOL() SAY CHR(27)+".271}"
	arq = FOPEN("IFSWEDA.PRN")
	status = freadstr(arq,128)
 	fclose(arq)
	IF SUBST(STATUS,2,1)="-"
		SET PRINTER TO
		SET DEVICE TO SCREEN
		RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTelao)
		M_DISPLAY("CUPOM CANCELADO",79)
		M_DISPLAY("MOTIVO:"+SUBST(STATUS,1,30),79)
		RETURN(NIL)
	ENDIF	
	nNum := IF(CECCSET->IMPFIS=1,14,121)
	cNota  := STRZERO(VAL(SUBST(status,nNum,4))+1,10)
	cSerie := ""
	nSub   := 0
	CECCBAL2->(DBGOTOP())
	IF CECCBAL2->PEDIDO # CECCBAL1->PEDIDO .OR. CECCBAL2->(EOF())
		SET PRINTER TO
		SET DEVICE TO SCREEN
		RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTelao)
		M_DISPLAY("Pedido sem itens verifique, e o refa‡a",79)
		RETURN(NIL)
	ENDIF	
	CA:=.F.
	@ PROW(),PCOL() SAY CHR(27)+".17}"
	arq = FOPEN("IFSWEDA.PRN")
	status = freadstr(arq,128)
	fclose(arq)
	IF SUBST(STATUS,2,1)="-"
		@ PROW(),PCOL() SAY CHR(27)+".05}"
		SET PRINTER TO
		SET DEVICE TO SCREEN
		RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTelao)
		M_DISPLAY("CUPOM CANCELADO",79)
		M_DISPLAY("MOTIVO:"+SUBST(STATUS,1,30),79)
		RETURN(NIL)
	ENDIF	
	DO WHILE (CECCBAL2->PEDIDO == CECCBAL1->PEDIDO .AND. !CECCBAL2->(EOF())) .AND. !CA
		CECCMER->(DBSEEK(CECCBAL2->MERCADORIA))
		cItem := STRZERO(VAL(CECCMER->REFEREM),13)
		cItem += STUFF(STRZERO(CECCBAL2->QTD,8,3),5,1,"")
		cItem += STUFF(STRZERO(CECCBAL2->PRECOU,10,2),8,1,"")
		cItem += STUFF(STRZERO(CECCBAL2->PRECOT,13,2),11,1,"")
		cItem += SUBST(CECCBAL2->DESCRICAO,1,24)
		IF !((CECCMER->CODLINM>=3900 .AND. CECCMER->CODLINM<=3904) .OR. CECCMER->CODLINM=3300 .OR. CECCMER->CODLINM=9999)
			cItem+=IF(CECCMER->CODLINM=2700,"T03","T01")
		ELSE
			cItem+=[I  ]
		ENDIF		
		@ PROW(),PCOL() SAY CHR(27)+".01"+cItem+"}"
		arq = FOPEN("IFSWEDA.PRN")
		status = freadstr(arq,128)
		CA := .F.
		fclose(arq)
		IF SUBST(STATUS,2,1)="-"
			@ PROW(),PCOL() SAY CHR(27)+".05}"
			SET PRINTER TO
			SET DEVICE TO SCREEN
			RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTelao)
			M_DISPLAY("CUPOM CANCELADO",79)
		   M_DISPLAY("MOTIVO:"+SUBST(STATUS,1,30),79)
			RETURN(NIL)
		ENDIF	
		IF CECCBAL2->DESCONTO>0
			@ PROW(),PCOL() SAY CHR(27)+".02"+"ESPECIAL  "+STUFF(STRZERO(CECCBAL2->DESCONTO,13,2),11,1,"")+"}"
			arq = FOPEN("IFSWEDA.PRN")
			status = freadstr(arq,128)
			CA := .F.
			fclose(arq)
			IF SUBST(STATUS,2,1)="-"
				@ PROW(),PCOL() SAY CHR(27)+".05}"
				SET PRINTER TO
				SET DEVICE TO SCREEN
				RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTelao)
				M_DISPLAY("CUPOM CANCELADO",79)
				M_DISPLAY("MOTIVO:"+SUBST(STATUS,1,30),79)
				RETURN(NIL)
			ENDIF	
		ENDIF	
		CECCBAL2->(DBSKIP())
	ENDDO	
      IF (CECCBAL1->VDESCONTO+CECCBAL1->VDESC2)>0
		@ PROW(),PCOL() SAY CHR(27)+".03"+"ESPECIAL  "+STUFF(STRZERO((CECCBAL1->VDESCONTO+CECCBAL1->VDESC2),13,2),11,1,"")+"}"	
		arq = FOPEN("IFSWEDA.PRN")
		status = freadstr(arq,128)
		CA := .F.
		fclose(arq)
		IF SUBST(STATUS,2,1)="-"
			@ PROW(),PCOL() SAY CHR(27)+".05}"
			SET PRINTER TO
			SET DEVICE TO SCREEN
			RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTelao)
			M_DISPLAY("CUPOM CANCELADO",79)
			M_DISPLAY("MOTIVO:"+SUBST(STATUS,1,30),79)
			RETURN(NIL)
		ENDIF	
	ENDIF
	cPagto := ""
	_cPag := ""
	FOR X:=1 TO 10
		IF AMODALIDADE[X]#0
			_cPag := STRZERO(AMODALIDADE[X],2)
			_cPag += STUFF(STRZERO(AVALOR[X],13,2),11,1,"")
			cPagto += _cPag
		ELSE
			EXIT
		ENDIF
	NEXT			
	
	@ PROW(),PCOL() SAY CHR(27)+".10"+cPagto+"}"
	arq = FOPEN("IFSWEDA.PRN")
	status = freadstr(arq,128)
	CA := .F.
	fclose(arq)
	IF SUBST(STATUS,2,1)="-"
		@ PROW(),PCOL() SAY CHR(27)+".05}"
		SET PRINTER TO
		SET DEVICE TO SCREEN
		RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTelao)
		M_DISPLAY("CUPOM CANCELADO",79)
		M_DISPLAY("MOTIVO:"+SUBST(STATUS,1,30),79)
		RETURN(NIL)
	ENDIF	
	@ PROW(),PCOL() SAY CHR(27)+".12"+CECCSET->MENSAGEM+"}"
	arq = FOPEN("IFSWEDA.PRN")
	status = freadstr(arq,128)
	CA := .F.
	fclose(arq)
	IF SUBST(STATUS,2,1)="-"
		@ PROW(),PCOL() SAY CHR(27)+".05}"
		SET PRINTER TO
		SET DEVICE TO SCREEN
		RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTelao)
		M_DISPLAY("CUPOM CANCELADO",79)
		M_DISPLAY("MOTIVO:"+SUBST(STATUS,1,30),79)
		RETURN(NIL)
	ENDIF	
	SET PRINTER TO

	SET DEVICE TO SCREEN

	RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)

	M_MESSAGE("Atualizando arquivos ...",23)
	
	CECCBAL2->(DBGOTOP())
	_lPrimeiro := .T.	
	DO WHILE CECCBAL2->PEDIDO == CECCBAL1->PEDIDO .AND. !CECCBAL2->(EOF())
		CECCMER->(DBSEEK(CECCBAL2->MERCADORIA))
		CECCMOV->(Inclui_Registro(.T.))
	   // Movimentos
		CECCMOV->(Lock_Registro(.T.))
		CECCMOV->NUMDOCTO   := cNota
		CECCMOV->SERIE      := cSerie
		CECCMOV->SUBSERIE   := nSub
		CECCMOV->FORNECEDOR := CECCBAL1->CLIENTE
		CECCMOV->NUMPED     := CECCBAL2->PEDIDO
		CECCMOV->MERCADORIA := CECCBAL2->MERCADORIA
		CECCMOV->DESCMERC   := CECCBAL2->DESCRICAO
		CECCMOV->REFERENCIA := CECCMER->REFEREM
		CECCMOV->DATAMOV    := DATE()
		CECCMOV->CODLOJA    := CECCBAL2->LOJA
		CECCMOV->LINHA      := CECCMER->CODLINM
		CECCMOV->TIPOMOV    := "S"
		CECCMOV->CODMOV     := "VE"
		CECCMOV->ORIGEM     := CECCMER->ORIGEMM
		CECCMOV->UNIDADE    := CECCMER->UNIDADE
		CECCMOV->PRECOMPRA  := CECCMER->PRECCOM
		CECCMOV->QUANTMOV   := -CECCBAL2->QTD
		CECCMOV->TOTVEND    := IF(_lPrimeiro,CECCBAL1->TOTAL,0)
		_lPrimeiro := .F.
      CECCMOV->SALANTMOV  := CECCMER->SALDOEM
		CECCMOV->CUSTOMOV   := ROUND(CECCMER->CMEDM*CECCBAL2->QTD,3)
		CECCMOV->PREVENDA   := CECCMER->PRECVEM
		nDesc 				  := IF((CECCBAL1->VDESCONTO+CECCBAL1->VDESC2)#0,(((CECCBAL2->PRECOU*CECCBAL2->QTD)/CECCBAL1->SUBTOTAL)*(CECCBAL1->VDESCONTO+CECCBAL1->VDESC2)),0)
		nDesc 				  := ROUND(nDesc / CECCBAL2->QTD,3)
		CECCMOV->PREVENDIDO := CECCMER->PRECVEM-(ROUND(CECCBAL2->DESCONTO/CECCBAL2->QTD,3) + nDesc)
		CECCMOV->VLDESCITEM := nDesc+ROUND(CECCBAL2->DESCONTO/CECCBAL2->QTD,3)
		_nAliDesc           := ROUND((nDesc+ROUND(CECCBAL2->DESCONTO/CECCBAL2->QTD,3)/CECCBAL2->PRECOU)*100,2)
		CECCMOV->ALIDESITEM := _nAliDesc
		CECCMOV->VENDEDOR   := CECCBAL1->VENDEDOR
		CECCMOV->(DBUNLOCK())
		CECCMOV->(DBCOMMIT())
	
		// Lojas
		IF !CECCLOJ->(DBSEEK(STR(CECCBAL2->LOJA,4)+CECCBAL2->MERCADORIA))
			CECCLOJ->(Inclui_Registro(.T.))
		ENDIF
		CECCLOJ->(Lock_Registro(.T.))
		CECCLOJ->SALDOEJ-=CECCBAL2->QTD	
		CECCLOJ->DTUVLOJ:=DATE()
		CECCLOJ->DCUVLOJ:=cNota
		CECCLOJ->(DBUNLOCK())
		CECCLOJ->(DBCOMMIT())
		
		// Mercadoria
		CECCMER->(DBSEEK(CECCBAL2->MERCADORIA))
		CECCMER->(Lock_Registro(.T.))
		CECCMER->SALDOEM-=CECCBAL2->QTD
		CECCMER->DTULTVM:=DATE()
		CECCMER->DCULTVM:=cNota
		IF CECCBAL1->TIPO=="P"
			CECCMER->QTDPED -= CECCBAL2->QTD
		ENDIF
		IF CECCBAL1->TIPO=="C"
			CECCMER->CAUTELA -= CECCBAL2->QTD
		ENDIF		
		CECCMER->(DBUNLOCK())
		CECCMER->(DBCOMMIT())		
			
		SELECT("CECCBAL2")	
		DBSKIP()
	
	ENDDO	

	CECCFIS->(INCLUI_REGISTRO(.T.))
	CECCFIS->(LOCK_REGISTRO(.T.))
	ceccfis->CLI_FOR  :=  CECCBAL1->CLIENTE    //OK
	cecCFIS->NNOTA    :=  cNota                //OK
	cecCFIS->SERIE    :=  cSerie               //OK 
	cecCFIS->SUBSER   :=  nSub                 //OK 
	cecCFIS->DEMI     :=  DATE()               //OK
	cecCFIS->DSAI     :=  DATE()               //OK
	cecCFIS->DENT     :=  CTOD("  /  /    ")     //OK
	CECCFIS->DATAS    := DATE()
	cecCFIS->VLNOT    :=  CECCBAL1->TOTAL      //OK
	cecCFIS->CFO      :=  "512"                //OK
	cecCFIS->CODTRI   :=  1                    //OK
	cecCFIS->ALIICMS  :=  17                   //OK
	cecCFIS->ALIDICMS :=  0                    //OK
	cecCFIS->VLICMS   :=  ROUND(CECCBAL1->TOTAL*(17/100),2) //OK
	cecCFIS->VLDICMS  :=  0                    //OK 
	cecCFIS->VLIPI    :=  0 		             //OK
	cecCFIS->FRETE    :=  0                    //OK 
	cecCFIS->SEGURO   :=  0                    //OK
	cecCFIS->BASICMS  :=  CECCBAL1->TOTAL      //OK
	cecCFIS->BASIPI   :=  0                    //OK
	cecCFIS->NLANFIS  :=  0                    //OK
	cecCFIS->CONPAG   :=  0                    //OK
	CECCFIS->CANCELADA := .F.
	CECCFIS->(DBUNLOCK())
		
	//Tabela de lojas
	M->MES:="VENM"+STRZERO(MONTH(DATE()),2)+"TL"
	CECTLOJ->(DBSEEK(CECCBAL1->LOJA))
	CECTLOJ->(Lock_Registro(.T.))
	CECTLOJ->TOTVENTL += CECCBAL1->TOTAL
	CECTLOJ->COMIGETL += ROUND(CECCBAL1->TOTAL*(CECTLOJ->PCOMGETL/100),2)
	REPL CECTLOJ->&MES WITH CECTLOJ->&MES + CECCBAL1->TOTAL
	CECTLOJ->(DBUNLOCK())
	
	// Vendedores
	CECCVEN->(DBSEEK(STR(CECCBAL1->VENDEDOR,5)+STR(CECCBAL1->LOJA,4)))
	CECCVEN->(Lock_Registro(.T.))
	CECCVEN->VENMES += CECCBAL1->TOTAL
	CECCVEN->TOTVEN += CECCBAL1->TOTAL
	CECCVEN->COMMES += ROUND(CECCVEN->VENMES*(CECCVEN->PCONIS/100),2)
	CECCVEN->TOTCOM += ROUND(CECCVEN->TOTVEN*(CECCVEN->PCONIS/100),2)
   CECCVEN->(DBUNLOCK())
 
	//Balcao 1
	CECCBAL1->(Lock_Registro(.T.))
	CECCBAL1->ATENDIDO := .T.
	CECCBAL1->CANCELADO := .F.
	CECCBAL1->NOTA := cNota
	CECCBAL1->SERIE := cSerie
	CECCBAL1->SUBSERIE := nSub
	CECCBAL1->DATAATD  := DATE()
	CECCBAL1->(DBUNLOCK())
	
	DBCOMMITALL()
	SELECT("CECCBAL2")
	DBGOTOP()
	RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
RETURN(NIL)	

FUNCTION CancelaP()
	LOCAL nDesc,;
			nNum,;
			cTela:=SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
			nCursor:=SETCURSOR(),;
			cFusuario:=space(20),;
			GetList:={}
			
	PRIVATE MES       
	
	IF !CECCBAL1->ATENDIDO	
		M_DISPLAY("Pedido nÆo foi atendido, nÆo pode ser cancelado !!!",79)
		RETURN(NIL)
	ENDIF	
	
	IF CECCBAL1->CANCELADO	
		M_DISPLAY("Pedido ja foi cancelado !!!",79)
		RETURN(NIL)
	ENDIF	
	//
	While .T.
      bPass := PASS()
      //SELECT("CECCPAS")
      //DBSETORDER(2)
		//
      IF !CECCPAS->(DBSEEK(bPass)) .or. LASTKEY() = 27 .or. empty(bPass) .or. LEN(bPass) = 1
         M_DISPLAY("Usuario nao Autorizado",79)
         IF !M_QUERY("Deseja Continuar",23)
            //SELECT("CECCBAL2")
            RETURN(NIL)
         ENDIF

         SETCURSOR(nCursor)
        	//   SETCOLOR(cCor)
        	//   RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
        	//   DBCLOSEALL()
         LOOP         //RETURN(NIL)
      ELSE
         cFusuario := Criptografa(CECCPAS->NOME,"HAWK",.F.)
         EXIT
      ENDIF           
   EndDo
	
	IF !Confirma("Confirma o cancelamento do pedido ?",23)
		RETURN(NIL)
	ENDIF	
	
	M_MESSAGE("Atualizando arquivos ...",23)
	
	CECCBAL2->(DBGOTOP())
	_lPrimeiro := .T.	
	DO WHILE CECCBAL2->PEDIDO == CECCBAL1->PEDIDO .AND. !CECCBAL2->(EOF())
		CECCMER->(DBSEEK(CECCBAL2->MERCADORIA))
		CECCMOV->(Inclui_Registro(.T.))
		// Movimentos
		CECCMOV->(Lock_Registro(.T.))
		CECCMOV->NUMDOCTO   := CECCBAL1->NOTA
		CECCMOV->SERIE      := CECCBAL1->SERIE
		CECCMOV->SUBSERIE   := CECCBAL1->SUBSERIE
		CECCMOV->NUMPED     := CECCBAL2->PEDIDO
		CECCMOV->MERCADORIA := CECCBAL2->MERCADORIA
		CECCMOV->DESCMERC   := CECCBAL2->DESCRICAO
		CECCMOV->REFERENCIA := CECCMER->REFEREM
		CECCMOV->FORNECEDOR := CECCBAL1->CLIENTE
		CECCMOV->DATAMOV    := DATE()
		CECCMOV->CODLOJA    := CECCBAL2->LOJA
		CECCMOV->LINHA      := CECCMER->CODLINM
		CECCMOV->TIPOMOV    := "E"
		CECCMOV->CODMOV     := "CV"
		CECCMOV->ORIGEM     := CECCMER->ORIGEMM
		CECCMOV->UNIDADE    := CECCMER->UNIDADE
		CECCMOV->PRECOMPRA  := CECCMER->PRECCOM
		CECCMOV->QUANTMOV   := CECCBAL2->QTD
		CECCMOV->TOTVEND    := IF(_lPrimeiro,-CECCBAL1->TOTAL,0)
		_lPrimeiro := .F.
      CECCMOV->SALANTMOV  := CECCMER->SALDOEM
		CECCMOV->CUSTOMOV   := ROUND(CECCMER->CMEDM*CECCBAL2->QTD,3)
		CECCMOV->PREVENDA   := CECCMER->PRECVEM
		nDesc := IF((CECCBAL1->VDESCONTO+CECCBAL1->VDESC2)#0,(((CECCBAL2->PRECOU*CECCBAL2->QTD)/CECCBAL1->SUBTOTAL)*(CECCBAL1->VDESCONTO+CECCBAL1->VDESC2)),0)
		nDesc := ROUND(nDesc / CECCBAL2->QTD,3)
		CECCMOV->PREVENDIDO := CECCMER->PRECVEM-(ROUND(CECCBAL2->DESCONTO/CECCBAL2->QTD,3) + nDesc)
		CECCMOV->VLDESCITEM := nDesc+ROUND(CECCBAL2->DESCONTO/CECCBAL2->QTD,3)
		_nAliDesc := ROUND((nDesc+ROUND(CECCBAL2->DESCONTO/CECCBAL2->QTD,3)/CECCBAL2->PRECOU)*100,2)		
		CECCMOV->ALIDESITEM := _nAliDesc
		CECCMOV->VENDEDOR   := CECCBAL1->VENDEDOR
		CECCMOV->(DBUNLOCK())
		CECCMOV->(DBCOMMIT())
		
		// Lojas
		IF !CECCLOJ->(DBSEEK(STR(CECCBAL2->LOJA,4)+CECCBAL2->MERCADORIA))
			CECCLOJ->(Inclui_Registro(.T.))
		ENDIF
		CECCLOJ->(Lock_Registro(.T.))
		CECCLOJ->SALDOEJ+=CECCBAL2->QTD	
		CECCLOJ->DTUVLOJ:=DATE()
		CECCLOJ->DCUVLOJ:=CECCBAL1->NOTA
		CECCLOJ->(DBUNLOCK())
		CECCLOJ->(DBCOMMIT())
		
		// Mercadoria
		CECCMER->(DBSEEK(CECCBAL2->MERCADORIA))
		CECCMER->(Lock_Registro(.T.))
		CECCMER->SALDOEM+=CECCBAL2->QTD
		CECCMER->DTULTVM:=DATE()
		CECCMER->DCULTVM:=CECCBAL1->NOTA
		// Retirar as Qtds. da Cautela e QtdPed do item - WLV - 07/06/97
		IF CECCBAL1->TIPO=="P"
			CECCMER->QTDPED += CECCBAL2->QTD
		ENDIF
		IF CECCBAL1->TIPO=="C"
         CECCMER->CAUTELA += CECCBAL2->QTD
		ENDIF		
		//
		//If CECCMER->CAUTELA < 0
		//	CECCMER->CAUTELA:=0
	   //	EndIf
		//If CECCMER->QTDPED < 0
		//	CECCMER->QTDPED:=0
		//EndIf
		CECCMER->(DBUNLOCK())
		CECCMER->(DBCOMMIT())		
		//
		SELECT("CECCBAL2")
		DBSKIP()
		//
	ENDDO	
	
	CECCFIS->(DBSEEK(CECCBAL1->NOTA+CECCBAL1->SERIE+STR(CECCBAL1->SUBSERIE,2)+DTOS(CECCBAL1->DATAATD)))
	CECCFIS->(LOCK_REGISTRO(.T.))
	CECCFIS->CANCELADA := .T.
	CECCFIS->(DBUNLOCK())
		
	//Tabela de lojas
	M->MES:="VENM"+STRZERO(MONTH(DATE()),2)+"TL"
	CECTLOJ->(DBSEEK(CECCBAL1->LOJA))
	CECTLOJ->(Lock_Registro(.T.))
	CECTLOJ->TOTVENTL -= CECCBAL1->TOTAL
	CECTLOJ->COMIGETL -= ROUND(CECCBAL1->TOTAL*(CECTLOJ->PCOMGETL/100),2)
	REPL CECTLOJ->&MES WITH CECTLOJ->&MES - CECCBAL1->TOTAL
	CECTLOJ->(DBUNLOCK())
	
	// Vendedores
	CECCVEN->(DBSEEK(STR(CECCBAL1->VENDEDOR,5)+STR(CECCBAL1->LOJA,4)))
	CECCVEN->(Lock_Registro(.T.))
	CECCVEN->VENMES -= CECCBAL1->TOTAL
	CECCVEN->TOTVEN -= CECCBAL1->TOTAL
	CECCVEN->COMMES -= ROUND(CECCVEN->VENMES*(CECCVEN->PCONIS/100),2)
	CECCVEN->TOTCOM -= ROUND(CECCVEN->TOTVEN*(CECCVEN->PCONIS/100),2)
	CECCVEN->(DBUNLOCK())
	
	//Balcao 1
	CECCBAL1->(Lock_Registro(.T.))
	CECCBAL1->CANCELADO := .F.
	CECCBAL1->ATENDIDO  := .F.
	CECCBAL1->USUCANCELA:= cFusuario
	CECCBAL1->(DBUNLOCK())
	DBCOMMITALL()
	SELECT("CECCBAL2")
	DBGOTOP()
	RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
RETURN(NIL)	

FUNCTION ConfirmaP3()
        LOCAL nDesc,bPass,;
			cTela:=SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
			nCursor:=SETCURSOR(0),;
			lManaus := .T.			
			lPessoa := .F.
			lTipo   := .F.
         cFusuario:=space(20)
       
	PRIVATE MES       
	
	IF CECCBAL1->ATENDIDO	
		M_DISPLAY("Pedido ja foi atendido",79)
		RETURN(NIL)
	ENDIF

   IF CECCBAL1->TIPO =" "  
      M_DISPLAY("Cotacao nao pode ser atendida, Transformar em Pedido de Compra",79)
		RETURN(NIL)
	ENDIF	

	IF !Confirma("Confirma o pedido ?",23)
		RETURN(NIL)
	ENDIF

   While .T.
      bPass :=PASS()
      SELECT("CECCPAS")
      DBSETORDER(2)
		//
      IF !DBSEEK(bPass) .or. LASTKEY() = 27 .or. empty(bPass) .or. LEN(bPass) = 1
         M_DISPLAY("Usuario nao Autorizado",79)
         IF !M_QUERY("Deseja Continuar",23)
            SELECT("CECCBAL2")
            RETURN(NIL)
         ENDIF

         SETCURSOR(nCursor)
        	//   SETCOLOR(cCor)
        	//   RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
        	//   DBCLOSEALL()
         LOOP         //RETURN(NIL)
      ELSE
         cFusuario := Criptografa(CECCPAS->NOME,"HAWK",.F.)
         EXIT
      ENDIF           
   EndDo

	_cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL())
	SETCURSOR(1)
	_nPed := 0
	SETCOLOR(M->CEDICAO)
   BOX(04,09,08,75,M->FR,127,3,8)
   _Obs := SPACE(100)
   _Ob  := SPACE(100)
	_Transp := "O MESMO"+SPACE(23)
   @ 05,10 SAY "Observacao.(1):" GET _Obs PICTURE "@S40"
   @ 06,10 SAY "Observacao.(2):" GET _Ob  PICTURE "@S40"
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
	IF !lPrazo
		IF M_QUERY('Deseja gravar informa‡äes no Contas a Receber ?',23)
			lPrazoAvista := .T.
		ENDIF
	ENDIF	
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
		@ 06,10 SAY "Quantas vezes ?:" GET nVezes PICTURE "99"	VALID nVezes>=1 .AND. nVezes<=4
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
		nSelo  := STRZERO(CECCSET->ULTFIS+1,8)
		SELECT("CECCBOL")
		_Valor := ROUND(CECCBAL1->TOTAL / nVezes,2)
		_Arred := 0
		IF (_Valor * nVezes)#CECCBAL1->TOTAL
			_Arred := CECCBAL1->TOTAL - (_Valor * nVezes)
		ENDIF	
		_aValores := {}
		FOR X:=1 TO nVezes
			INCLUI_registro(.t.)
			lock_registro(.t.)
			CECCBOL->NOTA := cNota	
			CECCBOL->CLIENTE := CECCBAL1->CLIENTE
			CECCBOL->VENCIMENTO := aDatas[x]
			CECCBOL->VALOR := ROUND(CECCBAL1->TOTAL / nVezes,2)+IF(x=1,_Arred,0)
			AADD(_aValores,CECCBOL->VALOR)
			SELECT("CECCREC")
			INCLUI_REGISTRO(.T.)
			LOCK_REGISTRO(.T.)
			CECCREC->CODCLIR := CECCBAL1->CLIENTE
			CECCREC->DOCDUPR := STRZERO(VAL(cNota),7)+"/"+STRZERO(X,2)
			CECCREC->DTEMISR := xData
			CECCREC->DTVENCR := aDatas[x]
			CECCREC->VLDOCTR := ROUND(CECCBAL1->TOTAL / nVezes,2)+IF(x=1,_Arred,0)
			CECCREC->SLDOCTR := ROUND(CECCBAL1->TOTAL / nVezes,2)+IF(x=1,_Arred,0)
			CECCREC->CODBANR := nBanco
			CECCREC->STATUSR := " "
			CECCREC->(DBCOMMIT())
			CECCREC->(DBUNLOCK())
			SELECT("CECCBOL")
		NEXT	
	ELSE
		lTipo := M_QUERY(" uma Permuta?",23)		
	ENDIF	
	//
	SELECT("CECCBAL2")
	//			
	M_MESSAGE("Aguarde imprimindo nota fiscal ...", 23)
	//
	SET DEVICE TO PRINT
	@ PROW(),PCOL() SAY CHR(15)
	@ PROW(),PCOL() SAY CHR(27)+CHR(67)+CHR(69)
	cNota  := STRZERO(CECCSET->ULTNF+1,10)
	nSelo  := STRZERO(CECCSET->ULTFIS+1,8)
	cSerie := "F"
	nSub   := 0
	_Total_Bruto := 0
	@01,091 SAY "X"
	@01,127 SAY cNota
	@06,006 SAY IF(lPrazo,"VENDA A PRAZO",If(lTipo,"OUTRAS SAIDAS - PERMUTA","VENDA A VISTA"))
	IF lTipo
		@06,053 SAY "5.99"
	ELSE
		@06,053 SAY IF(lManaus,"5.12","6.12")
	ENDIF
	//
	CECCCLI->(DBSEEK(CECCBAL1->CLIENTE))
	@09,014 SAY CECCCLI->NOMECLC+"CODIGO:"+STRZERO(CECCBAL1->CLIENTE,5)
	@09,095 SAY CECCCLI->CGCCPFC  PICTURE "@R 99.999.999/9999-99"
	@09,126 SAY XDATA
	@11,006 SAY CECCCLI->ENDEREC 
	@11,105 SAY CECCCLI->CEPCLIC PICTURE "@R 99999-999"  
 *      @11,126 SAY XDATA2   // Alteracao Valdo 04/08/98 - sera usado o carimbo
	@13,006 SAY CECCCLI->CIDADEC
	@13,061 SAY CECCCLI->TELEFOC
	@13,084 SAY CECCCLI->ESTADOC
	@13,095 SAY CECCCLI->INSESTC
 *        @13,126 SAY TIME() // Alteracao Valdo 04/08/98 - sera usado o carimbo
	IF lPrazo
		NCOL := 06
		FOR X:=1 TO NVEZES
			@16,NCOL SAY ADATAS[X]
			NCOL := NCOL + 18
			@16,NCOL SAY _aValores[x] PICT "@R@E 999,999.99"
			NCOL := NCOL + 18
		NEXT	
	ENDIF			
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
		_nDesc+=CECCBAL2->DESCONTO
		_Total_Bruto += CECCBAL2->PRECOT
		nLin++
		CECCBAL2->(DBSKIP())
	ENDDO	
	//
	IF CECCBAL1->VDESCONTO>0
		@ 39,085 SAY [Total bruto......:]
		@ 39,103 SAY _Total_Bruto PICTURE "@R@E 99,999,999.99"
		@ 40,085 SAY "Desconto "+STR(CECCBAL1->PERCDESC,5,2)+"%..:"
		@ 40,103 SAY CECCBAL1->VDESCONTO PICTURE "@R@E 99,999,999.99"
	ENDIF
	//
	IF CECCBAL1->VDESC2>0
		@ 41,085 SAY "Desconto em R$...:"
		@ 41,103 SAY CECCBAL1->VDESC2 PICTURE "@R@E 99,999,999.99"
	ENDIF
	//
	IF !EMPTY(_OBS)
      @ 41,06 SAY _OBS
	ENDIF

   IF !EMPTY(_OB)
      @ 42,06 SAY _OB
	ENDIF	
	//
	IF !( (CECCMER->CODLINM>=3900 .AND. CECCMER->CODLINM<=3904) .OR. CECCMER->CODLINM=3300 .OR. CECCMER->CODLINM=9999)
		___aliquota := IF(lManaus,IF(CECCMER->CODLINM=2700,12/100,17/100),If(lPessoa,17/100,12/100) )
		@ 44,13  SAY CECCBAL1->TOTAL - _nVal
	ELSE
		___aliquota := 0
	ENDIF		
	@ 44,39  SAY xIcms := (ROUND(((CECCBAL1->TOTAL - _nVal)*___aliquota),2))
	@ 44,68  SAY IF(_nVal>0,CECCBAL1->TOTAL - _nVal," ")
	@ 44,96  SAY _nVal
	@ 44,123 SAY CECCBAL1->TOTAL - _nVal
	@ 46,13  SAY 0.00
	@ 46,39  SAY 0.00
	@ 46,68  SAY 0.00
	@ 46,96  SAY 0.00
	@ 46,123 SAY CECCBAL1->TOTAL
	//
	@ 49,006 SAY _Transp
   @ 59,96 say "NF:"+CNOTA
   @ 64,86 say "SERIE "+ceccset->selo+" "+nSelo+"  NF:"+CNOTA
	@ 67,127 SAY CNOTA
	EJECT
	EJECT
	
	SET DEVICE TO SCREEN
	
	RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
	
	M_MESSAGE("Atualizando arquivos ...",23)
	
	CECCBAL2->(DBGOTOP())
	_lPrimeiro := .T.
	DO WHILE CECCBAL2->PEDIDO == CECCBAL1->PEDIDO .AND. !CECCBAL2->(EOF())
		CECCMER->(DBSEEK(CECCBAL2->MERCADORIA))
		CECCMOV->(Inclui_Registro(.T.))
		// Movimentos
		CECCMOV->(Lock_Registro(.T.))
		CECCMOV->NUMDOCTO   := cNota
		CECCMOV->SERIE      := cSerie
		CECCMOV->SUBSERIE   := nSub
		CECCMOV->NUMPED     := CECCBAL2->PEDIDO
		CECCMOV->MERCADORIA := CECCBAL2->MERCADORIA
		CECCMOV->DESCMERC   := IF(!EMPTY(CECCBAL2->DESCRICAO),CECCBAL2->DESCRICAO,CECCMER->DESCRIM)
		CECCMOV->REFERENCIA := CECCMER->REFEREM
		CECCMOV->PRECOMPRA  := CECCMER->PRECCOM
		CECCMOV->FORNECEDOR := CECCBAL1->CLIENTE
		CECCMOV->DATAMOV    := DATE()
		CECCMOV->CODLOJA    := CECCBAL2->LOJA
		CECCMOV->LINHA      := CECCMER->CODLINM
		CECCMOV->TIPOMOV    := "S"
		CECCMOV->CODMOV     := "VE"
		CECCMOV->ORIGEM     := CECCMER->ORIGEMM
		CECCMOV->UNIDADE    := CECCMER->UNIDADE
		CECCMOV->QUANTMOV   := -CECCBAL2->QTD
                CECCMOV->SALANTMOV  := CECCMER->SALDOEM
		CECCMOV->CUSTOMOV   := ROUND(CECCMER->CMEDM*CECCBAL2->QTD,3)
		CECCMOV->PREVENDA   := CECCMER->PRECVEM
		CECCMOV->TOTVEND    := IF(_lPrimeiro,CECCBAL1->TOTAL,0)
		_lPrimeiro := .F.
		CECCMOV->PREVENDA   := CECCMER->PRECVEM
		nDesc := IF((CECCBAL1->VDESCONTO+CECCBAL1->VDESC2)#0,(((CECCBAL2->PRECOU*CECCBAL2->QTD)/CECCBAL1->SUBTOTAL)*(CECCBAL1->VDESCONTO+CECCBAL1->VDESC2)),0)
		nDesc := ROUND(nDesc / CECCBAL2->QTD,3)
		CECCMOV->PREVENDIDO := CECCMER->PRECVEM-(ROUND(CECCBAL2->DESCONTO/CECCBAL2->QTD,3) + nDesc)
		CECCMOV->VLDESCITEM := nDesc+ROUND(CECCBAL2->DESCONTO/CECCBAL2->QTD,3)
		_nAliDesc := ROUND((nDesc+ROUND(CECCBAL2->DESCONTO/CECCBAL2->QTD,3)/CECCBAL2->PRECOU)*100,2)
		CECCMOV->ALIDESITEM := _nAliDesc
		CECCMOV->VENDEDOR   := CECCBAL1->VENDEDOR
		CECCMOV->(DBUNLOCK())
		CECCMOV->(DBCOMMIT())
		
		// Lojas
		IF !CECCLOJ->(DBSEEK(STR(CECCBAL2->LOJA,4)+CECCBAL2->MERCADORIA))
			CECCLOJ->(Inclui_Registro(.T.))
		endif
		CECCLOJ->(Lock_Registro(.T.))
		CECCLOJ->SALDOEJ-=CECCBAL2->QTD	
		CECCLOJ->DTUVLOJ:=DATE()
		CECCLOJ->DCUVLOJ:=cNota
		CECCLOJ->(DBUNLOCK())
		CECCLOJ->(DBCOMMIT())
		
		// Mercadoria
		IF CECCMER->(DBSEEK(CECCBAL2->MERCADORIA))
			CECCMER->(Lock_Registro(.T.))
			CECCMER->SALDOEM-=CECCBAL2->QTD
			CECCMER->DTULTVM:=DATE()
			CECCMER->DCULTVM:=cNota
			// Retirar as Qtds. da Cautela e QtdPed do item - WLV - 07/06/97
			IF CECCBAL1->TIPO=="P"
				CECCMER->QTDPED += CECCBAL2->QTD
			ENDIF
			IF CECCBAL1->TIPO=="C"
                                CECCMER->CAUTELA -= CECCBAL2->QTD
			ENDIF		
			CECCMER->(DBUNLOCK())
			CECCMER->(DBCOMMIT())		
		ENDIF	
				
		SELECT("CECCBAL2")
		DBSKIP()
		
	ENDDO	
	
	CECCFIS->(INCLUI_REGISTRO(.T.))
	CECCFIS->(LOCK_REGISTRO(.T.))
	ceccfis->CLI_FOR  :=  CECCBAL1->CLIENTE    //OK
	cecCFIS->NNOTA    :=  cNota                //OK
	cecCFIS->SERIE    :=  cSerie               //OK 
	cecCFIS->SUBSER   :=  nSub                 //OK 
	cecCFIS->DEMI     :=  DATE()               //OK
	cecCFIS->DSAI     :=  DATE()               //OK
	cecCFIS->DENT     :=  CTOD("  /  /    ")     //OK
	CECCFIS->DATAS    := DATE()
	cecCFIS->VLNOT    :=  CECCBAL1->TOTAL      //OK
	cecCFIS->BASICMS  :=  CECCBAL1->TOTAL - _nVal     //ok
	xIcms := ROUND(CECCFIS->BASICMS * IF(lManaus,(17/100),(12/100)),2)     
	cecCFIS->CFO      :=  IF(lManaus,"512","612")  //OK
	cecCFIS->CODTRI   :=  1                    //OK
	cecCFIS->ALIICMS  :=  IF(lManaus,17,12)                   //OK
	cecCFIS->ALIDICMS :=  0                    //OK
	cecCFIS->VLICMS   :=  xIcms
	cecCFIS->VLDICMS  :=  0                    //OK 
	cecCFIS->VLIPI    :=  0 		             //OK
	cecCFIS->FRETE    :=  0                    //OK 
	cecCFIS->SEGURO   :=  0                    //OK
	cecCFIS->BASIPI   :=  0                    //OK
	cecCFIS->NLANFIS  :=  0                    //OK
	cecCFIS->CONPAG   :=  0                    //OK
	CECCFIS->CANCELADA := .F.
	CECCFIS->ICMSFONTE := _nVal
	CECCFIS->(DBUNLOCK())
		
	//Tabela de lojas
	M->MES:="VENM"+STRZERO(MONTH(DATE()),2)+"TL"
	CECTLOJ->(DBSEEK(CECCBAL1->LOJA))
	CECTLOJ->(Lock_Registro(.T.))
	CECTLOJ->TOTVENTL += CECCBAL1->TOTAL
	CECTLOJ->COMIGETL += ROUND(CECCBAL1->TOTAL*(CECTLOJ->PCOMGETL/100),2)
	REPL CECTLOJ->&MES WITH CECTLOJ->&MES + CECCBAL1->TOTAL
	CECTLOJ->(DBUNLOCK())
	
	// Vendedores
	CECCVEN->(DBSEEK(STR(CECCBAL1->VENDEDOR,5)+STR(CECCBAL1->LOJA,4)))
	CECCVEN->(Lock_Registro(.T.))
	CECCVEN->VENMES += CECCBAL1->TOTAL
	CECCVEN->TOTVEN += CECCBAL1->TOTAL
	CECCVEN->COMMES += ROUND(CECCVEN->VENMES*(CECCVEN->PCONIS/100),2)
	CECCVEN->TOTCOM += ROUND(CECCVEN->TOTVEN*(CECCVEN->PCONIS/100),2)
	CECCVEN->(DBUNLOCK())
	
	// Nota fiscal
	CECCSET->(LOCK_REGISTRO(.T.))
	CECCSET->ULTNF += 1
	CECCSET->ULTFIS += 1
	CECCSET->(DBUNLOCK())
	
	//Balcao 1
	CECCBAL1->(Lock_Registro(.T.))
	CECCBAL1->ATENDIDO  := .T.
	CECCBAL1->NOTA      := cNota
	CECCBAL1->SERIE     := cSerie
	CECCBAL1->SUBSERIE  := nSub
	CECCBAL1->DATAATD   := DATE()
	CECCBAL1->CANCELADO := .F.
   CECCBAL1->FUSUARIO  :=cFusuario 
	CECCBAL1->(DBUNLOCK())
	
	DBCOMMITALL()
	
	SELECT("CECCBAL2")
	DBGOTOP()
	RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
RETURN(NIL)	

FUNCTION ConfirmaP4()
	LOCAL cTela:=SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
			nCursor:=SETCURSOR(0),;
			cNota,;
			lManaus := .T.,;
			cSerie,;
			nSub
			
	PRIVATE MES		
	
	IF CECCBAL1->ATENDIDO	
		M_DISPLAY("Pedido ja foi atendido",79)
		RETURN(NIL)
	ENDIF	

   IF CECCBAL1->TIPO =" "  
      M_DISPLAY("Cotacao nao pode ser atendida, Transformar em Pedido de Compra",79)
		RETURN(NIL)
	ENDIF	

	IF !Confirma("Confirma o pedido ?",23)
		RETURN(NIL)
	ENDIF	
	
	cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL())
	
	SELECT("CECCBAL2")
				
	M_MESSAGE("Aguarde imprimindo nota fiscal ...", 23)
	
	cNota  := STRZERO(CECCSET->ULTNFD1+1,10)
	cSerie := "D"
	nSub   := 1
	
	SET DEVICE TO PRINT
	
	@ PROW(),PCOL() SAY CHR(15)
	@ PROW(),PCOL() SAY CHR(27)+CHR(67)+CHR(33)
	
	CECCVEN->(DBSEEK(STR(CECCBAL1->VENDEDOR,5)+STR(CECCBAL1->LOJA,4)))
	@ 02,60 SAY "VENDEDOR.:"+STRZERO(CECCBAL1->VENDEDOR,5)
	@ 03,60 SAY CECCVEN->NOMVEN
	
	@ 09,13 SAY SUBST(DTOC(DATE()),1,2)
	@ 09,17 SAY SUBST(DTOC(DATE()),4,2)
	@ 09,23 SAY SUBST(DTOC(DATE()),7,4)

	CECCBAL2->(DBGOTOP())
	nLin := 13
	DO WHILE CECCBAL2->PEDIDO == CECCBAL1->PEDIDO .AND. !CECCBAL2->(EOF())
		CECCMER->(DBSEEK(CECCBAL2->MERCADORIA))
		@nLin,00  SAY CECCBAL2->QTD PICTURE "@R@E 9999.99"
		@nLin,09  SAY SUBST(ALLTRIM(CECCBAL2->MERC2)+[-]+ALLTRIM(CECCMER->DESCRIM),1,45)
		@nLin,62  SAY CECCBAL2->PRECOU PICTURE "@R@E 99,999.99"
		@nLin,78 SAY CECCBAL2->PRECOT PICTURE "@R@E 999,999.99"
		nLin++
		CECCBAL2->(DBSKIP())
	ENDDO	
	
	nLin := 24
	IF (CECCBAL1->VDESCONTO)>0
		NlIN++
		@ NLIN,53 SAY "Desconto "+STR(CECCBAL1->PERCDESC,5,2)+"%..:"
		@ NLIN,78 SAY CECCBAL1->VDESCONTO PICTURE "@R@E 999,999.99"
	ENDIF
	IF CECCBAL1->VDESC2>0
		NlIN++
		@ NLIN,53 SAY "Desconto em R$...:"
		@ NLIN,78 SAY CECCBAL1->VDESC2 PICTURE "@R@E 999,999.99"
	ENDIF
	
	@ 27,12 SAY "AGRADECEMOS A PREFERENCIA E VOLTE SEMPRE"	
	
	@ 28,78 SAY CECCBAL1->TOTAL PICTURE "@R@E 999,999.99"
	
	EJECT
	
	SET DEVICE TO SCREEN
	
	RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
	
	M_MESSAGE("Atualizando arquivos ...",23)
	
	CECCBAL2->(DBGOTOP())
	_lPrimeiro := .T.
	DO WHILE CECCBAL2->PEDIDO == CECCBAL1->PEDIDO .AND. !CECCBAL2->(EOF())
		CECCMER->(DBSEEK(CECCBAL2->MERCADORIA))
		CECCMOV->(Inclui_Registro(.T.))
		// Movimentos
		CECCMOV->(Lock_Registro(.T.))
		CECCMOV->NUMDOCTO   := cNota
		CECCMOV->SERIE      := cSerie
		CECCMOV->SUBSERIE   := nSub
		CECCMOV->NUMPED     := CECCBAL2->PEDIDO
		CECCMOV->MERCADORIA := CECCBAL2->MERCADORIA
		CECCMOV->DESCMERC   := CECCMER->DESCRIM
		CECCMOV->REFERENCIA := CECCMER->REFEREM
		CECCMOV->PRECOMPRA  := CECCMER->PRECCOM
		CECCMOV->DATAMOV    := DATE()
		CECCMOV->CODLOJA    := CECCBAL2->LOJA
		CECCMOV->FORNECEDOR := CECCBAL1->CLIENTE
		CECCMOV->LINHA      := CECCMER->CODLINM
		CECCMOV->TIPOMOV    := "S"
		CECCMOV->CODMOV     := "VE"
		CECCMOV->ORIGEM     := CECCMER->ORIGEMM
		CECCMOV->UNIDADE    := CECCMER->UNIDADE
		CECCMOV->QUANTMOV   := -CECCBAL2->QTD
      CECCMOV->SALANTMOV  := CECCMER->SALDOEM
		CECCMOV->CUSTOMOV   := ROUND(CECCMER->CMEDM*CECCBAL2->QTD,3)
		CECCMOV->PREVENDA   := CECCMER->PRECVEM
		CECCMOV->TOTVEND    := IF(_lPrimeiro,CECCBAL1->TOTAL,0)
		_lPrimeiro := .F.
		CECCMOV->PREVENDA   := CECCMER->PRECVEM
		nDesc := IF((CECCBAL1->VDESCONTO+CECCBAL1->VDESC2)#0,(((CECCBAL2->PRECOU*CECCBAL2->QTD)/CECCBAL1->SUBTOTAL)*(CECCBAL1->VDESCONTO+CECCBAL1->VDESC2)),0)
		nDesc := ROUND(nDesc / CECCBAL2->QTD,3)
		CECCMOV->PREVENDIDO := CECCMER->PRECVEM-(ROUND(CECCBAL2->DESCONTO/CECCBAL2->QTD,3) + nDesc)
		CECCMOV->VLDESCITEM := nDesc+ROUND(CECCBAL2->DESCONTO/CECCBAL2->QTD,3)
		_nAliDesc := ROUND((nDesc+ROUND(CECCBAL2->DESCONTO/CECCBAL2->QTD,3)/CECCBAL2->PRECOU)*100,2)
		CECCMOV->ALIDESITEM := _nAliDesc
		CECCMOV->VENDEDOR   := CECCBAL1->VENDEDOR
		CECCMOV->(DBUNLOCK())
		CECCMOV->(DBCOMMIT())
		
		// Lojas
		IF !CECCLOJ->(DBSEEK(STR(CECCBAL2->LOJA,4)+CECCBAL2->MERCADORIA))
			CECCLOJ->(Inclui_Registro(.T.))
		endif
		CECCLOJ->(Lock_Registro(.T.))
		CECCLOJ->SALDOEJ-=CECCBAL2->QTD	
		CECCLOJ->DTUVLOJ:=DATE()
		CECCLOJ->DCUVLOJ:=cNota
		CECCLOJ->(DBUNLOCK())
		CECCLOJ->(DBCOMMIT())
		
		// Mercadoria
		CECCMER->(DBSEEK(CECCBAL2->MERCADORIA))
		CECCMER->(Lock_Registro(.T.))
		CECCMER->SALDOEM-=CECCBAL2->QTD
		CECCMER->DTULTVM:=DATE()
		CECCMER->DCULTVM:=cNota
		CECCMER->(DBUNLOCK())
		CECCMER->(DBCOMMIT())		
				
		SELECT("CECCBAL2")
		DBSKIP()
		
	ENDDO	
	
	CECCFIS->(INCLUI_REGISTRO(.T.))
	CECCFIS->(LOCK_REGISTRO(.T.))
	ceccfis->CLI_FOR  :=  CECCBAL1->CLIENTE    //OK
	cecCFIS->NNOTA    :=  cNota                //OK
	cecCFIS->SERIE    :=  cSerie               //OK 
	cecCFIS->SUBSER   :=  nSub                 //OK 
	cecCFIS->DEMI     :=  DATE()               //OK
	cecCFIS->DSAI     :=  DATE()               //OK
	cecCFIS->DENT     :=  CTOD("  /  /    ")     //OK
	CECCFIS->DATAS    := DATE()
	cecCFIS->VLNOT    :=  CECCBAL1->TOTAL      //OK
	cecCFIS->BASICMS  :=  CECCBAL1->TOTAL      //ok
	xIcms := ROUND(CECCFIS->BASICMS * IF(lManaus,(17/100),(12/100)),2)     
	cecCFIS->CFO      :=  IF(lManaus,"512","612")  //OK
	cecCFIS->CODTRI   :=  1                    //OK
	cecCFIS->ALIICMS  :=  IF(lManaus,17,12)                   //OK
	cecCFIS->ALIDICMS :=  0                    //OK
	cecCFIS->VLICMS   :=  xIcms
	cecCFIS->VLDICMS  :=  0                    //OK 
	cecCFIS->VLIPI    :=  0 		             //OK
	cecCFIS->FRETE    :=  0                    //OK 
	cecCFIS->SEGURO   :=  0                    //OK
	cecCFIS->BASIPI   :=  0                    //OK
	cecCFIS->NLANFIS  :=  0                    //OK
	cecCFIS->CONPAG   :=  0                    //OK
	CECCFIS->CANCELADA := .F.
	CECCFIS->ICMSFONTE := 0
	CECCFIS->(DBUNLOCK())
		
	//Tabela de lojas
	M->MES:="VENM"+STRZERO(MONTH(DATE()),2)+"TL"
	CECTLOJ->(DBSEEK(CECCBAL1->LOJA))
	CECTLOJ->(Lock_Registro(.T.))
	CECTLOJ->TOTVENTL += CECCBAL1->TOTAL
	CECTLOJ->COMIGETL += ROUND(CECCBAL1->TOTAL*(CECTLOJ->PCOMGETL/100),2)
	REPL CECTLOJ->&MES WITH CECTLOJ->&MES + CECCBAL1->TOTAL
	CECTLOJ->(DBUNLOCK())
	
	// Vendedores
	CECCVEN->(DBSEEK(STR(CECCBAL1->VENDEDOR,5)+STR(CECCBAL1->LOJA,4)))
	CECCVEN->(Lock_Registro(.T.))
	CECCVEN->VENMES += CECCBAL1->TOTAL
	CECCVEN->TOTVEN += CECCBAL1->TOTAL
	CECCVEN->COMMES += ROUND(CECCVEN->VENMES*(CECCVEN->PCONIS/100),2)
	CECCVEN->TOTCOM += ROUND(CECCVEN->TOTVEN*(CECCVEN->PCONIS/100),2)
	CECCVEN->(DBUNLOCK())
	
	// Nota fiscal
	CECCSET->(LOCK_REGISTRO(.T.))
	CECCSET->ULTNFD1 += 1
	CECCSET->(DBUNLOCK())
	
	//Balcao 1
	CECCBAL1->(Lock_Registro(.T.))
	CECCBAL1->ATENDIDO := .T.
	CECCBAL1->NOTA := cNota
	CECCBAL1->SERIE := cSerie
	CECCBAL1->SUBSERIE := nSub
	CECCBAL1->DATAATD  := DATE()
	CECCBAL1->(DBUNLOCK())
	
	DBCOMMITALL()
	
	SELECT("CECCBAL2")
	DBGOTOP()
	RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
RETURN(NIL)	

FUNCTION ShowData(xData,xDias,dData)
	dData := xData +xDias
	@ ROW(),COL()+2 SAY [Data.:]+DTOC(dData)
RETURN(.T.)	