// Sistemas de Controle de Estoque Comercial
// W&R Informatica Ltda
// 19 de Outubro de 1995
// Roberto Falcao Rocha
// Cadastro de mercadorias / lojas

LOCAL cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
		cCor := SETCOLOR(),;
		nCursor := SETCURSOR(0),;
		aDad := {"CODILOJ","MERCLOJ","SALDOEJ","DTUCLOJ","DCUCLOJ",;
					"DTUVLOJ","DCUVLOJ"},;
		aCab := {"Loja","Mercadoria","Saldo","Èltima compra","Doc. ultima compra","Èltima venda","Doc. ultima venda"}
		aPic := {"9999","@!","@R@E 9,999,999.999","@D","@!","@D","@!"}

// Verificando arquivos
IF !ARQNTX("CECCMER",.F.) .OR. ;
	!ARQNTX("CECTLOJ",.F.) .OR. ;
	!ARQNTX("CECCLOJ",.F.) 
	DBCLOSEALL()
	RETURN
ENDIF	

HBrowseDB( 1,0,24,79,"Saldo de estoque por loja",aCab,aDad,aPic,NIL,,,.F.)
DBCLOSEAll()
RETURN

FUNCTION PLoja(oBrowse)				
	LOCAL cCor := SETCOR(m->cEdicao),;
			nCursor := SETCURSOR(1),;
			cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
			nReg := RECNO(),;
			Getlist:={},;
			lAchou,;
			nCodiLoj:=0,;
			cMercLoj:=SPACE(16)
	
	DISPBOX(05,03,08,75,M->FR)
	@ 06,04 SAY "C¢digo da loja..:";
			  GET nCodiLoj;
			  PICTURE "@K@R@E 9,999"
			  
	@ 07,04 SAY "Mercadoria......:";
			  GET cMercLoj;
			  PICTURE "@K@!";
			  VALID Existe(STR(nCodiLoj,4)+cMercLoj,"Mercadoria n∆o cadastrada",.F.) 
			  
	READ		  
	
	SETCURSOR(nCursor)
	SETCOLOR(cCor)
	RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)	
	
	IF LASTKEY()==27
		DBGOTO(nReg)
	ENDIF	
	
	oBrowse:refreshAll()
RETURN(NIL)
			