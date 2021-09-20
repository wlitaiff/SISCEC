// Sistemas de Controle de Estoque Comercial
// W&R Informatica Ltda
// 23 de Outubro de 1995
// Roberto Falcao Rocha
// Cadastro de fornecedores

LOCAL cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
		cCor := SETCOLOR(),;
		nCursor := SETCURSOR(0),;
		aDad := {"CODIGOF","NOMECLF","APELIDO","CONTATO","ENDEREF","BAIRRO","CIDADEF",;
					"ESTADOF","CEPCLIF","TELEFOF","FAXCLIF",;
					"CGCCPFF","INSESTF","INSCSUF","CBANCOF",;
					"AGENCIF","CONTACF"},;
		aCab := {"Codigo do fornecedor","Nome","Apelido","Contato","Endere‡o","Bairro","Cidade","UF",;
					"CEP","Telefone/Celular","Fax","CGC","Inscri‡Æo estadual","Inscricao na Suframa",;
					"Banco","Agˆncia","No. da conta"},;
		aPic := {"99999","@!","@!","@!","@!","@!","@!","@!","@R 99999-999","@!","@!",;
					"@R 99.999.999/9999-99","@!","@!","@!","@!","@!"}

// Verificando arquivos
IF !ARQNTX("CECCSET",.F.) .OR. ;
   !ARQNTX("CECCFOR",.F.) 
 	DBCLOSEALL()
	RETURN
ENDIF	

HBrowseDB( 1,0,24,79,"Cadastro de fornecedores",aCab,aDad,aPic,NIL,,,;
			  {"NOMECLF","ENDEREF","CIDADEF","ESTADOF","CEPCLIF","TELEFOF",;
			   "FAXCLIF","INSCSUF","APELIDO","CONTATO","CGCCPFF","INSESTF","CBANCOF","AGENCIF","BAIRRO",;
				"CONTACF"})
DBCLOSEAll()
RETURN

FUNCTION CFornecedor( oBrowse )
	LOCAL cCor := SETCOR(m->cEdicao),;
			nCursor := SETCURSOR(1),;
			cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
			nReg  := RECNO(),;
			RegAtual := 0 ,;
			UltRegistro := 0,;
			nCodigoF := CECCSET->ULTNUMFORN ,;
			cApelido := SPACE(30),;
			cContato := SPACE(30),;
			cSuframa := SPACE(20),;
			cNomeclF:=SPACE(60),;
			cEndereF:=SPACE(60),;
			cBairro := SPACE(30),;
			cCidadeF:=SPACE(40),;
			cEstadoF:=SPACE(2),;
			cCepCliF:=SPACE(8),;
			cTelefoF:=SPACE(60),;
			cFaxCliF:=SPACE(40),;
			cTelexxF:=SPACE(20),;
			cCGCCPFF:=SPACE(14),;
			cInsEstF:=SPACE(20),;
			cCBancoF:=SPACE(15),;
			cAgenciF:=SPACE(10),;
			cContaCF:=SPACE(10),;
			GetList:={}
			
	DO WHILE .T.			
		BOX(05,03,21,75,M->FR,127,3,8)
		nCodigoF++
		@ 06,04 SAY "C¢digo do fornecedor..:";
				  GET nCodigoF;
				  PICTURE "@K@R@E 99,999";
				  VALID !EMPTY(nCodigoF) .AND.;
				  !Existe(nCodigoF,"Fornecedor j  cadastrado",.T.) 
			  
		@ 07,04 SAY "Nome..................:";
				  GET cNomeClF;
				  PICTURE "@K@!@s40";
				  VALID !EMPTY(cNomeClF)
			  
		@ 08,04 SAY "Endere‡o..............:";
				  GET cEndereF;
				  PICTURE "@K@!@s40"
				  
		@ 09,04 SAY "Bairro.:";
				  GET cBairro;
				  PICTURE "@K@!@s20"
				  
		@ 09,45 SAY "Cidade.:";
				  GET cCidadeF;
				  PICTURE "@K@!@S15"		  
			  
		@ 10,04 SAY "Estado................:";
				  GET cEstadoF;
				  PICTURE "@K@!"
			  
		@ 11,04 SAY "CEP...................:";
				  GET cCEPCliF;
				  PICTURE "@K@R 99999-999"
			  
		@ 12,04 SAY "Telefone/Celular.:";			  
				  GET cTelefoF;
				  PICTURE "@K@!@S50"
				  
		@ 13,04 SAY "Fax...................:";			
				  GET cFaxCliF;
				  PICTURE "@K@!"
		
		@ 14,04 SAY "Inscricao na Suframa..:";			
				  GET cSuframa;
				  PICTURE "@!"		  		  
				  
		@ 15,04 SAY "CGC...................:";			
				  GET cCGCCPFF;
				  PICTURE "@K@R 99.999.999/9999-99"
				  
		@ 16,04 SAY "Inscri‡Æo Estadual....:";			
				  GET cInsEstF;
				  PICTURE "@K@!"		  
				  
		@ 17,04 SAY "Banco.................:";			
				  GET cCBancoF;
				  PICTURE "@K@!"		  
				  
		@ 18,04 SAY "Agˆncia...............:";			
				  GET cAgenciF;
				  PICTURE "@K@!"		  
				  
		@ 19,04 SAY "Conta corrente........:";			
				  GET cContaCF;
				  PICTURE "@K@!"		  		  		  		  		  		  
				  
		@ 20,04 SAY "Apelido:";			
				  GET cApelido;
				  PICTURE "@K@!"		  		  		  		  		  		  
				  
		@ 20,45 SAY "Contato:";			
				  GET cContato;
				  PICTURE "@K@!@S20"		  		  		  		  		  		  		  		  		  
			  
		READ	
		
		IF LASTKEY()==27
			SETCURSOR(nCursor)
			SETCOLOR(cCor)
			RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
			DBGOTO(nReg)
			oBrowse:refreshAll()
			RETURN(NIL)
		ENDIF	
			
		IF Confirma("Confirma a inclusao deste fornecedor",23)
			IF Inclui_Registro(.T.)
				Lock_Registro(.T.)
				CECCFOR->INSCSUF := cSuframa
				CECCFOR->APELIDO := cApelido
				CECCFOR->CONTATO := cContato
				CECCFOR->NOMECLF := cNomeclF
				CECCFOR->CODIGOF := nCodigoF
				CECCFOR->NOMECLF := cNomeclF
				CECCFOR->ENDEREF := cEndereF
				CECCFOR->CIDADEF := cCidadeF
				CECCFOR->ESTADOF := cEstadoF
				CECCFOR->BAIRRO  := cBairro
				CECCFOR->CEPCLIF := cCepCliF
				CECCFOR->TELEFOF := cTelefoF
				CECCFOR->FAXCLIF := cFaxCliF
				CECCFOR->CGCCPFF := cCGCCPFF
				CECCFOR->INSESTF := cInsEstF
				CECCFOR->CBANCOF := cCBancoF
				CECCFOR->AGENCIF := cAgenciF
				CECCFOR->CONTACF := cContaCF
				DBUNLOCK()
				DBCOMMIT()
				RegAtual :=Recno()
				DBGOBOTTOM()
				UltRegistro:=CECCFOR->CODIGOF
				DBGOTO(RegAtual)
 				// Atualizar ultimo numero do fornecedor
				IF UltRegistro > CECCSET->ULTNUMFORN
					CECCSET->( Lock_Registro(.T.) )
					CECCSET->ULTNUMFORN:=nCodigoF
					CECCSET->(DBUNLOCK())
					CECCSET->(DBCOMMIT())
				Else
					nCodigoF:=CECCSET->ULTNUMFORN
				EndIf
				//
			ENDIF	
		ENDIF
	ENDDO
RETURN(NIL)	
	
FUNCTION PFornecedor(oBrowse)				
	LOCAL cCor := SETCOR(m->cEdicao),;
			nCursor := SETCURSOR(1),;
			cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
			nReg := RECNO(),;
			Getlist:={},;
			lAchou,;
			nCodigoF:=0,;
			cNomeClF:=SPACE(40)
	
	DISPBOX(05,03,08,75,M->FR)
	@ 06,04 SAY "C¢digo do fornecedor..:";
			  GET nCodigoF;
			  PICTURE "@K@R@E 99,999"
			  
	@ 07,04 SAY "Nome..................:";
			  GET cNomeclF;
			  PICTURE "@K@!";
			  VALID PVerifica({nCodigoF,cNomeclF})		  
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
		CASE !EMPTY(nCodigoF)	  
			CECCFOR->(DBSETORDER(1))
			lAchou := Existe(nCodigoF,"Fornecedor nÆo cadastrado",.F.) 				
		CASE !EMPTY(cNomeclF)	  
			CECCFOR->(DBSETORDER(2))
	   	lAchou := Existe(cNomeclF,"Fornecedor nÆo cadastrado",.F.,,2,,,,,.T.) 			
	ENDCASE		
		
	IF !lAchou
		DBGOTO(nReg)
	ENDIF
		
	oBrowse:refreshAll()
RETURN(NIL)

FUNCTION ZFornecedor( oBrowse )
	LOCAL cCor := SETCOR(m->cEdicao),;
			nCursor := SETCURSOR(1),;
			cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
			nInd := INDEXORD()
	Lock_Registro(.T.)		
	BOX(05,03,18,75,M->FR,127,3,8)
	@ 06,04 SAY "CODIGO.........:"+STR(CECCFOR->CODIGOF,5) 
	@ 07,04 SAY "NOME...........:" GET CECCFOR->NOMECLF PICTURE "@!@S40"
	@ 08,04 SAY "ENDERECO.......:" GET CECCFOR->ENDEREF PICTURE "@!@S40"
	@ 09,04 SAY "BAIRRO.........:" GET CECCFOR->BAIRRO  PICTURE "@!"
	@ 10,04 SAY "CIDADE.........:" GET CECCFOR->CIDADEF PICTURE "@!"
	@ 11,04 SAY "ESTADO.........:" GET CECCFOR->ESTADOF PICTURE "@!"
	@ 12,04 SAY "CEP............:" GET CECCFOR->CEPCLIF PICTURE "@R 99999-999"
	@ 13,04 SAY "TELEFONE.......:" GET CECCFOR->TELEFOF PICTURE "@!@S40"
	@ 14,04 SAY "FAX............:" GET CECCFOR->FAXCLIF PICTURE "@!" 
	@ 15,04 SAY "CGC............:" GET CECCFOR->CGCCPFF PICTURE "@R 99.999.999/9999-99"
   @ 16,04 SAY "INSCRICAO ESTAD:" GET CECCFOR->INSESTF PICTURE "@!"
   @ 17,04 SAY "CONTATO........:" GET CECCFOR->CONTATO PICTURE "@!"
	READ
	RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
	SETCURSOR(nCursor)
	SETCOLOR(cCor)
	oBrowse:refreshAll()
	DBSETORDER(nInd)
RETURN(NIL)	