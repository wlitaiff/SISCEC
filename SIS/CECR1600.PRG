// Sistemas de Controle de Estoque Comercial
// W&R Informatica Ltda
// 31 de Marco de 1997
// Roberto Falcao Rocha
// Relat¢rio de pre‡os de mercadorias 

#include "HAWK.CH"

LOCAL cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
      cCor := SETCOLOR(),;
		nCursor := SETCURSOR(1),;
		nLinha := 0,;
		cOrigem := SPACE(1),;
        nFornecedor:=0,;
		lCab:=.T.,;
		nPage:=0,;
		nLin:=0,;
		dReajuste:=CTOD("  /  /    "),;
		cTela2,;
		GetList:={},;
		nPerc:=0
							 

IF !ARQNTX("CECCFOR",.F.) .OR.;
	!ARQNTX("CECTLIN",.F.) .OR.;
	!ARQNTX(m->sLog,.F.)      .OR.;
	!ARQNTX("CECCMER",.F.)
	DBCLOSEALL()
	RETURN
ENDIF	



SET RELATION TO FIELD->FORNECM INTO CECCFOR,;
					 FIELD->CODLINM INTO CECTLIN
					 
DBSETORDER(7)	

DO WHILE .T.
	SETCOR(M->cEdicao)
	SETCURSOR(1)
	BOX(06,03,12,75,M->FR,127,3,8)						 
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
	@ PROW(),PCOL() SAY CHR(m->sEsc)
	
	DBGOTOP()
    xVarT := xCmpT := xVenT := 0
	DO WHILE !EOF()
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
		
		IF lCab
			nPage++
			Cabecalho(nPage,"ESTOQUE FISICO FINANCEIRO",;
            "MERCADORIA------ DESCRICAO------------------------------- UND ESTOQUE     P.COMPRA   V. COMPRA  PREC.VENDA VALOR      VARIACAO")
			lCab := .F.
			nLin:=9
		ENDIF
		
		@ nLin,001 SAY CECCMER->CODIGOM
        @ nLin,018 SAY SUBST(CECCMER->DESCRIM,1,40)
        @ nLin,059 SAY CECCMER->UNIDADE
        @ nLin,063 SAY CECCMER->SALDOEM
        @ nLin,075 SAY (CECCMER->PRECCOM) PICTURE "@R@e 999,999.99"
        @ nlin,86 SAY  xCmp := ROUND(CECCMER->SALDOEM*CECCMER->PRECCOM,2) picture "@r@e 999,999.99"
        @ nLin,097 SAY (CECCMER->PRECVEM) PICTURE "@R@e 999,999.99"
        @ nlin,108 SAY xVen := ROUND((CECCMER->SALDOEM*CECCMER->PRECVEM),2) picture "@r@e 999,999.99"
        @ nLin,119 say xVar := (xVen - xCmp)  pict "@R@e 999,999.99"
		//
		DBSKIP()
		nLin++
        xVarT += xVar
        xVenT += xVen
        xCmpT += xCmp
		IF nLin>60
			lCab := .T.
		ENDIF
	ENDDO
    @ NlIN,01 say repl("-",132)
    nlin++
    @ NLIN,01 SAY "T O T A L I Z A C A O = = = = = > > > > >"
    @ NLIN,86 SAY xCmpT PICTURE "@R@E 9,999,999.99"
    @ NLIN,108 SAY XVENT PICTURE "@R@E 9,999,999.99"
    @ nlin,119 say xvart picture "@e@r 9,999,999.99"
    nlin++
    @ NlIN,01 say repl("-",132)
	EJECT
	SET DEVICE TO SCREEN
	RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela2)
ENDDO		
							  

