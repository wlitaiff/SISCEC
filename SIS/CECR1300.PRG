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
	
	@ 10,04 SAY "Dt. Ajuste:";
			  GET dReajuste;
			  PICTURE "@K@D"
	
	@ 11,04 SAY "% Ajuste..:";
			  GET nPerc;
			  PICTURE "@K 99.9999"		  

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

		IF lCab
			nPage++
			Cabecalho(nPage,"LISTA DE PRECOS",;
			"MERCADORIA------ DESCRICAO------------------------- UN O PRECO VENDA QTD.ESTOQUE",80)		
		   //XXXXXXXXXXXXXXXX 17XXXXXXXXXXXXX35XXXXXXXXXXXXXXXXX 53 X 0058,999,99 7099.999,99 
			@ 09,001 SAY chr(18)+"GRUPO.:"+STR(CECCMER->CODLINM)+" - "+SUBS(CECTLIN->NOMLIN,1,20)+"     FORNECEDOR.:";
								 		  +STR(CECCMER->FORNECM)+" - "+SUBS(CECCFOR->NOMECLF,1,25)
			lCab := .F.
			nLin:=11
		ENDIF
		
		@ nLin,001 SAY CECCMER->CODIGOM
		@ nLin,018 SAY SUBST(CECCMER->DESCRIM,1,35)
		@ nLin,053 SAY CECCMER->UNIDADE
		@ nLin,056 SAY CECCMER->ORIGEMM
		@ nLin,058 SAY IF(EMPTY(nPerc),(ceccmer->precvem),(CECCMER->PRECVEM*(1+Round((nPerc/100),4)))) PICTURE "@E 9999,999.99"
		@ nLin,070 SAY CECCMER->SALDOEM pict "@E 999,999.999"
		//
		IF !EMPTY(nPerc)
		   Lock_Registro(.T.)
		   CECCMER->PRECVEM  := (CECCMER->PRECVEM *(1+Round((nPerc/100),4)))
		   CECCMER->PRECVEM2 := (CECCMER->PRECVEM2*(1+Round((nPerc/100),4)))
		   CECCMER->DTUALTPRM:= dReajuste
		   DBCOMMIT()
		   DBUNLOCK()
		ENDIF
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