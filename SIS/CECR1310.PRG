// Sistemas de Controle de Estoque Comercial
// W&R Informatica Ltda
// 04 de Dezembro de 1995
// Roberto Falcao Rocha
// Relat¢rio de pre‡os de mercadorias 

#include "HAWK.CH"

LOCAL cTela     := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
		cCor    := SETCOLOR(),;
		nCursor := SETCURSOR(1),;
		nLinha  := 0,;
		cOrigem := SPACE(1),;
   		nFornecedor:=0,;
		lCab    :=.T.,;
		nPage   :=0,;
		nLin    :=0,;
		dReajuste:=CTOD("  /  /    "),;
		cTela2,;
		GetList:={},;
		nPerc:=0
							 
IF !ARQNTX("CECCFOR",.F.)  .OR.;
   !ARQNTX("CECTLIN",.F.) .OR.;
   !ARQNTX(m->sLog,.F.)   .OR.;
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
	
	@ 10,04 SAY "Reajuste..:";
			  GET dReajuste;
			  PICTURE "@K@D"
	
	@ 11,04 SAY "Ajuste....:";
			  GET nPerc;
			  PICTURE "@K 99.99"		  

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

		IF !EMPTY(dReajuste)	
			IF	CECCMER->DTUALTPRM < dReajuste
				DBSKIP()
				LOOP
			ENDIF			
		ENDIF
		
		IF lCab
			nPage++
			Cabecalho(nPage,"ANALISE DE PRECOS",;
			"MERCADORIA------  DESCRICAO----------------------------  UND O FORNECEDOR--------- PREC.COMPRA  PREC.VENDA   VARIACAO  REAJUST")			
//1234567890123  123456                                                           9999,999.99  9,999,999.99 99,999.99
//			 1              16                                     55 58 61                  81           90          116      125
//        9999999999999  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XX  X XXXXXXXXXXXXXXXXXXX  999.999,99  999.999,99  9999,99  99/99/99         
			lCab := .F.
			nLin:=9
		ENDIF
		
		@ nLin,001 SAY CECCMER->CODIGOM
		@ nLin,019 SAY SUBST(CECCMER->DESCRIM,1,38)
		@ nLin,058 SAY CECCMER->UNIDADE
		@ nLin,062 SAY CECCMER->ORIGEMM
		@ nLin,064 SAY SUBST(CECCFOR->NOMECLF,1,20)	
		@ nLin,084 SAY (CECCMER->PRECCOM) PICTURE "@R 9999,999.99"
		@ nLin,097 SAY (CECCMER->PRECVEM*(1+(ROUND(nPerc/100,4)))) PICTURE "@R 9,999,999.99"
		@ nLin,110 say (CECCMER->PRECVEM*(1+(ROUND(nPerc/100,4)))) - (CECCMER->PRECCOM) pict "@R 99,999.99"		
		@ nLin,120 SAY CECCMER->DTUALTPRM
		//
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