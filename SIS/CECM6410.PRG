// Sistemas de Controle de Estoque Comercial
// W&R Informatica Ltda
// 12 de Dezembro de 1995
// Roberto Falcao Rocha
// Curva ABC por VOLUME DE VENDAS (VALOR) / PERIODO


LOCAL cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
		cCor := SETCOLOR(),;
		nCursor := SETCURSOR(1),;
		dDataI:=CTOD("  /  /    "),;
		dDataF:=CTOD("  /  /    "),;
		aItens:={},;
		nTotalV := 0,;
		nTotalQ := 0,;
		x:=0,;
		nTotV:=0,;
		nTotQ:=0,;
		nX,;
		nLoja:=0

IF !ARQNTX("CECCMOV",.F.) .OR.;
	!ARQNTX("CECTLOJ",.F.) .OR.;
	!ARQNTX("CECCABC",.F.)
	DBCLOSEALL()
	RETURN
ENDIF	

SELECT("CECCMOV")
DBSETORDER(2)
DO WHILE .T.
	SETCOR(M->cEdicao)
	SETCURSOR(1)
	BOX(05,03,09,75,M->FR,127,3,8)						 	
	@ 06,04 SAY "Data inicial..:";
		  GET dDataI;
		  PICTURE "@D"
				  
	@ 07,04 SAY "Data Final....:";
		  GET dDataF;
		  PICTURE "@D"
					  
	@ 08,04 SAY "Loja..........:";
			  GET nLoja;
			  PICTURE "@K 9999";
			  VALID IF(EMPTY(nLoja),EVAL({||DISPOUT(" Todas                                     "),.T.}),;
			        Existe(nLoja,"Loja nÆo cadastrada",.F.,"CECTLOJ",1,"NOMLOJTL","@!",ROW(),COL()+1))
	READ
	
	IF LASTKEY()==27
		SETCOLOR(cCor)
		SETCURSOR(nCursor)
		RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
		DBCLOSEALL()
		RETURN
	ENDIF	

	IF EMPTY(dDataI)
		DBGOTOP()
	ELSE
		DBSEEK(DTOS(dDataI),.T.)
	ENDIF
	
	IF FIELD->DATAMOV>dDataF
		M_DISPLAY("Per¡odo inv lido, ou nÆo existe",79)
		LOOP
	ELSE
		EXIT	
	ENDIF
ENDDO	




M_MESSAGE("Gerando curva ABC por volume de vendas/valor ...",23)

	
DO WHILE !EOF() .AND. IF(EMPTY(dDataF),.T.,FIELD->DATAMOV<=dDataF)	
	IF IF(!EMPTY(nLoja),FIELD->CODLOJA#nLoja,.T.) .OR. FIELD->CODMOV#"VE"
		DBSKIP()
		LOOP
	ENDIF	
	IF (x:=ASCAN(aItens,{|x| x[1]==FIELD->MERCADORIA}))==0
		AADD(aItens,{FIELD->MERCADORIA,FIELD->CUSTOMOV," "})
	ELSE
		aItens[x,2] += FIELD->CUSTOMOV
	ENDIF		
	DBSKIP()
ENDDO	

IF LEN(aItens)==0
	M_DISPLAY("Nao existem movimentos neste periodo",79)
	RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
	DBCLOSEALL()
	RETURN
ENDIF
	
ASORT(aItens,,,{|x,y| x[2]>y[2]})

FOR x:=1 TO LEN(aItens)
	nTotalV += aItens[x,2]
NEXT	
nTotalQ := LEN(aItens)

FOR x:=1 TO LEN(aItens)
	 nTotV+=aItens[x,2]
 	 nTotQ++
	 IF ((nTotV <= (nTotalV * 75/100)) .AND.;
	    (nTotQ <= ROUND((nTotalQ * 5/100),0))) .OR.;
		 nTotQ == 1
		 aItens[x,3]:="A"
	 ELSE
	 	 nX:=nTotQ
	 	 nTotQ:=0
		 nTotV:=0
	 	 EXIT	 
	 ENDIF
NEXT

FOR x:=nX TO LEN(aItens)
	 nTotV+=aItens[x,2]
 	 nTotQ++
	 IF ((nTotV <= (nTotalV * 20/100)) .AND.;
	    (nTotQ <= ROUND((nTotalQ * 20/100),0))) .OR.;
		 nTotQ == 1
		 aItens[x,3]:="B"
	 ELSE
	 	 nX+=(nTotQ-1)
	 	 nTotQ:=0
		 nTotV:=0
	 	 EXIT	 
	 ENDIF
NEXT

FOR x:=nX TO LEN(aItens)
	 aItens[x,3]:="C"
NEXT

FOR x:=1 TO LEN(aItens)
	DBSEEK(aItens[x,1])
	Lock_Registro(.T.)
	CECCMER->CLAABCM := aItens[x,3]
	CECCABC->(DBSEEK(aItens[x,1]))
	CECCABC->(Lock_Registro(.T.))
	CECCABC->VVALOR:=aItens[x,3]
	CECCABC->(DBUNLOCK())
	DBUNLOCK()
NEXT	

RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
DBCLOSEALL()
RETURN