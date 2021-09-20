// Sistemas de Controle de Estoque Comercial
// W&R Informatica Ltda
// 04 de Dezembro de 1995
// Roberto Falcao Rocha
// Relat¢rio Vendedores

#include "HAWK.CH"

LOCAL cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
		cCor := SETCOLOR(),;
		nCursor := SETCURSOR(1),;
		nLoja := 0,;
		lCab:=.T.,;
		nPage:=0,;
		nLin:=0,;
		cTela2,;
		GetList:={}
							 

IF !ARQNTX("CECTLOJ",.F.) .OR.;
	!ARQNTX(m->sLog,.F.)      .OR.;
	!ARQNTX("CECCVEN",.F.) 
	DBCLOSEALL()
	RETURN
ENDIF	

DBSETORDER(2)
SET RELATION TO FIELD->CODLOJ INTO CECTLOJ
					 
DO WHILE .T.
	SETCOR(M->cEdicao)
	SETCURSOR(1)
	BOX(05,03,07,75,M->FR,127,3,8)						 
	@ 06,04 SAY "Loja:";
			  GET nLoja;
			  PICTURE "@K 9999";
			  VALID IF(EMPTY(nLoja),EVAL({||DISPOUT(" Todas                                                 "),.T.}),;
			        Existe(nLoja,"Loja nÆo cadastrada",.F.,"CECTLOJ",1,"NOMLOJTL","@!",ROW(),COL()+1))				  				 
	
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
		IF !EMPTY(nLoja)
			IF nLoja#CECCVEN->CODLOJ
				DBSKIP()
				LOOP
			ENDIF
		ENDIF	
		
		IF lCab
			nPage++
			Cabecalho(nPage,"RELATORIO DE VENDEDORES",;
			"CODIGO NOME                                     LOJA                           COMISSAO    VENDAS      %COMISSAO %DESCONTO MAXIMO")
			nLin := 9
			lCab := .F.
		ENDIF
		
		@ nLin,01 SAY CECCVEN->CODVEN
		@ nLin,08 SAY CECCVEN->NOMVEN
		@ nLin,49 SAY CECTLOJ->NOMLOJTL
		@ nLin,80 SAY CECCVEN->COMMES PICTURE "99999999.99"
		@ nLin,92 SAY CECCVEN->VENMES PICTURE "99999999.99"
		@ nLin,104 SAY CECCVEN->PCONIS PICTURE "999.999"
		@ nLin,114 SAY CECCVEN->MAXDES PICTURE "999.999"
		
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