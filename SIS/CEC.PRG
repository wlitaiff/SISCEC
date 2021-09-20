// Sistemas de Controle de Estoque Comercial
// W&R Informatica Ltda
// 12 de Outubro de 1995
// Roberto Falcao Rocha
// Modulo principal


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
#define MTROCAS          10      // Acerto
#define MCOMPRAFIS       28
#define MREQUISICOES     29
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
#define CFICHAKARDEX       11
#define CCONSULTAMOV       55
#define CVENDASVENDEDOR    63
#DEFINE CPENDENCIAS        72
#DEFINE CCOMPRACLIENTES    76
#DEFINE CSALDOESTOQUE      98

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
#define RCURVAABC         64
#define FINAN             71

// Menu "Inventario"
#define INVENTARIO    500000
#define PREPARQINV    13           // - CECI1000=ZERA CECTRINV E COPIA MOV P/ MOI
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
#DEFINE FINANCAS 		 1000000
#DEFINE CRECEBER 		 73
#DEFINE CPAGAR   		 74
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
#DEFINE FCONCPAGDPF   85				// "Duplicatas Pendentes a Pagar - Fornecedor"
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
#DEFINE FRELRPAGDPF   95				// "Duplicatas Pendentes a Pagar - Fornecedor"
#DEFINE FRELRPAGPGD   96				// "Rela‡Æo de Pagamentos do Dia"
#DEFINE FRELRPAGASD   99				// "Rela‡Æo de Pagamentos do Dia"
#DEFINE FRELRRECEBI  100            //  Duplicatas Recebidas
//#DEFINE FCTPAGACHEQ   1230000       // Pagamento com Baixa autom tica do Cta. a Pagar e emissao de cheques

// Ultima opcao = 100 - EM 29-01-1999

// Variaveis para o menu
STATIC hMenu,;
		 hFinancas,;
		 hArquivos,;
		 hMovimentos,;
		 hConsultas,;
		 hRelatorios,;
		 hFiscal,;
		 hLivro,;
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

FUNCTION MenuPrincipal(Cores)
	LOCAL cCor    := SETCOLOR()
	LOCAL nCursor := SETCURSOR ( 1 )
	LOCAL GETLIST := {}
	PUBLIC cEdicao,;
	    cError1,;
		 cError2,;
	    cError3,;
	    cError4,;
	    cBTITULO,;
       cBMOVER,;
		 cBDADOS,;
	    cBSTATUS,;   
	    cBFUNCOES,;  
	    cBTECLAS,;   
	    cBRODAPE,;   
	    cBCERCADURA,;
	    cBDELETADO,;
	    cbMBROWSE,; 
	    cBMVBROWSE,;
		 cJanTitu,;
	 	 cJan,;
	    CQUADRO
		 
IF UPPER(IF(CORES#NIL,CORES,"A"))=="M"
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
	SETCANCEL(.F.)
	SET CONFIRM ON
	SET WRAP ON
   SET SCOR OFF
	SET DELE ON
	SET BELL ON
	SET DATE TO BRIT
	SET CENTURY ON
	
	// Variaveis gerais
	PRIVATE quadro01:="ÛßÛÛÛÜÛÛ",;
           quadro02:="ÛßÛÛÛÜÛÛ ",;
			  fr:="ÖÄ·º½ÄÓº "
			  
	CLEAR SCREEN 
	SYSARQ("CEC")
	
	IF !ARQNTX("CECCPAS")
		RETURN(NIL)
	ENDIF	
	
	PRIVATE cNivel     := REPL  ( "0", 64 )
	PRIVATE cSenha     := SPACE ( 15 )
	PRIVATE cUsuario   := SPACE ( 20 )
	PRIVATE cSubNtx    := SPACE ( 4 )          // PARA NOME DO INDICE DA SUBNTX
	PRIVATE PTEMPODESC := 60
	SETCURSOR ( 1 )
	
	SetCor(cEdicao)
	Box( 16,12,18,70,fr,127,03,08 )
	@ 17,14 SAY "Usu rio:" GET cUsuario PICTURE "@!" VALID !EMPTY(cUsuario) .AND. Existe ( cUsuario, "Usu rio n„o cadastrado", .F. )
	READ
	IF LASTKEY() == 27
		SetCor ( cCor )
		SETCURSOR ( nCursor )
		DBCLOSEALL()
		CLEAR SCREEN
		QUIT
	ENDIF	
	cSenha := PASS()

   IF ! ( cSenha == ALLTRIM(Criptografa ( CECCPAS -> SENHA,cUsuario,.F.)) )
		M_DISPLAY ( "Usu rio n„o autorizado", 79 )
		SetCor ( cCor )
		SETCURSOR ( nCursor )
		DBCLOSEALL()
		CLEAR SCREEN
		QUIT
   ENDIF	
	
	cNivel  := Criptografa ( CECCPAS -> ACESSO,cSenha,.F.)
	cSubntx := (CECCPAS -> ARQSUBNTX)
	
	DBCLOSEAREA()
	PRIVATE  sNom,;
        sCGC,;
        sIns,;
        sSen,;  
        sEnd,;
        sLpt,;
        sEsc,;
        sLog,;
        sDat
	
	IF !ARQNTX("CECCSET")
		RETURN(NIL)
	ENDIF	 	
	DBGOTOP ()
	sNom := Criptografa ( CECCSET -> NOMEMPS, "HAWK", .F. ) // Nome da empresa
	sCGC := Criptografa ( CECCSET -> NUMCGCS, "HAWK", .F. ) // CGC
	sIns := Criptografa ( CECCSET -> INSESTS, "HAWK", .F. ) // Inscricao estadual
	sEnd := Criptografa ( CECCSET -> ENDCOMS, "HAWK", .F. ) // Endereco
	sLog := Criptografa ( CECCSET -> NOMLOGS, "HAWK", .F. ) // Logotipo
	sSen := Criptografa ( CECCSET -> PASSWDS, "HAWK", .F. ) // Senha
	sDat := CTOD(Criptografa ( CECCSET -> DATAEXP, "HAWK", .F. )) // Senha
	sLpt := CECCSET -> PORTALP // Porta de impressao
	sEsc := CECCSET -> CHSCAPE // Tipo de impressao
	PTEMPODESC := CECCSET->TEMPO // Tempo da tela de descanso
	LPTSET(1,sLpt)
	IF !EMPTY(sDat)
		IF DATE()>sDat .OR. CECCSET->HAWK=CHR(255)
			LOCK_REGISTRO(.T.)
			CECCSET->HAWK := CHR(255)
			DBUNLOCK()
			DBCLOSEAREA()
			CLEAR SCREEN
			cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL())
			M_message("Esta copia perdeu a validade, e sera destruida",79)
			INKEY(2)
			RESTSCREEN(0,0,MAXROW(),MAXCOL(),CtELA)
			Sistema(2)
			Autores(2)
			!del *.exe
		ENDIF
	ENDIF	
	DBCLOSEAREA ()		 		
	SETKEY(K_F12,{||CALCU()})        // Calculadora
	SETKEY(K_F11,{||CALEN()})        // Calendario
	SETKEY(K_F9 ,{||Acessa_Editor() } )
	
	// Criacao do Menu
	CriaMenu()
	MainWindow("Sistema de Controle de Estoque Comercial")
	
   DO WHILE .T.
		BarActivate( hMenu )
   ENDDO
	
RETURN(NIL)

STATIC FUNCTION CriaMenu()

	hMenu := BarNew()

   // Cria Menus Principais
   hArquivos     := MenuNew("~Arquivos")
	hFinancas     := MenuNew("F~inan‡as")
   hMovimentos   := MenuNew("~Movimentos")
   hConsultas    := MenuNew("~Consultas")
	hRelatorios   := MenuNew("~Relatorios")
	hRMercadorias := MenuNew("~Mercadorias")
	hFiscal		  := MenuNew("~Fiscal")
	hLivro  		  := MenuNew("~Livro Fiscal")
	hRAnaliseMov  := MenuNew("~Analise de Movimentos")     // submenu
	hRMEstoque    := MenuNew("~Saldo de estoque")  	
	hInventario   := MenuNew("Inven~tario")
	hUtilitarios  := MenuNew("~Utilitarios")
	hSobre        := MenuNew("~Sobre")
	//hMCurvaAbc    := MenuNew("Gerar ~Curva ABC")
	hMCVolume     := MenuNew("~Volume de vendas")
	hFConsultas   := MenuNew("~Consultas")
	hFConRecebe   := MenuNew("Contas a ~Receber")
	hFConPagar    := MenuNew("Contas a ~Pagar")
	hFRelatorios  := MenuNew("~Relatorios")
	hFRelRecebe   := MenuNew("Contas a ~Receber")
	hFRelPagar    := MenuNew("Contas a ~Pagar")
	
   //Menu de Arquivos
	PromptAdd(hArquivos,AMERCADORIAS,"~Mercadorias")
	PromptAdd(hArquivos,ALOJAS,"Mercadorias/~Lojas")
	PromptAdd(hArquivos,AVENDEDORES,"~Vendedores" )
	PromptAdd(hArquivos,ACLIENTES,"~Clientes") 
	PromptAdd(hArquivos,AFORNECEDORES,"~Fornecedores")
	PromptAddLine(hArquivos)
 	PromptAdd(hArquivos,ALINHAS,"~Grupos de mercadorias")
	PromptAddLine(hArquivos)
	PromptAdd(hArquivos,ATLOJAS,"Lojas/V~endas")
	PromptAddLine(hArquivos)
	PromptAdd(hArquivos,ASAIR,"~Saida     ALT-X")
	//Menu de Movimentos                                          // DO, NOS PROGRAMAS:
	PromptAdd(hMovimentos,MCOMPRAFIS   ,"~Movimentacoes      ")   // CECM2000
        PromptAdd(hMovimentos,MTROCAS   ,"Acer~to   ")           // CECM1000
	PromptAdd(hMovimentos,MPEDIDOVEN   ,"~Atendimento Balcao ")   // CECM4000
	PromptAdd(hMovimentos,MVENDAS      ,"~Baixa Vendas Balcao")   // CECM5000
	//Menu Fiscal
	PromptAdd(hFiscal,FVENDAS,"~Vendas")
	PromptAdd(hFiscal,FCANCELA,"~Cancelamento")
	PromptAdd(hFiscal,FLEITURAX,"~Leitura X")
	PromptAdd(hFiscal,FREDUCAOZ,"~Redu‡Æo Z")
	PromptAdd(hFiscal,FMENSAGEM,"~Mensagens")
	PromptAdd(hFiscal,FBOLETO,"~Boleto bancario")
	
	//Menu de Consultas
	PromptAdd(hConsultas,CFICHAKARDEX,"~Ficha Kardex por Item ")     //CECC1000
	PromptAdd(hConsultas,CCONSULTAMOV,"~Movimento Por Tipo ")  		  //CECC2000
	PromptAdd(hConsultas,CSALDOESTOQUE,"~Saldo Estoque ")  		  	  //CECC6000
	PromptAdd(hConsultas,CVENDASVENDEDOR,"~Vendas / Vendedor ")      //CECC3000
	PromptAddLine(hConsultas)
	PromptAdd(hConsultas,CPENDENCIAS,"~Pendecias / Clientes")        // CECC4000
	PromptAdd(hConsultas,CCOMPRACLIENTES,"~Compras por Clientes")
	//Menu de Relatorios
	PromptAddSub(hRelatorios,RMERCADORIAS,hRMercadorias)
		PromptAdd(hRMercadorias,RMGERAL,"~Geral")
		PromptAdd(hRMercadorias,RMNMOVIMENTADOS,"~NÆo movimentados")
		PromptAdd(hRMercadorias,RMPRECOS,"~Pre‡os")
		PromptAdd(hRMercadorias,RMMINIMO,"~Estoque m¡nimo")
		PromptAddSub(hRMercadorias,RMESTOQUE,hRMEstoque)
			PromptAdd(hRMEstoque,RMEGERAL,"~Geral")
			PromptAdd(hRMEstoque,RMELOJA,"~Loja")
        PromptAdd(hRMercadorias,FINAN,"~F¡sico/Financeiro")
	PromptAdd(hRelatorios,RVENDEDORES,"~Vendedores")		
	PromptAdd(hRelatorios,RCLIENTES,"~Clientes")		
	PromptAdd(hRelatorios,RFORNECEDORES,"~Fornecedores")		
	PromptAddLine(hRelatorios)
	PromptAdd(hRelatorios,RLINHAS,"~Linhas")		
	PromptAdd(hRelatorios,RDIVISOES,"~Divisoes")
	PromptAddLine(hRelatorios)	
		PromptAddSub(hRelatorios,RANALISEMOV,hRAnalisemov)
			PromptAdd(hRAnalisemov,RANAPORMOVGERAL,"~Por Movimento ou Geral")	//cecr7100	
			PromptAdd(hRAnalisemov,RANADASCOMPRAS ,"Analise das ~Compras")		//cecr7200
			PromptAdd(hRAnalisemov,RANADASVENDAS  ,"Analise das ~Vendas")		//cecr7300
			PromptAdd(hRAnalisemov,RSINTETICO  ,"Analise das Vendas ~Sintetica")//cecr7400
			PromptAdd(hRAnalisemov,RCURVAABC  ,"Analise da Curva ~ABC")//cecr7500
	//Menu do Livro Fiscal
	PromptAdd(hLivro,LFMANUTENCAO ,"Manuten‡Æo dos ~Livros")
	PromptAdd(hLivro,LFENTRADA    ,"Livro de ~Entrada")
	PromptAdd(hLivro,LFSAIDA      ,"Livro de ~Sa¡da")
	PromptAdd(hLivro,LFAPURACAO   ,"~Apura‡Æo ICMS")
	//PromptAdd(hLivro,LFDAM        ,"~D.A.M")
	// Menu de Inventario
	PromptAdd(hInventario,PREPARQINV ,"~Preparar Arquivos")
	PromptAdd(hInventario,LANCAMEINV ,"~Lancamento de Inventario")
	PromptAdd(hInventario,CONFEREINV ,"Lista para ~Conferencia")
	PromptAdd(hInventario,ATUALIZAINV,"~Atuliza‡Æo do Inventario")
	PromptAdd(hInventario,SALDODOINV ,"~Saldo do Inventario")
	PromptAdd(hInventario,VARIACAOINV,"~Varia‡äes de Inventario")
	PromptAdd(hInventario,MODELO7INV ,"~Registro de Inventario Mod. 7")
	// Menu Finan‡as  ****** Contas a Pagar e Receber ******
	PromptAdd(hFinancas,CRECEBER,"Contas a ~Receber")
	PromptAdd(hFinancas,CPAGAR,"Contas a ~Pagar")
	PromptAddLine(hFinancas)
		PromptAddSub(hFinancas,FCONSULTAS,hFConsultas)
			PromptAddSub(hFConsultas,FCONRECEBER,hFConRecebe)
				PromptAdd(hFConRecebe,FCONCRECEBE,"Rela‡Æo de C. a Receber - ~Geral")
				PromptAdd(hFConRecebe,FCONCRECCLI,"Rela‡Æo de C. a Receber - ~Cliente")
				PromptAdd(hFConRecebe,FCONCCOMCLI,"~Compras de um Clientes")
				PromptAdd(hFConRecebe,FCONCRECDPT,"~Duplicatas Pendentes - Geral")
				PromptAdd(hFConRecebe,FCONCRECDPC,"Duplicatas ~Pendentes - Cliente")
				PromptAdd(hFConRecebe,FCONCRECBOR,"~Rela‡Æo de C. a Receber do Dia")
				//
			PromptAddSub(hFconsultas,FCONPAGAR  ,hFConPagar)
				//
				PromptAdd(hFConPagar,FCONCPAGAR, "Rela‡Æo de C. a Pagar - ~Geral")
				PromptAdd(hFConPagar,FCONCPAGFOR,"Rela‡Æo de C. a Pagar - ~Fornecedor")
				PromptAdd(hFConPagar,FCONCPAGDPT,"~Duplicatas Pendentes a Pagar - Geral")
				PromptAdd(hFConPagar,FCONCPAGDPF,"Duplicatas ~Pendentes a Pagar - Fornecedor")
				PromptAdd(hFConPagar,FCONCPAGPGD,"~Rela‡Æo de Pagamentos do Dia")
				//
		PromptAddSub(hFinancas,FRELATORIOS,hFRelatorios)
			PromptAddSub(hFRelatorios,FRELRECEBER,hFRelRecebe)
				//
				PromptAdd(hFRelRecebe,FRELRRECEBE,"Rela‡Æo de C. a Receber - ~Geral")
				PromptAdd(hFRelRecebe,FRELRRECCLI,"Rela‡Æo de C. a Receber - ~Cliente")
				PromptAdd(hFRelRecebe,FRELRRECDPT,"~Duplicatas Pendentes - Geral")
				PromptAdd(hFRelRecebe,FRELRRECDPC,"Duplicatas ~Pendentes - Cliente")
				PromptAdd(hFRelRecebe,FRELRRECBOR,"~Borderot - C. a Receber do Dia")
				PromptAdd(hFRelRecebe,FRELRRECEBI,"Duplicatas ~Recebidas")
				//
			PromptAddSub(hFRelatorios,FRELPAGAR  ,hFRelPagar)
				//
				PromptAdd(hFRelPagar,FRELRPAGAR ,"Rela‡Æo de C. a Pagar - ~Geral")
				PromptAdd(hFRelPagar,FRELRPAGFOR,"Rela‡Æo de C. a Pagar - ~Fornecedor")
				PromptAdd(hFRelPagar,FRELRPAGDPT,"~Duplicatas Pendentes a Pagar - Geral")
				PromptAdd(hFRelPagar,FRELRPAGDPF,"Duplicatas ~Pendentes a Pagar - Fornecedor")
				PromptAdd(hFRelPagar,FRELRPAGPGD,"~Rela‡Æo de Pagamentos do Dia")
				PromptAdd(hFRelPagar,FRELRPAGASD,"Duplicatas Pa~gas")
				//
	PromptAddLine(hFinancas)
	PromptAdd(hFinancas,RPENDENCIAS,"Clientes em ~Atraso")
	//Menu de Utilitarios
	PromptAddToggle(hUtilitarios,USOM,"~Som",{|lChecked|SET(_SET_BELL,lChecked)})
   PromptAddToggle(hUtilitarios,UROLAGEM,"~Rolagem de menus",{|lChecked|SET(_SET_WRAP,lChecked)})
   PromptAddToggle(hUtilitarios,UCONFIRMA,"~Confirma",{|lChecked|SET(_SET_CONFIRM,lChecked)})
	PromptAddToggle(hUtilitarios,UDELECAO,"R~egistros deletados",{|lChecked|SET(_SET_DELETED,lChecked)})
   PromptAdd(hUtilitarios,UDOS,"~Dos" )
	PromptAdd(hUtilitarios,UINDICES,"~Indexacao")
	PromptAdd(hUtilitarios,UCOMPACTACAO,"~Compactacao")
	PromptAdd(hUtilitarios,UCALCULADORA,"C~alculadora")
	PromptAdd(hUtilitarios,UCALENDARIO,"Ca~lendario")
	PromptAdd(hUtilitarios,UIMPRESSORA,"I~mpressora")
	PromptAdd(hUtilitarios,UCONFIGURACAO,"C~onfiguracao")
        PromptAdd(hUtilitarios,USENHA,"Acer~to Senha")
	// Menu Sobre
	PromptAdd(hSobre,SSISTEMA,"~Sistema")
	PromptAdd(hSobre,SAUTORES,"~Autores")
	// Verificar se estao ativos as opcoes
   IF SET(_SET_BELL)
      PromptCheck(hUtilitarios,USOM)
   ENDIF
   IF SET(_SET_WRAP)
      PromptCheck(hUtilitarios,UROLAGEM)
   ENDIF
   IF SET(_SET_CONFIRM)
      PromptCheck(hUtilitarios,UCONFIRMA)
   ENDIF
	IF SET(_SET_DELETED)
      PromptCheck(hUtilitarios,UDELECAO)
   ENDIF
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
   DO CASE
		CASE nEscolha == ASAIR
	      DBCLOSEALL()
			SET COLOR TO
			SETCURSOR(1)
			CLS
			QUIT
		CASE nEscolha == UDOS
			Dos()	
		CASE nEscolha == UINDICES
			CECIndices()
		CASE nEscolha == UCOMPACTACAO
			CECCompactar()		
		CASE nEscolha == UCALCULADORA
			Calcu()
		CASE nEscolha == UCALENDARIO
			Calen()		
		CASE nEscolha == UIMPRESSORA
			PrinterManeger()
		CASE nEscolha == UCONFIGURACAO	
			SETUP()
		CASE nEscolha == USENHA
			Senha()		
		CASE nEscolha == AMERCADORIAS
			CECA1000()
		CASE nEscolha == ALOJAS
			CECA2000()	
		CASE nEscolha == AVENDEDORES
			CECA3000()	
		CASE nEscolha == ACLIENTES
			CECA4000()	
		CASE nEscolha == AFORNECEDORES
			CECA5000()	
		CASE nEscolha == ALINHAS
			CECA6000()	
		CASE nEscolha == ADIVISOES
			CECA7000()		
		CASE nEscolha == ATLOJAS
			CECA8000()			
		CASE nEscolha == CPENDENCIAS .OR. nEscolha == FCONCRECDPT  .OR. nEscolha == FCONCRECDPC
			CECC4000()	
		CASE nEscolha == MCOMPRAFIS
			CECM2000()
		CASE nEscolha == MPEDIDOVEN
			CECM4000()	
		CASE nEscolha == MVENDAS
			CECM5000()		
		CASE nEscolha == CFICHAKARDEX
			CECFICHA()		
		CASE nEscolha == CCONSULTAMOV
			//CECC2000()
		CASE nEscolha == CSALDOESTOQUE
			//CECC6000()	
		CASE nEscolha == CCOMPRACLIENTES  .OR. nEscolha == FCONCCOMCLI
			CECBCCLI()
		CASE nEscolha == SAUTORES
			AUTORES()
		CASE nEscolha == SSISTEMA
			SISTEMA()	
		CASE nEscolha == RMGERAL 
			CECR1100()
		CASE nEscolha == RMNMOVIMENTADOS
			CECR1200()
		CASE nEscolha == RMPRECOS
			CECR1300()
		CASE nEscolha == RMMINIMO
			CECR1400()				
		CASE nEscolha == RMEGERAL
			CECR1510()
		CASE nEscolha == RMELOJA
			CECR1520()		
		CASE nEscolha == RVENDEDORES
			CECR2000()		
		CASE nEscolha == RCLIENTES
			CECR3000()		
		CASE nEscolha == RFORNECEDORES
			CECR4000()		
		CASE nEscolha == RLINHAS
			CECR5000()		
		CASE nEscolha == RDIVISOES
			CECR6000()
		CASE nEscolha == RANAPORMOVGERAL
			CECR7100()
		CASE nEscolha == RANADASCOMPRAS
			CECR7200()
		CASE nEscolha == RANADASVENDAS
			nRelVenda:=ALERT("Relatorio de Vendas",{"Anal¡tico","Sint‚tico"})
			IF nRelVenda==1
				CECR7300()
			else 
				CECR7310()
			ENDIF							
		CASE nEscolha == MCPRECOVENDA
			CECM6100()								
		CASE nEscolha == MCPRECOCOMPRA
			CECM6200()								
		CASE nEscolha == MCCUSTOMEDIO
			CECM6300()								
		CASE nEscolha == MCVVALOR
			CECM6410()								
		CASE nEscolha == MCVQUANTIDADE
			CECM6420()
			// ** Inventario
		CASE nEscolha == PREPARQINV
			CECI1000()
		CASE nEscolha == LANCAMEINV
			CECI2000()
		CASE nEscolha == CONFEREINV
			//CECI3000()
		CASE nEscolha == ATUALIZAINV
			//CECI4000()
		CASE nEscolha == SALDODOINV
			//CECI5000()
		CASE nEscolha == VARIACAOINV
			//CECI6000()
		CASE nEscolha == MODELO7INV
			CECI7000()
		CASE nEscolha == FVENDAS
			CECF1000()	
		CASE nEscolha == FCANCELA
			CECF2000()	
		CASE nEscolha == FLEITURAX
			CECF3000()			
		CASE nEscolha == FREDUCAOZ
			CECF4000()	
		CASE nEscolha == FMENSAGEM
			CECF5000()			
		CASE nEscolha == RSINTETICO
			CECR7400()				
		CASE nEscolha == CVENDASVENDEDOR
			CECC3000()					
		CASE nEscolha == RCURVAABC
			CECR7500()						
		CASE nEscolha == FBOLETO
			CECF6000()							
		CASE nEscolha == LFMANUTENCAO
			CECL1000()
		CASE nEscolha == LFENTRADA
			CECL2000()
		CASE nEscolha == LFSAIDA
			CECL3000()
		CASE nEscolha == LFAPURACAO
			CECL4000()
		CASE nEscolha == MTROCAS
			CECM1000()	
    //CASE nEscolha == MREQUISICOES
		 //CECM3000()
      CASE nEscolha == FINAN
         CECR1600()
		CASE nEscolha==FRELRRECEBE
			CECCR002()
		CASE nEscolha==FCONCRECEBE
			CECCR010()
		CASE nEscolha==FRELRRECCLI
			CECCR003()
		CASE nEscolha==CRECEBER
			CECCR100()
		CASE nEscolha==RPENDENCIAS .OR. nEscolha==FRELRRECDPT .OR. nEscolha==FRELRRECDPC
			CECCR001()
		CASE nEscolha==CPAGAR
			CECCP100()	
		CASE nEscolha==FRELRPAGAR
			CECPG001()				
		CASE nEscolha==FRELRPAGFOR
			CECPG002()
		CASE nEscolha==FRELRPAGDPT
			CECPG003()
		CASE nEscolha==FRELRPAGDPF
			CECPG004()
		CASE nEscolha==FRELRPAGPGD
			CECPG005()	
		CASE nEscolha==FRELRPAGASD
			CECPG006()
		CASE nEscolha==FRELRRECEBI
			CECCR006()  
		CASE nEscolha==FCONCPAGAR
		  	CECPG010()
		OTHERWISE
	      IF(SET(_SET_BELL),QQOUT(CHR(7)),NIL)		
	ENDCASE		
RETURN(NIL)
