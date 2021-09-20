// Sistemas de Controle de Estoque Comercial
// W&R Informatica Ltda
// 12 de Dezembro de 1995
// Roberto Falcao Rocha
// Curva ABC por preco de venda

LOCAL cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
		cCor := SETCOLOR(),;
		nCursor := SETCURSOR(1),;
		xVar,;
		nTotalV := 0,;
		nTotalQ := 0,;
		x,;
		nTotV:=0,;
		nTotQ:=0,;
		nX
		
							 

IF !ARQNTX("CECCMER",.F.) .OR.;
	!ARQNTX("ABCTEMP",.T.) .OR.;
	!ARQNTX("CECCABC",.F.)
	DBCLOSEALL()
	RETURN
ENDIF	

M_MESSAGE("Gerando curva ABC por preco de venda, aguarde ...",23)

SELECT("CECCMER")
DBGOTOP()
DO WHILE !EOF()
	ABCTEMP->(Inclui_Registro(.T.))
	ABCTEMP->CODIGO := CECCMER->CODIGOM
	ABCTEMP->VALOR  := CECCMER->PRECVEM
	DBSKIP()
ENDDO	

SELECT("ABCTEMP")
INDEX ON DESCEND(ABCTEMP->VALOR) TO ABCTEMP
SET INDEX TO ABCTEMP
SUM ABCTEMP->VALOR TO nTotalV
nTotalQ := RECCOUNT()
DBGOTOP()
DO WHILE !EOF()
	 nTotV+=ABCTEMP->VALOR
 	 nTotQ++
	 IF ((nTotV <= (nTotalV * 75/100)) .AND.;
	    (nTotQ <= ROUND((nTotalQ * 5/100),0))) .OR.;
		 nTotQ == 1
		 ABCTEMP->CURVA := "A"
	 ELSE
	 	 nTotQ:=0
		 nTotV:=0
	 	 EXIT	 
	 ENDIF
	 DBSKIP()
ENDDO	 

DO WHILE !EOF()
	 nTotV+=ABCTEMP->VALOR
 	 nTotQ++
	 IF ((nTotV <= (nTotalV * 20/100)) .AND.;
	    (nTotQ <= ROUND((nTotalQ * 20/100),0))) .OR.;
		 nTotQ == 1
		 ABCTEMP->CURVA := "B"
	 ELSE
	 	 nTotQ:=0
		 nTotV:=0
	 	 EXIT	 
	 ENDIF
	 DBSKIP()
ENDDO

DO WHILE !EOF()
	 ABCTEMP->CURVA:="C"
	 DBSKIP()
ENDDO

DBGOTOP()

DO WHILE !EOF()
	CECCMER->(DBSEEK(ABCTEMP->CODIGO))
	CECCMER->(Lock_Registro(.T.))
	CECCMER->CLAABCM := ABCTEMP->CURVA
	CECCABC->(DBSEEK(ABCTEMP->CODIGO))
	CECCABC->(Lock_Registro(.T.))
	CECCABC->PVENDA:=ABCTEMP->CURVA
	CECCABC->(DBUNLOCK())
	CECCMER->(DBUNLOCK())
	DBSKIP()
ENDDO

ZAP

RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
DBCLOSEALL()
RETURN