// Sistemas de Controle de Estoque Comercial - Modulo de Livro Fiscal
// W&R Informatica Ltda
// 21 de Agosto de 1996
// Waldemir Litaiff Vasconcelos
// Manuten‡Æo do Cadastro Fiscal - ( CecCfis )

LOCAL cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
		cCor := SETCOLOR(),;
		nCursor := SETCURSOR(0),;
		aDad := {"NNOTA","SERIE","SUBSER","DEMI","DENT","DSAI",;
					"CFO","VLNOT","BASICMS","ALIICMS","VLICMS","ICMSFONTE","CLI_FOR","CODTRI","ALIDICMS",;
					"VLDICMS","BASIPI","VLIPI","CANCELADA"},;
		aCab := {"Num.Nota","Serie","SubSer","Dt.EmissÆo",;
					"Dt.Entrada","Dt.Saida","Cod.Fiscal","Valor da Nota",;
					"Base Cal. ICMS","Aliq.ICMS","Vl. do ICMS","Icms na fonte","Cliente/Fornecedor","Codigo Tributario","Aliq.Desc.IMCS","Vl.Desc.ICMS",;
					"Base Cal. IPI","Valor IPI","Cancelada"},;
		aPic := {"@!","!","99","@d","@d","@d",;
					"@!","@E@R 99,999,999.99","@E@R 99,999,999.99","@E@R 999.99","@E@R 99,999,999.99","@E@R 999,999.99",;
					"99999999","9","@R@E 999,999.99","@R@E 99,999,999.99","@E@R 999,999.99","@e@r 999,999.99","@L"}
PUBLIC nOrdem
// Verificando arquivos
IF !ARQNTX("CECCFIS",.F.) .OR.;
	!ARQNTX("CECCSET",.F.) .OR.;
	!ARQNTX("CECCCLI",.F.) .OR.; 
	!ARQNTX("CECCFOR",.F.) 
	DBCLOSEALL()
	RETURN
ENDIF	


SELECT("CECCFIS")

nOrdem := Alert("Escolha a ordem desejada",{"Livro de Saida","Livro de Entrada","Apuracao","Geral"})
DO CASE
	CASE nOrdem==1
		DBSETORDER(4)
		nOrdem := 4
	CASE nOrdem==2
		DBSETORDER(3)
		nOrdem := 3
	CASE nOrdem==3
		DBSETORDER(5)
		nOrdem := 5
	CASE nOrdem==4
		DBSETORDER(1)
		nOrdem := 4
ENDCASE					

HBrowseDB( 1,0,24,79,"Manuten‡Æo do Cadastro de Livros fiscais",aCab,aDad,aPic,NIL,,,;
			  {"CLI_FOR","DEMI","DENT","DSAI","CFO","CODTRI","VLNOT",;
			  "BASICMS","ALIICMS","VLICMS","ALIDICMS","VLDICMS","BASIPI","VLIPI","ICMSFONTE","CANCELADA","NNOTA","SERIE","SUBSER"})
			  
DBCLOSEAll()
RETURN

FUNCTION Cad_Livro( oBrowse )
	LOCAL cCor := SETCOR(m->cEdicao),;
			nCursor := SETCURSOR(1),;
			cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
			nReg := RECNO()
			//
	LOCAL	nLancamento:=0,;
			cNnota     :=space(10),;
			cSerie     :=" ",;
			nSubser    :=0,;
			nCliente   :=0,;
			nFornecedor:=0,;
			dDemi:=dDent:=dDsai:=ctod("  /  /  "),;
			cCfo     :=space(5),;
			nCodtri  :=1,;
			nVlnot   :=0,;
			nFonte   :=0,;
			nBasicms :=0,;
			nAliicms :=0,;
			nVlicms  :=0,;
			nAlidicms:=0,;
			nVldicms :=0,;
			nBasipi  :=0,;
			nVlipi   :=0,;
			GetList  :={}
			
	DO WHILE .T.			
		BOX(05,03,16,75,M->FR,127,3,8)
		@ 06,04 SAY "Num.Nota..: XXXXXXXXXX S‚rie.: X SubS‚rie.: 0 "
		@ 06,16 GET cNnota;
				  PICTURE "@!";
				  VALID !EMPTY(cNnota) .AND. ShowZeros(@cNnota)
		@ 06,35 GET cSerie;
				  PICTURE "@!"
				  
		@ 06,48 GET nSubSer;
				  PICTURE "99";	
				  Valid !Existe( (cNnota+cSerie+str(nSubSer,2) ),"Documento j  Existe",.T.,,1)
				 
		@ 07,04 SAY "Fornecedor(Se Entrada):";
				  GET nFornecedor;
				  PICTURE "99999";
				  VALID If(!empty(nFornecedor),Existe(nFornecedor,"Fornecedor nÆo cadastrado",.F.,"CECCFOR",1,"NOMECLF","@!",ROW(),COL()+1),.T.)
		
		@ 08,04 SAY "Cliente (Se Saida)....:";
				  GET nCliente;
				  PICTURE "99999";
				  VALID ;
				  Existe(nCliente,"Cliente n„o cadastrado",.F.,"CECCCLI",1,"NOMECLC","@!",ROW(),COL()+1) when nFornecedor==0
				  
		@ 09,04 SAY "Dt.EmissÆo.:            Dt.Entrada.:            Dt.Saida.:"
		@ 09,17 GET dDemi;
				  PICTURE "@K@D"
	
		@ 09,41 GET dDent;
				  PICTURE "@K@D";
				  When !EMPTY(nFornecedor)
				  
		@ 10,62 GET dDsai;
				  PICTURE "@K@D";
				  WHEN !EMPTY(nCliente)
			  
		@ 11,04 SAY "C.F.O.:" GET cCfo;
				  PICTURE "@!";
				  
		@ 11,20 SAY "Tipo (1=Normal,5=Outros creditos,6=Outro debitos):" get nCodtri picture "99"		  
		
		@ 12,04 SAY "Valor Cont bil........:";
				  GET nVlNot;
				  PICTURE "@K@R@E 999,999,999.99";
				  Valid !Empty(nVlNot)
				  		
		@ 13,04 SAY "Base de C lculo ICMS..:";
				  GET nBasIcms;
				  PICTURE "@K@R@E 999,999,999.99";
				  
		@ 14,04 SAY "Al¡quota de ICMS......:";
				  GET nAliIcms;
				  PICTURE "@K@R@E 999,999,999.99";
		
		@ 15,04 SAY "ICMS na fonte........:";
				  GET nFonte;
				  PICTURE "@K@R@E 999,999,999.99"
				  
		READ	
		
		IF LASTKEY()==27
			SETCURSOR(nCursor)
			SETCOLOR(cCor)
			RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
			DBSETORDER(nOrdem)
			DBGOTO(nReg)
			oBrowse:refreshAll()
			RETURN(NIL)
		ENDIF	
			
		IF Confirma("Confirma a inclusÆo deste Documento",23)
			IF Inclui_Registro(.T.)
				Lock_Registro(.T.)
				//
				CECCFIS->Nnota  := cNnota
			   CECCFIS->Serie  := cSerie
			   CECCFIS->SubSer := nSubser
			   CECCFIS->Cli_for:= IF(nCliente==0,nFornecedor,nCliente)
			   CECCFIS->Demi   := dDemi
				CECCFIS->Dent   := dDent
				CECCFIS->Dsai   := dDsai
				IF !EMPTY(dDent)
					CECCFIS->DATAS  := dDent
				ELSE
					CECCFIS->DATAS  := dDsai
				ENDIF		
			   CECCFIS->CFO    := cCfo
				CECCFIS->Codtri := nCodtri
				CECCFIS->Vlnot  := nVlNot
				CECCFIS->BasIcms:= nBasIcms
				CECCFIS->AliIcms:= nAliicms
				CECCFIS->Vlicms := Round(nBasIcms * (nAliIcms/100),2)
				CECCFIS->Alidicms:=0
				CECCFIS->Vldicms :=0
				CECCFIS->Basipi  :=nBasIcms
				CECCFIS->Vlipi   :=0
				CECCFIS->ICMSFONTE := nFonte
				//
				DBUNLOCK()
				DBCOMMIT()
			ENDIF	
		ENDIF
	ENDDO
RETURN(NIL)	

FUNCTION PesqNotas(oBrowse)
	LOCAL cCor := SETCOR(m->cEdicao),;
			nCursor := SETCURSOR(1),;
			cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
			nReg := RECNO(),;
			Getlist:={},;
			lAchou,;
			cNotas:=SPACE(10),;
			cSerie:=SPACE(1),;
			dData := CTOD("  /  /  "),;
			nSubSerie:=0
	
	DISPBOX(05,03,10,75,M->FR)
	@ 06,04 SAY "No. da nota.:";
			  GET cNotas;
			  PICTURE "@K@!";
			  VALID ShowZeros(@cNotas)
			  
	@ 07,04 SAY "Serie.......:";
			  GET cSerie;
			  PICTURE "@K@!"
			  
	@ 08,04 SAY "Sub-serie...:";
			  GET nSubSerie;
			  PICTURE "@K 99"
			  
	@ 09,04 SAY "Data...:";
			  GET dData;
			  PICTURE "@D"
	READ		  
		
	SETCURSOR(nCursor)
	SETCOLOR(cCor)
	RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)	
	
	IF LASTKEY()==27
		DBSETORDER(nOrdem)
		DBGOTO(nReg)
		oBrowse:refreshAll()
		RETURN(NIL)
	ENDIF	
	
  	lAchou := Existe(cNotas+cSerie+STR(nSubSerie,2)+DTOS(dData),"Nota n„o cadastrada",.F.,,1,,,,,.T.) 			
		
	IF !lAchou
		DBGOTO(nReg)
	ENDIF
		
	oBrowse:refreshAll()
RETURN(NIL)