// Sistemas de Controle de Estoque Comercial
// W&R Informatica Ltda
// 24 de Outubro de 1995
// Roberto Falcao Rocha
// Cadastro de Grupos

LOCAL cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
		cCor := SETCOLOR(),;
		nCursor := SETCURSOR(0),;
		aDad := {"CODLIN","NOMLIN","PULTREAJ","DATULTREAJ"},;
		aCab := {"C¢digo do Grupo","Descriá∆o","% Èltimo reajuste","Ultimo reajuste"},;
		aPic := {"@R@E 99,999","@!","@R@E 99.9999","@D"}
	
// Verificando arquivos
IF !ARQNTX("CECTLIN",.F.) 
	DBCLOSEALL()
	RETURN
ENDIF	

HBrowseDB( 1,0,24,79,"Tabela de Grupos",aCab,aDad,aPic,NIL,,,;
			{"NOMLIN"})
DBCLOSEAll()
RETURN

FUNCTION CLinha( oBrowse )
	LOCAL cCor := SETCOR(m->cEdicao),;
			nCursor := SETCURSOR(1),;
			cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
			nReg := RECNO(),;
			nCodLin:=0,;
			cNomLin:=SPACE(25),;
			GetList:={}
			
	DO WHILE .T.			
		BOX(05,03,08,75,M->FR,127,3,8)
		@ 06,04 SAY "C¢digo do Grupo..:";
				  GET nCodLin;
				  PICTURE "@K@R@E 99,999";
				  VALID !EMPTY(nCodLin) .AND.;
				  !Existe(nCodLin,"Grupo j† cadastrado",.T.) 
			  
		@ 07,04 SAY "Descriá∆o........:";
				  GET cNomLin;
				  PICTURE "@K@!";
				  VALID !EMPTY(cNomLin)
			  
		READ	
		
		IF LASTKEY()==27
			SETCURSOR(nCursor)
			SETCOLOR(cCor)
			RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
			DBGOTO(nReg)
			oBrowse:refreshAll()
			RETURN(NIL)
		ENDIF	
			
		IF Confirma("Confirma a inclusao deste Grupo",23)
			IF Inclui_Registro(.T.)
				Lock_Registro(.T.)
				CECTLIN->CODLIN := nCodLin
				CECTLIN->NOMLIN := cNomLin
				DBUNLOCK()
				DBCOMMIT()
			ENDIF	
		ENDIF
	ENDDO
RETURN(NIL)	
	
FUNCTION PLinha(oBrowse)				
	LOCAL cCor := SETCOR(m->cEdicao),;
			nCursor := SETCURSOR(1),;
			cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
			nReg := RECNO(),;
			Getlist:={},;
			lAchou,;
			nCodLin:=0,;
			cNomLin:=SPACE(25)
	
	DISPBOX(05,03,08,75,M->FR)
	@ 06,04 SAY "C¢digo do Grupo..:";
			  GET nCodLin;
			  PICTURE "@K@R@E 99,999"
			  
	@ 07,04 SAY "Descriá∆o........:";
			  GET cNomLin;
			  PICTURE "@K@!";
			  VALID PVerifica({nCodLin,cNomLin})		  
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
		CASE !EMPTY(nCodLin)	  
			lAchou := Existe(nCodLin,"Grupo n∆o cadastrado",.F.) 				
		CASE !EMPTY(cNomLin)	  
	   	lAchou := Existe(cNomLin,"Grupo n∆o cadastrado",.F.,,2,,,,,.T.) 			
	ENDCASE		
		
	IF !lAchou
		DBGOTO(nReg)
	ENDIF
		
	oBrowse:refreshAll()
RETURN(NIL)