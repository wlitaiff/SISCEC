// SisCEC - Controle de Estoque Comercial
// W&R Informatica Ltda
// 19 de Agosto de 1997
// Waldemir Litaiff Vasconcelos / Roberto Falcao Rocha
// CECCP100() - Contas a pagar

LOCAL cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
		cCor := SETCOLOR(),;
		nCursor := SETCURSOR(0),;
		aDad := {"FORNECEDOR","DUPLICATA","EMISSAO","VENCIMENTO","VALOR","DEBITO","BANCO","STATUS","HISTORICO"},;
		aCab := {"Fornecedor","Duplicata","Emiss∆o","Vencto","Valor","Debito","Banco","Status","Hist¢rico"},;
		aPic := {[@R 99999],[@!],[@d],[@d],[@R@E 9,999,999.99],[@R@E 9,999,999.99],[9],[@!],[@!]}
		

// Verificando arquivos

IF 	!ARQNTX("CECLOGO",.F.) .OR. ;
	!ARQNTX("CECCFOR",.F.) .OR. ;
	!ARQNTX("CECCPAG",.F.) .OR. ;
	!ARQNTX("CECCPGF",.F.) .OR. ;
	!ARQNTX("CPAGDIA",.T.) 
	DBCLOSEALL()
	RETURN
ENDIF	

SELECT("CECCPAG")						

DBGOTOP()

HBrowseDB( 1,0,24,79,"Contas a Pagar",aCab,aDad,aPic,NIL,,,{"BANCO","EMISSAO","VENCIMENTO","VALOR","DEBITO","STATUS","HISTORICO"})
DBCLOSEAll()
RETURN

FUNCTION CPagar( oBrowse )
	LOCAL cCor := SETCOR(m->cEdicao),;
			nCursor := SETCURSOR(1),;
			cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
			nReg := RECNO(),;
			nFornecedor:=0,;
			cDuplicata := SPACE(7),;
			cParcela := SPACE(2),;
			dDataEmissao := DATE(),;
			dDataVencimento := CTOD([  /  /  ]),;
			nValor := 0,;
			nBanco := 0
			cHistorico := Space(50)
			GetList:={}

			
	DO WHILE .T.			
		BOX(05,03,13,75,M->FR,127,3,8)
		@ 06,04 SAY "Duplicata No.:";
			     GET cDuplicata;
				  PICTURE "@k 9999999";
				  VALID ShowZeros(@cDuplicata,7) .AND. CDUPLICATA<>[0000000]
				  
		@ 06,30 say "Parcela No...:";		  
		        GET cParcela;
				  PICTURE "@k 99";
				  VALID ShowZeros(@cParcela,2) .AND. CPARCELA<>[00] .AND.;
				        !Existe(cDuplicata+[/]+cParcela,"Duplicata j† cadastrada",.T.,"CECCPAG",3)
						  
		@ 07,04 SAY "Fornecedor......:";
				  GET nFornecedor;
				  PICTURE "@K 99999";
				  VALID !EMPTY(nFornecedor) .AND.;
				  Existe(nFornecedor,"Fornecedor n∆o cadastrado",.F.,"CECCFOR",1,"NOMECLF","@!",ROW(),COL()+2) 
			  

		@ 08,04 SAY "Emiss∆o......:";
				  GET dDataEmissao;
				  PICTURE "@K@D";
				  VALID !EMPTY(dDataEmissao)
			  
		@ 09,04 SAY "Vencimento...:";
				  GET dDataVencimento;
				  PICTURE "@K@D";
				  VALID !EMPTY(dDataVencimento)
				  
		@ 10,04 SAY "Valor........:";
				  GET nValor;
				  PICTURE "@K@E@R 99,999,999.99";
				  VALID !EMPTY(nValor)		  
				  
		@ 11,04 SAY "Banco........:";
				  GET nBanco;
				  PICTURE "@K 9";
				  VALID !EMPTY(nBanco) .AND. nBanco>=1 .and. nBanco<=3
		
		@ 12,04 Say "Hist¢rico....:";
				  Get cHistorico;
				  Picture "@K@!@S30"
		READ	
		
		IF LASTKEY()==27
			SETCURSOR(nCursor)
			SETCOLOR(cCor)
			RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
			DBGOTO(nReg)
			oBrowse:refreshAll()
			RETURN(NIL)
		ENDIF	
			
		IF Confirma("Confirma a inclusÑo deste lanáamento",23)
			IF Inclui_Registro(.T.)
				Lock_Registro(.T.)
				CECCPAG->FORNECEDOR   := nFornecedor
				CECCPAG->DUPLICATA  := cDuplicata+[/]+cParcela
				CECCPAG->EMISSAO    := dDataEmissao
				CECCPAG->VENCIMENTO := dDataVencimento
				CECCPAG->VALOR      := nValor
				CECCPAG->DEBITO     := nValor
				CECCPAG->BANCO      := nBanco
				CECCPAG->HISTORICO  := cHistorico
				DBUNLOCK()
				DBCOMMIT()
			ENDIF
		ENDIF
	ENDDO
RETURN(NIL)	
	
FUNCTION PPagar(oBrowse)				
	LOCAL cCor := SETCOR(m->cEdicao),;
			nCursor := SETCURSOR(1),;
			cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
			nReg := RECNO(),;
			Getlist:={},;
			lAchou,;
			nFornecedor:=0,;
			cDuplicata := SPACE(7),;
			cParcela   := [01],;
			dData      := CTOD([  /  /  ])
			
	
	DISPBOX(05,03,09,75,M->FR)
	@ 06,04 SAY "Fornecedor...:";
			  GET nFornecedor;
			  PICTURE "@K 99999";
			  VALID IF(!EMPTY(nFornecedor),Existe(nFornecedor,"Fornecedor n∆o cadastrado",.F.,"CECCFOR",1,"NOMECLF","@!",ROW(),COL()+1),.T.)
 			  
	@ 07,04 SAY "Duplicata No.:";
			       GET cDuplicata;
				    PICTURE "9999999";
				    VALID ShowZeros(@cDuplicata,7) .AND. cDuplicata<>[0000000];
					 WHEN EMPTY(nFornecedor)
	
	@ 07,30 SAY "Parcela No.:";
			       GET cParcela;
				    PICTURE "99";
				    VALID Showzeros(@cParcela,2)  .AND. cParcela<>[00];
					 WHEN EMPTY(nFornecedor)
					 
	@ 08,04 SAY "Vencimento..:";
				  	 GET dData;
					 PICTURE "@D";
					 VALID iF(EMPTY(nFornecedor),Existe(cDuplicata+[/]+cParcela+if(!empty(ddata),DTOS(dData),[]),"Duplicata n∆o encontrada",.F.,"CECCPAG",3) .AND.;
							 EVAL({||DBSETORDER(3),.T.}),;		 
				  	       Existe(STRZERO(nFornecedor,5)+if(!empty(ddata),dtos(dData),[]),"Fornecedor n∆o possui lancamentos ou data n∆o encontrada",.F.,"CECCPAG",1) .AND. EVAL({||DBSETORDER(1),.T.}))
							 
	READ		  
		
	SETCURSOR(nCursor)
	SETCOLOR(cCor)
	RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)	
	
	IF LASTKEY()==27
		DBGOTO(nReg)
		oBrowse:refreshAll()
		RETURN(NIL)
	ENDIF	
	oBrowse:refreshAll()
RETURN(NIL)			

// *      Baixa mÇtodo anterios, Ç bom deixa-lo??
FUNCTION BaixaFor(oBrowse)
	
	LOCAL cCor 				 := SETCOR(m->cEdicao),;
			nCursor 			 := SETCURSOR(1),;
			cTela 			 := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
			nReg 				 := RECNO(),;
			nFornecedor		 := CECCPAG->FORNECEDOR,;
			cDuplicata 		 := CECCPAG->DUPLICATA,;
			cHistorico      := SPACE(50),;
			dDataPagamento  := CECCPAG->VENCIMENTO,;
			dDataEmissao    := CECCPAG->EMISSAO,;
			nValorJuros		 := 0,;
			nPerceJuros     := 0,;
			nValorPago		 := CECCPAG->VALOR,;
			nBanco			 := CECCPAG->BANCO,;
			Wal             := .f.,;
			GetList			 := {}
	
	IF (CECCPAG->STATUS)=="*"
		M_Display("Duplicata j† foi Quitada!",23)
	Else
		BOX(05,03,12,75,M->FR,127,3,8)
		@ 06,04 SAY "Duplicata No.:";
			     GET cDuplicata;
				  PICTURE "@k 9999999"
						  
		@ 07,04 SAY "Fornecedor...:";
				  GET nFornecedor;
				  PICTURE "@K 99999";
				  VALID !EMPTY(nFornecedor) .AND.;
				  Existe(nFornecedor,"Fornecedor n∆o cadastrado",.F.,"CECCFOR",1,"NOMECLF","@!",ROW(),COL()+2) 

		@ 08,04 SAY "Emiss∆o......:";
				  GET  dDataEmissao;
				  PICTURE "@K@D";
				  VALID !EMPTY(dDataEmissao) when wal
			  
		@ 09,04 SAY "Pagamento....:";
				  GET dDataPagamento;
				  PICTURE "@K@D";
				  VALID !EMPTY(dDataPagamento)
				  
		@ 10,04 SAY "Valor Pago...:";
				  GET nValorPago;
				  PICTURE "@K@E@R 99,999,999.99";
				  VALID !EMPTY(nValorPago)		  
		
		@ 11,04 SAY "Historico....:";
				  GET cHistorico;
				  PICTURE "@K@!@S30"
		
		READ	
		
		IF LASTKEY()==27
			SETCURSOR(nCursor)
			SETCOLOR(cCor)
			RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
			DBGOTO(nReg)
			oBrowse:refreshAll()
			RETURN(NIL)
		ENDIF	
	
		IF Confirma("Confirma a Baixa Total Desta Duplicata?",23)
			SELECT("CECCPGF")
			IF Inclui_Registro(.T.)
				Lock_Registro(.T.)
				CECCPGF->FORNECEDOR := nFornecedor
				CECCPGF->DUPLICATA  := cDuplicata
				CECCPGF->PAGAMENTO  := dDataPagamento
				CECCPGF->VALOR      := nValorPago
				CECCPGF->HISTORICO  := cHistorico
				DBUNLOCK()
				DBCOMMIT()
			ENDIF
			//
			SELECT("CECCPAG")
			Lock_Registro(.T.)
			CECCPAG->DEBITO -= nValorPago
			If(CECCPAG->DEBITO==0,CECCPAG->STATUS:="*",CECCPAG->STATUS:="P")
			DBUNLOCK()
 			DBCOMMIT()
		ENDIF
	EndIf

SETCURSOR(nCursor)
SETCOLOR(cCor)
RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
DBGOTO(nReg)
oBrowse:refreshAll()
RETURN(.T.)     //       ************************/

// Novo Tipo de Baixa de Duplicatas a Pagar
FUNCTION BaixaFor1(oBrowse)
	//
	LOCAL cCor 				 := SETCOR(m->cEdicao),;
			nCursor 			 := SETCURSOR(1),;
			cTela 			 := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
			nReg 				 := RECNO(),;
			DdATA           := ctod('  /  /  '),;
			nFornecedor			 := 0,;
			cDuplicata 		 := space(7),;
			cParcela        := [01],;
			dDataPagamento  := date(),;
			dDataEmissao    := ctod('  /  /  '),;
			nValorJuros		 := 0,;
			nPerceJuros     := 0,;
			cHistorico      := SPACE(50),;
			nValorPago		 := 0,;
			nValorDup       := 0,;
			nValorDebito    := 0,;
			nBanco			 := 0,;
			Wal             := .f.,;
			GetList			 := {}
	//
	BOX(2,0,24,79,M->FR,127,3,8)
	BOX(6,02,16,79,M->FR,127,3,8)	
	@ 05,26 SAY 'Baixa de Duplicatas a Pagar'
	DO WHILE .T.
 			  
		@ 07,04 SAY "Duplicata No.:";
			       GET cDuplicata;
				    PICTURE "@k 9999999";
				    VALID ShowZeros(@cDuplicata,7) .AND. cDuplicata<>[0000000]
	
		@ 07,30 SAY "Parcela No.:";
			       GET cParcela;
				    PICTURE "@k 99";
				    VALID Showzeros(@cParcela,2)  .AND. cParcela<>[00]
		READ
		
		IF LASTKEY()==27
			SETCURSOR(nCursor)
			SETCOLOR(cCor)
			RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
			DBGOTO(nReg)
			oBrowse:refreshAll()
			RETURN(NIL)
		ENDIF
					 
		@ 09,04 SAY "Vencimento..:";
				  	 GET dData;
					 PICTURE "@k @D";
					 VALID Existe(cDuplicata+[/]+cParcela+if(!empty(ddata),DTOS(dData),[]),"Duplicata n∆o encontrada",.F.,"CECCPAG",3) .AND.;
							 if(CECCPAG->status=[*],eval({||m_DISPLAY('Duplicata j† foi Quitada',79),.F.}),.T.) .AND. ;				 
							 EVAL({||DBSETORDER(3),.T.}) .and.;
							 PegaValorFor(@dDataEmissao,@nValorPago,@nValorDup,@nFornecedor,@dData,@nValorDebito)
											 
		@ 10,04 SAY "Fornecedor...:";
			  GET nFornecedor;
			  PICTURE "@K 99999";
			  VALID IF(!EMPTY(nFornecedor),Existe(nFornecedor,"Cliente n∆o cadastrado",.F.,"CECCFOR",1,"NOMECLF","@!",ROW(),COL()+1),.T.)
			  
			  					 
		@ 11,04 SAY "Emiss∆o......:";
				  GET  dDataEmissao;
				  PICTURE "@K@D";
				  VALID !EMPTY(dDataEmissao) when wal
			  
		@ 12,04 SAY "Pagamento....:";
				  GET dDataPagamento;
				  PICTURE "@K@D";
				  VALID !EMPTY(dDataPagamento)
				  
		@ 13,04 SAY "Valor Duplicata...:";
				  GET nValorDup;
				  PICTURE "@K@E@R 99,999,999.99";
				  VALID !EMPTY(nValorDup)		  ;
				  when .f.
				  
		@ 13,40 SAY "Saldo a pagar.....:";
				  GET nValorDebito;
				  PICTURE "@K@E@R 99,999,999.99";
				  VALID !EMPTY(nValorDebito)		  ;
				  when .f.
				  
		@ 14,04 SAY "Valor Pago...:";
				  GET nValorPago;
				  PICTURE "@K@E@R 99,999,999.99";
				  VALID !EMPTY(nValorPago)		  		  
		
		@ 15,04 SAY "Historico....:";
				  GET cHistorico;
				  PICTURE "@K@!@S30"		  
		
		READ	
		
		IF LASTKEY()==27
			LOOP
		ENDIF	
		//
		IF Confirma("Confirma a Baixa desta Duplicata?",23)
			QUITA := .F.
			IF nValorPago < CECCPAG->DEBITO
				QUITA := M_QUERY('Valor pago menor que o devido, quita a duplicata ?',79)
			endif	
			SELECT("CECCPGF")
			IF Inclui_Registro(.T.)
				Lock_Registro(.T.)
				CECCPGF->FORNECEDOR := nFornecedor
				CECCPGF->DUPLICATA  := cDuplicata
				CECCPGF->PAGAMENTO  := dDataPagamento
				CECCPGF->VALOR      := nValorPago
				CECCPGF->HISTORICO  := cHistorico
				DBUNLOCK()
				DBCOMMIT()
			ENDIF
			//
			SELECT("CECCPAG")
			Lock_Registro(.T.)
			CECCPAG->DEBITO -= nValorPago
			IF CECCPAG->DEBITO <  0 .OR. QUITA
				CECCPAG->DEBITO := 0
			ENDIF	
			If(CECCPAG->DEBITO==0 .OR. QUITA,CECCPAG->STATUS:="*",CECCPAG->STATUS:="P")
			DBUNLOCK()
 			DBCOMMIT()
		ENDIF
		DDATA := CTOD([  /  /  ])
	ENDDO	
	//
SETCURSOR(nCursor)
SETCOLOR(cCor)
RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
DBGOTO(nReg)
oBrowse:refreshAll()
RETURN(.T.)

FUNCTION PegaValorfor(dDataEmissao,nValorPago,nValorDup,nFornecedor,dData,nDebito)
	dDataEmissao := CECCPAG->EMISSAO
	nValorPago   := CECCPAG->DEBITO
	nValorDup    := ceccpag->valor   
	nFornecedor  := CECCPAG->FORNECEDOR
	dData        := CECCPAG->VENCIMENTO
	nDebito      := CECCPAG->DEBITO
RETURN(.T.)	

// Baixa autom†tica do dia com emissao de cheques
FUNCTION AutoBaixaFor(oBrowse)
	LOCAL aDad1 := {"FORNECEDOR","DUPLICATA","EMISSAO","VENCIMENTO","VALOR","DEBITO","BANCO","STATUS","HISTORICO"},;
			aCab1 := {"Fornecedor","Duplicata","Emiss∆o","Vencto","Valor","Debito","Banco","Status","Hist¢rico"},;
			aPic1 := {[@R 99999],[@!],[@d],[@d],[@R@E 9,999,999.99],[@R@E 9,999,999.99],[9],[@!],[@!]}
			
	LOCAL cCor 				 := SETCOR(m->cEdicao),;
			nCursor 			 := SETCURSOR(1),;
			cTela 			 := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
			nReg 				 := RECNO(),;
			nFornecedor		 := CPAGDIA->FORNECEDOR,;
			cDuplicata 		 := CPAGDIA->DUPLICATA,;
			cHistorico      := SPACE(50),;
			dDataPagamento  := CPAGDIA->VENCIMENTO,;
			dDataEmissao    := CPAGDIA->EMISSAO,;
			nValorJuros		 := 0,;
			nPerceJuros     := 0,;
			nValorPago		 := CPAGDIA->VALOR,;
			nBanco			 := CPAGDIA->BANCO,;
			Wal             := .f.,;
			cTela1 			 := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
			GetList			 := {}
	
	BOX(05,03,12,75,M->FR,127,3,8)
	@ 09,04 SAY "Dt. Pagamento:";
				  GET dDataPagamento;
				  PICTURE "@K@D";
				  VALID !EMPTY(dDataPagamento)
				  Read
				  
	IF Confirma("Confirma a Geraá∆o dos dados para Baixa Autom†tico?",23)
		SELECT("CPAGDIA")
		DBCLOSEAREA("CPAGDIA")
		SELECT("CECCPAG")
		//Do While dDataPagamento == VENVIMENTO .AND. !EOF()
			//
			M_Message("Aguarde, Gerando Contas a Pagar do Dia ",23)
			//
			Copy To CPAGDIA FOR dDataPagamento == VENCIMENTO .AND. STATUS=" "
			//
		//ENDDO
		//
		IF !ARQNTX("CPAGDIA",.F.)
			M_Message("Arquivo Pagamento do Dia n∆o foi liberado Verifique...",79)
		Else
			SELECT("CPAGDIA")
			aDad1 := {"FORNECEDOR","DUPLICATA","EMISSAO","VENCIMENTO","VALOR","DEBITO","BANCO","STATUS","HISTORICO"}
			HBrowseDB( 1,0,24,79,"Contas a Pagar do Dia",aCab1,aDad1,aPic1,NIL,,,{"BANCO","EMISSAO","VENCIMENTO","VALOR","DEBITO","STATUS","HISTORICO"})
		EndIf
		//
	ENDIF
	//
SELECT("CECCPAG")
SETCURSOR(nCursor)
SETCOLOR(cCor)
RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela1)
DBGOTO(nReg)
oBrowse:refreshAll()
RETURN(.T.)

///
FUNCTION BaixaAuto(oBrowse)
	//
	LOCAL cCor 				 := SETCOR(m->cEdicao),;
			nCursor 			 := SETCURSOR(1),;
			cTela 			 := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
			nReg 				 := RECNO(),;
			dData           := CTOD('  /  /  '),;
			nFornecedor		 := 0,;
			cDuplicata 		 := SPACE(7),;
			cParcela        := [01],;
			dDataPagamento  := DATE(),;
			dDataEmissao    := CTOD('  /  /  '),;
			nValorJuros		 := 0,;
			nPerceJuros     := 0,;
			cHistorico      := SPACE(50),;
			nValorPago		 := 0,;
			nValorDup       := 0,;
			nValorDebito    := 0,;
			nBanco			:= 0,;
			Wal             := .F.,;
			lEmiteCheque    := .F.,;
			nNumCheque 		:= 0,;
			nNumAgencia		:= 0,;
			nNumConta		:= 0,;
			nNumDigito 		:= 0,;
			dDataCheque     := Date(),;
			cObsPagto       := Space(30),;
			nTotDoctos		:= 0,;
			cTipoPagto      := {"CHE","DIN","OUT"},;
			nFormaPagto     := 1,;
			nPage           := 1,;
			nLin            := 0,;
			lCab           	:= .T.
			lPrimeiraVez    := .T.

	Priv nTotalDoCheque

	//
	cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL())
	SELECT("CPAGDIA")
	DBGOTOP()
	IF Confirma("Confirma a Baixa das Duplicata do Dia?",23)
		//
		nTotalDoCheque:=0
		SomaDupCheq()
		//
		SELECT("CPAGDIA")
		DBGOTOP()
		//
		Do While !EOF()
			dDataVencimento := VENCIMENTO
			nFornecedor		 := FORNECEDOR
			cDuplicata 		 := DUPLICATA
			dDataPagamento  := VENCIMENTO
			dDataEmissao    := EMISSAO
			nValorJuros		 := 0
			nPerceJuros     := 0
			cHistorico      := HISTORICO
			nValorPago		 := VALOR
			nValorDup       := VALOR
			nValorDebito    := 0
			nBanco			 := BANCO
			Quita 			 := .F.
			//
			IF nValorPago < CECCPAG->DEBITO
				Quita := M_QUERY('Valor pago menor que o devido, quita a duplicata ?',79)
			ENDIF	
			//
			SELECT("CECCPAG")
			DBSETORDER(3)
			If DBSEEK(cDuplicata+DTOS(dDataVencimento))
				// 
				// *********** Incluir aqui Layout para Inpressao dos Cheques ******
				// *************** CHEQUES *************************
				//
				If lPrimeiraVez
				nFormaPagto := Alert("Forma de Pagamento.: ",cTipoPagto,79)
				If nFormapagto == 1
					If M_Query("Desejas Emitir Relaá∆o de Cheques?",79)
						//
						BOX(10,20,16,79,M->FR,127,3,8)
						Do While .T.
							IF LASTKEY()==27
                            	SELECT("CECCPAG")
                                DBSETORDER(1)
                                SELECT("CPAGDIA")
                                SETCURSOR(nCursor)
                                SETCOLOR(cCor)                                  
                                RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
                                DBGOTO(nReg)
                                oBrowse:refreshAll()
                                RETURN(.T.)                                                                   
							ENDIF
							@ 11,21 Say "Cheque No..:" Get nNumCheque 	Pict "99999999"
							@ 12,21 Say "Agància....:" Get nNumAGencia  Pict "999"
							@ 13,21 Say "Conta No...:" Get nNumConta    Pict "999999"
							@ 13,40 Say "-"            Get nNumDigito   Pict "9"
							@ 14,21 Say "Data Cheque:" Get dDataCheque  Pict "@D"
							@ 15,21 Say	"Observaá∆o.:" Get cObsPagto    Pict "@K@!@S30"
							Read
							If Confirma("Os Dados Est∆o Corretos?",23)
							   Exit
							   //RestScreen(0,0,MAXROW(),MAXCOL(),cTela)
							Endif
						EndDo	
					EndIf
				EndIf
					lPrimeiraVez := .F.
				EndIf
				// 
				If lCab
					M_Display("Coloque o formul†rio adequado na Impressora!",79)
					Do While !Impres()
					EndDo
					//
					SET DEVICE TO PRINT
					Cabecalho(nPage,"CHEQUES PARA PAGAMENTOS DO DIA "+DTOC(CECCPAG->VENCIMENTO),,)
					//
					lEmiteCheque := .T.
					//
					@ PROW(),PCOL() Say CHR(18)
					@ 09,01 Say "CHEQUE No....: " + Str(nNumCheque)
					@ 09,40 Say "DATA EMISSAO.: " + DTOC((CECCPAG->EMISSAO))
					@ 10,01 Say "BANCO........: " + Str(nBanco)
					@ 10,40 Say "AGENCIA......: " + Str(nNumAgencia)+"  CONTA..:" + Str(nNumConta) +"-"+Str(nNumDigito)
					@ 11,01 SAY "CHEQUE VALOR.: " + TRANS(nTotalDoCheque,"@E 999,999,999.99")
					@ 12,16	SAY SUBS(EXTENSO(nTotalDoCheque),1,55)
					@ 13,16 SAY SUBS(EXTENSO(NTotalDoCheque),56,55)
					@ 14,01 SAY "HITORICO.....: " + cObsPagto
					@ 15,01 SAY REPL("-",80)
					@ 16,01 SAY "RELACAO DOS TITULOS (COMPOSICAO DO CHEQUE)"+REPL("-",37)
					@ 17,01 SAY "FORNEC|    NOME FORNECEDOR    |PRF| NUMERO |NATUREZA|VENCIMENTO|VALOR DO TITULO"
					@ 18,01 SAY REPL("-",80)
					lCab := .F.
				  	nLin := 18
				ENDIF
				//
				CECCFOR->(DBSEEK(nFornecedor))
				nLin ++
				@ nLin,01 Say nFornecedor
				@ nLin,08 say SubS( (ceccfor->nomeclf),1,23) 
				@ nLin,32 Say "CHE"
				@ nLin,36 Say cDuplicata
				@ nLin,44 Say "  "
				@ nLin,54 say ceccpag->vencimento
				@ nLin,62 Say nValorPago Pict "@E 999,999,999,999.99"
				nTotDoctos += nValorPago
				If nLin > 58
				   lCab := .T.
				EndIf
				// 
				// Resgistrar Movimento de Baixa no Arquivo de Baixas - CECCPGT
				SELECT("CECCPGF")
				IF Inclui_Registro(.T.)
					Lock_Registro(.T.)
					CECCPGF->FORNECEDOR := nFornecedor
					CECCPGF->DUPLICATA  := cDuplicata
					CECCPGF->PAGAMENTO  := dDataPagamento
					CECCPGF->VALOR      := nValorPago
					CECCPGF->VENCIDOEM  := dDataPagamento
					CECCPGF->HISTORICO  := cHistorico
					CECCPGF->CHEQUE     := nNumCheque
					CECCPGF->FORMAPAGTO := cTipoPagto[nFormaPagto]
					CECCPGF->CONTABANCO := StrZero(nNumConta,8)+"-"+StrZero(nNumDigito,1)
					DBUNLOCK()
					DBCOMMIT()
				ENDIF
				//
				SELECT("CECCPAG")
				Lock_Registro(.T.)
				CECCPAG->DEBITO -= nValorPago
				IF CECCPAG->DEBITO <  0 .OR. QUITA
					CECCPAG->DEBITO := 0
				ENDIF	
				If(CECCPAG->DEBITO==0 .OR. QUITA,CECCPAG->STATUS:="*",CECCPAG->STATUS:="P")
				DBUNLOCK()
 				DBCOMMIT()
				//
			Else
				M_DISPLAY("Duplicata N∆o Encontrada, Verifique...",79)
				SELECT("CPAGDIA")
				DbSkip()
				Loop
			EndIf
			//
			SELECT("CPAGDIA")
			Lock_Registro(.T.)
			DBDELETE()
			DBUNLOCK()
			DBCOMMIT()
			//
			DBSKIP()
		ENDDO
		//
		If lEmiteCheque
			@ nLin+2,02 Say "TOTAL DOS DOCUMENTOS>>>>>>>>>>>>>>>>>"
			@ nLin+2,62 Say nTotDoctos Pict "@E 999,999,999,999.99"
			Eject
		EndIf
		SET DEVICE TO SCREEN
	ELSE 
		SELECT("CECCPAG")
		DBSETORDER(1)
		SELECT("CPAGDIA")
		SETCURSOR(nCursor)
		SETCOLOR(cCor)
		RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
		DBGOTO(nReg)
		oBrowse:refreshAll()
		RETURN(.T.)
	ENDIF
	//
SELECT("CECCPAG")
DBSETORDER(1)
SELECT("CPAGDIA")
SETCURSOR(nCursor)
SETCOLOR(cCor)
RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
DBGOTO(nReg)
oBrowse:refreshAll()
RETURN(.T.)

Function SomaDupCheq()
	DO WHILE !EOF()
		nTotalDoCheque += VALOR
	   	DBSKIP()
	ENDDO
	RETURN(nTotalDoCheque)
