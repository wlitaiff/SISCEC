// Sistemas de Controle de Estoque Comercial
// W&R Informatica Ltda
// 15 de Outubro de 1995
// Roberto Falcao Rocha
// Biblioteca de funcoes do sistema

#include "inkey.ch"

// Apagar registros
FUNCTION apagar( oObject,cOpcao )
	LOCAL cArea,;
			lAchou,;
			nTot,;
			nDes,;
			nPedido
			
	IF cOpcao="CAUTELASPENDENTES"
		RETURN(NIL)
	ENDIF	
			
	IF deleted()
		M_DISPLAY( "Registro ja esta deletado", 79 )
		RETURN ( NIL )
	ENDIF
			
	IF (ALIAS(SELECT())=="CECCBAL1" .OR. ALIAS(SELECT())=="CECCBAL2") .AND. cOpcao<>"CAUTELASPENDENTES"
		//
		IF CECCBAL1->ATENDIDO .OR. CECCBAL1->CANCELADO
			M_DISPLAY("Pedidos atendidos ou cancelados nao podem ser apagados",79)
			RETURN(NIL)
		ENDIF	
		//
	ENDIF	
	//
	IF ALIAS(SELECT())=="CECCLOJ"
		M_DISPLAY( "Opcao indisponivel", 79 )
		RETURN ( NIL )
	ENDIF	
	
   IF m_query("Deletar registro ?",23)
		//
		IF ALIAS(SELECT())=="CECCMER"
			IF CECCMER->SALDOEM#0 
				M_DISPLAY("Mercadoria possui saldo de estoque, nao pode ser apagada",79)
				RETURN(NIL)
			ENDIF
		ENDIF
		cArea := ALIAS(SELECT())
		IF ALIAS(SELECT())=="CECTLIN" .OR. ALIAS(SELECT())="CECTDIV" .OR. ALIAS(SELECT())="CECCFOR";
			.OR. cArea == "CECTLOJ"
			IF cArea#"CECTLOJ"
				IF !ARQNTX("CECCMER",.F.)
					RETURN(NIL)
				ENDIF	
			ELSE
				IF !ARQNTX("CECCLOJ",.F.)
					RETURN(NIL)
				ENDIF		
			ENDIF	
			SELECT(cArea)
			DO CASE
				CASE cArea=="CECTLIN"
					CECCMER->(DBSETORDER(5))
					lAchou:=CECCMER->(DBSEEK(CECTLIN->CODLIN))
				CASE cArea=="CECTDIV"
					CECCMER->(DBSETORDER(6))
					lAchou:=CECCMER->(DBSEEK(CECTDIV->CODDIV))	
				CASE cArea=="CECCFOR"
					CECCMER->(DBSETORDER(4))
					lAchou:=CECCMER->(DBSEEK(CECCFOR->CODIGOF))		
				CASE cArea=="CECTLOJ"
					lAchou:=CECCLOJ->(DBSEEK(STR(CECTLOJ->CODLOJTL,4)))
			ENDCASE
			IF cArea#"CECTLOJ"
				CECCMER->(DBCLOSEAREA())
			ELSE
				CECCLOJ->(DBCLOSEAREA())	
			ENDIF	
			IF lAchou
				M_DISPLAY("Nao pode ser apagado, pois existe em outra tabela",79)
				RETURN(NIL)
			ENDIF	
		ENDIF		
		//
		IF ALIAS(SELECT())#"CECCBAL1" .AND. ALIAS(SELECT())#"CECCBAL2"
			IF LOCK_REGISTRO(.F.)
				DBDELETE()
				DBUNLOCK()
				oObject:refreshAll()
			ENDIF
		ENDIF
		//
		IF ALIAS(SELECT())="CECCBAL1" .AND. cOpcao<>"CAUTELASPENDENTES"
			nPedido := CECCBAL2->PEDIDO
			DO WHILE CECCBAL1->PEDIDO == CECCBAL2->PEDIDO .AND. CECCBAL2->(!EOF())
				//
				CECCMER->(DBSEEK(CECCBAL2->MERCADORIA))
				CECCMER->(Lock_Registro(.T.))
				// Retirar as Qtds. da Cautela e QtdPed do item - WLV - 07/06/97
				IF CECCBAL1->TIPO=="P"
					CECCMER->QTDPED -= CECCBAL2->QTD
				ENDIF
				IF CECCBAL1->TIPO=="C"
					CECCMER->CAUTELA -= CECCBAL2->QTD
				ENDIF		
				//
				If CECCMER->CAUTELA < 0
					CECCMER->CAUTELA:=0
				EndIf
				If CECCMER->QTDPED < 0
					CECCMER->QTDPED:=0
				EndIf
				CECCMER->(DBUNLOCK())
				CECCMER->(DBCOMMIT())			
				//
				CECCBAL2->(Lock_Registro(.T.))
				CECCBAL2->(DBDELETE())
				CECCBAL2->(DBUNLOCK())
				CECCBAL2->(DBSKIP())
			ENDDO
			CECCBAL1->(Lock_Registro(.T.))
			CECCBAL1->(DBDELETE())
			CECCBAL1->(DBUNLOCK())
			oObject:refreshAll()
		ENDIF
		//
		IF ALIAS(SELECT())="CECCBAL2" .AND. cOpcao<>"CAUTELASPENDENTES"
			CECCMER->(DBSEEK(CECCBAL2->MERCADORIA))
			CECCMER->(Lock_Registro(.T.))
			// Retirar as Qtds. da Cautela e QtdPed do item - WLV - 07/06/97
			IF CECCBAL1->TIPO=="P"
				CECCMER->QTDPED -= CECCBAL2->QTD
			ENDIF
			IF CECCBAL1->TIPO=="C"
				CECCMER->CAUTELA -= CECCBAL2->QTD
			ENDIF		
			//
			nTot := CECCBAL2->PRECOT
			nDes := CECCBAL2->DESCONTO
			// Baixar Cautelas e Pedidos nao atendidos no CMER
			If CECCMER->CAUTELA < 0
				CECCMER->CAUTELA:=0
			EndIf
			If CECCMER->QTDPED < 0
				CECCMER->QTDPED:=0
			EndIf
			//
			CECCMER->(DBUNLOCK())
			CECCMER->(DBCOMMIT())			
			//
			CECCBAL2->(Lock_Registro(.T.))
			CECCBAL2->(DBDELETE())
			CECCBAL2->(DBUNLOCK())
			//
			CECCBAL1->(LOCK_REGISTRO(.T.))
			CECCBAL1->SUBTOTAL -= nTot
			CECCBAL1->VDESCONTO -= nDes
			CECCBAL1->TOTAL := CECCBAL1->SUBTOTAL - CECCBAL1->VDESCONTO
			CECCBAL1->(DBUNLOCK())
			oObject:refreshAll()
		ENDIF
   ENDIF
RETURN( NIL )

//Indexacao
FUNCTION CECIndices()
   LOCAL cOldColor  := SetCor()
	LOCAL	cOldScreen := SaveScreen(0,0,MAXROW(),MAXCOL())				  
	LOCAL nAchoice,te
	PUBLIC AFILES    := {"Mercadorias        ",;
	   						"Fornecedores       ",;
								"Estoques           ",;
			               "Clientes           ",;
								"Vendedores         ",;
								"Divisoes           ",;
					         "Linhas             ",;
								"Vendas             ",;
								"Sistema            ",;
								"Todos              "}
	Public  aFileMan, aFileList
   Public  hScrollBar, nMenuItem, nTagged
   Public  nEl, nRel, lReloadDir, nFileItem
								
	DO WHILE .T.							  
	nAchoice := fileman(7,55,aFiles,"N/W,W+/B")
	if nAchoice == 0
	  EXIT
	END
		IF nAchoice = 01 .OR. nAchoice = 10
				ARQNTX("CECCMER",,.T.)
		END	
		IF nAchoice = 02 .OR.  nAchoice = 10
				ARQNTX("CECCFOR",,.T.)
		END	
		IF nAchoice = 03 .OR. nAchoice = 10
				ARQNTX("CECCLOJ",,.T.)
		END	
		IF nAchoice = 04 .OR. nAchoice = 10
			ARQNTX("CECCCLI",,.T.)
		ENDIF
		if nAchoice = 05 .OR. nAchoice = 10
			ARQNTX("CECCVEN",,.T.)
		ENDIF	
		if nAchoice = 06 .OR. nAchoice = 10
			ARQNTX("CECTDIV",,.T.)
		ENDIF	
		if nAchoice = 07 .OR. nAchoice = 10
			ARQNTX("CECTLIN",,.T.)
		ENDIF	
		if nAchoice = 08 .OR. nAchoice = 10
			ARQNTX("CECTLOJ",,.T.)
		ENDIF	
		if nAchoice = 09 .OR. nAchoice = 10
			ARQNTX("CECCPAS",,.T.)
		ENDIF	
	ENDDO	
	SetCor(cOldColor)
	RESTSCREEN(0,0,MAXROW(),MAXCOL(),cOldScreen)	
RETURN(NIL)

//Compactacao
FUNCTION CECCompactar()
   LOCAL cOldColor  := SetCor()
	LOCAL	cOldScreen := SaveScreen(0,0,MAXROW(),MAXCOL())				  
	LOCAL nAchoice,te
	PUBLIC AFILES    := {"Mercadorias        ",;
	   						"Fornecedores       ",;
								"Estoques           ",;
			               "Clientes           ",;
								"Vendedores         ",;
								"Divisoes           ",;
					         "Linhas             ",;
								"Vendas             ",;
								"Sistema            ",;
								"Todos              "}
	Public  aFileMan, aFileList
   Public  hScrollBar, nMenuItem, nTagged
   Public  nEl, nRel, lReloadDir, nFileItem							
	DO WHILE .T.							  
	nAchoice := fileman(7,55,aFiles,"N/W,W+/B")
	if nAchoice == 0
	  EXIT
	END
		IF nAchoice = 01 .OR. nAchoice = 10
			IF COMPACTAR("CECCMER")
				ARQNTX("CECCMER",,.T.)
			ENDIF	
		END	
		IF nAchoice = 02 .OR.  nAchoice = 10
			IF COMPACTAR("CECCFOR")
				ARQNTX("CECCFOR",,.T.)
			ENDIF	
		END	
		IF nAchoice = 03 .OR. nAchoice = 10
			IF COMPACTAR("CECCLOJ")	
				ARQNTX("CECCLOJ",,.T.)
			ENDIF	
		END	
		IF nAchoice = 04 .OR. nAchoice = 10
			IF COMPACTAR("CECCCLI")
				ARQNTX("CECCCLI",,.T.)
			ENDIF	
		ENDIF
		if nAchoice = 05 .OR. nAchoice = 10
			IF COMPACTAR("CECCVEN")
				ARQNTX("CECCVEN",,.T.)
			ENDIF	
		ENDIF	
		if nAchoice = 06 .OR. nAchoice = 10
			IF COMPACTAR("CECTDIV")
				ARQNTX("CECTDIV",,.T.)	
			ENDIF	
		ENDIF	
		if nAchoice = 07 .OR. nAchoice = 10
			IF COMPACTAR("CECTLIN")
				ARQNTX("CECTLIN",,.T.)
			ENDIF	
		ENDIF	
		if nAchoice = 08 .OR. nAchoice = 10
			IF COMPACTAR("CECTLOJ")
				ARQNTX("CECTLOJ",,.T.)
			ENDIF	
		ENDIF	
		if nAchoice = 09 .OR. nAchoice = 10
			IF COMPACTAR("CECCPAS")
				ARQNTX("CECCPAS",,.T.)
			ENDIF	
		ENDIF	
	ENDDO	
	SetCor(cOldColor)
	RESTSCREEN(0,0,MAXROW(),MAXCOL(),cOldScreen)	
RETURN(NIL)

// Troca a senha do usuario
FUNCTION Senha()
	LOCAL GETLIST:={}
	LOCAL cCor 	  := SETCOLOR()
	LOCAL nCursor := SETCURSOR ( 1 )
	LOCAL cOldScreen := SAVESCREEN( 0,0,LASTROW(),LASTCOL() )
	LOCAL cTelaS,;
			nVer,;
			cSenha2,;
			cSenhaOld
	IF !M_QUERY("Troca a senha do supervisor ?",23)		
		IF !ARQNTX("CECCPAS")
			RETURN(NIL)
		ENDIF	
		DBSEEK(M->cUsuario)
		lSup := .F.
	ELSE
		IF !ARQNTX("CECCSET")
			RETURN(NIL)
		ENDIF		
		lSup := .T.
	ENDIF	
	setcolor(m->cEdicao)
	Box( 19,12,21,70,M->fr,127,03,08 )
	nVer := 1
	cSenhaOld := SPACE ( 15 )
	@ 20,14 SAY "Digite a senha anterior:" GET cSenhaOld   PICTURE "@!" COLOR ( "W/W" )  VALID !( EMPTY ( cSenhaOld ) )
	READ	
	if lastkey()==27
		DBCLOSEALL()
		RESTSCREEN( 0,0,LASTROW(),LASTCOL(),cOldScreen )
		RETURN (NIL)
	endif
	IF !lSup
		if ! ( alltrim(M->cSenha) == alltrim(cSenhaOld) ) 
			M_DISPLAY ( "Senha Incorreta... Usu rio nÆo autorizado", 79 )
			DBCLOSEALL()
			RESTSCREEN( 0,0,LASTROW(),LASTCOL(),cOldScreen )
			RETURN (NIL)
		endif
	ELSE
		if ! ( alltrim(Criptografa ( CECCSET -> PASSWDS, "HAWK", .F. ) )   == alltrim(cSenhaOld) ) 
			M_DISPLAY ( "Senha Incorreta... Usu rio nÆo autorizado", 79 )
			DBCLOSEALL()
			RESTSCREEN( 0,0,LASTROW(),LASTCOL(),cOldScreen )
			RETURN (NIL)
		endif
	ENDIF		
	DO WHILE .T.
	   M->cSenha := SPACE ( 15 )
		@ 20,14 SAY IF(nVer=1,"Digite a nova senha....:","Redigite a senha.......:") GET MEMVAR->cSenha   PICTURE "@!" COLOR ( "W/W" )  VALID !( EMPTY ( MEMVAR->cSenha ) )
		READ	
		IF LASTKEY() == 27 
			MEMVAR->cSenha:=alltrim(cSenhaOld)
			DBCLOSEALL()
			RESTSCREEN( 0,0,LASTROW(),LASTCOL(),cOldScreen )
			RETURN (NIL)
		ENDIF	
		MEMVAR->cSenha:=alltrim(MEMVAR->cSenha)
		IF nVer == 1
			cSenha2 := MEMVAR->cSenha
			m_squeak()
			m_squeak()
		ENDIF	
		IF nVer == 2 .AND. MEMVAR->cSenha == cSenha2
			EXIT
		ENDIF
		IF nVer == 2
			M_DISPLAY ( "Senhas diferentes, tente novamente", 79 )
			nVer := 0
		ENDIF		
		nVer ++
	ENDDO
	MEMVAR->cSenha:=MEMVAR->cSenha+space(15-len(MEMVAR->cSenha))
	IF !lSup
		if lock_registro(.T.)
			CECCPAS -> ACESSO := Criptografa ( MEMVAR->cNivel, MEMVAR->cSenha,  .T. ) 
			CECCPAS -> SENHA  := Criptografa ( MEMVAR->cSenha, MEMVAR->CUSUARIO,.T. )
			DBCOMMIT()
			DBUNLOCK()
		endif
	ELSE
		if lock_registro(.T.)
			CECCSET -> PASSWDS  := Criptografa ( MEMVAR->cSenha, "HAWK",.T. )
			DBCOMMIT()
			DBUNLOCK()
		endif
	ENDIF	
	DBCLOSEALL()
	RESTSCREEN( 0,0,LASTROW(),LASTCOL(),cOldScreen )
RETURN (NIL)

// Funcao de SETUP
// Configura o Sistema

FUNCTION SETUP ()
	LOCAL Getlist := {}
	LOCAL cOldScreen := SAVESCREEN ( 06,05,24,79 )
	LOCAL nOldCursor := SETCURSOR ()
	LOCAL cOldColors := SETCOLOR ()
	LOCAL cTempo,nVerImp,nImpPed,nUltNf,nUltNfD1,nUCli,nUFor
	IF !ARQNTX("CECCSET")
		RETURN(NIL)
	ENDIF	
	DBGOTOP ()
	SETCURSOR(1)
	SetCor (m->cEdicao)
	Box ( 08,05,21,78,MEMVAR->fr,127,03,08 )		
	cTempo 			:= TIMEASSTRING(MEMVAR->PTEMPODESC)
	nVerImp 		:= CECCSET->IMPFIS
	nImpPed 		:= CECCSET->IMPPED	
	nUltNf  		:= CECCSET->ULTNF
	nUltNfD1  		:= CECCSET->ULTNFD1
	cMora 			:= CECCSET->MORA
	cIniL 			:= CECCSET->INIE
	CSERIESELO 		:= CECCSET->SELO
	NuLTFIS 		:= ceccset->ultfis
	nUCli           := ceccset->ULTNUMCLIE
	nUFor			:= ceccset->ULTNUMFORN
	//
	@ 09,07 SAY "Tempo para tela de descanso.............:" GET cTempo PICTURE [@ 99:99]                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
	@ 10,07 SAY "Impressora Fiscal Versao................:" GET nVerImp PICTURE "99" 
	@ 11,07 SAY "Imprime pedido de compra.(0=NAO - 1=SIM):" GET nImpPed PICTURE "99" VALID (nImpPed=0 .OR. nImpPed=1)
	@ 12,07 SAY "Ultima nota fiscal impressa.............:" GET nUltnf PICTURE "9999999999"
	@ 13,07 SAY "Ultima nota fiscal impressa (D1)........:" GET nUltnfD1 PICTURE "999999"
	@ 14,07 SAY "Ultimo selo fiscal impresso.............:" GET nUltfis PICTURE "9999999999"
	@ 15,07 SAY "Serie do selo fiscal....................:" GET cSerieSelo PICTURE "@!"
	@ 16,07 SAY "Entre com o valor do juros de mora......:" GET cMora  PICTURE "9,99"
	@ 17,07 SAY "Entre com as iniciais da loja...........:" GET cIniL  PICTURE "@!"
	@ 18,07 SAY "Ultimo numero do Cliente................:" GET nUCli  pict "99,999"
	@ 19,07 SAY "Ultimo numero do Fornecedor.............:" GET nUFor  pict "99,999"
	READ
	IF LASTKEY () == 27 .OR. !M_QUERY ( "Confirma altera‡„o ?",23 )	
		RESTSCREEN (06,05,24,79,cOldScreen )
		SETCURSOR ( nOldCursor )
		SETCOLOR ( cOldColors )
		DBCLOSEALL ()
		RETURN ( NIL ) 
	ENDIF
	IF Lock_Registro ( .F. )
		CECCSET -> TEMPO   := TIMEASSECOND(cTempo)
		CECCSET -> IMPPED  := nImpPed
		CECCSET -> IMPFIS  := nVerImp
		CECCSET -> ULTNF   := nUltnf
		CECCSET -> ULTNFD1 := nUltnfD1
		CECCSET -> MORA    := cMora
		CECCSET -> INIE    := cIniL
		CECCSET -> ULTFIS  := nUltFis
		CECCSET -> SELO    := CSERIESELO
		CECCSET -> ULTNUMCLIE := nUCli
		CECCSET -> ULTNUMFORN := nUFor
		DBCOMMIT()
		DBUNLOCK()
	ELSE
		M_DISPLAY ( "Op‡„o cancelada pelo usu rio",79 )
	ENDIF
	MEMVAR->PTEMPODESC := TIMEASSECOND(cTempo)
	RESTSCREEN (06,05,24,79,cOldScreen )
	SETCURSOR ( nOldCursor )
	SETCOLOR ( cOldColors )		
	DBCLOSEALL ()
RETURN ( NIL )	 

FUNCTION Help(Par1,Par2,Par3)
	LOCAL cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL())
	LOCAL nCursor := SETCURSOR()
	LOCAL cCor := SETCOLOR()
	LOCAL nArea := SELECT()
	LOCAL aCab,;
			aDad,;
			aPic,;
			nAchoice
	Public  aFileMan, aFileList,AFILES
	Public  hScrollBar, nMenuItem, nTagged
	Public  nEl, nRel, lReloadDir, nFileItem		
	
	IF Par1 == "HELP"
		RETURN(NIL)
	ENDIF	
	DO CASE
		CASE Par1 == "BROWSE"
			BOX(5,30,21,75,M->FR,127,3,8)
	      SETCOR(m->cEdicao)
			@ 06,31 SAY "Teclas:           A‡„o:                     "
			@ 07,31 SAY "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"     
	  		@ 08,31 SAY "Ctrl+Page_Up     ³ Inicio do Arquivo        "
	  		@ 09,31 SAY "Ctrl+Page_Down   ³ Fim do Arquivo           "
			@ 10,31 SAY "ALT+F            ³ Congelar campo           "
			@ 11,31 SAY "ALT+L            ³ Libera campo congelado   "
			@ 12,31 SAY "ALT+"+CHR(26)+"            ³ Aumenta tamanho do campo " 
			@ 13,31 SAY "ALT+            ³ Diminui tamanho do campo " 
			@ 14,31 SAY "ALT+R            ³ Restaurar tela de dados  "
			@ 15,31 SAY "ALT+V            ³ Visualizar descricao     "
			@ 16,31 SAY "ALT+-            ³ Menu do Browse           "
			@ 17,31 SAY CHR(24)+CHR(25)+CHR(26)+CHR(27)
			@ 17,48 SAY "³"
			@ 17,50 SAY "Movimentos"
			@ 18,31 SAY "F11              ³ Calend rio               "
			@ 19,31 SAY "F12              ³ Calculadora              "
			@ 20,31 SAY "F7               ³ Zoom                     " 
			M_SQUEAK()
	  		MINKEY(0)
		CASE Par1 == NIL .AND. Par2 == NIL .AND. Par3 == NIL
  	   	BOX(3,04,07,44,M->FR,127,3,8)  
			SETCOR(m->cEdicao)
			@ 04,05 SAY "Escolha a opcao digitando ALT+ a  letra"
			@ 05,05 SAY "da opcao que estiver   em  destaque  na"       
			@ 06,05 SAY "parte superior do monitor.             "
			MINKEY(0)
		CASE (Par1 == "CMERCADORI" .AND. Par3 == "NFORNECM") .OR.;
			  (Par1 == "CECM2000"   .AND. Par3 == "NFOR") .OR.;
			  (Par3 == "NFORNECEDOR")
			  /**((Par1 == "CECR1100" .OR. Par1=="CECR1200" .OR.;
			  	 Par1 == "CECR1300" .OR. Par1=="CECR1400" .OR.;
				 Par1 == "CECR1510" .OR. Par1=="CECR1520" .OR.;
				 Par1 == "CECCP100" .OR. Par1=="CECL1000") .AND. Par3 == "NFORNECEDOR")
			  **/
         aCab:={"Codigo","Nome"} 
         aDad:={"CODIGOF","NOMECLF"} 
		   aPic:={"99999","@!" }
			SELECT("CECCFOR")
			DBSETORDER(2)
			CECCFOR->(DBGOTOP())
  			HBrowseDB(ROW()+1,0,23,79,"Tabela de Fornecedores",aCab,aDad,aPic,,,.F.)
			DBSETORDER(1)			
		CASE (Par3 == "NCLIENTE" .OR. PAR3="CLIENTE" ) .OR.;
			  (Par1 == "CECM2000" .AND. Par3 == "NCLI") 			  
         aCab:={"Codigo","Nome","Endereco","CGC"} 
         aDad:={"CODIGOC","NOMECLC","ENDEREC","CGCCPFC"} 
		   aPic:={"99999","@!","@!","@R 99.999.999/9999-99"}
			SELECT("CECCCLI")
			DBSETORDER(2)
			CECCCLI->(DBGOTOP())
  			HBrowseDB(ROW()+1,0,23,79,"Tabela de Clientes",aCab,aDad,aPic,,,.F.)
			DBSETORDER(1)				
		CASE (Par1 == "CMERCADORI" .AND. Par3 == "NCODLINM") .OR.;
			  ((Par1 == "CECR1100" .OR. Par1=="CECR1200" .OR.;
			  	 Par1 == "CECR1300" .OR. Par1=="CECR1400" .OR.;
				 Par1 == "CECR1510" .OR. Par1=="CECR1520") .AND. Par3 == "NLINHA")	
         aCab:={"Codigo","Linha"} 
         aDad:={"CODLIN","NOMLIN"} 
		   aPic:={"9999","@!" }
			SELECT("CECTLIN")
			DBSETORDER(2)
			CECTLIN->(DBGOTOP())
  			HBrowseDB(ROW()+1,0,23,79,"Tabela de Linhas",aCab,aDad,aPic,,,.F.)
			DBSETORDER(1)				
		CASE (Par1 == "CMERCADORI" .AND. Par3 == "NCODDIVM") .OR.;
		     ((Par1 == "CECR1100" .OR. Par1=="CECR1200" .OR.;
			  	 Par1 == "CECR1300" .OR. Par1=="CECR1400" .OR.;
				 Par1 == "CECR1510" .OR. Par1=="CECR1520") .AND. Par3 == "NDIVISAO")
         aCab:={"Codigo","Divis„o"} 
         aDad:={"CODDIV","NOMDIV"} 
		   aPic:={"9999","@!" }
			SELECT("CECTDIV")
			DBSETORDER(2)
			CECTDIV->(DBGOTOP())
  			HBrowseDB(ROW()+1,0,23,79,"Tabela de Divisäes",aCab,aDad,aPic,,,.F.)
			DBSETORDER(1)					
		CASE (Par1 == "CVENDEDOR" .AND. Par3 == "NCODLOJ")	.OR.;
			  (Par1 == "CECM2000"  .AND. Par3 == "NLOJA")   .OR.;
			  (Par1 == "CBALCAO"   .AND. Par3 == "NLOJA")   .OR.;
			  (Par1 == "CECR1520"  .AND. PAR3 == "NLOJA")
         aCab:={"Codigo","Loja"} 
         aDad:={"CODLOJTL","NOMLOJTL"} 
		   aPic:={"9999","@!" }
			SELECT("CECTLOJ")
			DBSETORDER(2)
			CECTLOJ->(DBGOTOP())
  			HBrowseDB(ROW()+1,0,23,79,"Tabela de Lojas",aCab,aDad,aPic,,,.F.)
			DBSETORDER(1)
		CASE (Par1 == "CBALCAO"  .AND. Par3 == "NVENDEDOR") .or.;
		     (Par1 == "CECM2000"  .AND. Par3 == "NCODVENDEDOR") 
         aCab:={"Codigo","Loja","Nome"} 
         aDad:={"CODVEN","CODLOJ","NOMVEN"} 
		   aPic:={"99999","9999","@!" }
			SELECT("CECCVEN")
			SET INDEX TO
			SUBNTX("CECIVEN3.NTX","SUBIVEN3.NTX",STR(CECTLOJ->CODLOJTL,4),STR(CECTLOJ->CODLOJTL,4),"***",.F.,-1)
			DBSETINDEX("SUBIVEN3")
			DBSETINDEX("CECIVEN2")
			DBGOTOP()
  			HBrowseDB(ROW()+1,0,23,79,"Tabela de Vendedores",aCab,aDad,aPic,,,.F.)
			CECCVEN->(DBCLOSEAREA())
			ARQNTX("CECCVEN",.F.)
		CASE (Par1 == "CECM2000" .AND. Par3 == "CMERCADORIA") .OR.;
			  (Par1 == "CBALCAO"  .AND. SUBST(Par3,1,7) == "ACODIGO") .OR.;
			  (PAR1 == "CECFICHA" .AND. PAR3 == "CCOD") .OR. SUBST(PAR3,1,7) == "ACODIGO"
			IF Par1=="CBALCAO"  
	         aCab:={"Codigo","Mercadoria","Preco a Vista","Preco Faturado","Estoque"} 
   	      aDad:={"CODIGOM","DESCRIM","PRECVEM","PRECVEM2","SALDOEM"} 
			   aPic:={"@!","@!","@R 9,999,999.99","@R 9,999,999.99","@R 999,9999.999"}
			ELSE	
				aCab:={"Codigo","Mercadoria"} 
   	      aDad:={"CODIGOM","DESCRIM"} 
			   aPic:={"@!","@!" }	
			ENDIF	
			SELECT("CECCMER")
			DBSETORDER(3)
			CECCMER->(DBGOTOP())
  			HBrowseDB(ROW()+1,0,23,79,"Tabela de mercadorias",aCab,aDad,aPic,,,.F.)
			IF Par1#"CBALCAO"
				DBSETORDER(1)								
			ENDIF	
		CASE  (PAR1=="CECM2000" .AND. PAR3=="CCODTRIB") .OR.;
				(PAR1=="CECL1000" .AND. PAR3=="NCODTRI")
				aFiles:={"1-Com Imposto - Desconto de rodap‚, %desc. icms e/ou %icms",;
				         "2-Com Imposto - Valor l¡quido, se h  desc. icms informe % ",;
							"3-Isentas ou nao tributadas          ",;
							"4-Com base de icms diferente da nota ",;
							"5-So IPI                             ",;
							"6-Outros                             "}
		      nAchoice := fileman(7,5,AFILES,"N/W,W+/B")
				IF nAchoice>0
				   KEYBOARD LEFT(AFILES[NACHOICE],1)+CHR(13)
				ENDIF
		CASE  (PAR1="CONFIRMAP2" .AND. SUBST(PAR3,1,11)="AMODALIDADE")
				aFiles:={"1-Dinheiro",;
				         "2-Cheque  ",;
							"3-Cartao  ",;
							"4-Tickets ",;
							"5-Convenio",;
							"6-Outros  "}
		      nAchoice := fileman(7,5,AFILES,"N/W,W+/B")
				IF nAchoice>0
				   KEYBOARD LEFT(AFILES[NACHOICE],1)+CHR(13)
				ENDIF		
 		CASE  (PAR1="CECF1000" .AND. subst(PAR3,1,11)="AMODALIDADE") .OR. ;
				(PAR1="CECM2000" .AND. PAR3="NFORMAPAGA") 
				aFiles:={"1-Dinheiro",;
				         "2-Cheque  ",;
							"3-Cartao  ",;
							"4-Tickets ",;
							"5-Convenio",;
							"6-Outros  "}
		      nAchoice := fileman(7,5,AFILES,"N/W,W+/B")
				IF nAchoice>0
				   KEYBOARD LEFT(AFILES[NACHOICE],1)+CHR(13)
				ENDIF		
		CASE  (PAR1="CMERCADORIA" .AND. PAR3="CORIGEMM")
				aFiles:={"I - Importada",;
				         "N - Nacional "}
		      nAchoice := fileman(7,5,AFILES,"N/W,W+/B")
				IF nAchoice>0
				   KEYBOARD LEFT(AFILES[NACHOICE],1)+CHR(13)
				ENDIF		
		CASE  (PAR1="CECM2000" .AND. PAR3="CMOVIMENTO") .OR. ;
				(PAR1="CECR7100" .AND. PAR3="TMOV")
				aFiles:={"CF-Entrada de Compra Fiscal  ",;
				         "CD-Devolucao de Compra Fiscal",;
							"CP-Complemento de Precos     ",;
							"VE-Saida por Venda Fiscal    ",;
							"VD-Devolucao de Saida Fiscal ",;
							"TR-Transferencias            ",;
							"RQ-Requisicoes               ",;
							"TC-Trocas                    ",;
							"CV-Cancelamento de vendas    "}
		      nAchoice := fileman(7,5,AFILES,"N/W,W+/B")
				IF nAchoice>0
				   KEYBOARD LEFT(AFILES[NACHOICE],2)+CHR(13)
				ENDIF
		CASE  (PAR1="CECM2000" .AND. (PAR3="M_TIPMM" .OR. PAR3="CTIPO")) 
				aFiles:={"E-Para as Entradas       ",;
				         "S-Para as Saidas         ",;
							"I-Para Inventario/Acerto "}
		      nAchoice := fileman(7,5,AFILES,"N/W,W+/B")
				IF nAchoice>0
				   KEYBOARD LEFT(AFILES[NACHOICE],1)+CHR(13)
				ENDIF
		CASE  (PAR1="CECM2000" .AND. PAR3="NPAG") 
				aFiles:={"01-· Vista",;
							"02-· Prazo",;
							"15-Dias   ",;
				         "30-Dias   ",;
							"60-Dias   ",;
							"90-Dias   "}
		      nAchoice := fileman(7,5,AFILES,"N/W,W+/B")
				IF nAchoice>0
				   KEYBOARD LEFT(AFILES[nAchoice],2)+CHR(13)
				ENDIF
	ENDCASE
	SETCOLOR(cCor)
	SETCURSOR(nCursor)
	SELECT(nArea)
	RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
RETURN(NIL)

FUNCTION Pesquisa(oBrowse,cOpcao)
	DO CASE
		CASE ALIAS(SELECT())=="CECCBAL2"
			CancelaP()
		CASE ALIAS(SELECT())=="CECTLOJ"
			PTLoja(oBrowse)
		CASE ALIAS(SELECT())=="CECCMER"
			PMercadoria(oBrowse)
		CASE ALIAS(SELECT())=="CECCFOR"
			PFornecedor(oBrowse)	
		CASE ALIAS(SELECT())=="CECTLIN"
			PLinha(oBrowse)	
		CASE ALIAS(SELECT())=="CECTDIV"
			PDivisao(oBrowse)			
		CASE ALIAS(SELECT())=="CECCLOJ"
			PLoja(oBrowse)				
		CASE ALIAS(SELECT())=="CECCVEN"
			PVendedor(oBrowse)					
		CASE ALIAS(SELECT())=="CECCCLI"
			PCliente(oBrowse)						
		CASE ALIAS(SELECT())=="CECCBAL1" .AND. cOpcao == "CECF1000"
			PBalcao2(oBrowse)							
		CASE ALIAS(SELECT())=="CECCBAL1" .AND. cOpcao == "CECM5000"
			PBalcao(oBrowse)								
		CASE ALIAS(SELECT())=="CECCFIS"
			PesqNotas(oBrowse)									
		CASE ALIAS(SELECT())=="CECCREC"
			PReceber(oBrowse)	
		CASE ALIAS(SELECT())=="CECCPAG"
			PPagar(oBrowse)		
	ENDCASE
RETURN(NIL)			

FUNCTION Zoom(oBrowse,cOpcao)
	DO CASE
		CASE ALIAS(SELECT())=="CECCMER"
			ZMercadoria(oBrowse)
		CASE ALIAS(SELECT())=="CECCCLI"
			ZCliente(oBrowse)	
		CASE ALIAS(SELECT())=="CECCFOR"
			ZFornecedor(oBrowse)	
		CASE ALIAS(SELECT())=="CECCREC"	
			Baixa(oBrowse)
		CASE ALIAS(SELECT())=="CECCPAG"
			If !M_QUERY("Baixa Autom tica Por Data?",23)
				BaixaFor(oBrowse)	
			Else
				AutoBaixaFor(oBrowse)
			EndIf
		CASE ALIAS(SELECT())=="CPAGDIA"
			BaixaAuto(oBrowse)
		OTHERWISE
			M_DISPLAY("Op‡Æo nÆo dispon¡vel",79)
	ENDCASE			
RETURN(NIL)			

FUNCTION Inclusao(oBrowse,cOpcao)
	DO CASE
		CASE ALIAS(SELECT())=="CECTLOJ"
			CTLoja(oBrowse)
		CASE ALIAS(SELECT())=="CECCMER" .AND. cOpcao==NIL
			CMercadoria(oBrowse)	
		CASE ALIAS(SELECT())=="CECCFOR"
			CFornecedor(oBrowse)	
		CASE ALIAS(SELECT())=="CECTLIN"
			CLinha(oBrowse)	
		CASE ALIAS(SELECT())=="CECTDIV"
			CDivisao(oBrowse)			
		CASE ALIAS(SELECT())=="CECCVEN"
			CVendedor(oBrowse)					
		CASE ALIAS(SELECT())=="CECCCLI"
			CCliente(oBrowse)						
		CASE ALIAS(SELECT())=="CECCFIS"
			Cad_Livro(oBrowse)						
		CASE ALIAS(SELECT())=="CECCMER" .AND. cOpcao=="CECM4000"
			CBalcao(oBrowse)				
		CASE ALIAS(SELECT())=="CECCREC"
			CReceber(oBrowse)	
		CASE ALIAS(SELECT())=="CECCPAG"
			CPagar(oBrowse)					
		CASE ALIAS(SELECT())=="CECCBAL1" .AND. cOpcao=="CECF1000"
			Atende2()								
		CASE ALIAS(SELECT())=="CECCBAL1" .AND. cOpcao=="CAUTELASPENDENTES"
			Itens()									
		CASE ALIAS(SELECT())=="CECCBAL2" .AND. cOpcao=="ATENDE"
			IF CECCBAL1->CLIENTE == 1
				ConfirmaP2()									
				//ConfirmaP4()
			ELSE
				ConfirmaP3()
			ENDIF		
		CASE ALIAS(SELECT())=="CECCBAL1" .AND. cOpcao=="CECM5000"
			Atende(oBrowse)								
		CASE ALIAS(SELECT())=="CECCBAL2" .AND. cOpcao=="ATENDE2"
			ConfirmaP()										
			KEYBOARD(K_ESC)
	ENDCASE
	oBrowse:refreshAll()
RETURN(NIL)

FUNCTION Pesquisa2(oBrowse)
	LOCAL cTela := SAVESCREEN( 0,0,MAXROW(),MAXCOL()),;
			cCor := SETCOLOR(),;
	      nCursor := SETCURSOR(),;
			GETLIST := {},;
			cCaracter:=SPACE(40),;
			cCampo
		
	DISPBOX(08,04,12,78,M->FR) 		
	SETCURSOR(1)
	DO CASE
		CASE ALIAS(SELECT()) == "CECCFOR"  
			cCampo := "Fornecedor:"
		CASE ALIAS(SELECT()) == "CECTLIN"
			cCampo := "Grupo:"
		CASE ALIAS(SELECT()) == "CECTDIV"  
			cCampo := "DivisÆo:"
		CASE ALIAS(SELECT()) == "CECTLOJ"  
			cCampo := "Loja:"	
		CASE ALIAS(SELECT()) == "CECCMER"  
			Pesquisa3(oBrowse)
			RESTSCREEN( 0,0,MAXROW(),MAXCOL(),cTela)
			SETCOLOR(cCor)
			SETCURSOR(nCursor)
			oBrowse:refreshAll()
			RETURN(NIL)
		CASE ALIAS(SELECT()) == "CECCVEN"	
			cCampo := "Vendedor:"
		CASE ALIAS(SELECT()) == "CECCCLI"	
			cCampo := "Cliente:"	
	ENDCASE		
	@ 10,06 SAY cCampo;
				   GET cCaracter;
				   PICTURE "@!";
				   VALID !EMPTY(cCaracter) .AND.;
					Existe(cCaracter,cCampo+" nÆo tem cadastro",.F.,ALIAS(SELECT()),IF(cCampo=="Mercadoria:",3,2),,,,,.T.)    	
	READ
	RESTSCREEN( 0,0,MAXROW(),MAXCOL(),cTela)
	SETCOLOR(cCor)
	SETCURSOR(nCursor)
	oBrowse:refreshAll()
RETURN(NIL)

FUNCTION Pesquisa3(oBrowse)
	LOCAL cTela := SAVESCREEN( 0,0,MAXROW(),MAXCOL()),;
			cCor := SETCOLOR(),;
	      nCursor := SETCURSOR(),;
			GETLIST := {},;
			cCaracter:=SPACE(16),;
			cDesc    :=SPACE(40)
		
	DISPBOX(08,04,13,78,M->FR) 		
	SETCURSOR(1)
	@ 10,06 SAY [MERCADORIA.:];
				   GET cCaracter;
				   PICTURE "@!";
					
	@ 11,06 SAY [DESCRICAO..:];
				   GET cdESC;
				   PICTURE "@!";
				   WHEN(EMPTY(cCaracter))    					
	READ
	RESTSCREEN( 0,0,MAXROW(),MAXCOL(),cTela)
	SETCOLOR(cCor)
	SETCURSOR(nCursor)
	IF !EMPTY(CCARACTER)
		CECCMER->(DBSETORDER(1))
		DBGOTOP()
		Existe(ALLTRIM(cCaracter),[Mercadoria nÆo tem cadastro],.F.,ALIAS(SELECT()),1,,,,,.T.)    	
	ENDIF	
	IF !EMPTY(cdESC)
		CECCMER->(DBSETORDER(3))
		DBGOTOP()
		Existe(ALLTRIM(cdESC),[Mercadoria nÆo tem cadastro],.F.,ALIAS(SELECT()),3,,,,,.T.)
	ENDIF	
	oBrowse:refreshAll()
RETURN(NIL)

FUNCTION ChecaMov(tMov,modo)
	Do Case
		Case tMov == "CF"
		   If modo== .T.
			   @ row(),col()+2 say "Entrada por Compra Fiscal             "
				Return( .t. ) 
			Else
				Return ( "Entrada por Compra Fiscal             " )
			EndIf
		Case tMov == "CV"
		   If modo== .T.
			   @ row(),col()+2 say "Cancelamento de vendas                "
				Return( .t. ) 
			Else
				Return ( "Cancelamento de vendas                " )
			EndIf	
		Case tMov == "CD"
			If modo == .T.
				@ row(),col()+2 say "Devolu‡Æo de Compra Fiscal           "
				Return( .t. ) 
			Else
				Return ( "Devolu‡Æo de Compra Fiscal           " )
			EndIf
		Case tMov == "CP"
			If modo == .T.
				@ row(),col()+2 say "Complemento de Pre‡o - Entra so Valor"
				Return( .t. )
			Else
				Return( "Complemento de Pre‡o - Entra s¢ Valor" )
			Endif
		Case tMov == "VE"
			If modo == .T. 
				@ row(),col()+2 say "Sa¡da por Venda Fiscal               "
				Return( .t. ) 
			Else
				Return( "Sa¡da por Venda Fiscal               " )
			EndIf
	   Case tMov == "VD"
			If modo == .T.
				@ row(),col()+2 say "Devolu‡Æo de Sa¡da Fiscal            "
				Return( .t. ) 
			Else
				Return ("Devolu‡Æo de Sa¡da Fiscal            ")
			Endif
		Case tMov == "TR"
			If modo == .T.
				@ row(),col()+2 say "Transferencias - Movimentos Internos "
				Return( .t. ) 
			Else
			 	Return ("Transferencias - Movimentos Internos ")
			Endif
		Case tMov == "RQ"
			If modo == .T.
				@ row(),col()+2 say "Requisicoes - Loja para Loja "
				Return( .t. ) 
			Else
			 	Return ("Requisicoes - Loja para Loja ")
			Endif	
		Case tMov == "TC"
			If modo == .T.
				@ row(),col()+2 say "Trocas de mercadorias"
				Return( .t. ) 
			Else
			 	Return ("Trocas de mercadorias")
			Endif		
		Other
			If modo == .T.
				@ row(),col()+2 say "Movimento nÆo Existe - F1 Verifica  "
 				Return( .F. ) 
			Else
				Return("Movimento nÆo Existe - F1 Verifica  ")
			Endif
 	EndCase

RETURN(NIL)

FUNCTION ChecaStatus(tSta,modo)
	Do Case
                Case tMov == "N"
		   If modo== .T.
                           @ row(),col()+2 say "Normal                "
				Return( .t. )
                   Endif

                Case tMov == "A"
		   If modo== .T.
                          @ row(),col()+2 say "Somente Comtra A Vista"
                          Return( .t. )
                   Endif

                Case tMov == "B"
			If modo == .T.
                                @ row(),col()+2 say "Cliente Bloqueado    "
				Return( .t. ) 
			EndIf

		Other
			If modo == .T.
                                @ row(),col()+2 say "Status  nÆo Existe   "
 				Return( .F. )
                        Endif
        EndCase
RETURN(NIL)






FUNCTION Autores(nTempo)
	LOCAL cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL())
	LOCAL cCor := SETCOR(m->cEdicao)
	IF nTempo == NIL
		nTempo := 0
	ENDIF	
	BOX(7,30,22,60,M->FR,127,3,8)
   SETCOR(m->cEdicao)
   @ 08,31 SAY "     Roberto Fal‡Æo Rocha       "
	@ 09,31 SAY "  Waldemir Litaiff Vaconcelos   "
	@ 10,31 SAY "     Analistas de sistemas      "
	@ 11,31 SAY "                                "
	@ 12,31 SAY "Conhecimentos nas linguagens :  "
	@ 13,31 SAY "           Clipper              "
	@ 14,31 SAY "           Pascal               "
	@ 15,31 SAY "             C                  "
	@ 16,31 SAY "           Delphi               "
	@ 17,31 SAY "    Telefones para contato:     "
	@ 18,31 SAY "                                "
	@ 19,31 SAY "  Residencial.: (092) 651-2613  "
	@ 20,31 SAY "  Celular.....: (092) 981-7655  "
	@ 21,31 SAY "  Comercial...: (092) 644-3100  "
	M_SQUEAK()
	MINKEY(nTempo)	
	IF nTempo == 0
		RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
		SETCOR(cCor)
	ENDIF	
RETURN(NIL)	

FUNCTION Sistema(nTempo)
	LOCAL cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL())
	LOCAL cCor := SETCOR(m->cEdicao)
	IF nTempo ==  NIL
		nTempo := 0
	ENDIF	
	BOX(7,19,19,71,M->FR,127,3,8)
   @ 08,20 SAY "Sistema de Controle de Estoque Comercial (CEC) v3.5"
	@ 09,20 SAY "                                                   "
	@ 10,20 SAY "            por: Roberto FalcÆo Rocha              "
	@ 11,20 SAY "                 Waldemir Litaiff Vasconcelos      "
	@ 12,20 SAY "                                                   "
	@ 13,20 SAY "                  W&R Inform tica                  "
	@ 14,20 SAY "             Solu‡äes do futuro agora              "
	@ 15,20 SAY "                                                   "
	@ 16,20 SAY "                Novembro de 1995                   "
	@ 17,20 SAY "                                                   "
	@ 18,20 SAY "           Todos os direitos reservados            "
	M_SQUEAK()
	MINKEY(nTempo)	
	RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
	SETCOR(cCor)
RETURN(NIL)
	
FUNCTION Visualizar(cVar)
	LOCAL nOrdem,;
			cDesc,;
			nArea := SELECT()
			
	DO CASE
		CASE cVar == "CODIGOM" .OR. cVar == "MERCLOJ"
			cVar := &cVar
			SELECT("CECCMER")
			nOrdem := INDEXORD()
			DBSETORDER(1)
			CECCMER->(DBSEEK(cVar))
			cDesc := CECCMER->DESCRIM
			DBSETORDER(nOrdem)
			SELECT(nArea)
			M_DISPLAY(cDesc,23)
		CASE cVar == "FORNECM" .OR. cVar == "CODIGOF"
			cVar := &cVar
			SELECT("CECCFOR")
			nOrdem := INDEXORD()
			DBSETORDER(1)
			CECCFOR->(DBSEEK(cVar))
			cDesc := CECCFOR->NOMECLF
			DBSETORDER(nOrdem)
			SELECT(nArea)
			M_DISPLAY(cDesc,23)	
		CASE cVar == "CODLINM" .OR. cVar == "CODLIN"
			cVar := &cVar
			SELECT("CECTLIN")
			nOrdem := INDEXORD()
			DBSETORDER(1)
			CECTLIN->(DBSEEK(cVar))
			cDesc := CECTLIN->NOMLIN
			DBSETORDER(nOrdem)
			SELECT(nArea)
			M_DISPLAY(cDesc,23)		
		CASE cVar == "CODDIVM" .OR. cVar == "CODDIV"	
			cVar := &cVar
			SELECT("CECTDIV")
			nOrdem := INDEXORD()
			DBSETORDER(1)
			CECTDIV->(DBSEEK(cVar))
			cDesc := CECTDIV->NOMDIV
			DBSETORDER(nOrdem)
			SELECT(nArea)
			M_DISPLAY(cDesc,23)	
		CASE cVar == "CODILOJ" .OR. cVar == "CODLOJTL" .OR. cVar == "CODLOJ"
			cVar := &cVar
			SELECT("CECTLOJ")
			nOrdem := INDEXORD()
			DBSETORDER(1)
			CECTLOJ->(DBSEEK(cVar))
			cDesc := CECTLOJ->NOMLOJTL
			DBSETORDER(nOrdem)
			SELECT(nArea)
			M_DISPLAY(cDesc,23)		
		CASE cVar == "CODIGOC" 
			cVar := &cVar
			SELECT("CECCCLI")
			nOrdem := INDEXORD()
			DBSETORDER(1)
			CECCCLI->(DBSEEK(cVar))
			cDesc := CECCCLI->NOMECLC
			DBSETORDER(nOrdem)
			SELECT(nArea)
			M_DISPLAY(cDesc,23)			
		CASE cVar == "CODVEN" .OR. cVar == "NCODVENDEDOR"
			cVar := &cVar
			SELECT("CECCVEN")
			nOrdem := INDEXORD()
			DBSETORDER(1)
			CECCVEN->(DBSEEK(STR(cVar,5)))
			cDesc := CECCVEN->NOMVEN
			DBSETORDER(nOrdem)
			SELECT(nArea)
			M_DISPLAY(cDesc,23)			
	ENDCASE
	
RETURN(.T.)			
			
			
FUNCTION FuncaoF6(oBrowse,cOpcao)
	DO CASE
		CASE cOpcao=="CECM5000"
			AtualizationOfAll(oBrowse)
	ENDCASE
RETURN(NIL)