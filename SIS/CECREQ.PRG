// Sistemas de Controle de Estoque Comercial
// W&R Informatica Ltda
// 02 de Janeiro de 1997
// Roberto Falcao Rocha
// Requisicoes

#INCLUDE "INKEY.CH"

LOCAL cCor := SETCOR(m->cEdicao),;
		nCursor := SETCURSOR(1),;
		cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
		nReg := RECNO(),;
		nLoja:=0,;
		cLoja := SPACE(20),;
		aCodigo[50],;
		aQuantidade[50],;
		cDoc,;
		_SAI:=.F.,;
		GetList:={},;
		nI,;
		nX

// Verificando arquivos
IF !ARQNTX("CECTLOJ",.F.) .OR. ;
	!ARQNTX("CECCVEN",.F.) .OR. ;
	!ARQNTX("CECCLOJ",.F.) .OR. ;
	!ARQNTX("CECCSET",.F.) .OR. ;
	!ARQNTX("CECCMER",.F.) .OR. ;
	!ARQNTX("CECCMOV",.F.) 
	DBCLOSEALL()
	RETURN
ENDIF	

IF CECCSET->IMPFIS==0
	nLoja := 1
ENDIF	
AFILL(aCodigo,SPACE(13))
AFILL(aQuantidade,0)
	
IF FILE("NPEDIDO.MEM")
	RESTORE FROM NPEDIDO ADDITIVE
ELSE
	M->nPed:=0
	SAVE ALL LIKE NPED TO NPEDIDO
ENDIF		
_SAI := .f.
DO WHILE .T.
	IF !_SAI
		AFILL(aCodigo,SPACE(13))
		AFILL(aQuantidade,0)
	ENDIF	
	RESTORE FROM NPEDIDO ADDITIVE
	m->nPed++			
	SAVE ALL LIKE NPED TO NPEDIDO
	BOX(03,01,07,79,M->FR,127,3,8)
	BOX(09,00,24,79,M->FR,127,3,8)
	@ 10,01 SAY "[Mercadoria   ][Quant.   ][Descricao                                         ]"
	cDoc := "RQ"+STRZERO(M->NPED,8)
	@ 04,02 SAY "Documento No.:"+cDoc
		
	@ 05,02 SAY "Loja solicitante:";
	        GET nLoja;
			  PICTURE "@K 9999";
			  VALID !EMPTY(nLoja) .AND.;
			  Existe(nLoja,"Loja nÆo cadastrada",.F.,"CECTLOJ",1,"NOMLOJTL","@!",ROW(),COL()+1)
	
	@ 06,02 SAY "Loja solicitada.:";
			  GET cLoja;
			  PICTURE "@!";
			  VALID !EMPTY(cLoja)		  
				  
	READ
	IF LASTKEY()==27
		SETCURSOR(nCursor)
		SETCOLOR(cCor)
		RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
		DBCLOSEALL()
		RETURN(NIL)
	ENDIF			  
		
	nI := 1
	_SAI := .F.
	DO WHILE .T.
		@ 11,02 GET aCodigo[nI];
				  PICTURE "@K@!"; 
				  VALID !EMPTY(aCodigo[nI]) .AND.;
				  Existe(aCodigo[nI],"Mercadoria nÆo cadastrada",.F.,"CECCMER",1,"SUBST(DESCRIM,1,50)","@!",ROW(),28) 
					  
		@ 11,17 GET aQuantidade[nI];
		        PICTURE "@R@K 99,999.999";
				  VALID !EMPTY(aQuantidade[nI]) 
				  
		READ		  
		IF LASTKEY()#27
			nI ++ 
		ENDIF	
		IF LASTKEY()=27 .OR. IF(nI==51,EVAL({||M_DISPLAY("LIMITE DE ITENS ESGOTADO",79),.T.}),.F.)
			IF !M_QUERY("Confirma essa requisi‡Æo ?",23)
				RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
				_sai := .T.
				EXIT
			ELSE
				IF (nI-1) == 0
					M_DISPLAY("Esta requisi‡Æo nao possue itens, verifique !!!",79)	
					_sai := .T.
				ENDIF	
				EXIT
			ENDIF	
		ENDIF	
		SCROLL(11,02,21,76,-1)		  
	ENDDO			  
	
	IF _SAI
		LOOP
	ENDIF	
	cTelao := SAVESCREEN(0,0,MAXROW(),MAXCOL())
	M_MESSAGE("Atualizando arquivos ...",23)
	FOR nX:=1 TO (nI-1)
		CECCMER->(DBSEEK(aCodigo[nX]))
		CECCMOV->(Inclui_Registro(.T.))
		// Movimentos
		CECCMOV->(Lock_Registro(.T.))
		CECCMOV->NUMDOCTO   := cDoc
		CECCMOV->SERIE      := " "
		CECCMOV->SUBSERIE   := 0
		CECCMOV->NUMPED     := 0
		CECCMOV->MERCADORIA := aCodigo[nX]
		CECCMOV->DESCMERC   := CECCMER->DESCRIM
		CECCMOV->REFERENCIA := CECCMER->REFEREM
		CECCMOV->DATAMOV    := DATE()
		CECCMOV->CODLOJA    := nLoja
		CECCMOV->LINHA      := CECCMER->CODLINM
		CECCMOV->TIPOMOV    := "E"
		CECCMOV->CODMOV     := "RQ"
		CECCMOV->ORIGEM     := CECCMER->ORIGEMM
		CECCMOV->UNIDADE    := CECCMER->UNIDADE
		CECCMOV->QUANTMOV   := aQuantidade[nX]
		CECCMOV->SALANTMOV  := CECCMER->SALDOEM
		CECCMOV->PRECOMPRA  := CECCMER->PRECCOM
		CECCMOV->TOTVEND    := 0
		CECCMOV->CUSTOMOV   := ROUND(CECCMER->CMEDM*aQuantidade[nX],3)
		CECCMOV->PREVENDA   := CECCMER->PRECVEM
		CECCMOV->PREVENDIDO := 0
		CECCMOV->VLDESCITEM := 0
		CECCMOV->ALIDESITEM := 0
		CECCMOV->(DBUNLOCK())
		CECCMOV->(DBCOMMIT())
		
		// Lojas
		IF !CECCLOJ->(DBSEEK(STR(nLoja,4)+aCodigo[nX]))
			CECCLOJ->(Inclui_Registro(.T.))
		ENDIF
		CECCLOJ->(Lock_Registro(.T.))
		CECCLOJ->SALDOEJ+=aQuantidade[nX]
		CECCLOJ->DTUVLOJ:=DATE()
		CECCLOJ->DCUVLOJ:=cDoc
		CECCLOJ->(DBUNLOCK())
		CECCLOJ->(DBCOMMIT())
		
		// Mercadoria
		CECCMER->(DBSEEK(aCodigo[nX]))
		CECCMER->(Lock_Registro(.T.))
		CECCMER->SALDOEM+=aQuantidade[nx]
		CECCMER->DTULTVM:=DATE()
		CECCMER->DCULTVM:=cDoc
		CECCMER->(DBUNLOCK())
		CECCMER->(DBCOMMIT())		
		
	NEXT
	RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTelao)
	DO WHILE !IMPRES()
	ENDDO
	cTelao := SAVESCREEN(0,0,MAXROW(),MAXCOL())
	M_MESSAGE("Aguarde imprimindo requisi‡Æo",23)
	SET DEVICE TO PRINT
	LCAB := .T.
	FOR nX:=1 TO (nI-1)
		IF lCab
			@ 01,01 SAY "REQUISICAO No. "+cDoc
			@ 02,01 SAY "DATA: "+DTOC(DATE())
			@ 03,01 SAY "LOJA SOLICITANTE: "+CECTLOJ->NOMLOJTL
			@ 04,01 SAY "LOJA SOLICITADA.: "+cLoja	
			@ 05,01 SAY REPL("-",79)
			@ 06,01 SAY "CODIGO        DESCRICAO                                          QUANTIDADE"
			@ 07,01 SAY REPL("-",79)
			nLin := 8
			lCab := .F.
		ENDIF	
		@ nLin,01 SAY aCodigo[nX]
		@ nLin,15 SAY SUBST(CECCMER->DESCRIM,1,50)
		@ nLin,66 SAY aQuantidade[nX]
		nLin++
		IF nLin > 60
			lCab := .T.
		ENDIF	
	NEXT
	EJECT	
	SET DEVICE TO SCREEN
	RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTelao)	
ENDDO

RETURN(NIL)	

