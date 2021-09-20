// Sistemas de Controle de Estoque Comercial
// W&R Informatica Ltda
// 04 de Dezembro de 1995
// Roberto Falcao Rocha
// Relat¢rio de itens com estpque minimo atingido

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
		cTela2,;
		GetList:={}
							 

IF !ARQNTX("CECCFOR",.F.) .OR.;
	!ARQNTX("CECTLIN",.F.) .OR.;
	!ARQNTX(m->sLog,.F.)      .OR.;
	!ARQNTX("CECCMER",.F.)
	DBCLOSEALL()
	RETURN
ENDIF	

DBSETORDER(3)

SET RELATION TO FIELD->FORNECM INTO CECCFOR,;
					 FIELD->CODLINM INTO CECTLIN
					 
DO WHILE .T.
	SETCOR(M->cEdicao)
	SETCURSOR(1)
	BOX(06,03,10,75,M->FR,127,3,8)						 
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
	@ PROW(),PCOL() SAY CHR(M->sEsc)
	
	DBGOTOP()
	
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
		IF CECCMER->ESTMINM<CECCMER->SALDOEM
			DBSKIP()
			LOOP
		ENDIF
		
		IF lCab
			nPage++
			Cabecalho(nPage,"ITENS COM ESTOQUES MINIMOS ATINGIDOS",;
			"MERCADORIA       REFERENCIA      DESCRICAO                              UND O FORNECEDOR           GRUPO                 ATUAL      MINIMO")			
			nLin := 9
			lCab := .F.
		ENDIF
		
		@ nLin,01 SAY CECCMER->CODIGOM
		@ nLin,18 SAY CECCMER->REFEREM
		@ nLin,34 SAY SUBST(CECCMER->DESCRIM,1,38)
		@ nLin,73 SAY CECCMER->UNIDADE
		@ nLin,77 SAY CECCMER->ORIGEMM
		@ nLin,79 SAY SUBST(CECCFOR->NOMECLF,1,20)	
		@ nLin,100 SAY SUBST(CECTLIN->NOMLIN,1,17)
		@ nLin,119 SAY CECCMER->SALDOEM PICTURE "999999.999"
		@ nLin,130 SAY CECCMER->ESTMINM PICTURE "999999"
		
		DBSKIP()
		nLin++
		IF nLin>60
			lCab := .T.
		ENDIF
			
	ENDDO
	EJECT
	SET DEVICE TO SCREEN
	RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela2)
ENDDO		
							  