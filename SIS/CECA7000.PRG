// Sistemas de Controle de Estoque Comercial
// W&R Informatica Ltda
// 24 de Outubro de 1995
// Roberto Falcao Rocha
// Cadastro de Divis‰es

LOCAL cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
		cCor := SETCOLOR(),;
		nCursor := SETCURSOR(0),;
		aDad := {"CODDIV","NOMDIV","PULTREAJ","DATULTREAJ"},;
		aCab := {"C¢digo da divis∆oa","Descriá∆o","% Èltimo reajuste","Ultimo reajuste"},;
		aPic := {"@R@E 99,999","@!","@R@E 99.9999","@D"}
	
// Verificando arquivos
IF !ARQNTX("CECTDIV",.F.) 
	DBCLOSEALL()
	RETURN
ENDIF	

HBrowseDB( 1,0,24,79,"Tabela de divis‰es",aCab,aDad,aPic,NIL,,,;
			{"NOMDIV"})
DBCLOSEAll()
RETURN

FUNCTION CDivisao( oBrowse )
	LOCAL cCor := SETCOR(m->cEdicao),;
			nCursor := SETCURSOR(1),;
			cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
			nReg := RECNO(),;
			nCodDiv:=0,;
			cNomDiv:=SPACE(25),;
			GetList:={}
			
	DO WHILE .T.			
		BOX(05,03,08,75,M->FR,127,3,8)
		@ 06,04 SAY "C¢digo da Divis∆o..:";
				  GET nCodDiv;
				  PICTURE "@K@R@E 99,999";
				  VALID !EMPTY(nCodDiv) .AND.;
				  !Existe(nCodDiv,"Divis∆o j† cadastrada",.T.) 
			  
		@ 07,04 SAY "Descriá∆o..........:";
				  GET cNomDiv;
				  PICTURE "@K@!";
				  VALID !EMPTY(cNomDiv)
			  
		READ	
		
		IF LASTKEY()==27
			SETCURSOR(nCursor)
			SETCOLOR(cCor)
			RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
			DBGOTO(nReg)
			oBrowse:refreshAll()
			RETURN(NIL)
		ENDIF	
			
		IF Confirma("Confirma a inclusao desta divis∆o",23)
			IF Inclui_Registro(.T.)
				Lock_Registro(.T.)
				CECTDIV->CODDIV := nCodDiv
				CECTDIV->NOMDIV := cNomDiv
				DBUNLOCK()
				DBCOMMIT()
			ENDIF	
		ENDIF
	ENDDO
RETURN(NIL)	
	
FUNCTION PDivisao(oBrowse)				
	LOCAL cCor := SETCOR(m->cEdicao),;
			nCursor := SETCURSOR(1),;
			cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
			nReg := RECNO(),;
			Getlist:={},;
			lAchou,;
			nCodDiv:=0,;
			cNomDiv:=SPACE(25)
	
	DISPBOX(05,03,08,75,M->FR)
	@ 06,04 SAY "C¢digo da divis∆o..:";
			  GET nCodDiv;
			  PICTURE "@K@R@E 99,999"
			  
	@ 07,04 SAY "Descriá∆o..........:";
			  GET cNomDiv;
			  PICTURE "@K@!";
			  VALID PVerifica({nCodDiv,cNomDiv})		  
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
		CASE !EMPTY(nCodDiv)	  
			lAchou := Existe(nCodDiv,"Divis∆o n∆o cadastrada",.F.) 				
		CASE !EMPTY(cNomDiv)	  
	   	lAchou := Existe(cNomDiv,"Divis∆o n∆o cadastrada",.F.,,2,,,,,.T.) 			
	ENDCASE		
		
	IF !lAchou
		DBGOTO(nReg)
	ENDIF
		
	oBrowse:refreshAll()
RETURN(NIL)