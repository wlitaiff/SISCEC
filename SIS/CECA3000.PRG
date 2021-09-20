// Sistemas de Controle de Estoque Comercial
// W&R Informatica Ltda
// 24 de Outubro de 1995
// Roberto Falcao Rocha
// Cadastro de vendedores

LOCAL cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
		cCor := SETCOLOR(),;
		nCursor := SETCURSOR(0),;
		aDad := {"CODVEN","CODLOJ","NOMVEN","PCONIS",;
					"VENMES","VENMIM","COMMES","TOTVEN",;
					"TOTCOM","SNDESC","MAXDES","DTENTRA","DTSAIDA"},;
		aCab := {"Codigo do vendedor","Loja","Nome","% Comiss∆o","Vendas no màs",;
					"Vendas m°nimas","Comiss∆o do màs","Total de vendas","Total de comiss∆o",;
					"Desconto","% Desconto m†ximo","Entrada","Saida"},;
		aPic := {"@E@R 99,999","@R@E 9,999","@!","@R@E 999.999","@E@R 99,999,999.99",;
					"@R@E 99,999,999.99","@E@R 99,999,999.99","@E@R 99,999,999.99",;
					"@R@E 99,999,999.99","!","@E@R 999.999","@d","@d"}

// Verificando arquivos
IF !ARQNTX("CECTLOJ",.F.) .OR.;
	!ARQNTX("CECCVEN",.F.)
	DBCLOSEALL()
	RETURN
ENDIF	

HBrowseDB( 1,0,24,79,"Cadastro de vendedores",aCab,aDad,aPic,NIL,,,;
			  {"NOMVEN","PCONIS","VENMIM","SNDESC","MAXDES","DTENTRA","DTSAIDA"})
DBCLOSEAll()
RETURN

FUNCTION CVendedor( oBrowse )
	LOCAL cCor := SETCOR(m->cEdicao),;
			nCursor := SETCURSOR(1),;
			cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
			nReg := RECNO(),;
			nCodVen:=0,;
			nCodLoj:=0,;
			cNomVen:=SPACE(40),;
			nPConis:=0,;
			nVenMin:=0,;
			cSNDesc:=SPACE(1),;
			nMaxDesc:=0,;
			dEntrada:=CTOD("  /  /    "),;
			GetList:={}
			
	DO WHILE .T.			
		BOX(05,03,14,75,M->FR,127,3,8)
		@ 06,04 SAY "C¢digo do vendedor....:";
				  GET nCodVen;
				  PICTURE "@K@R@E 99,999";
				  VALID !EMPTY(nCodVen) .AND.;
				  !Existe(STR(nCodVen,5),"Vendedor j† cadastrado",.T.) 
			  
		@ 07,04 SAY "Loja..................:";
				  GET nCodLoj;
				  PICTURE "@K@R@E 9,999";
				  VALID !EMPTY(nCodLoj) .AND.;
				  Existe(nCodLoj,"Loja n∆o cadastrada",.F.,"CECTLOJ",,"NOMLOJTL","@!",ROW(),COL()+1)
				  
		@ 08,04 SAY "Nome..................:";
				  GET cNomVen;
				  PICTURE "@K@!";
				  VALID !EMPTY(cNomVen)
			  
		@ 09,04 SAY "% Comiss∆o............:";
				  GET nPconis;
				  PICTURE "@K@R@E 999.999"
				  
		@ 10,04 SAY "Venda m°nima..........:";
				  GET nVenMin;
				  PICTURE "@K@R@E 99,999,999.99"
			  
		@ 11,04 SAY "Autoriza Desconto.....:";
				  GET cSNDesc;
				  PICTURE "@K!";
				  VALID cSNDesc$"SN"
			  
		@ 12,04 SAY "Desconto m†ximo.......:";
				  GET nMaxDesc;
				  PICTURE "@K@R@E 999.999";
				  WHEN cSNDesc=="S"
		
		@ 13,04 SAY "Data da entrada.......:";
				  GET dEntrada;
				  PICTURE "@K@D"
			  
		READ	
		
		IF LASTKEY()==27
			SETCURSOR(nCursor)
			SETCOLOR(cCor)
			RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
			DBGOTO(nReg)
			oBrowse:refreshAll()
			RETURN(NIL)
		ENDIF	
			
		IF Confirma("Confirma a inclusao deste vendedor",23)
			IF Inclui_Registro(.T.)
				Lock_Registro(.T.)
				CECCVEN->CODVEN := nCodVen
				CECCVEN->CODLOJ := nCodLoj
				CECCVEN->NOMVEN := cNomVen
				CECCVEN->VENMIM := nVenMin
				CECCVEN->PCONIS := nPconis
				CECCVEN->SNDESC := cSNDesc
				CECCVEN->MAXDES := nMaxDesc
				CECCVEN->DTENTRA := dEntrada
				DBUNLOCK()
				DBCOMMIT()
			ENDIF	
		ENDIF
	ENDDO
RETURN(NIL)	
	
FUNCTION PVendedor(oBrowse)				
	LOCAL cCor := SETCOR(m->cEdicao),;
			nCursor := SETCURSOR(1),;
			cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
			nReg := RECNO(),;
			Getlist:={},;
			lAchou,;
			nCodVen:=0,;
			cNomVen:=SPACE(40)
	
	DISPBOX(05,03,08,75,M->FR)
	@ 06,04 SAY "C¢digo do vendedor..:";
			  GET nCodVen;
			  PICTURE "@K@R@E 99,999"
			  
	@ 07,04 SAY "Nome................:";
			  GET cNomVen;
			  PICTURE "@K@!";
			  VALID PVerifica({nCodVen,cNomVen})		  
	READ		  
		
	IF LASTKEY()==27
		SETCURSOR(nCursor)
		SETCOLOR(cCor)
		RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
		DBGOTO(nReg)
		oBrowse:refreshAll()
		RETURN(NIL)
	ENDIF	
	
	DO CASE
		CASE !EMPTY(nCodVen)	  
			lAchou := Existe(STR(nCodVen,5),"Vendedor n∆o cadastrado",.F.) 				
		CASE !EMPTY(cNomVen)	  
	   	lAchou := Existe(cNomVen,"Vendedor n∆o cadastrado",.F.,,2,,,,,.T.) 			
	ENDCASE		
		
	IF !lAchou
		DBGOTO(nReg)
	ENDIF
		
	oBrowse:refreshAll()
RETURN(NIL)