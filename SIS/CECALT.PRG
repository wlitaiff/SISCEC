// Sistemas de Controle de Estoque Comercial
// W&R Informatica Ltda
// 19 de Outubro de 1995
// Roberto Falcao Rocha
// Cadastro de mercadorias

LOCAL cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
		cCor := SETCOLOR(),;
		nCursor := SETCURSOR(0),;
		nTclass := 0,;
		cTaClas := {"C¢digo","Referˆncia","Descri‡„o","Cancela"},;
		aDad := {"FORNECM","CODIGOM","DESCRIM","REFEREM","UNIDADE","CODLINM",;
					"CODDIVM","ORIGEMM","CLAABCM",;
					"ESTMINM","MARLUCM","PRECVEM","DTULTVM","DCULTVM",;
					"PRECCOM","DTULTCM","DCULTCM","SALDOEM","ULTPRPM",;
					"DTUALTPRM","CMEDM","CFOBM","CCIFM","CSTAM"},;
		aCab := {"Fornecedor","Material","Descri‡„o","Referencia","Unidade","Linha","Divis„o",;
					"Origem","Classe ABC","Estoque m¡nimo",;
					"Margem de lucro","Preco de venda","éltima venda","Documento Ultima Venda",;
					"Pre‡o de compra","éltima compra","Documento ultima compra","Saldo de estoque",;
					"Ultimo pre‡o","Data do reajuste","Custo m‚dio",;
					"Custo FOB","Custo CIF","Custo padrÆo"},;
		aPic := {"99999","@!","@!","@!","@!","@R@E 99,999","@R@E 99,999","!","!","@R@E 999,999,999",;
					"@R@E 999.999","@E@R 99,999,999.99","@D","@!","@E@R 99,999,999.99",;
					"@D","@!","@R@E 9,999,999.999","@R@E 99,999,999.99","@D","@E@R 9,999,999.999",;
					"@E@R 9,999,999.999","@E@R 9,999,999.999","@E@R 9,999,999.999"}
cEdicao:="B/W,W+/Bg,,,B/W"
	cError1:="BG/B"
	cError2:="W+/B"
	cError3:="R+/B"
	cError4:="N/BG"
	cBTITULO :=   "W+/B"
	cBMOVER  :=   "W+/B"
	cBDADOS  :=   "N/BG,W+/N"
	cBSTATUS :=   "W+/N"
	cBFUNCOES :=  "GR+/B"
	cBTECLAS :=   "W+/B"
	cBRODAPE :=   "N+/W"
	cBCERCADURA:= "N+/BG"
	cBDELETADO:=  "W+/R,W+/N"
	cbMBROWSE:=   "W+/W"
	cBMVBROWSE:=  "W+*/W"
	cJanTitu:="W/B"
	cJan    := "W+/Bg"
	CQUADRO:="N+/BG"
	PTEMPODESC := 60
	FR=""
SET PROC TO WRLIB

SET PROC TO HBROWSE

SET PROC TO CECLIB

// Verificando arquivos
IF !ARQNTX("CECCMER",.F.) .OR. ;
	!ARQNTX("CECTDIV",.F.) .OR. ;
	!ARQNTX("CECCABC",.F.) .OR. ;
	!ARQNTX("CECCSET",.F.) .OR. ;
	!ARQNTX("CECTLIN",.F.) .OR. ;
	!ARQNTX("CECCFOR",.F.) 
	DBCLOSEALL()
	RETURN
ENDIF	

CLEAR SCREEN

SELECT("CECCMER")						

dbsetorder(8)

DBGOTOP()

HBrowseDB( 1,0,24,79,"Cadastro de mercadorias",aCab,aDad,aPic,NIL,,,;
			{"CODIGOM","REFEREM","DESCRIM","UNIDADE","CODLINM","CODDIVM","ORIGEMM","FORNECM",;
			 "MARLUCM","PRECVEM","CLAABCM","ESTMINM","CSTAM"})
DBCLOSEAll()
RETURN

FUNCTION PMercadoria(oBrowse)				
	LOCAL cCor := SETCOR(m->cEdicao),;
			nCursor := SETCURSOR(1),;
			cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
			nReg := RECNO(),;
			Getlist:={},;
			lAchou,;
			cCodigoM:=SPACE(13),;
			cDescriM:=SPACE(40),;
			cRefereM:=SPACE(15)
	
	DISPBOX(05,03,09,75,M->FR)
	@ 06,04 SAY "C¢digo da mercadoria..:";
			  GET cCodigoM;
			  PICTURE "@K@!"
			  
	@ 07,04 SAY "Descri‡„o.............:";
			  GET cDescriM;
			  PICTURE "@K@!"
			  
	@ 08,04 SAY "Referˆncia............:";
			  GET cRefereM;
			  PICTURE "@K@!";
			  VALID PVerifica({cCodigoM,cDescriM,cRefereM})		  
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
		CASE !EMPTY(cCodigoM)	  
			lAchou := Existe(cCodigoM,"Mercadoria n„o cadastrada",.F.,,1) 				
		CASE !EMPTY(cDescriM)	  
	   	lAchou := Existe(cDescriM,"Descri‡„o n„o cadastrada",.F.,,3,,,,,.T.) 			
		CASE !EMPTY(cRefereM)	  
	   	lAchou := Existe(cRefereM,"Referˆncia n„o cadastrada",.F.,,2,,,,,.T.) 				
	ENDCASE		
		
	IF !lAchou
		DBGOTO(nReg)
	ENDIF
		
	oBrowse:refreshAll()
RETURN(NIL)			