// Sistemas de Controle de Estoque Comercial
// W&R Informatica Ltda
// 24 de Outubro de 1995
// Roberto Falcao Rocha
// Cadastro de Lojas/Vendas

LOCAL cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
		cCor := SETCOLOR(),;
		nCursor := SETCURSOR(0),;
		aDad := {"CODLOJTL","NOMLOJTL","TOTVENTL","VENM01TL","VENM02TL","VENM03TL",;
					"VENM04TL","VENM05TL","VENM06TL","VENM07TL","VENM08TL","VENM09TL",;
					"VENM10TL","VENM11TL","VENM12TL","GERENTTL","PCOMGETL","COMIGETL","METVENTL"},;
		aCab := {"C¢digo da loja","Nome","Total de vendas","Janeiro","Fevereiro",;
					"Maráo","Abril","Maio","Junho","Julho","Agosto","Setembro","Outubro",;
					"Novembro","Dezembro","Gerente","% Comiss∆o p/ gerente","Comiss∆o","Meta de vendas"},;
		aPic := {"9999","@!","@R@E 99,999,999.99","@R@E 99,999,999.99","@R@E 99,999,999.99",;
					"@R@E 99,999,999.99","@R@E 99,999,999.99","@R@E 99,999,999.99",;
					"@R@E 99,999,999.99","@R@E 99,999,999.99","@R@E 99,999,999.99",;
					"@R@E 99,999,999.99","@R@E 99,999,999.99","@R@E 99,999,999.99",;
					"@R@E 99,999,999.99","@!","@R@E 999.999","@E@R 99,999,999.99","@E@R 99,999,999.99"}

// Verificando arquivos
IF !ARQNTX("CECTLOJ",.F.)
	DBCLOSEALL()
	RETURN
ENDIF	

HBrowseDB( 1,0,24,79,"Cadastro de Lojas/Vendas",aCab,aDad,aPic,NIL,,,;
			 {"NOMLOJTL","GERENTTL","PCOMGETL","METVENTL"})
DBCLOSEAll()
RETURN

FUNCTION CTLoja( oBrowse )
	LOCAL cCor := SETCOR(m->cEdicao),;
			nCursor := SETCURSOR(1),;
			cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
			nReg := RECNO(),;
			nCodLojTL:=0,;
			cNomLojTL:=SPACE(30),;
			cGerentTL:=SPACE(30),;
			nPcomGeTL:=0,;
			GetList:={}
			
	DO WHILE .T.			
		BOX(05,03,10,75,M->FR,127,3,8)
		@ 06,04 SAY "C¢digo da loja....:";
				  GET nCodLojTL;
				  PICTURE "@K@E@R 99,999";
				  VALID !EMPTY(nCodLojTL) .AND.;
				  !Existe(nCodLojTL,"Loja ja cadastrada",.T.)
			  
		@ 07,04 SAY "Nome..............:";
				  GET cNomLojTL;
				  PICTURE "@K@!";
				  VALID !EMPTY(cNomLojTL)
				  
		@ 08,04 SAY "Gerente...........:";
				  GET cGerentTL;
				  PICTURE "@K@!";
				  VALID !EMPTY(cGerentTL)
				  
		@ 09,04 SAY "% Comiss∆o/Gerente:";
				  GET nPComGeTL;
				  PICTURE "@K@R@E 999.999"
				  
		READ	
		
		IF LASTKEY()==27
			SETCURSOR(nCursor)
			SETCOLOR(cCor)
			RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
			DBGOTO(nReg)
			oBrowse:refreshAll()
			RETURN(NIL)
		ENDIF	
			
		IF Confirma("Confirma a inclusao desta loja",23)
			IF Inclui_Registro(.T.)
				Lock_Registro(.T.)
				CECTLOJ->CODLOJTL := nCodLojTL
				CECTLOJ->NOMLOJTL := cNomLojTL
				CECTLOJ->GERENTTL := cGerentTL
				CECTLOJ->PCOMGETL := nPComGETL
				DBUNLOCK()
				DBCOMMIT()
			ENDIF	
		ENDIF
	ENDDO
RETURN(NIL)	
	
FUNCTION PTLoja(oBrowse)				
	LOCAL cCor := SETCOR(m->cEdicao),;
			nCursor := SETCURSOR(1),;
			cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
			nReg := RECNO(),;
			Getlist:={},;
			lAchou,;
			nCodLojTL:=0,;
			cNomLojTL:=SPACE(30)
	
	DISPBOX(05,03,08,75,M->FR)
	@ 06,04 SAY "C¢digo da loja..:";
			  GET nCodLojTL;
			  PICTURE "@K@R@E 9,999"
			  
	@ 07,04 SAY "Nome............:";
			  GET cNomLojTL;
			  PICTURE "@K@!";
			  VALID Pverifica({nCodLojTL,cNomLojTL})
			  
	READ		  
	
	SETCURSOR(nCursor)
	SETCOLOR(cCor)
	RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)	
	
	IF LASTKEY()==27
		DBGOTO(nReg)
		oBrowse:refreshAll()
		RETURN(NIL)
	ENDIF	
	
	DO CASE
		CASE !EMPTY(nCodLojTL)	  
			lAchou := Existe(nCodLojTL,"Loja n∆o cadastrada",.F.) 				
		CASE !EMPTY(cNomLojTL)	  
	   	lAchou := Existe(cNomLojTL,"Loja n∆o cadastrada",.F.,,2,,,,,.T.) 			
	ENDCASE		
		
	IF !lAchou
		DBGOTO(nReg)
	ENDIF
	
	oBrowse:refreshAll()
RETURN(NIL)
			