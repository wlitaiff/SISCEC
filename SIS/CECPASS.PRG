
// Sistemas de Controle de Estoque Comercial
// W&R Informatica Ltda
// 14 de Outubro de 1995
// Roberto Falcao Rocha
// Modulo cadastro de usuarios

#include "OMENU.CH"
#include "INKEY.CH"
#include "MEMOEDIT.CH"

// Definicoes para o Menu 
// Menu "Arquivos" 
#define ARQUIVOS      100000
#define ASAIR         1
#define AMERCADORIAS  2
#define ALOJAS        3
#define AVENDEDORES   4
#define ACLIENTES     5
#define AFORNECEDORES 6
#define ALINHAS       7
#define ADIVISOES     8
#define ATLOJAS       9

// Menu "Movimentos"
#define MOVIMENTOS    200000
#define MPEDCOMPRA       10
#define MCOMPRAFIS       28
#define MCOTACAOPR       29
#define MPEDIDOVEN       30
#define MVENDAS          31
#define MCURVAABC     210000
#define MCPRECOVENDA     32
#define MCPRECOCOMPRA    43
#define MCCUSTOMEDIO     44
#define MCVOLUMEVENDAS   211000
#define MCVVALOR         45
#define MCVQUANTIDADE    46
// Menu "Consultas" 
#define CONSULTAS     300000
#define CFICHAKARDEX      11
#define CMOVIMENTOS       55
#define CVENDASVENDEDORES 63
#define FINAN             71
#define CPENDENCIAS       72
#DEFINE CCOMPRACLIENTES   76

// Menu "Relatorios" 
#define RELATORIOS    400000
#define RMERCADORIAS  410000
#define RMGERAL           12
#define RMNMOVIMENTADOS   33
#define RMPRECOS          34
#define RMMINIMO          35
#define RMESTOQUE     420000
#define RMEGERAL          36
#define RMELOJA           37     
#define RVENDEDORES       38
#define RCLIENTES         39
#define RFORNECEDORES     40
#define RLINHAS           41
#define RDIVISOES         42
#define RANALISEMOV   430000
#define RANAPORMOVGERAL   47
#define RANADASCOMPRAS    48
#define RANADASVENDAS     49
#define RSINTETICO        62
#define RCURVAABC        64
// Menu "Inventario"
#define INVENTARIO    500000
#define PREPARQINV    13           // - Copia o arq. Mer e Loj p/ Inv -
#define LANCAMEINV    50
#define CONFEREINV    51
#define SALDODOINV    52           
#define VARIACAOINV   53
#define MODELO7INV    54
#define ATUALIZAINV   56

// Menu "Utilitarios"
#define UTILITARIOS   600000
#define USOM          14
#define UROLAGEM      15
#define UCONFIRMA     16
#define UDELECAO      17
#define UDOS          18
#define UINDICES      19
#define UCOMPACTACAO  20
#define UCALCULADORA  21
#define UCALENDARIO   22
#define UIMPRESSORA   23
#define UCONFIGURACAO 24
#define USENHA        25
// Menu "Sobre"
#define SOBRE         700000
#define SSISTEMA      26
#define SAUTORES      27

// Menu "Fiscal"
#define FISCAL        800000
#define FVENDAS       57
#define FCANCELA      58
#define FLEITURAX     59
#define FREDUCAOZ     60
#define FMENSAGEM     61
#define FBOLETO       65

// Menu "Livros Fiscais"
#define LIVROFISCAL   900000
#define LFMANUTENCAO  66
#define LFENTRADA     67
#define LFSAIDA       68
#define LFAPURACAO    69
#define LFDAM         70

// Menu Financas      10000000
#define FINANCAS      1000000
#DEFINE CRECEBER      73
#DEFINE CPAGAR        74
#DEFINE RPENDENCIAS   75
#DEFINE FCONSULTAS    1100000
#DEFINE FCONRECEBER   1110000
#DEFINE FCONCRECEBE   77            // "Rela‡Æo de C. a Receber - Geral"
#DEFINE FCONCRECCLI   78				// "Rela‡Æo de C. a Receber - Cliente"
#DEFINE FCONCRECDPT   79				// "Duplicatas Pendentes - Geral"
#DEFINE FCONCRECDPC   80				// "Duplicatas Pendentes - Cliente"
#DEFINE FCONCRECBOR   81				// "Borderot - C. a Receber do Dia"
#DEFINE FCONCCOMCLI   97				// "Compras de um Clientes"
#DEFINE FCONPAGAR     1120000
#DEFINE FCONCPAGAR    82            // "Rela‡Æo de C. a Pagar - Geral"
#DEFINE FCONCPAGFOR   83				// "Rela‡Æo de C. a Pagar - Fornecedor"
#DEFINE FCONCPAGDPT   84				// "Duplicatas Pendentes a Pagar - Geral"
#DEFINE FCONCPAGDPC   85				// "Duplicatas Pendentes a Pagar - Fornecedor"
#DEFINE FCONCPAGPGD   86				// "Rela‡Æo de Pagamentos do Dia"
#DEFINE FRELATORIOS   1200000
#DEFINE FRELRECEBER   1210000
#DEFINE FRELRRECEBE   87            // "Rela‡Æo de C. a Receber - Geral"
#DEFINE FRELRRECCLI   88				// "Rela‡Æo de C. a Receber - Cliente"
#DEFINE FRELRRECDPT   89				// "Duplicatas Pendentes - Geral"
#DEFINE FRELRRECDPC   90				// "Duplicatas Pendentes - Cliente"
#DEFINE FRELRRECBOR   91				// "Borderot - C. a Receber do Dia"
#DEFINE FRELPAGAR     1220000
#DEFINE FRELRPAGAR    92            // "Rela‡Æo de C. a Pagar - Geral"
#DEFINE FRELRPAGFOR   93				// "Rela‡Æo de C. a Pagar - Fornecedor"
#DEFINE FRELRPAGDPT   94				// "Duplicatas Pendentes a Pagar - Geral"
#DEFINE FRELRPAGDPC   95				// "Duplicatas Pendentes a Pagar - Fornecedor"
#DEFINE FRELRPAGPGD   96				// "Rela‡Æo de Pagamentos do Dia"
#DEFINE FRELRPAGASD   99				// "Rela‡Æo de Pagamentos do Dia"
#DEFINE FRELRRECEBI  100            //  Duplicatas Recebidas


// Ultima opcao =  100        99 ******

// Variaveis para o menu
STATIC hMenu,;
	    hFinancas,;
		 hArquivos,;
		 hMovimentos,;
		 hConsultas,;
		 hFiscal,;
		 hLivro,;
		 hRelatorios,;
		 hRMercadorias,;
		 hRMEstoque,;
		 hRAnalisemov,;
		 hInventario,;
		 hUtilitarios,;
		 hSobre ,;
		 hMCurvaABC,;
		 hMCVolume,;
		 hFConsulas,;
		 hFRelatorios		 		 
		 
FUNCTION MenuPrincipal(cores)
	LOCAL cCor 	  := SETCOLOR()
	LOCAL nCursor := SETCURSOR ( 1 )
	LOCAL cTelaS,;
			nVer,;
			cSenha2
IF CORES=="M"
	cEdicao:="N/W,W+/N,,,N/W"		 	
	cError1:="BG/W"
	cError2:="N/W"
	cError3:="W+/W"
	cError4:="W+/W"
	cBTITULO:=  "W+/N"
	cBMOVER :=  "W+/W"
	cBDADOS :=  "W+/W,W+/N"
	cBSTATUS:=  "W+/N"
	cBFUNCOES :="N/W"
	cBTECLAS := "W+/W"
	cBRODAPE := "N+/W"
	cBCERCADURA:="N+/W"
	cBDELETADO:= "N/W+,W+/N"
	cbMBROWSE:=   "W+/W"
	cBMVBROWSE := "W+*/N"
	cJanTitu:="W+/W"
	cJan := "W+/W"
	CQUADRO:="N+/W"
ELSE	
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
ENDIF			
	CLEAR SCREEN
	
	IF !ARQNTX("CECCSET")
		RETURN ( NIL )
	ENDIF		
	DBGOTOP()
	PRIVATE PTEMPODESC:=180	
	IF ! ( PASS () == ALLTRIM ( Criptografa ( CECCSET -> PASSWDS, "HAWK", .F. ) ) ) 
		M_DISPLAY ( "Usu rio nÆo autorizado", 79 )
		RETURN ( NIL )
	ENDIF	
		
	PRIVATE cUsuario := SPACE ( 20 )
	PRIVATE cNivel := REPLICATE ( "0", 100)
	cNivel := "1"+cNivel
	PRIVATE cSenha := SPACE(15)
	PRIVATE cMoldura1 := "ÛßÛÛÛÜÛÛ",;
          cMoldura2 := "ÛßÛÛÛÜÛÛ ",;
			 fr:="ÖÄ·º½ÄÓº ",;
			 Quadro01 := "ÛßÛÛÛÜÛÛ",;
          Quadro02 := "ÛßÛÛÛÜÛÛ "
			 
   cSenha2 := SPACE ( 15 )
	IF !ARQNTX("CECCPAS")
		DBCLOSEALL()
		RETURN(NIL)
	ENDIF	
	//
	SETCANCEL ( .F. )
	SET DATE TO BRITISH
	SET SCORE OFF
	SET CONFIRM ON
	SET EXACT ON
	MainWindow("Sistema de Controle de Estoque Comercial - Usuarios")
	DO WHILE .T.
		cUsuario := SPACE ( 20 )
		cNivel := REPLICATE ( "0", 100)
		cNivel := "1"+cNivel
		cSenha := SPACE(15)
	   cSenha2 := SPACE ( 15 )
		SETCURSOR ( 1 )
		SetCor("B/W,W+/Bg,,,B/W")
		Box( 16,12,18,70,fr,127,03,08 )
		@ 17,14 SAY "Usu rio:" GET cUsuario PICTURE "@!" VALID !EMPTY(cUsuario)
		READ
		IF LASTKEY() == 27 
			SetCor ( cCor )
			SETCURSOR ( nCursor )
			DBCLOSEALL()
			CLEAR SCREEN
			QUIT
		ENDIF	
		cTelaS := SAVESCREEN ( 19, 12, 22, 71 )
		IF ! ( DBSEEK ( cUsuario ) )
			M_DISPLAY ( "Novo usu rio , entre com a senha.", 23 )
			Box( 19,12,21,70,fr,127,03,08 )
			nVer := 1
			sai := .f.
			IF LASTKEY()==27
				LOOP
			ENDIF	
			DO WHILE .T.
         	cSenha := SPACE ( 15 )
				@ 20,14 SAY IF(nVer==1,"Senha...:","Redigite:") GET cSenha   PICTURE "@!" COLOR ( "W/W" )  VALID !( EMPTY ( cSenha ) )
				READ	
				IF LASTKEY() == 27 
					SetCor ( cCor )
					SETCURSOR ( nCursor )
					sai := .t.
					EXIT
				ENDIF	
				IF nVer == 1
					cSenha2 := cSenha
				ENDIF	
				IF nVer == 2 .AND. cSenha == cSenha2
					EXIT
				ENDIF
				IF nVer == 2
					M_DISPLAY ( "Senhas diferentes, tente novamente", 79 )
					nVer := 0
				ENDIF		
				nVer ++
			ENDDO
			IF SAI 
				LOOP
			ENDIF	
		ELSE
			IF M_QUERY ( "Deseja alterar a senha ?", 23 )
				cPass := Criptografa ( CECCPAS -> SENHA , cUsuario, .F. )
				Box( 19,12,21,70,fr,127,03,08 )
				nVer := 1
				SAI := .F.
				DO WHILE .T.
			  		cSenha := SPACE ( 15 )
					@ 20,14 SAY IF(nVer==1,"Senha...:","Redigite:") GET cSenha   PICTURE "@!" COLOR ( "W/W" )  VALID !( EMPTY ( cSenha ) )
					READ	
					IF LASTKEY() == 27 
						SetCor ( cCor )
						SETCURSOR ( nCursor )
						SAI := .T.
					ENDIF	
					IF nVer == 1
						cSenha2 := cSenha
					ENDIF	
					IF nVer == 2 .AND. cSenha == cSenha2
						EXIT
					ENDIF
					IF nVer == 2
						M_DISPLAY ( "Senhas diferentes, tente novamente", 79 )
						nVer := 0
					ENDIF		
					nVer ++
				ENDDO
				IF SAI 
					LOOP
				ENDIF	
			ELSE
				cPass := Criptografa ( CECCPAS -> SENHA, cUsuario, .F. ) 	
				cSenha := cPass
			ENDIF
		ENDIF			
		RESTSCREEN ( 19, 12, 22, 71, cTelaS )
		SETCURSOR ( 0 )
		IF DBSEEK ( cUsuario )
			cNivel := Criptografa ( ACESSO, cPass, .F. )
		ENDIF	
		FOR x=1 TO LEN(cNivel)
			IF SUBST(cNivel,x,1)#"0" .AND. SUBST(cNivel,x,1)#"1"
				cNivel := STUFF( cNivel, x, 1, "0" )
			ENDIF	
			IF (x=1) .AND. SUBST(cNivel,x,1)#"1" 
				cNivel := STUFF( cNivel, x, 1, "1" )
			ENDIF	
		NEXT	
		CriaMenu()
		DO WHILE .T.
			BarActivate( hMenu )
   	ENDDO
	ENDDO	
RETURN(NIL)


STATIC FUNCTION CriaMenu()

	hMenu := BarNew()
	
	// Cria Menus Principais
   hArquivos   := MenuNew("~Arquivos")
	hFinancas   := MenuNew("F~inan‡as")
   hMovimentos := MenuNew("~Movimentos")
   hConsultas  := MenuNew("~Consultas")
	hRelatorios := MenuNew("~Relatorios")
	hRMercadorias := MenuNew("~Mercadorias")
	hRAnalisemov  := MenuNew("~Analise de Movimentos")
	hRMEstoque    := MenuNew("~Saldo de Estoque")
	hInventario   := MenuNew("~Inventario")
	hUtilitarios  := MenuNew("~Utilitarios")
	hFiscal       := MenuNew("~Fiscal")
	hLivro  		  := MenuNew("~Livro Fiscal")
	hSobre        := MenuNew("~Sobre")
	hMCurvaAbc    := MenuNew("Gerar Curva ~ABC")
	hMCVolume     := MenuNew("~Volume de vendas")
	hFConsultas   := MenuNew("~Consultas")
	hFConRecebe   := MenuNew("Contas a ~Receber")
	hFConPagar    := MenuNew("Contas a ~Pagar")
	hFRelatorios  := MenuNew("~Relatorios")
	hFRelRecebe   := MenuNew("Contas a ~Receber")
	hFRelPagar    := MenuNew("Contas a ~Pagar")
	
   //Menu de Arquivos
	PromptAddToggle(hArquivos,AMERCADORIAS,"~Mercadorias", { | lChecked | IsChecked ( lChecked,2 ) } )
	PromptAddToggle(hArquivos,ALOJAS,"~Lojas", { | lChecked | IsChecked ( lChecked,3 ) } )
	PromptAddToggle(hArquivos,AVENDEDORES,"~Vendedores" , { | lChecked | IsChecked ( lChecked,4 ) } )
	PromptAddToggle(hArquivos,ACLIENTES,"~Clientes", { | lChecked | IsChecked ( lChecked,5 ) } ) 
	PromptAddToggle(hArquivos,AFORNECEDORES,"~Fornecedores", { | lChecked | IsChecked ( lChecked,6 ) } )
	PromptAddLine(hArquivos)
	PromptAddToggle(hArquivos,ALINHAS,"~Linhas de mercadorias", { | lChecked | IsChecked ( lChecked,7 ) } )
	PromptAddToggle(hArquivos,ADIVISOES,"~Divisoes das mercadorias", { | lChecked | IsChecked ( lChecked,8 ) } )
	PromptAddToggle(hArquivos,ATLOJAS,"V~endas", { | lChecked | IsChecked ( lChecked,9 ) } )
	PromptAddLine(hArquivos)
	PromptAdd(hArquivos,ASAIR,"~Saida     ALT-X")
	//Menu de Movimentos
	PromptAddToggle(hMovimentos,MPEDCOMPRA   ,"~Pedido de Compra", { | lChecked | IsChecked ( lChecked,10 ) } )
	PromptAddToggle(hMovimentos,MCOMPRAFIS   ,"~Entradas (Compras)",{ | lChecked | IsChecked ( lChecked,28 ) } )
	PromptAddToggle(hMovimentos,MCOTACAOPR   ,"Cotacao de ~Venda",{ | lChecked | IsChecked ( lChecked,29 ) } )
	PromptAddToggle(hMovimentos,MPEDIDOVEN   ,"~Atendimento Balcao",{ | lChecked | IsChecked ( lChecked,30 ) } )
	PromptAddToggle(hMovimentos,MVENDAS      ,"~Baixar Venda (Saidas)",{ | lChecked | IsChecked ( lChecked,31 ) } )
	PromptAddSub(hMovimentos,MCURVAABC,hMCurvaABC)
		PromptAddToggle(hMCurvaABC,MCPRECOVENDA,"Pre‡o de ~venda",{ | lChecked | IsChecked ( lChecked,32 ) } )
		PromptAddToggle(hMCurvaABC,MCPRECOCOMPRA,"Pre‡o de ~compra",{ | lChecked | IsChecked ( lChecked,43 ) } )
		PromptAddToggle(hMCurvaABC,MCCUSTOMEDIO,"~Custo M‚dio",{ | lChecked | IsChecked ( lChecked,44 ) } )
		PromptAddSub(HMCurvaABC,MCVOLUMEVENDAS,hMCVolume)       
			PromptAddToggle(hMCVolume,MCVVALOR,"~Valor",{ | lChecked | IsChecked ( lChecked,45 ) } )
			PromptAddToggle(hMCVolume,MCVQUANTIDADE,"~Quantidade",{ | lChecked | IsChecked ( lChecked,46 ) } )
	//Menu de Consultas
	PromptAddToggle(hConsultas,CFICHAKARDEX,"~Ficha Kardex por Item ", { | lChecked | IsChecked ( lChecked,11 ) } )
	//PromptAddToggle(hConsultas,CMOVIMENTOS,"~Por tipo de Movimentos ", { | lChecked | IsChecked ( lChecked,55 ) } )
	PromptAddToggle(hConsultas,CVENDASVENDEDORES,"~Vendas / Vendedores", { | lChecked | IsChecked ( lChecked,63 ) } )
	PromptAddToggle(hConsultas,CPENDENCIAS,"~Pendencias / Clientes", { | lChecked | IsChecked ( lChecked,72 ) } )
	PromptAddToggle(hConsultas,CCOMPRACLIENTES,"~Compras por Clientes",{ | lChecked | IsChecked ( lChecked,76 ) } )
	//Menu Fiscal
	PromptAddToggle(hFiscal,FVENDAS,"~Vendas", { | lChecked | IsChecked ( lChecked,57 ) } )
	PromptAddToggle(hFiscal,FCANCELA,"~Cancelamento", { | lChecked | IsChecked ( lChecked,58 ) } )
	PromptAddToggle(hFiscal,FLEITURAX,"~Leitura X", { | lChecked | IsChecked ( lChecked,59 ) } )
	PromptAddToggle(hFiscal,FREDUCAOZ,"~Redu‡Æo Z", { | lChecked | IsChecked ( lChecked,60 ) } )
	PromptAddToggle(hFiscal,FMENSAGEM,"~Mensagens", { | lChecked | IsChecked ( lChecked,61 ) } )
	PromptAddToggle(hFiscal,FBOLETO,"~Boletos bancarios", { | lChecked | IsChecked ( lChecked,65 ) } )
	//Menu de Relatorios
	PromptAddSub(hRelatorios,RMERCADORIAS,hRMercadorias)
		PromptAddToggle(hRMercadorias,RMGERAL,"~Geral",{ | lChecked | IsChecked ( lChecked,12 ) } )
		PromptAddToggle(hRMercadorias,RMNMOVIMENTADOS,"~NÆo movimentados",{ | lChecked | IsChecked ( lChecked,33 ) } )
		PromptAddToggle(hRMercadorias,RMPRECOS,"~Pre‡os",{ | lChecked | IsChecked ( lChecked,34 ) } )
        PromptAddToggle(hRMercadorias,RMMINIMO,"~Estoque m¡nimo",{ | lChecked | IsChecked ( lChecked,35 ) } )
		PromptAddSub(hRMercadorias,RMESTOQUE,hRMEstoque)
			PromptAddToggle(hRMEstoque,RMEGERAL,"~Geral",{ | lChecked | IsChecked ( lChecked,36 ) } )
			PromptAddToggle(hRMEstoque,RMELOJA,"~Loja",{ | lChecked | IsChecked ( lChecked,37 ) } )
        PromptAddToggle(hRMercadorias,FINAN,"~Fisico/Financeiro",{ | lChecked | IsChecked ( lChecked,71 ) } )
	PromptAddToggle(hRelatorios,RVENDEDORES,"~Vendedores",{ | lChecked | IsChecked ( lChecked,38 ) } )		
	PromptAddToggle(hRelatorios,RCLIENTES,"~Clientes",{ | lChecked | IsChecked ( lChecked,39 ) } )		
	PromptAddToggle(hRelatorios,RFORNECEDORES,"~Fornecedores",{ | lChecked | IsChecked ( lChecked,40 ) } )		
	PromptAddLine(hRelatorios)
	PromptAddToggle(hRelatorios,RLINHAS,"~Linhas",{ | lChecked | IsChecked ( lChecked,41 ) } )		
	PromptAddToggle(hRelatorios,RDIVISOES,"~Divisoes",{ | lChecked | IsChecked ( lChecked,42 ) } )			
	PromptAddLine(hRelatorios)	
		PromptAddSub(hRelatorios,RANALISEMOV,hRAnalisemov)
			PromptAddToggle(hRAnalisemov,RANAPORMOVGERAL,"~Por Movimento ou Geral",{ | lChecked | IsChecked ( lChecked,47 ) } )	
			PromptAddToggle(hRAnalisemov,RANADASCOMPRAS ,"Analise das ~Compras"   ,{ | lChecked | IsChecked ( lChecked,48 ) } )		
			PromptAddToggle(hRAnalisemov,RANADASVENDAS  ,"Analise das ~Vendas"    ,{ | lChecked | IsChecked ( lChecked,49 ) } )		
			PromptAddToggle(hRAnalisemov,RSINTETICO  ,"Analise das Vendas ~Sintetica"    ,{ | lChecked | IsChecked ( lChecked,62 ) } )		
			PromptAddToggle(hRAnalisemov,RCURVAABC  ,"Analise da Curva ~ABC"    ,{ | lChecked | IsChecked ( lChecked,64 ) } )		
	// Menu Finan‡as
	PromptAddtOGGLE(hFinancas,CRECEBER,"Contas a ~receber" ,{ | lChecked | IsChecked ( lChecked,73 ) } )		
	PromptAddTOGGLE(hFinancas,CPAGAR,"Contas a ~pagar" ,{ | lChecked | IsChecked ( lChecked,74 ) } )				
	PromptAddSub(hFinancas,FCONSULTAS,hFConsultas)
			PromptAddSub(hFConsultas,FCONRECEBER,hFConRecebe)
				PromptAddTOGGLE(hFConRecebe,FCONCRECEBE,"Rela‡Æo de C. a Receber - ~Geral",{ | lChecked | IsChecked ( lChecked,77 ) })
				PromptAddTOGGLE(hFConRecebe,FCONCRECCLI,"Rela‡Æo de C. a Receber - ~Cliente",{ | lChecked | IsChecked ( lChecked,78 ) })
				PromptAddTOGGLE(hFConRecebe,FCONCCOMCLI,"Compras de um Clientes",				  { | lChecked | IsChecked ( lChecked,97 ) })
				PromptAddTOGGLE(hFConRecebe,FCONCRECDPT,"~Duplicatas Pendentes - Geral",{ | lChecked | IsChecked ( lChecked,79 ) })
				PromptAddTOGGLE(hFConRecebe,FCONCRECDPC,"Duplicatas ~Pendentes - Cliente",{ | lChecked | IsChecked ( lChecked,80 ) })
				PromptAddTOGGLE(hFConRecebe,FCONCRECBOR,"~Borderot - C. a Receber do Dia",{ | lChecked | IsChecked ( lChecked,81 ) })
				//
			PromptAddSub(hFconsultas,FCONPAGAR  ,hFConPagar)
				//
				PromptAddTOGGLE(hFConPagar,FCONCPAGAR, "Rela‡Æo de C. a Pagar - ~Geral",{ | lChecked | IsChecked ( lChecked,82 ) })
				PromptAddTOGGLE(hFConPagar,FCONCPAGFOR,"Rela‡Æo de C. a Pagar - ~Fornecedor",{ | lChecked | IsChecked ( lChecked,83 ) })
				PromptAddTOGGLE(hFConPagar,FCONCPAGDPT,"~Duplicatas Pendentes a Pagar - Geral",{ | lChecked | IsChecked ( lChecked,84 ) })
				PromptAddTOGGLE(hFConPagar,FCONCPAGDPC,"Duplicatas ~Pendentes a Pagar - Fornecedor",{ | lChecked | IsChecked ( lChecked,85 ) })
				PromptAddTOGGLE(hFConPagar,FCONCPAGPGD,"~Rela‡Æo de Pagamentos do Dia",{ | lChecked | IsChecked ( lChecked,86 ) })
				
				//
		PromptAddSub(hFinancas,FRELATORIOS,hFRelatorios)
			PromptAddSub(hFRelatorios,FRELRECEBER,hFRelRecebe)
				//
				PromptAddTOGGLE(hFRelRecebe,FRELRRECEBE,"Rela‡Æo de C. a Receber - Geral",{ | lChecked | IsChecked ( lChecked,87 ) })
				PromptAddTOGGLE(hFRelRecebe,FRELRRECCLI,"Rela‡Æo de C. a Receber - Cliente",{ | lChecked | IsChecked ( lChecked,88 ) })
				PromptAddTOGGLE(hFRelRecebe,FRELRRECDPT,"Duplicatas Pendentes - Geral",{ | lChecked | IsChecked ( lChecked,89 ) })
				PromptAddTOGGLE(hFRelRecebe,FRELRRECDPC,"Duplicatas Pendentes - Cliente",{ | lChecked | IsChecked ( lChecked,90 ) })
				PromptAddTOGGLE(hFRelRecebe,FRELRRECBOR,"Borderot - C. a Receber do Dia",{ | lChecked | IsChecked ( lChecked,91 ) })
				PromptAddTOGGLE(hFRelRecebe,FRELRRECEBI,"Duplicatas Recebidas",{ | lChecked | IsChecked ( lChecked,100 ) })
				//
			PromptAddSub(hFRelatorios,FRELPAGAR  ,hFRelPagar)
				//
				PromptAddTOGGLE(hFRelPagar,FRELRPAGAR ,"Rela‡Æo de C. a Pagar - Geral",{ | lChecked | IsChecked ( lChecked,92 ) })
				PromptAddTOGGLE(hFRelPagar,FRELRPAGFOR,"Rela‡Æo de C. a Pagar - Fornecedor",{ | lChecked | IsChecked ( lChecked,93 ) })
				PromptAddTOGGLE(hFRelPagar,FRELRPAGDPT,"Duplicatas Pendentes a Pagar - Geral",{ | lChecked | IsChecked ( lChecked,94 ) })
				PromptAddTOGGLE(hFRelPagar,FRELRPAGDPC,"Duplicatas Pendentes a Pagar - Fornecedor",{ | lChecked | IsChecked ( lChecked,95 ) })
				PromptAddTOGGLE(hFRelPagar,FRELRPAGPGD,"Rela‡Æo de Pagamentos do Dia",{ | lChecked | IsChecked ( lChecked,96 ) })
				PromptAddTOGGLE(hFRelPagar,FRELRPAGASD,"Duplicatas ~Pagas",{ | lChecked | IsChecked ( lChecked,99 ) }) 
	PromptAddTOGGLE(hFinancas,RPENDENCIAS,"~Clientes em atraso" ,{ | lChecked | IsChecked ( lChecked,75 ) } )				
	
	//Menu do Livro Fiscal
	PromptAddToggle(hLivro,LFMANUTENCAO ,"~Manuten‡Æo dos Livros",{ | lChecked | IsChecked ( lChecked,66 ) } )	
	PromptAddToggle(hLivro,LFENTRADA ,"Livro de ~Entrada",{ | lChecked | IsChecked ( lChecked,67 ) } )	
	PromptAddToggle(hLivro,LFSAIDA   ,"Livro de ~Sa¡da"  ,{ | lChecked | IsChecked ( lChecked,68 ) } )	
	PromptAddToggle(hLivro,LFAPURACAO,"~Apura‡Æo ICMS"   ,{ | lChecked | IsChecked ( lChecked,69 ) } )	
	PromptAddToggle(hLivro,LFDAM     ,"~D.A.M"           ,{ | lChecked | IsChecked ( lChecked,70 ) } )	
	//Menu de Inventario
	PromptAddToggle(hInventario,PREPARQINV ,"~Preparar Arquivos"            , { | lChecked | IsChecked ( lChecked,13 ) } )
	PromptAddToggle(hInventario,LANCAMEINV ,"~Lancamento de Inventario"     , { | lChecked | IsChecked ( lChecked,50 ) } )
	PromptAddToggle(hInventario,CONFEREINV ,"Lista para ~Conferencia"       , { | lChecked | IsChecked ( lChecked,51 ) } )
	PromptAddToggle(hInventario,SALDODOINV ,"~Saldo do Inventario"          , { | lChecked | IsChecked ( lChecked,52 ) } )
	PromptAddToggle(hInventario,VARIACAOINV,"~Variacoes de Inventario"      , { | lChecked | IsChecked ( lChecked,53 ) } ) 
	PromptAddToggle(hInventario,MODELO7INV ,"~Registro de Inventario Mod. 7", { | lChecked | IsChecked ( lChecked,54 ) } )
	//Menu de Utilitarios
	PromptAddToggle(hUtilitarios,USOM,"~Som", { | lChecked | IsChecked ( lChecked,14 ) } )
   PromptAddToggle(hUtilitarios,UROLAGEM,"~Rolagem de menus", { | lChecked | IsChecked ( lChecked,15 ) } )
   PromptAddToggle(hUtilitarios,UCONFIRMA,"~Confirma", { | lChecked | IsChecked ( lChecked,16 ) } )
	PromptAddToggle(hUtilitarios,UDELECAO,"R~egistros deletados", { | lChecked | IsChecked ( lChecked,17 ) } )
   PromptAddToggle(hUtilitarios,UDOS,"~Dos", { | lChecked | IsChecked ( lChecked,18 ) } )
	PromptAddToggle(hUtilitarios,UINDICES,"~Indexacao", { | lChecked | IsChecked ( lChecked,19 ) } )
	PromptAddToggle(hUtilitarios,UCOMPACTACAO,"~Compactacao", { | lChecked | IsChecked ( lChecked,20 ) } )
	PromptAddToggle(hUtilitarios,UCALCULADORA,"C~alculadora", { | lChecked | IsChecked ( lChecked,21 ) } )
	PromptAddToggle(hUtilitarios,UCALENDARIO,"Ca~lendario", { | lChecked | IsChecked ( lChecked,22 ) } )
	PromptAddToggle(hUtilitarios,UIMPRESSORA,"I~mpressora", { | lChecked | IsChecked ( lChecked,23 ) } )
	PromptAddToggle(hUtilitarios,UCONFIGURACAO,"C~onfiguracao", { | lChecked | IsChecked ( lChecked,24 ) } )
	PromptAddToggle(hUtilitarios,USENHA,"~Troca Senha", { | lChecked | IsChecked ( lChecked,25 ) } )
	// Menu Sobre
	PromptAddToggle(hSobre,SSISTEMA,"~Sistema", { | lChecked | IsChecked ( lChecked,26 ) } )
	PromptAddToggle(hSobre,SAUTORES,"~Autores", { | lChecked | IsChecked ( lChecked,27 ) } )
	
   // Adicionando menus ao menu principal
   MenuAdd(hMenu,hArquivos)
	MenuAdd(hMenu,hMovimentos)
	MenuAdd(hMenu,hFiscal)
   MenuAdd(hMenu,hConsultas)
	MenuAdd(hMenu,hRelatorios)
	MenuAdd(hMenu,hLivro)
	MenuAdd(hMenu,hFinancas)
	MenuAdd(hMenu,hInventario)
	MenuAdd(hMenu,hUtilitarios)
	MenuAdd(hMenu,hSobre)

   // Adicionando teclas rapidas
   PromptQuickKey(hMenu,hArquivos,ASAIR,K_ALT_X)
	
RETURN NIL

FUNCTION Executa(nEscolha)
	LOCAL cTela
   DO CASE
		CASE nEscolha == ASAIR
			IF ( M_QUERY ( " Confirma os dados ", 23 ) ) 
				cTela := SAVESCREEN ( 0, 0, LASTROW(), LASTCOL() )
				M_MESSAGE ( " Gravando informa‡äes do usu rio ", 23 )
				IF ! ( DBSEEK ( cUsuario ) )
					Inclui_Registro ( .T. )
				ENDIF
				Lock_Registro ( .T. )
				CECCPAS -> NOME   := Criptografa ( cUsuario, "HAWK", .T. )
				CECCPAS -> ACESSO := Criptografa ( cNivel, cSenha, .T. )
				CECCPAS -> SENHA  := Criptografa ( cSenha, cUsuario, .T. )
				CECCPAS -> ARQSUBNTX := STRZERO(RECNO(),4)
				DBUNLOCK()
				DBCOMMIT()
				DBCLOSEALL()	
				SET COLOR TO
				SETCURSOR ( 1 )
				CLEAR
				QUIT
			ELSE
				IF M_QUERY("Sai sem gravar ?",23)
					DBCLOSEALL()	
					SET COLOR TO
					SETCURSOR ( 1 )
					CLEAR
					QUIT
				ENDIF	
			ENDIF		
ENDCASE
RETURN( NIL )

FUNCTION IsChecked ( lChecked, num )
	IF lChecked
		cNivel := STUFF ( cNivel, num, 1, "1" )
		RETURN ( .F. )
	ELSE
		cNivel := STUFF ( CNivel, num, 1, "0" )
		RETURN ( .T. )					
	ENDIF
