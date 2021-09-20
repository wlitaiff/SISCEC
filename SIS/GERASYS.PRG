// Sistemas de Controle de Estoque Comercial
// W&R Informatica Ltda
// 14 de Outubro de 1995
// Roberto Falcao Rocha
// Modulo gerador de sistemas

#include "OMENU.CH"
#include "INKEY.CH"
#include "MEMOEDIT.CH"

// Vari veis dos Menus

// Menu - Arquivo 

#define A_NOVO     1100   
#define A_ABRIR	 1200
#define A_SALVAR	 1300	
#define A_DELETAR	 1400
#define A_IMPRIMIR 1500
#define A_SAIDA    1600

// Menu - Op‡”es

#define O_SALVA	 2100
#define O_CONFIRM  2200
#define O_DELE     2300
#define O_WRAP     2400

// Menu - Ajuda

#define J_CONTEUDO 3100
#define J_PROCURA  3200
#define J_COMO     3300
#define J_TUTORIAL 3400 
#define J_SOBRE    3500

STATIC hBar,;
		 hArqMenu,;
		 hOpcMenu,;
		 hAjuMenu
		 
FUNCTION MainMenu(CORES)
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
		
	PRIVATE quadro01 := "ÛßÛÛÛÜÛÛ" ,;
           quadro02 := "ÛßÛÛÛÜÛÛ ",;
			  fr := "ÖÄ·º½ÄÓº ",;
			  PTEMPODESC:=180
			  
	// SET'S
	SETCANCEL ( .F. )
	SET DATE BRITISH
	SET SCOR OFF
	SET CENTURY ON
	
	// Verifica se us rio est  autorizado
	IF PASS()#"SYSCON"
		M_DISPLAY ( "Usu rio n„o autorizado ", 79 )
		RETURN ( NIL )
	ENDIF
	
	// Vari veis de BOX
	
	// Cria Janela
			 
	CreateBar()
	
	MainWindow ( "Gerador de Sistemas v1.0 - CopyRight 1993 - by Hawk Software" )
	
	DO WHILE .T.
		BarActivate ( hBar )
   ENDDO
	
RETURN ( NIL )


STATIC FUNCTION CreateBar()

	hBar := BarNew()

   // Menus Principais
	
   hArqMenu  := MenuNew ( "~Arquivo" )
   hOpcMenu  := MenuNew ( "~Op‡”es " )
   hAjuMenu  := MenuNew ( "A~juda  " )
	
   // Menu - Arquivo
	
	PromptAdd ( hArqMenu, A_NOVO    , "~Novo              " )
	PromptAdd ( hArqMenu, A_ABRIR   , "~Abrir             " )
	PromptAdd ( hArqMenu, A_SALVAR  , "~Salvar      Ctrl+S" )
	PromptAdd ( hArqMenu, A_DELETAR , "A~pagar            " )
	PromptAddLine ( hArqMenu )
	PromptAdd ( hArqMenu, A_IMPRIMIR, "~Imprimir          " )
	PromptAddLine ( hArqMenu )
	PromptAdd ( hArqMenu, A_SAIDA   , "Sai~r         Alt+X" )
	
	// Menu - Op‡”es
	
	PromptAddToggle ( hOpcMenu, O_SALVA  , "~Salva altera‡”es", { | _SET_SALVA | _SET_SALVA := !_SET_SALVA    } )
	PromptAddToggle ( hOpcMenu, O_CONFIRM, "SET ~CONFIRM     ", { | lChecked | SET ( _SET_CONFIRM, lChecked ) } )
	PromptAddToggle ( hOpcMenu, O_DELE   , "SET ~DELE        ", { | lChecked | SET ( _SET_DELETED, lChecked ) } )
	PromptAddToggle ( hOpcMenu, O_WRAP   , "SET ~WRAP        ", { | lChecked | SET ( _SET_WRAP, lChecked )    } )
	
	// Menu - Ajuda
	
	PromptAdd ( hAjuMenu, J_CONTEUDO, "~Conte£do               " )
	PromptAdd ( hAjuMenu, J_PROCURA , "~Procura ajuda sobre ..." )
	PromptAddLine ( hAjuMenu )
	PromptAdd ( hAjuMenu, J_COMO    , "Como usar a ~ajuda      " )
	PromptAdd ( hAjuMenu, J_TUTORIAL, "~Gerasys tutorial       " )
	PromptAddLine ( hAjuMenu )
	PromptAdd ( hAjuMenu, J_SOBRE   , "~Sobre o Gerasys        " )
	
	// Op‡”es n„o dispon¡veis
	
	PromptGray ( hArqMenu, A_SALVAR   )
	PromptGray ( hArqMenu, A_DELETAR  )
	PromptGray ( hArqMenu, A_IMPRIMIR )
	PromptGray ( hOpcMenu, O_SALVA    )
	PromptGray ( hOpcMenu, O_DELE     )
	
   // Adiciona os menus de barra
	
   MenuAdd ( hBar, hArqMenu )
	MenuAdd ( hBar, hOpcMenu )
   MenuAdd ( hBar, hAjuMenu )

   // Teclas adicionais de acelera‡„o
	
   PromptQuickKey ( hBar, hArqMenu, A_SAIDA , K_ALT_X  )
	PromptQuickKey ( hBar, hArqMenu, A_SALVAR, K_CTRL_S )
	
RETURN NIL

FUNCTION EXECUTA ( nEscolha )

   DO CASE
	   CASE nEscolha == A_NOVO
		CASE nEscolha == A_ABRIR
			SETCEC()
		CASE nEscolha == A_SALVAR
		CASE nEscolha == A_DELETAR
		CASE nEscolha == A_IMPRIMIR
		CASE nEscolha == A_SAIDA
			CLEAR SCREEN
			DBCLOSEALL()
			QUIT
		CASE nEscolha == O_SALVA
		CASE nEscolha == O_CONFIRM
		CASE nEscolha == O_DELE
		CASE nEscolha == O_WRAP
		CASE nEscolha == J_CONTEUDO
	   CASE nEscolha == J_PROCURA
		CASE nEscolha == J_COMO     
		CASE nEscolha == J_TUTORIAL
		CASE nEscolha == J_SOBRE    
	ENDCASE

RETURN ( NIL )

FUNCTION SETCEC ()
	LOCAL cOldScreen := SAVESCREEN ( 06,15,24,79 )
	LOCAL nOldCursor := SETCURSOR ()
	LOCAL cOldColors := SETCOLOR ()
	LOCAL sNom,;
			sCGC,;
			sIns,;
			sEnd,;
			sLog,;
			sSen
	LOCAL GetList:={}		
	IF PASS () # "W092R0806V1113H"
		RETURN ( NIL )
	ENDIF
	IF !ARQNTX("CECCSET")	
		RETURN(NIL)
 	ENDIF
	DBGOTOP ()
	IF EOF()
		Inclui_Registro ( .T. )
	ENDIF	
	sNom := IF(!EMPTY(CECCSET->NOMEMPS),Criptografa ( CECCSET -> NOMEMPS, "HAWK", .F. ),SPACE(35)) // Nome da empresa
	sCGC := IF(!EMPTY(CECCSET->NUMCGCS),Criptografa ( CECCSET -> NUMCGCS, "HAWK", .F. ),SPACE(14)) // CGC
	sIns := IF(!EMPTY(CECCSET->INSESTS),Criptografa ( CECCSET -> INSESTS, "HAWK", .F. ),SPACE(20)) // Inscricao estadual
	sEnd := IF(!EMPTY(CECCSET->ENDCOMS),Criptografa ( CECCSET -> ENDCOMS, "HAWK", .F. ),SPACE(40)) // Endereco
	sLog := IF(!EMPTY(CECCSET->NOMLOGS),Criptografa ( CECCSET -> NOMLOGS, "HAWK", .F. ),SPACE(08)) // Logotipo
	sSen := IF(!EMPTY(CECCSET->PASSWDS),Criptografa ( CECCSET -> PASSWDS, "HAWK", .F. ),SPACE(15)) // Senha
	sDat := IF(!EMPTY(CECCSET->DATAEXP),CTOD(Criptografa ( CECCSET -> DATAEXP, "HAWK", .F. )),CTOD("  /  /    "))  // Data de expiracao da copia       
	SIFI := CECCSET->IMPFIS
	SUNF := CECCSET->ULTNF
	SETCURSOR(1)
	SetCor ("B/W,W+/BG,,,B/W") 
	Box ( 10,15,20,78,fr,127,03,08 )		
	@ 11,17 SAY "Nome da Empresa....:" GET sNom PICTURE "@!S39"
	@ 12,17 SAY "C.G.C..............:" GET sCGC PICTURE "@R 99.999.999/9999-99"
	@ 13,17 SAY "Inscri‡„o Estadual.:" GET sIns PICTURE "@X" 
	@ 14,17 SAY "Endere‡o...........:" GET sEnd PICTURE "@!"
	@ 15,17 SAY "Arq. de Logotipo...:" GET sLog PICTURE "XXXXXXXX"
	@ 16,17 SAY "Senha do Supevisor.:" GET sSen PICTURE "@K@!" COLOR "W/W" VALID !EMPTY(sSen)
	@ 17,17 SAY "Data de expira‡Æo..:" GET sDat PICTURE "@D"
	@ 18,17 SAY "VersÆo da IFiscal..:" GET sIfi PICTURE "9"
	@ 19,17 SAY "Ultima Nota Fiscal.:" GET sUNF PICTURE "9999999999"
	READ
	IF LASTKEY () == 27 .OR. !M_QUERY ( "Confirma altera‡„o ?",23 )	
		RESTSCREEN (06,15,24,79,cOldScreen )
		SETCURSOR ( nOldCursor )
		SETCOLOR ( cOldColors )
		DBCLOSEALL ()
		RETURN ( NIL ) 
	ENDIF
	IF Lock_Registro ( .F. )
		CECCSET -> NOMEMPS := Criptografa ( sNom, "HAWK", .T. )
		CECCSET -> NUMCGCS := Criptografa ( sCGC, "HAWK", .T. )
		CECCSET -> INSESTS := Criptografa ( sIns, "HAWK", .T. )
		CECCSET -> ENDCOMS := Criptografa ( sEnd, "HAWK", .T. )
		CECCSET -> NOMLOGS := Criptografa ( sLog, "HAWK", .T. )
		CECCSET -> PASSWDS := Criptografa ( sSen, "HAWK", .T. )
		CECCSET -> DATAEXP := Criptografa ( DTOC(sDat), "HAWK", .T. )
		CECCSET -> PORTALP := IF(EMPTY(CECCSET->PORTALP),1,CECCSET->PORTALP)
		CECCSET -> CHSCAPE := IF(EMPTY(CECCSET->CHSCAPE),1,CECCSET->CHSCAPE)
		CECCSET -> TEMPO := IF(EMPTY(CECCSET->TEMPO),60,CECCSET->TEMPO)
		CECCSET -> ULTNF := sUNF
		CECCSET -> IMPFIS := sIFI
	ELSE
		M_DISPLAY ( "Op‡„o cancelada pelo usu rio",79 )
	ENDIF
	RESTSCREEN (06,15,24,79,cOldScreen )
	SETCURSOR ( nOldCursor )
	SETCOLOR ( cOldColors )		
	DBCLOSEALL ()
RETURN ( NIL )