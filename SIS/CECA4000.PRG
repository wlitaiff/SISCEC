// Sistemas de Controle de Estoque Comercial
// W&R Informatica Ltda
// 23 de Outubro de 1995
// Roberto Falcao Rocha
// Cadastro de clientes

LOCAL cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
		cCor := SETCOLOR(),;
		nCursor := SETCURSOR(0)
		
		
LOCAL   aDad := {"CODIGOC","STATUS", "NOMECLC", "APELIDO", "CONTATO", "ENDEREC", "BAIRRO","CIDADEC",;
					"ESTADOC", "CEPCLIC", "TELEFOC", "FAXCLIC",;
					"CGCCPFC", "INSESTC", "INSCSUF", "CBANCOC",;
					"AGENCIC", "CONTACC", "ENDEREC1","CIDADEC1",;
                                        "ESTADOC1","CEPCLIC1","TELEFOC1","FAXCLIC1","DESCONTO","DT1COMP","DTUCOMP","OBS"}
					
LOCAL   aCab := {"Cliente","Status" ,"Nome","Apelido","Contato", "Endere‡o","Bairro","Cidade","UF",;
					"CEP","Telefone/Celular","Fax","CGC","Inscri‡Æo estadual","Inscricao na Suframa",;
					"Banco","Agˆncia","No. da conta","Endereco p/ cobran‡a",;
                                        "Cidade","UF","CEP","Telefone","Fax","Desconto padrÆo (%)","1a. Compra","Ultima compra","Observacao"}
					
LOCAL           aPic := {"99999","@!","@!","@!","@!","@!","@!","@!","@!","@R 99999-999","@!","@!",;
					"@R 99.999.999/9999-99","@!","@!","@!","@!","@!","@!","@!","@!",;
                                        "@R 99999-999","@!","@!","99.99","@D","@d","@!"}

// Verificando arquivos
IF 	!ARQNTX("CECCSET",.F.) .OR. ;
	!ARQNTX("CECCCLI",.F.) 
	DBCLOSEALL()
	RETURN
ENDIF	

HBrowseDB( 1,0,24,79,"Cadastro de clientes",aCab,aDad,aPic,NIL,,,;
                          {"STATUS","NOMECLC","ENDEREC","CIDADEC","ESTADOC","CEPCLIC","TELEFOC",;
			   "FAXCLIC","CGCCPFC","INSESTC","CBANCOC","AGENCIC","BAIRRO",;
				"CONTACC","ENDEREC1","CIDADEC1","ESTADOC1","CEPCLIC1","TELEFOC1",;
                                "FAXCLIC1","DT1COMP","CONTATO","APELIDO","INSCSUF","DESCONTO","OBS"} )
DBCLOSEAll()
RETURN

FUNCTION CCliente( oBrowse )
	LOCAL cCor := SETCOR(m->cEdicao),;
			nCursor := SETCURSOR(1),;
			cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
			nReg := RECNO(),;
			RegAtual := 0,;
			UltRegistro := 0,;
			nCodigoC:= CECCSET->ULTNUMCLIE ,;
                        cStatus:=SPACE(1),;
			cNomeclC:=SPACE(60),;
			cApelido := SPACE(30),;
			cContato := SPACE(30),;
			cSuframa := SPACE(20),;
			cEndereC:=SPACE(60),;
			cCidadeC:=SPACE(40),;
			cCelular:=SPACE(40),;
			cEstadoC:=SPACE(2),;
			cCepCliC:=SPACE(8),;
			cTelefoC:=SPACE(60),;
			cFaxCliC:=SPACE(40),;
			cCGCCPFC:=SPACE(14),;
			cEndereC1:=SPACE(60),;
			cBairro := SPACE(30),;
			cCidadeC1:=SPACE(40),;
			cEstadoC1:=SPACE(2),;
			cCepCliC1:=SPACE(8),;
			cTelefoC1:=SPACE(40),;
			nDesconto := 0,;
			cFaxCliC1:=SPACE(40),;
			dDt1Comp :=DATE(),;
			cInsEstC:=SPACE(20),;
			cCBancoC:=SPACE(15),;
			cAgenciC:=SPACE(10),;
                        cObs    :=SPACE(50),;
			cContaCC:=SPACE(10),;
			GetList:={}
			
	DO WHILE .T.			
		BOX(03,03,21,75,M->FR,127,3,8)
		nCodigoC ++
		@ 04,04 SAY "C¢digo do cliente.....:";
				  GET nCodigoC;
				  PICTURE "@K@R@E 99,999";
				  VALID !EMPTY(nCodigoC) .AND.;
				  !Existe(nCodigoC,"Cliente j  cadastrado",.T.)


                @ 04,40 SAY "Status (N/A/B)..:";
                                  GET cStatus;
                                  PICTURE "@!";
                                  VALID !EMPTY(cStatus) .AND. (cStatus$"NAB")
                                   

		@ 05,04 SAY "Nome..................:";
				  GET cNomeClC;
				  PICTURE "@K@!@s40";
				  VALID !EMPTY(cNomeClC)
			  
		@ 06,04 SAY "Endere‡o..............:";
				  GET cEndereC;
				  PICTURE "@K@!@s40"
				  
		@ 07,04 SAY "Bairro.:";
				  GET cBairro;
				  PICTURE "@K@!@s20"
		
		@ 07,45 SAY "Cidade.:";
				  GET cCidadeC;
				  PICTURE "@K@!@s15"		  
			  
		@ 08,04 SAY "Estado................:";
				  GET cEstadoC;
				  PICTURE "@K@!"
			  
		@ 09,04 SAY "CEP...................:";
				  GET cCEPCliC;
				  PICTURE "@K@R 99999-999"
			  
		@ 10,04 SAY "Telefone/Celular:";			  
				  GET cTelefoC;
				  PICTURE "@K@!@S20"
				  
		@ 10,45 SAY "Fax:";			
				  GET cFaxCliC;
				  PICTURE "@K@!@S20" 
				  
		@ 11,04 SAY "CGC..:";			
				  GET cCGCCPFC;
				  PICTURE "@K@R 99.999.999/9999-99"
				  
		@ 11,31 SAY "Insc.Estad.:";			
				  GET cInsEstC;
				  PICTURE "@K@!"	
				  
		@ 12,04 SAY "Inscricao na Suframa..:";			
				  GET cSuframa;
				  PICTURE "@!@S10"		  		  	  
				  
		@ 13,04 SAY "Banco:";   
				  GET cCBancoC;
				  PICTURE "@K@!"		  
				  
		@ 13,28 SAY "Agˆncia:";			
				  GET cAgenciC;
				  PICTURE "@K@!"		  
				  
		@ 13,48 SAY "Conta corrente:";			
				  GET cContaCC;
				  PICTURE "@K@!"		  		  		  		  		  		  
		
		@ 14,04 SAY "Apelido:";			
				  GET cApelido;
				  PICTURE "@K@!"		  		  		  		  		  		  
				  
		@ 14,45 SAY "Contato:";			
				  GET cContato;
				  PICTURE "@K@!@S20"	
				  	  		  		  		  		  		  		  		  
		@ 15,04 SAY "Desconto padrÆo.......:";
				  GET nDesconto;
				  PICTURE "@R 99.99%"		  

                @ 16,04 SAY "Observacao.:";
                                  GET cObs;
				  PICTURE "@K@!"
                /* Endereco para cobranca */
		@ 17,04 SAY "Endere‡o p/ Cobranca..:";
				  GET cEndereC1;
				  PICTURE "@K@!@s40"
				  
		@ 18,04 SAY "Cidade...:";
				  GET cCidadeC1;
				  PICTURE "@K@!"
			  
		@ 18,60 SAY "Estado...:";
				  GET cEstadoC1;
				  PICTURE "@K@!"
			  
		@ 19,04 SAY "CEP......:";
				  GET cCEPCliC1;
				  PICTURE "@K@R 99999-999"
			  
		@ 19,45 SAY "Telefone.:";			  
				  GET cTelefoC1;
				  PICTURE "@K@!@s10"
				  
		@ 20,04 SAY "Fax...:";			
				  GET cFaxCliC1;
				  PICTURE "@K@!@S20"
				  
		@ 20,45 say "1a. Compra..:";
				  Get dDt1Comp;
				  PICTURE "@D" 	  
		READ	
		
		IF LASTKEY()==27
			SETCURSOR(nCursor)
			SETCOLOR(cCor)
			RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
			DBGOTO(nReg)
			oBrowse:refreshAll()
			RETURN(NIL)
		ENDIF	
			
		IF Confirma("Confirma a inclusao deste cliente",23)
			IF Inclui_Registro(.T.)
				Lock_Registro(.T.)
				CECCCLI->CODIGOC := nCodigoC
				CECCCLI->NOMECLC := cNomeclC
                                CECCCLI->STATUS  := cStatus
				//Endereco Pessoal
				CECCCLI->ENDEREC := cEndereC
				CECCCLI->CIDADEC := cCidadeC
				CECCCLI->ESTADOC := cEstadoC
				CECCCLI->CEPCLIC := cCepCliC
				CECCCLI->TELEFOC := cTelefoC
				CECCCLI->FAXCLIC := cFaxCliC
				CECCCLI->BAIRRO  := cBairro
				CECCCLI->INSCSUF := cSuframa
				CECCCLI->APELIDO := cApelido
				CECCCLI->CONTATO := cContato
				CECCCLI->DESCONTO := nDesconto
                                CECCCLI->OBS      := cObs
				//Endereco para cobranca
				CECCCLI->ENDEREC1 := cEndereC1
				CECCCLI->CIDADEC1 := cCidadeC1
				CECCCLI->ESTADOC1 := cEstadoC1
				CECCCLI->CEPCLIC1 := cCepCliC1
				CECCCLI->TELEFOC1 := cTelefoC1
				CECCCLI->FAXCLIC1 := cFaxCliC1
				//
				CECCCLI->CGCCPFC := cCGCCPFC
				CECCCLI->INSESTC := cInsEstC
				CECCCLI->CBANCOC := cCBancoC
				CECCCLI->AGENCIC := cAgenciC
				CECCCLI->CONTACC := cContaCC
				CECCCLI->DT1COMP := dDt1comp
				//
				DBUNLOCK()
				DBCOMMIT()
				RegAtual:=Recno()
				DBGOBOTTOM()
				Ultregistro:=CECCCLI->CODIGOC
				DBGOTO(RegAtual)
				//
				CECCSET->( LOCK_REGISTRO(.T.) )
				IF Ultregistro > CECCSET->ULTNUMCLIE
					CECCSET->( LOCK_REGISTRO(.T.) )
					CECCSET->ULTNUMCLIE:=nCodigoC
					CECCSET->(DBUNLOCK())
					CECCSET->(DBCOMMIT())
				ELSE
					nCodigoC:=CECCSET->ULTNUMCLIE
				ENDIF
				//
			ENDIF	
		ENDIF
	ENDDO
RETURN(NIL)	
	
FUNCTION PCliente(oBrowse)				
	LOCAL cCor := SETCOR(m->cEdicao),;
			nCursor := SETCURSOR(1),;
			cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
			nReg := RECNO(),;
			Getlist:={},;
			lAchou,;
			nCodigoC:=0,;
			cNomeClC:=SPACE(40)
	
	DISPBOX(05,03,09,75,M->FR)
	@ 06,04 SAY "C¢digo do cliente..:";
			  GET nCodigoC;
			  PICTURE "@K@R@E 99,999"
			  
	@ 07,04 SAY "Nome...............:";
			  GET cNomeclC;
			  PICTURE "@K@!";
			  VALID PVerifica({nCodigoC,cNomeclC})		  
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
		CASE !EMPTY(nCodigoC)	  
			CECCCLI->(DBSETORDER(1))
			lAchou := Existe(nCodigoC,"Cliente nÆo cadastrado",.F.) 				
		CASE !EMPTY(cNomeclC)	  
			CECCCLI->(DBSETORDER(2))
	   	lAchou := Existe(cNomeclC,"Cliente nÆo cadastrado",.F.,,2,,,,,.T.) 			
	ENDCASE		
		
	IF !lAchou
		DBGOTO(nReg)
	ENDIF
		
	oBrowse:refreshAll()
RETURN(NIL)

FUNCTION ZCliente( oBrowse )
	LOCAL cCor := SETCOR(m->cEdicao),;
			nCursor := SETCURSOR(1),;
			cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
			nInd := INDEXORD()
	Lock_Registro(.T.)		
	BOX(05,03,21,75,M->FR,127,3,8)
	@ 06,04 SAY "CODIGO.........:"+ STR(CECCCLI->CODIGOC,5)
        @ 06,40 SAY "STATUS (N/A/B)..:" GET CECCCLI->STATUS  PICTURE "@!" VALID !EMPTY(CECCCLI->STATUS) .AND. (CECCCLI->STATUS$"NAB")
	@ 07,04 SAY "NOME...........:" GET CECCCLI->NOMECLC PICTURE "@!@S40"
	@ 08,04 SAY "ENDERECO.......:" GET CECCCLI->ENDEREC PICTURE "@!@S40"
	@ 09,04 SAY "BAIRRO.........:" GET CECCCLI->BAIRRO  PICTURE "@!"
	@ 10,04 SAY "CIDADE.........:" GET CECCCLI->CIDADEC PICTURE "@!"
	@ 11,04 SAY "ESTADO.........:" GET CECCCLI->ESTADOC PICTURE "@!"
	@ 12,04 SAY "CEP............:" GET CECCCLI->CEPCLIC PICTURE "@R 99999-999"
	@ 13,04 SAY "TELEFONE.......:" GET CECCCLI->TELEFOC PICTURE "@!@S40"
	@ 14,04 SAY "FAX............:" GET CECCCLI->FAXCLIC PICTURE "@!" 
	@ 15,04 SAY "CGC............:" GET CECCCLI->CGCCPFC PICTURE "@R 99.999.999/9999-99"
        @ 16,04 SAY "INSCRICAO ESTAD:" GET CECCCLI->INSESTC PICTURE "@!"
        @ 17,04 SAY "CONTATO........:" GET CECCCLI->CONTATO PICTURE "@!"
	@ 18,04 SAY "DESCONTO.......:" GET CECCCLI->DESCONTO PICTURE "@R@E 99.99"
	@ 19,04 SAY "1a. COMPRA.....:"+DTOC(CECCCLI->DT1COMP)
	@ 20,04 SAY "ULTIMA COMPRA..:"+DTOC(CECCCLI->DTUCOMP)
	READ
	RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
	SETCURSOR(nCursor)
	SETCOLOR(cCor)
	oBrowse:refreshAll()
	DBSETORDER(nInd)
RETURN(NIL)	
