// Sistemas de Controle de Estoque Comercial
// W&R Informatica Ltda
// 06 de Dezembro de 1995
// Roberto Falcao Rocha
// Relat¢rio de saldo de estoque por loja

#include "HAWK.CH"

LOCAL cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
		cCor := SETCOLOR(),;
		nCursor := SETCURSOR(1),;
		nLinha := 0,;
		cOrigem := SPACE(1),;
   	nFornecedor:=0,;
		nLoja:=0,;
		NOLoja:=0,;
		cTexto,;
		lCab:=.T.,;
		nPage:=0,;
		nLin:=0,;
		cTela2,;
		GetList:={}
							 

IF !ARQNTX("CECCFOR",.F.) .OR.;
	!ARQNTX("CECTLIN",.F.) .OR.;
	!ARQNTX(m->sLog,.F.)      .OR.;
	!ARQNTX("CECCMER",.F.) .OR.;
	!ARQNTX("CECTLOJ",.F.) .OR.;
	!ARQNTX("CECCLOJ",.F.) 
	DBCLOSEALL()
	RETURN
ENDIF	

SELECT("CECCMER")
SET RELATION TO FIELD->FORNECM INTO CECCFOR,;
					 FIELD->CODLINM INTO CECTLIN

SELECT("CECCLOJ")
SET RELATION TO FIELD->CODILOJ INTO CECTLOJ,;
                FIELD->MERCLOJ INTO CECCMER    					 
					 
DO WHILE .T.
	SETCOR(M->cEdicao)
	SETCURSOR(1)
	BOX(06,03,11,75,M->FR,127,3,8)						 
	@ 07,04 SAY "Grupo..:";
			  GET nLinha;
			  PICTURE "@K 9999";
			  VALID IF(EMPTY(nLinha),EVAL({||DISPOUT(" Todas                     "),.T.}),;
			        Existe(nLinha,"Grupo de mercadoria nÆo cadastrada",.F.,"CECTLIN",1,"NOMLIN","@!",ROW(),COL()+1))
					  
	@ 08,04 SAY "Origem.:";
			  GET cOrigem;
			  PICTURE "@K!";
			  VALID cOrigem$"NI " .AND.;
			        IF(EMPTY(cOrigem),EVAL({||DISPOUT(" Todas                    "),.T.}),;
			        EVAL({|x|DISPOUT(IF(x=="N","Nacional","Importado")),.T.}))
					  
	@ 09,04 SAY "Fornecedor:";
			  GET nFornecedor;
			  PICTURE "@K 99999";
			  VALID IF(EMPTY(nFornecedor),EVAL({||DISPOUT(" Todos                                                 "),.T.}),;
			        Existe(nFornecedor,"Fornecedor nÆo cadastrado",.F.,"CECCFOR",1,"NOMECLF","@!",ROW(),COL()+1))				  				 
	
	@ 10,04 SAY "Loja......:";
			  GET nLoja;
			  PICTURE "@K 9999";
			  VALID IF(EMPTY(nLoja),EVAL({||DISPOUT(" Todas                                                      "),.T.}),;
			        Existe(nLoja,"Loja nÆo cadastrada",.F.,"CECTLOJ",1,"NOMLOJTL","@!",ROW(),COL()+1) .AND.;
					  Existe(STR(nLoja,4),"Loja nÆo possui mercadorias em estoque",.F.,"CECCLOJ",1))				  				  
	
	READ
	
	IF LASTKEY()==27
		SETCOLOR(cCor)
		SETCURSOR(nCursor)
		RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
		DBCLOSEALL()
		RETURN
	ENDIF	
	
	IF !IMPRES()
		LOOP
	ENDIF
	
	cTela2 := SAVESCREEN(0,0,MAXROW(),MAXCOL())
	M_MESSAGE("Imprimindo, aguarde ...",23)
	
	SET DEVICE TO PRINT
	@ PROW(),PCOL() SAY CHR(M->sEsc)
	
	IF EMPTY(nLoja)
		DBSETORDER(2)
		DBGOTOP()
	ENDIF	
	
	DO WHILE IF(!EMPTY(nLoja),nLoja==CECCLOJ->CODILOJ,.T.) .AND. !EOF()
		IF INKEY()==27
			IF Para_Impressao()
				EXIT
			ENDIF
		ENDIF						
		IF !EMPTY(nLinha)
			IF nLinha#CECCMER->CODLINM
				DBSKIP()
				LOOP
			ENDIF
		ENDIF	
		IF !EMPTY(cOrigem)	
			IF	cOrigem#CECCMER->ORIGEMM
				DBSKIP()
				LOOP
			ENDIF	
		ENDIF	
		IF !EMPTY(nFornecedor)	
			IF	nFornecedor#CECCMER->FORNECM
				DBSKIP()
				LOOP
			ENDIF		
		ENDIF	
		
		nOLoja := CECCLOJ->CODILOJ
		
		IF lCab
			nPage++
			IF !EMPTY(nLoja)
				cTexto := "LOJA: "+ALLTRIM(CECTLOJ->NOMLOJTL)+"-"+ALLTRIM(STR(CECCLOJ->CODILOJ,4))
			ELSE
				cTexto := "RELATORIO GERAL DE ESTOQUE POR LOJA"
			ENDIF		
			Cabecalho(nPage,cTexto,;
			"MERCADORIA       REFERENCIA      DESCRICAO                              UND O FORNECEDOR            GRUPO                       ESTOQUE")			
			nLin := 9
			lCab := .F.
		ENDIF
		
		@ nLin,01 SAY CECCLOJ->MERCLOJ
		@ nLin,18 SAY CECCMER->REFEREM
		@ nLin,34 SAY SUBST(CECCMER->DESCRIM,1,38)
		@ nLin,73 SAY CECCMER->UNIDADE
		@ nLin,77 SAY CECCMER->ORIGEMM
		@ nLin,79 SAY SUBST(CECCFOR->NOMECLF,1,21)	
		@ nLin,101 SAY SUBST(CECTLIN->NOMLIN,1,23)
		IF !EMPTY(nLoja)
			@ nLin,126 SAY CECCLOJ->SALDOEJ PICTURE "999999.999"
		ELSE
			@ nLin,126 SAY CECCMER->SALDOEM PICTURE "999999.999"
		ENDIF	
		
		IF EMPTY(nLoja)
			cMerc := CECCLOJ->MERCLOJ
			DO WHILE CECCLOJ->MERCLOJ == cMerc .AND. !EOF()
				nLin++
				IF nLin>60
					nPage++
					cTexto := ""
					Cabecalho(nPage,cTexto,;
					"MERCADORIA       REFERENCIA      DESCRICAO                              UND O FORNECEDOR            GRUPO                       ESTOQUE")			
					@ nLin,01 SAY CECCLOJ->MERCLOJ
					@ nLin,18 SAY CECCMER->REFEREM
					@ nLin,34 SAY SUBST(CECCMER->DESCRIM,1,38)
					@ nLin,73 SAY CECCMER->UNIDADE
					@ nLin,77 SAY CECCMER->ORIGEMM
					@ nLin,80 SAY SUBST(CECCFOR->NOMECLF,1,21)	
					@ nLin,101 SAY SUBST(CECTLIN->NOMLIN,1,20)
					IF !EMPTY(nLoja)
						@ nLin,126 SAY CECCLOJ->SALDOEJ PICTURE "999999.999"
					ELSE
						@ nLin,126 SAY CECCMER->SALDOEM PICTURE "999999.999"
					ENDIF	
					nLin := 10
				ENDIF	
				cTexto := "LOJA: "+ALLTRIM(CECTLOJ->NOMLOJTL)+"-"+ALLTRIM(STR(CECCLOJ->CODILOJ,4))				
				@ nLin,76 SAY cTexto
				@ nLin,126 SAY CECCLOJ->SALDOEJ PICTURE "999999.999"
				DBSKIP()
			ENDDO	
		ELSE
			DBSKIP()
		ENDIF
		nLin++
		IF nLin>60 .OR. IF(!EMPTY(nLoja),nOLoja#CECCLOJ->CODILOJ,.F.)
			lCab := .T.
		ENDIF
			
	ENDDO
	EJECT
	SET DEVICE TO SCREEN
	RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela2)
ENDDO