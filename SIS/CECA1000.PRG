// Sistemas de Controle de Estoque Comercial
// W&R Informatica Ltda
// 19 de Outubro de 1995
// Roberto Falcao Rocha
// Cadastro de mercadorias

LOCAL cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
		cCor := SETCOLOR(),;
		nCursor := SETCURSOR(0),;
		nTclass := 0,;
                cTaClas := {"C¢digo","Grupo","Descri‡„o","Cancela"},;
		aDad := {"CODIGOM","REFEREM","DESCRIM","UNIDADE","CODLINM",;
					"FORNECM","ORIGEMM","CLAABCM",;
					"ESTMINM","MARLUCM","PRECVEM","PRECVEM2","DTULTVM","DCULTVM",;
					"PRECCOM","DTULTCM","DCULTCM","SALDOEM","QTDPED","CAUTELA","ULTPRPM",;
               "DTUALTPRM","CMEDM","CFOBM","CCIFM","CSTAM","DTCHEGADA","QTDCHEGADA"},;
		aCab := {"Material","Referˆncia","Descri‡„o","Unidade","Grupo",;
					"Fornecedor","Origem","Classe ABC","Estoque m¡nimo",;
					"Margem de lucro","Preco de venda","Preco Faturado","éltima venda","Documento Ultima Venda",;
					"Pre‡o de compra","éltima compra","Documento ultima compra",;
					"Saldo de estoque","Qtd. Pedido","Cautela","Ultimo pre‡o","Data do reajuste","Custo m‚dio",;
               "Custo FOB","Custo CIF","Custo padrÆo","Previsao de Chegada","Quantidade"},;
		aPic := {"@!","@!","@!","@!","@R@E 99,999","99999","!","!","@R@E 999,999,999",;
					"@R@E 999.999","@E@R 99,999,999.99","@E@R 99,999,999.99","@D","@!","@E@R 99,999,999.99",;
					"@D","@!","@R@E 9,999,999.999","@R@E 9,999,999.999","@R@E 9,999,999.999","@R@E 99,999,999.99","@D","@E@R 9,999,999.999",;
                "@E@R 9,999,999.999","@E@R 9,999,999.999","@E@R 9,999,999.999","@D","@E@R 999,999.999"}

// Verificando arquivos
IF !ARQNTX("CECCMER",.F.) .OR. ;
	!ARQNTX("CECCABC",.F.) .OR. ;
	!ARQNTX("CECCSET",.F.) .OR. ;
	!ARQNTX("CECTLIN",.F.) .OR. ;
	!ARQNTX("CECCFOR",.F.) 
	DBCLOSEALL()
	RETURN
ENDIF	
nTclass := ALERT("Classifica‡„o por...",cTaClas)

SELECT("CECCMER")						

DO CASE
	CASE nTclass == 1
		DBSETORDER(1)
	CASE nTclass == 2
      DBSETORDER(8)
   CASE nTclass == 3
		DBSETORDER(3)
	OTHER
		DBCLOSEALL()
		RETURN
ENDCASE

DBGOTOP()

HBrowseDB( 1,0,24,79,"Cadastro de mercadorias",aCab,aDad,aPic,NIL,,,;
			{"REFEREM","DESCRIM","UNIDADE","CODLINM","FORNECM","ORIGEMM",;
           "MARLUCM","PRECVEM","CLAABCM","ESTMINM","CSTAM","QTDPED","CAUTELA","DTCHEGADA","QTDCHEGADA","PRECCOM"})
DBCLOSEAll()
RETURN

FUNCTION CMercadoria( oBrowse )
	LOCAL cCor := SETCOR(m->cEdicao),;
			nCursor := SETCURSOR(1),;
			cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
			nReg := RECNO(),;
			cCodigoM:=SPACE(16),;
			cRefereM:=SPACE(13),;
			cDescriM:=SPACE(40),;
			cOrigemM:=SPACE(1),;
			nFornecM:=0,;
			nCodLinM:=0,;
			cUnidade:=SPACE(3),;
			nPreco:=0,;
			nEstMin:=0,;
			GetList:={}
			
	DO WHILE .T.			
		BOX(05,03,15,75,M->FR,127,3,8)
		@ 06,04 SAY "C¢digo da mercadoria..:";
				  GET cCodigoM;
				  PICTURE "@K@!";
				  VALID !EMPTY(cCodigoM) .AND.;
				  !Existe(cCodigoM,"Mercadoria j  cadastrada",.T.,,1) 
			  
		//@ 07,04 SAY "Referencia............:";
		//		  GET cRefereM;
		//		  PICTURE "@K@!";
		//		  VALID !EMPTY(cRefereM) .AND.;
		//	     !Existe(cRefereM,"Referˆncia j  cadastrada",.T.,,1) 
			  
		@ 08,04 SAY "Descri‡„o.............:";
				  GET cDescriM;
				  PICTURE "@K@!";
				  VALID !EMPTY(cDescriM)
		
		@ 09,04 SAY "Unidade...............:";
				  GET cUnidade;
				  PICTURE "@K@!";
				  VALID !EMPTY(cUnidade)		  
				  
		@ 10,04 SAY "Grupo da mercadoria...:";
				  GET nCodLinM;
				  PICTURE "@K@R@E 9,999";
				  VALID !EMPTY(nCodLinM) .AND.;
				  Existe(nCodLinM,"Grupo n„o cadastrado",.F.,"CECTLIN",1,"NOMLIN","@!",ROW(),COL()+1)
			  
		@ 11,04 SAY "Fornecedor............:";
				  GET nFornecM;
				  PICTURE "@K@R@E 99,999";
				  VALID !EMPTY(nFornecM) .AND.;
				  Existe(nFornecM,"Fornecedor n„o cadastrado",.F.,"CECCFOR",1,"NOMECLF","@!",ROW(),COL()+1)
			  
		@ 12,04 SAY "Origem................:";			  
				  GET cOrigemM;
				  PICTURE "@K!";
				  VALID !EMPTY(cOrigemM) .AND.;
				  cOrigemM$"NI" .AND.;
				  EVAL({|cExp| DISPOUT(IF(cExp=="N"," NACIONAL      "," IMPORTADO      ")),.T.},cOrigemM)				
		
		@ 13,04 SAY "Pre‡o de venda........:";			  
				  GET nPreco;
				  PICTURE "@K 9,999,999.99"
		
		@ 14,04 SAY "Estoque m¡nimo........:";			  
				  GET nEstMin;
				  PICTURE "@K 999,999,999"		  
				  
		READ	
		
		IF LASTKEY()==27
			SETCURSOR(nCursor)
			SETCOLOR(cCor)
			RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
			DBGOTO(nReg)
			oBrowse:refreshAll()
			RETURN(NIL)
		ENDIF	
			
		IF Confirma("Confirma a inclus„o desta mercadoria",23)
			IF Inclui_Registro(.T.)
				Lock_Registro(.T.)
				CECCMER->CODIGOM := cCodigoM
				CECCMER->REFEREM := STRZERO(nCodLinM,4)+STRZERO(CECTLIN->SEQUENCIA+1,9)
				CECCMER->DESCRIM := cDescriM
				CECCMER->ORIGEMM := cOrigemM
				CECCMER->FORNECM := nFornecM
				CECCMER->CODLINM := nCodLinM
				CECCMER->UNIDADE := cUnidade
				CECCMER->PRECVEM := nPreco
				CECCMER->PRECVEM2 := Round(nPreco*1.05,2)
				CECCMER->ESTMINM := nEstMin
				DBUNLOCK()
				DBCOMMIT()
			ENDIF
			SELECT("CECTLIN")
			LOCK_REGISTRO(.T.)
			CECTLIN->SEQUENCIA++
			DBUNLOCK()
			DBCOMMIT()	
			SELECT("CECCABC")
			Inclui_Registro(.T.)
			Lock_Registro(.T.)	
			CECCABC->CODIGO := cCodigoM
			DBUNLOCK()
			DBCOMMIT()
			SELECT("CECCMER")
		ENDIF
	ENDDO
RETURN(NIL)	
	
FUNCTION PMercadoria(oBrowse)				
	LOCAL cCor := SETCOR(m->cEdicao),;
			nCursor := SETCURSOR(1),;
			cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
			nReg := RECNO(),;
			Getlist:={},;
			lAchou,;
			cCodigoM:=SPACE(16),;
			cDescriM:=SPACE(40),;
                        cRefereM:=0
                     // cRefereM:=SPACE(13)
	
	DISPBOX(05,03,09,75,M->FR)
	@ 06,04 SAY "C¢digo da mercadoria..:";
			  GET cCodigoM;
			  PICTURE "@K@!"
			  
	@ 07,04 SAY "Descri‡„o.............:";
			  GET cDescriM;
			  PICTURE "@K@!"
			  
        @ 08,04 SAY "Grupo  ...............:";
			  GET cRefereM;
                          PICTURE "99-99"  // ;
                         //  VALID PVerifica({cCodigoM,cDescriM,cRefereM})           
	READ		  
		
	SETCURSOR(nCursor)
	SETCOLOR(cCor)
	RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)	
	
	IF LASTKEY()==27
		DBGOTO(nReg)
		oBrowse:refreshAll()
		RETURN(NIL)
	ENDIF	
	
	DO CASE
		CASE !EMPTY(cCodigoM)	  
			lAchou := Existe(ALLTRIM(cCodigoM),"Mercadoria n„o cadastrada",.F.,,1,,,,,.T.) 				
		CASE !EMPTY(cDescriM)	  
	   	lAchou := Existe(cDescriM,"Descri‡„o n„o cadastrada",.F.,,3,,,,,.T.) 			
                CASE !EMPTY(STR(cRefereM,4))     
                lAchou := Existe(str(cRefereM,4),"Referˆncia n„o cadastrada",.F.,,8,,,,,.T.)                    
	ENDCASE		
		
	IF !lAchou
		DBGOTO(nReg)
	else
		DO CASE
			CASE !EMPTY(cCodigoM)	  
				DBSETORDER(1)
			CASE !EMPTY(cDescriM)	  
				DBSETORDER(3)
                        CASE !EMPTY(STR(cRefereM,4))     
                                DBSETORDER(8)
		ENDCASE		
	ENDIF
		
	oBrowse:refreshAll()
RETURN(NIL)			

FUNCTION ZMercadoria( oBrowse )
	LOCAL cCor := SETCOR(m->cEdicao),;
			nCursor := SETCURSOR(0),;
			cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
			nInd := INDEXORD()
	//Lock_Registro(.T.)		      -   retornar posteriormente
	BOX(05,03,18,75,M->FR,127,3,8)
	CECCFOR->(DBSEEK(CECCMER->FORNECM))
	CECTLIN->(DBSEEK(CECCMER->CODLINM))
        XCC := CECCMER->PRECVEM
	@ 06,04 SAY "CODIGO.........:"+CECCMER->CODIGOM 
	@ 07,04 SAY "DESCRICAO......:"+CECCMER->DESCRIM PICTURE "@!"
	@ 08,04 SAY "REFERENCIA.....:"+CECCMER->REFEREM PICTURE "@!"
	@ 09,04 SAY "UNIDADE........:"+CECCMER->UNIDADE PICTURE "@!"
	@ 10,04 SAY "GRUPO..........:"+Trans(CECCMER->CODLINM,"99999") 
			 // VALID Existe(CECCMER->CODLINM,"Grupo nÆo cadastrada",.F.,"CECTLIN",1,"NOMLIN","@!",ROW(),COL()+1)						
	@ 11,04 SAY "FORNECEDOR.....:"+Trans(CECCMER->FORNECM,"99999") 
			 //  VALID Existe(CECCMER->FORNECM,"Fornecedor nÆo cadastrado",.F.,"CECCFOR",1,"NOMECLF","@!",ROW(),COL()+1)											
	@ 12,04 SAY "ORIGEM.........:"+Trans(CECCMER->ORIGEMM,"!")  // VALID CECCMER->ORIGEMM=="I" .OR. CECCMER->ORIGEMM=="N"
	@ 13,04 SAY "SALDO..........:"+TRANS(CECCMER->SALDOEM,"@R 9999,999.999")
	@ 13,40 SAY "CAUTELAS.......:"+TRANS(CECCMER->CAUTELA,"@R 9999,999.999")
	@ 14,04 SAY "DISPONIVEL.....:"+TRANS( (CECCMER->SALDOEM)-(CECCMER->CAUTELA),"@R 9999,999.999")
	@ 14,40 SAY "ESTOQUE MINIMO.:"+Trans(CECCMER->ESTMINM,"@R 99,999.999")        // GET CECCMER->ESTMINM PICTURE "@R 99,999.999"
   @ 15,04 SAY "PRECO DE VENDA.:"+Trans(XCC,"@R 9,999,999.99")
           /** GET XCC PICTURE "@R 9,999,999.99";
            VALID EVAL ( { || IF ( PASS () == ALLTRIM ( Criptografa ( CECCSET -> PASSWDS, "HAWK", .F. ) ),;
                                   EVAL ( { || CECCMER->PRECVEM   := XCC,;
											  				  CECCMER->PRECVEM2  := Round(XCC*1.05,2),;
                                               CECCMER->DTUALTPRM := DATE(),;
                                               .T.}),;
                                   EVAL ( { || M_DISPLAY("Usuario nÆo autorizado",79),XCC := CECCMER->PRECVEM,;
                                               .T.})) } )   **/
	@ 15,40 SAY "PRECO FATURADO.:  "+TRANS(CECCMER->PRECVEM2,"@R 9,999,999.99")
        @ 16,04 SAY "PREVISAO DE CHEGADA:"+DTOC(CECCMER->DTCHEGADA)
        @ 16,40 SAY "QUANTIDADE: "+TRANS(CECCMER->QTDCHEGADA,"@R 999,999.999")
   //@ 16,04 SAY "PRECO DE VENDA.:" GET CECCMER->PRECVEM PICTURE "@R 9,999,999.99" VALID EVAL({||IF(UPDATED(),CECCMER->DTUALTPRM := DATE(),.T.),.T.})
	//@ 16,04 SAY "PRECO DE COMPRA.:" GET CECCMER->PRECCOM PICTURE "@R 9,999,999.99"  
	@ 17,04 SAY "REAJUSTE.......:"+DTOC(CECCMER->DTUALTPRM)
	//READ
	INKEY(0)
	RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
	SETCURSOR(nCursor)
	SETCOLOR(cCor)
	oBrowse:refreshAll()
	DBSETORDER(nInd)
RETURN(NIL)	
