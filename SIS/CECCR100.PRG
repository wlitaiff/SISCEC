// Sistemas de Controle de Estoque Comercial
// W&R Informatica Ltda
// 19 de Agosto de 1997
// Roberto Falcao Rocha
// Contas a receber (Duplicatas)

LOCAL cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
		cCor := SETCOLOR(),;
		nCursor := SETCURSOR(0),;
		aDad := {"CODCLIR","DOCDUPR","DTEMISR","DTVENCR","VLDOCTR","SLDOCTR","CODBANR","STATUSR","HISTORICO"},;
		aCab := {"Cliente","Duplicata","Emiss∆o","Vencto","Valor","Saldo","Banco","Status","Hist¢rico"},;
		aPic := {[@R 99999],[@!],[@d],[@d],[@R@E 9,999,999.99],[@R@E 9,999,999.99],[9],[@!],[@!]}
		

// Verificando arquivos

IF !ARQNTX("CECCCLI",.F.) .OR. ;
	!ARQNTX("CECCREC",.F.) .OR. ;
	!ARQNTX("CECCPGT",.F.)
	DBCLOSEALL()
	RETURN
ENDIF	

SELECT("CECCREC")						

DBGOTOP()

HBrowseDB(1,0,24,79,"Contas a Receber",aCab,aDad,aPic,NIL,,,{"CODBANR","DTEMISR","DTVENCR","VLDOCTR","SLDOCTR","CODBANR","STATUSR","HISTORICO"})
DBCLOSEAll()
RETURN

FUNCTION CReceber( oBrowse )
	LOCAL cCor := SETCOR(m->cEdicao),;
			nCursor := SETCURSOR(1),;
			cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
			nReg := RECNO(),;
			nCliente:=0,;
			cDuplicata := SPACE(7),;
			cParcela   := [01],;
			dDataEmissao := DATE(),;
			dDataVencimento := CTOD([  /  /  ]),;
			nValor := 0,;
			nBanco := 0
			GetList:={}
			
	DO WHILE .T.			
		BOX(05,03,12,75,M->FR,127,3,8)
		
		@ 06,04 SAY "Duplicata No.:";
			     GET cDuplicata;
				  PICTURE "@K 9999999";
				  VALID sHowzEROS(@cDuplicata,7) .AND. cDuplicata<>[0000000] 
		
		@ 06,30 SAY "Parcela No.:";
			     GET cParcela;
				  PICTURE "@K 99";
				  VALID sHowzEROS(@cPARCELA,2) .AND. cPARCELA<>[00] .AND.; 		  
				        !Existe(cDuplicata+[/]+CPARCELA,"Duplicata j† cadastrada",.T.,"CECCREC",3) .AND.;
						  IF(CECCREC->STATUSR="*",EVAL({||m_DISPLAY('DUPLICATA QUITADA',23),.T.}),.T.)
		
		
		@ 07,04 SAY "Cliente......:";
				  GET nCliente;
				  PICTURE "@K 99999";
				  VALID !EMPTY(nCliente) .AND.;
				  Existe(nCliente,"Cliente n∆o cadastrado",.F.,"CECCCLI",1,"NOMECLC","@!",ROW(),COL()+2) 
			  

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
				CECCREC->CODCLIR := nCliente
				CECCREC->DOCDUPR := cDuplicata+[/]+cParcela
				CECCREC->DTEMISR := dDataEmissao
				CECCREC->DTVENCR := dDataVencimento
				CECCREC->VLDOCTR := nValor
				CECCREC->SLDOCTR := nValor
				DBUNLOCK()
				DBCOMMIT()
			ENDIF
		ENDIF
	ENDDO
RETURN(NIL)	
	
FUNCTION PReceber(oBrowse)				
	LOCAL cCor := SETCOR(m->cEdicao),;
			nCursor := SETCURSOR(1),;
			cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
			nReg := RECNO(),;
			Getlist:={},;
			lAchou,;
			nCliente:=0,;
			cDuplicata := SPACE(7),;
			cParcela   := [01],;
			dData      := CTOD([  /  /  ])
			
	
	DISPBOX(05,03,09,75,M->FR)
	@ 06,04 SAY "Cliente......:";
			  GET nCliente;
			  PICTURE "@K 99999";
			  VALID IF(!EMPTY(nCliente),Existe(nCliente,"Cliente n∆o cadastrado",.F.,"CECCCLI",1,"NOMECLC","@!",ROW(),COL()+1),.T.)
 			  
	@ 07,04 SAY "Duplicata No.:";
			       GET cDuplicata;
				    PICTURE "@k 9999999";
				    VALID ShowZeros(@cDuplicata,7) .AND. cDuplicata<>[0000000];
					 WHEN EMPTY(nCliente)
	
	@ 07,30 SAY "Parcela No.:";
			       GET cParcela;
				    PICTURE "@k 99";
				    VALID Showzeros(@cParcela,2)  .AND. cParcela<>[00];
					 WHEN EMPTY(nCliente)
					 
	@ 08,04 SAY "Vencimento..:";
				  	 GET dData;
					 PICTURE "@k@D";
					 VALID iF(EMPTY(nCliente),Existe(cDuplicata+[/]+cParcela+if(!empty(ddata),DTOS(dData),[]),"Duplicata n∆o encontrada",.F.,"CECCREC",3) .AND.;
							 EVAL({||DBSETORDER(3),.T.}),;		 
				  	       Existe(STRZERO(nCliente,5)+if(!empty(ddata),dtos(dData),[]),"Cliente n∆o possui lancamentos ou data n∆o encontrada",.F.,"CECCREC",1) .AND. EVAL({||DBSETORDER(1),.T.}))
							 
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

FUNCTION AjusteDup(cDuplicata)
	LOCAL cPedaco1,cPedaco2
	cPedaco1 := SUBST(cDuplicata,1,7)
	cPedaco2 := SUBST(cDuplicata,9,2)
	cPedaco := STRZERO(VAL(cPedaco1),7)
	cPedaco := STRZERO(VAL(cPedaco2),2)
	cDuplicata := cPedaco1+"/"+cPedaco2
RETURN(.T.)

FUNCTION Baixa(oBrowse)
	//
	LOCAL cCor 				 := SETCOR(m->cEdicao),;
			nCursor 			 := SETCURSOR(1),;
			cTela 			 := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
			nReg 				 := RECNO(),;
			DdATA           := ctod('  /  /  '),;
			nCliente			 := 0,;
			cHistorico      := SPACE(50),;
			cDuplicata 		 := space(7),;
			cParcela        := [01],;
			dDataPagamento  := date(),;
			dDataEmissao    := ctod('  /  /  '),;
			nValorJuros		 := 0,;
			nPerceJuros     := 0,;
			nValorPago		 := 0,;
			nValorDup       := 0,;
			nValorDebito    := 0,;
			nBanco			 := 0,;
			Wal             := .f.,;
			GetList			 := {}
	//
	BOX(2,0,24,79,M->FR,127,3,8)
	BOX(6,02,16,79,M->FR,127,3,8)	
	@ 05,25 SAY 'Baixa de Duplicatas a Receber'
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
					 PICTURE "@k@D";
					 VALID Existe(cDuplicata+[/]+cParcela+if(!empty(ddata),DTOS(dData),[]),"Duplicata n∆o encontrada",.F.,"CECCREC",3) .AND.;
							 if(ceccrec->statusr=[*],eval({||m_DISPLAY('Duplicata j† foi QUITADA',79),.F.}),.T.) .AND. ;				 
							 EVAL({||DBSETORDER(3),.T.}) .and.;
							 PegaValores(@dDataEmissao,@nValorPago,@nValorDup,@nCliente,@dData,@nValordebito)
											 
		@ 10,04 SAY "Cliente......:";
			  GET nCliente;
			  PICTURE "@K 99999";
			  VALID IF(!EMPTY(nCliente),Existe(nCliente,"Cliente n∆o cadastrado",.F.,"CECCCLI",1,"NOMECLC","@!",ROW(),COL()+1),.T.)
			  
			  					 
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
				  
		@ 13,40 SAY "Saldo a receber...:";
				  GET nValorDebito;
				  PICTURE "@K@E@R 99,999,999.99";
				  VALID !EMPTY(nValorDebito)		  ;
				  when .f.
		
		@ 14,04 SAY "Valor Pago...:";
				  GET nValorPago;
				  PICTURE "@K@E@R 99,999,999.99";
				  VALID !EMPTY(nValorPago)		  		  
				  
		@ 15,04 SAY "Hist¢rico....:";
				  GET cHistorico;
				  PICTURE "@!@S30"
				  		  
		READ	
		
		IF LASTKEY()==27
			LOOP
			
		ENDIF	
		//
		IF Confirma("Confirma a Baixa desta Duplicata?",23)
			QUITA := .F.
			IF nValorPago<CECCREC->SLDOCTR
				QUITA := M_QUERY('Valor pago menor que o devido, quita a duplicata ?',79)
			endif	
			SELECT("CECCPGT")
			IF Inclui_Registro(.T.)
				Lock_Registro(.T.)
				CECCPGT->CODCLIP   := nCliente
				CECCPGT->DOCDUPP   := cDuplicata
				CECCPGT->DTPAGAP   := dDataPagamento
				CECCPGT->VLPAGAP   := nValorPago
				CECCPGT->HISTORICO := cHistorico
				DBUNLOCK()
				DBCOMMIT()
			ENDIF
			//
			SELECT("CECCREC")
			Lock_Registro(.T.)
			CECCREC->SLDOCTR -= nValorPago
			IF CECCREC->SLDOCTR<0 .OR. QUITA
				CECCREC->SLDOCTR := 0
			ENDIF	
			If(CECCREC->SLDOCTR==0 .OR. QUITA,CECCREC->STATUSR:="*",CECCREC->STATUSR:="P")
			DBUNLOCK()
 			DBCOMMIT()
		ENDIF
		dData := CTOD([  /  /  ])
	ENDDO	
	//
SETCURSOR(nCursor)
SETCOLOR(cCor)
RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
DBGOTO(nReg)
oBrowse:refreshAll()
RETURN(.T.)

FUNCTION PegaValores(dDataEmissao,nValorPago,nValorDup,nCliente,dData,nvalordebito)
	dDataEmissao := CECCREC->DTEMISR
	nValorPago   := CECCREC->SLDOCTR
	nValorDup    := ceccrec->VLDOCTR
	nCliente     := CECCREC->CODCLIR
	dData        := ceccrec->DTVENCR
	nValorDebito := ceccrec->SLDOCTR
RETURN(.T.)	
