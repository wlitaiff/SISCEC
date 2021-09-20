// Sistemas de Controle de Estoque Comercial
// W&R Informatica Ltda
// 15 de Outubro de 1995
// Roberto Falcao Rocha
// Biblioteca de funcoes genericas

#include "INKEY.CH"
#include "SETCURS.CH"
#include "FILEMAN.CH"
#include "DIRECTRY.CH"
#include "MEMOEDIT.CH"
#include "ACHOICE.CH"
#include "SET.CH"
#include "HAWK.CH"

#define MY_HSEP		"ÄÂÄ"
#define MY_CSEP		" ³ "
#define MY_FSEP      "ÄÁÄ"
#define fr1          "ÚÄ¿³ÙÄÀ³ "


FUNCTION m_display(_string, _color)
local  _pback,_pstrlen,_row,_col,_col2,_col3,_pscreen,teste,_cursor
		  teste = SetCor()	
        if pcount() < 2
           _color = standard()
           _pback = enhanced()
        else
           _pback = roloc(_color)
        endif
        _pstrlen = len(_string)
        if _pstrlen < 16
           _string  = strcenter(_string,16)
           _pstrlen = 16
           elseif _pstrlen > (maxcol()-9)
                  _string  = substr(_string,1,(maxcol()-9))
                  _pstrlen = (maxcol()-9)
        endif
        _pstrlen = (_pstrlen+6)
        _row     = ((maxrow()+1)/2)-4
        _col     = (((maxcol()+1)-_pstrlen))/2
        _col2    = (((maxcol()+1)/2)-2)
        _pscreen = savescreen(_row-2,_col-1,_row+9,_col+_pstrlen+2)
        _cursor  = setcursor()
        setcursor(0)
        m_squeak()
        box(_row, _col, _row+7, _col+_pstrlen+1, m_frame()+" ", _color)
        print(_row+1,_col+4,_string,_color)
        box(_row+3, _col2, _row+5, _col2+5,m_frame(),_pback)
        print(_row+4,_col2+1," OK ",_pback)
        Minkey(0)
        restscreen(_row-2,_col-1,_row+9,_col+_pstrlen+2,_pscreen)
        setcursor(_cursor)
		  SetCor(teste)
return(0)
   	
FUNCTION m_query (string,color)
  LOCAL pactive := .T.        ,;
        retflag := .F.        ,;
        pfore   := color      ,;
        lcol    := lastcol()  ,;
        pstrlen := len(string),;
        pback                 ,;
        row                   ,;
        col                   ,;
        col2                  ,;
        col3                  ,;
        pkey                  ,;
        pscreen               ,;
		  psscreen               ,;
		  o
        colorset( @pfore, @pback)
        IF pstrlen < 16
           string  := strcenter(string,16)
           pstrlen := 16
        ELSEIF pstrlen > lcol-9
               string  := substr(string,1,(lcol-9))
               pstrlen := (lcol-9)
        ENDIF
        pstrlen := (pstrlen+6)
        row     := ((lastrow()+1) /2)-4
        col     := (((lcol+1)-pstrlen)) / 2
        col2    := (((lcol+1)/2) - 10)
        col3    := (((lcol+1)/2) + 4)

        psscreen := savescreen(row-2,col-1,row+9,col+pstrlen+1)
        box(row, col, row+7, col+pstrlen, m_frame()+" ", pfore)
        print(row+1, col+4, string, pfore)
        o := setshadow(.T.)
        box(row+3, col2, row+5, col2+6, m_frame(), pback)
        box(row+3, col3, row+5, col3+6, m_frame(), pfore)
        print(row+4, col2+1, " Sim ", pback)
        print(row+4, col3+1, " NÆo ", pfore)
        setshadow(o)
        m_squeak()

        DO WHILE (.T.)
           DO WHILE (.T.)
              DO WHILE ((pkey := waitkey()) == 0)
                 m_wait(1)
              ENDDO
              pkey := nupper(pkey)
              IF pkey == 83
                 pactive := .T.
                 retflag := .T.
                 exit
              ELSEIF (pkey == 78 .or. pkey == 27)
                     pactive := .F.
                     retflag := .T.
                     exit
                  ELSEIF ((pkey == 13) .or. (pkey == 18) .or. (pkey == 3))
                         retflag := .T.
                         exit
                      ELSEIF (pkey == 19) 
                             pactive := .T.
                             exit
                           ELSEIF (pkey == 4) 
                                  pactive := .F.
                                  exit
              ENDIF
           ENDDO    

           IF ( pactive )
              o := setshadow(.F.)
              box(row+3, col3, row+5, col3+6, m_frame(), pfore)
              print(row+4, col3+1, " N†o ",pfore)
              box(row+3, col2, row+5, col2+6, m_frame(), pback)
              print(row+4, col2+1, " Sim ", pback)
              setshadow(o)
           ELSEIF (! pactive )
                  o := setshadow(.F.)
                  box(row+3, col2, row+5, col2+6, m_frame(), pfore)
                  print(row+4, col2+1, " Sim ", pfore)
                  box(row+3, col3, row+5, col3+6, m_frame(), pback)
                  print(row+4, col3+1," N†o ",pback)
                  setshadow(o)
           ENDIF
           IF (retflag)
              exit
           ENDIF
        ENDDO
        restscreen(row-2,col-1,row+9,col+pstrlen+1,psscreen)
        return( pactive )
		  
FUNCTION Confirma (string,color)
  LOCAL pactive := .T.        ,;
        retflag := .F.        ,;
        pfore   := color      ,;
        lcol    := lastcol()  ,;
        pstrlen := len(string),;
        pback                 ,;
        row                   ,;
        col                   ,;
        col2                  ,;
        col3                  ,;
        pkey                  ,;
        pscreen               ,;
		  psscreen               ,;
        o
        colorset( @pfore, @pback)
        IF pstrlen < 16
           string  := strcenter(string,16)
           pstrlen := 16
        ELSEIF pstrlen > lcol-9
               string  := substr(string,1,(lcol-9))
               pstrlen := (lcol-9)
        ENDIF
        pstrlen := (pstrlen+6)
        row     := ((lastrow()+1))-4
        col     := (((lcol+1)-pstrlen))
        col2    := (((lcol+1)) - 10)
        col3    := (((lcol+1)) + 4)

        psscreen := savescreen(row-2,col-1,row+9,col+pstrlen+1)
        box(row, col, row+7, col+pstrlen, m_frame()+" ", pfore)
        print(row+1, col+4, string, pfore)
        o := setshadow(.T.)
        print(row+2, col+4, " Sim ", pback)
        print(row+2, col+pstrlen-9, " N„o ", pfore)
        setshadow(o)
        m_squeak()

        DO WHILE (.T.)
           DO WHILE (.T.)
              DO WHILE ((pkey := waitkey()) == 0)
                 m_wait(1)
              ENDDO
              pkey := nupper(pkey)
              IF pkey == 83
                 pactive := .T.
                 retflag := .T.
                 exit
              ELSEIF (pkey == 78 .or. pkey == 27)
                     pactive := .F.
                     retflag := .T.
                     exit
                  ELSEIF ((pkey == 13) .or. (pkey == 18) .or. (pkey == 3))
                         retflag := .T.
                         exit
                      ELSEIF (pkey == 19) 
                             pactive := .T.
                             exit
                           ELSEIF (pkey == 4) 
                                  pactive := .F.
                                  exit
              ENDIF
           ENDDO    

           IF ( pactive )
              o := setshadow(.F.)
				  print(row+2, col+pstrlen-9, "     ", pfore)
				  print(row+2, col+pstrlen-9, " N„o ", pfore)
				  print(row+2, col+4, "     ", pback)
		        print(row+2, col+4, " Sim ", pback)
              setshadow(o)
           ELSEIF (! pactive )
                  o := setshadow(.F.)
						print(row+2, col+4, "     ", pfore)
						print(row+2, col+4, " Sim ", pfore)
						print(row+2, col+pstrlen-9, "     ", pback)
				      print(row+2, col+pstrlen-9, " N„o ", pback)
                  setshadow(o)
           ENDIF
           IF (retflag)
              exit
           ENDIF
        ENDDO
        restscreen(row-2,col-1,row+9,col+pstrlen+1,psscreen)
        return( pactive )		  


function open(cArquivo,lModo)
  local cTela_x
  if lModo
     use (cArquivo) NEW exclusive 
  else
     use (cArquivo) NEW shared 
  endif
  if !neterr()
  		return(.t.)
	endif	
  cTela_x := savescreen( 0, 0,lastrow(),lastcol())
  m_message("Aguarde... Acessando "+cArquivo,79)
  do while Minkey()!=27
     if lModo
        use (cArquivo) NEW exclusive 
     else
        use (cArquivo) NEW shared 
     endif
     if !neterr()
        restscreen( 0, 0,lastrow(),lastcol(),cTela_x)
        return(.t.)
     endif
  enddo
  m_display("Acesso cancelado pelo usu rio",79)
  restscreen( 0, 0,lastrow(),lastcol(),cTela_x)
  return(.F.)
  
function lock_arquivo(modo)
  local cTela_x
  if flock()
     return .t.
  endif
  cTela_x := savescreen( 0, 0,lastrow(),lastcol())
  m_message("Aguarde... Acessando arquivo",23)
  do while modo .or. Minkey()#27
     if flock()
        restscreen( 0, 0,lastrow(),lastcol(),cTela_x)
        return(.t.)
     endif
  enddo
  m_display("Acesso cancelado pelo usu rio",79)
  restscreen( 0, 0,lastrow(),lastcol(),cTela_x)
  return .F.

function lock_registro(modo)
  local cTela_x
  If rlock()
     return .T.
  endif
  cTela_x := savescreen( 0, 0,lastrow(),lastcol())
  m_message("Aguarde... Acessando Registro",23)
  do while modo .or. Minkey()#27 
     If rlock()
        restscreen( 0, 0,lastrow(),lastcol(),cTela_x)
        return .T.
     endif
  enddo
  m_display("Acesso cancelado pelo usu rio",79)
  restscreen( 0, 0,lastrow(),lastcol(),cTela_x)
  return .F.

function inclui_registro(modo)
  local cTela_x
  append blank
  if !neterr()
     return .T.
  endif
  cTela_x := savescreen( 0, 0,lastrow(),lastcol())
  m_message("Aguarde... Incluindo Registro",23)
  do while modo .or. Minkey()!=27
     append blank
     if !neterr()
        restscreen( 0, 0,lastrow(),lastcol(),cTela_x)
        return .T.
     endif
  enddo
  m_display("Acesso cancelado pelo usu rio",79)
  restscreen( 0, 0,lastrow(),lastcol(),cTela_x)
RETURN(.F.)  

FUNCTION recuperar( oObject )
	IF SET( _SET_DELETED )
		M_DISPLAY( "Para usar esta op‡„o, delete deve estar desativado", 79 )
		RETURN ( NIL )
	ENDIF	
	IF DELETED()
	   IF m_query("Recuperar registro marcado para elimina‡„o ?",23)
			IF LOCK_REGISTRO(.F.)
				RECALL
				DBUNLOCK()
				oObject:refreshAll()
			ENDIF	
	   ENDIF
	ELSE
		M_DISPLAY("Registro nÆo esta deletado",79)
	ENDIF		
RETURN( NIL )

FUNCTION Existe (var,mens,vf,area,ordem,var2,mascara,x,y,PROXIMO)
	local volta,aat,oant,cor
	if AREA # NIL
	  aat:=Select()
	  Select(area)
	end
	IF ORDEM # NIL
	  oant:=Indexord()
	  dbSetOrder(ordem)
	end
	If dbSeek(var,if(proximo#nil,.t.,.f.))
		volta = .T.
		If vf 
			M_Display(mens,79)
		EndI	
	Else
		volta = .F.
		If !vf
			IF PROXIMO==NIL
				M_Display(mens,79)
			else
				volta:=.t.	
			ENDIF	
		EndI
	EndI
	If VAR2 # NIL .and. volta
		@ x,y Say &var2 Pict mascara
	EndI	
	if AREA # NIL
	 Select(aat)
	endif
	if ORDEM # NIL
	 dbsetorder(oant)
   endif	 
Retu(volta)

* { Seta as Cores } *

Func SetCor(cor)
	If PCount() = 0
		Retu(SetColor())
	EndI
	If IsColor()
		SetColor(cor)	
	EndI
Retu(.T.)


Func MainWindow(titulo)
	Set Curs Off
	SetCor("N/N")
	Clea Scre
	SetCor(m->cJanTitu)
	@ 00,00 Clea To 00,79
   @ 00,01 Say Padc(titulo,79)
	SetCor(m->cJan)
	@ 02,00 Clea To 23,79
	SetCor(m->CQUADRO)
	@ 02,00,23,79 Box m->quadro01
	SetCor("N/W")
	@ 24,00 Clea To 24,79
	@ 24,00 Say "    - Menus          - Movimenta‡„o        - Confirma         - Sair"
	SetCor("W+/W")
	@ 24,01 Say "F10"
	@ 24,16 Say Chr(24)+Chr(25)+Chr(26)+Chr(27)
	@ 24,39 SAY Chr(17)+Chr(196)+Chr(217)
	@ 24,56 SAY "ALT-X"
	SetCor("B/Bg")
RETU(.T.)


Func Titulo(l1,c1,l2,c2,titulo,ctitulo,cborda,borda)
   LOCAL tela,corant,COL
   corant = SetCor()
   tela = SaveScreen(l1,c1,l2,c2)
   SetCor(cborda)
   @ l1,c1,l2,c2 Box (borda)
   SetCor(ctitulo)
	col:=at(left(titulo,1),padc(titulo,c2))
   @ l1,col Say alltrim(padc(titulo,c2))
   SetCor(corant)
Retu(tela)

Func Dos()
	LOCAL tela
	local getcur := SETCURSOR(1)
	local cor:=setcolor()
	tela = SaveScreen(0,0,lastrow(),lastcol())
	Clear screen
	? "     Digite EXIT para retornar ao CEC"
	! COMMAND.COM
	RestScreen(0,0,24,79,tela)
	SetCursOR(getcur)
	setcolor(cor)
Retu(NIL)						

Function Indices(arquivo,indice,chave,condicao,unico)
	Local cor,tel,volta,x
	X:=.t.
	volta := .f.
	IF UNICO==NIL
		UNICO := .F.
	ENDIF	
	cor := SetCor()
	tel := SaveScreen(0,0,LastRow(),LastCol())
	If Open(arquivo,.T.)
	   m_message("Aguarde Indexando "+indice+"...       ",23)
		if !unico
			if EMPTY(condicao)
		   	INDEX ON &chave TO &indice eval x:=percent(indice) 
			else
		   	INDEX ON &chave TO &indice FOR &condicao eval x:=percent(indice) 
			endif
		else
			if EMPTY(condicao)
		   	INDEX ON &chave TO &indice UNIQUE eval x:=percent(indice) 
			else
		   	INDEX ON &chave TO &indice UNIQUE FOR &condicao eval x:=percent(indice) 
			endif
		endif	
		if x
			volta := .t.	
		else 
			volta := .f.	
		endif	
		DBCLOSEAREA()
		if !volta
			indice=indice+".ntx"
			ERASE (indice)
		endif	
		RestScreen(0,0,LastRow(),LastCol(),tel)
	EndI
Retu(volta)


FUNCTION Pass()
	// Declara‡äes
	LOCAL nCursor := SETCURSOR ( 0 )
	LOCAL	cCor    := SETCOLOR()
	LOCAL nTamanho:= 33
	LOCAL nLinha  := ( ( ( MAXROW() + 1 ) / 2 ) - 2 )
	LOCAL nColuna := ( ( ( MAXCOL() + 1 ) - nTamanho ) / 2 )
	LOCAL cSenha := ""
	LOCAL cTela,;
			c,;
			cTecla
			
	// Processo
	cTela := SAVESCREEN ( nLinha - 2, nColuna - 1, nLinha + 9, nColuna + nTamanho + 1 )
	BOX ( nLinha - 1, nColuna, nLinha + 4, nColuna + nTamanho, M_FRAME() + " ", 23 )
	PRINT ( nLinha, nColuna + 4, "Digite c¢digo de acesso ?", 23 )
	c := nColuna + 10
	DO WHILE ( c < ( nColuna + 25 ) )
		SETCOLOR ( "W+/W, X" )
		cTecla := MINKEY ( 0 )
		SETCOLOR (m->cError2 )
		IF c = nColuna + 10 .AND. ( ( ( cTecla < 48 .AND. cTecla # 32 ) .OR. ( cTecla > 57 .AND. cTecla < 65 );
			.OR. ( cTecla > 90 .AND. cTecla < 97 ) .OR. cTecla > 122 ) )
			IF cTecla = 27 .OR. cTecla = 13
				RESTSCREEN ( nLinha - 2, nColuna - 1, nLinha + 9, nColuna + nTamanho + 1, cTela )
				SETCURSOR ( nCursor )
				SetCor ( cCor )
				RETURN ( UPPER ( ALLTRIM ( cSenha ) ) )
			ENDIF
			LOOP
		ENDIF
		IF cTecla = 19 .OR. cTecla = 8		
			cSenha := STUFF ( cSenha, LEN ( cSenha ), 1 )
			c--
			@ nLinha + 2, c SAY " "
			LOOP
		ENDIF	
		IF c = nColuna + 25
			IF cTecla = 13
				EXIT
			ENDIF	  
			M_SQUEAK()
			LOOP
		ENDIF	
      @ nLinha + 2, c SAY "Þ"
		IF cTecla = 27 .OR. cTecla == 13
			RESTSCREEN ( nLinha - 2, nColuna - 1, nLinha + 9, nColuna + nTamanho + 1, cTela )
			SETCURSOR ( nCursor )
			SetCor ( cCor )
			RETURN ( UPPER ( ALLTRIM ( cSenha ) ) )
      ENDIF
		IF ( ( cTecla < 48 .AND. cTecla # 32 ) .OR. ( cTecla > 57 .AND. cTecla < 65 );
			.OR. ( cTecla > 90 .AND. cTecla < 97 ) .OR. cTecla > 122 ) 
			LOOP
		ENDIF
      cSenha += CHR ( cTecla )
		c++
	ENDDO
	MINKEY ( 0 )
	SETCURSOR ( nCursor )
	SetCor ( cCor)
	RESTSCREEN ( nLinha - 2, nColuna - 1, nLinha + 9, nColuna + nTamanho + 1, cTela )
RETURN ( UPPER ( ALLTRIM ( cSenha ) ) )

FUNCTION FileMan( nRowTop, nColumnTop,aFiles,cColorString)
   m->nMenuItem   := 1
   m->nTagged     := 0
   m->nFileItem   := 1
   m->nEl         := 1
   m->nRel        := 1
   m->lReloadDir  := .T.
   m->aFileMan    := {}

   // Create the array
   m->aFileMan := ARRAY( FM_ELEMENTS )

   // Resolve parameters
   m->aFileMan[ FM_ROWTOP ] := nRowTop
   m->aFileMan[ FM_COLTOP ] := nColumnTop
   m->aFileMan[ FM_ROWBOTTOM ] :=NROWTOP+IF(LEN(AFILES)>8,8,LEN(AFILES)+1)
   m->aFileMan[ FM_COLBOTTOM ] := nColumnTop+LEN(AFILES[1])

   // Color string for FileMan()
   m->aFileMan[ FM_COLOR ] := cColorString
   // Save the old color
   m->aFileMan[ FM_OLDCOLOR ] := SETCOLOR( m->aFileMan[ FM_COLOR ] )


   // Save the screen
   m->aFileMan[ FM_OLDSCREEN ] := SAVESCREEN( m->aFileMan[ FM_ROWTOP    ],;
                                           m->aFileMan[ FM_COLTOP    ],;
                                           m->aFileMan[ FM_ROWBOTTOM ]+2,;
                                           m->aFileMan[ FM_COLBOTTOM ]+2)

   CreateScreen()          // Create the initial screen, etc.
   GetFiles()              // Call the actual file chooser

   // Restore the screen
   RESTSCREEN( m->aFileMan[ FM_ROWTOP    ], ;
               m->aFileMan[ FM_COLTOP    ], ;
               m->aFileMan[ FM_ROWBOTTOM ]+2, ;
               m->aFileMan[ FM_COLBOTTOM ]+2, ;
               m->aFileMan[ FM_OLDSCREEN ] )
   // Restore the color
   SetColor( m->aFileMan[ FM_OLDCOLOR ] )

   // Back to the real world!
   RETURN( m->aFileMan[ FM_RETURNFILE ] )

/***
*  GetFiles() --> NIL
*
*
*/
   STATIC FUNCTION GetFiles
   LOCAL lDone       := .F.            // Primary loop point
   LOCAL nCurrent    := 0              // ACHOICE() result
   LOCAL nLastKey    := 0              // Last value in LASTKEY()

   TabUpdate(m->hscrollbar, m->nel, LEN( m->aFiles ), .T. )
   nCurrent := ACHOICE( m->aFileMan[ FM_ROWTOP ]+1, ;
                        m->aFileMan[ FM_COLTOP ]+1, ;
                        m->aFileMan[ FM_ROWBOTTOM ]-1, ;
                        m->aFileMan[ FM_COLBOTTOM ], ;
                        m->aFiles, .T., "ProcessKey", m->nel, m->nRel )

      m->nFileItem := nCurrent
      nLastKey := Mlastkey()
      m->aFileMan[ FM_RETURNFILE ] := 0 
      DO CASE
         CASE nLastKey == K_ENTER
            // First let's assign the filename and path to m->aFileMan
            m->aFileMan[ FM_RETURNFILE ] := nCurrent 
				 // Ok, here's the biggee

      ENDCASE
   RETURN (m->aFileMan[ FM_RETURNFILE ])

/***
*  ProcessKey( <nStatus>, <nelement>, <nRelative> ) --> nReturnValue
*
*
*/
FUNCTION ProcessKey( nStatus, nelement, nRelative )
   LOCAL nReturnValue := AC_CONT    // Set the default handler to continue

   // Update the global element/relative with the passed versions
   m->nel  := nelement
   m->nRel := nRelative

   DO CASE
   CASE nStatus == AC_IDLE
        TabUpdate( m->hscrollbar, nelement, LEN( m->aFiles ) )
      
   CASE nStatus == AC_HITTOP .OR. nStatus == AC_HITBOTTOM
      // Tried to go too far!
      TONE( 900, 1 )

   CASE nStatus == AC_EXCEPT
      // Keystroke exception
      DO CASE
      CASE MLASTKEY() == K_ESC
         nReturnValue := AC_ABORT

      CASE MLASTKEY() == K_HOME
         KEYBOARD CHR( K_CTRL_PGUP )
         nReturnValue := AC_CONT

      CASE MLASTKEY() == K_END
         KEYBOARD CHR( K_CTRL_PGDN )
         nReturnValue := AC_CONT

      CASE UPPER(CHR(MLASTKEY())) $ ;
         "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890 " .OR. ;
         MLASTKEY() == K_DEL .OR. MLASTKEY() == K_ENTER .OR. ;
         MLASTKEY() == K_F5 .OR. MLASTKEY() == K_F6

         nReturnValue := AC_SELECT

      ENDCASE

   ENDCASE

   RETURN (nReturnValue)

/***
*  CreateScreen() --> NIL
*
*
*/
STATIC FUNCTION CreateScreen

   LOCAL cFrameType  := FM_SINGLEFRAME
   LOCAL cBorderType := FM_SINGLEBORDER
   LOCAL nRow        := 0
   local cor:=setcolor("w+/w")
   // Draw the primary box
	
	BOX(m->aFileMan[ FM_ROWTOP ], m->aFileMan[ FM_COLTOP ],;
   m->aFileMan[ FM_ROWBOTTOM ], m->aFileMan[ FM_COLBOTTOM ]+1,fr1,127,3,8)
	  
   setcolor(cor) 
   // Create the scrolling thumb tab and assign it to our global static
   m->hscrollbar := TabNew( m->aFileMan[ FM_ROWTOP ],;
                         m->aFileMan[ FM_COLBOTTOM ]+1,;
                         m->aFileMan[ FM_ROWBOTTOM ],;
                         m->aFileMan[ FM_COLOR ], 1 )
   TabDisplay(m->hscrollbar)

   RETURN NIL

/***
*	TabNew()
*/

   STATIC FUNCTION TabNew( nTopRow, nTopColumn, nBottomRow, ;
						cColorString, nInitPosition )
   // Creates a new "thumb tab" or scroll bar for the specified coordinates
   LOCAL aTab := ARRAY( TB_ELEMENTS )

   aTab[ TB_ROWTOP ]	:= nTopRow
   aTab[ TB_COLTOP ]	:= nTopColumn
   aTab[ TB_ROWBOTTOM ] := nBottomRow
   aTab[ TB_COLBOTTOM ] := nTopColumn

   // Set the default color to White on Black if none specified
   IF cColorString == NIL
	  cColorString := "W/N"
   ENDIF
   aTab[ TB_COLOR ] 	:= cColorString

   // Set the starting position
   IF nInitPosition == NIL
	  nInitPosition := 1
   ENDIF
   aTab[ TB_POSITION ]	:= nInitPosition

   RETURN aTab


/***
*	TabDisplay()
*/

   STATIC FUNCTION TabDisplay(aTab)
   LOCAL cOldColor, nRow

   cOldColor := SETCOLOR( aTab[ TB_COLOR ] )

   // Draw the arrows
   // @ aTab[ TB_ROWTOP ], aTab[ TB_COLTOP ] SAY TB_UPARROW
   // @ aTab[ TB_ROWBOTTOM ], aTab[ TB_COLBOTTOM ] SAY TB_DNARROW

   // Draw the background
   FOR nRow := (aTab[ TB_ROWTOP ]+1) TO (aTab[ TB_ROWBOTTOM ]-1)
	  @ nRow, aTab[ TB_COLTOP ] SAY TB_BACKGROUND
   NEXT

   SETCOLOR( cOldColor )

   RETURN aTab


/***
*	TabUpdate()
*/

   STATIC FUNCTION TabUpdate( aTab, nCurrent, nTotal, lForceUpdate )
   LOCAL cOldColor, nNewPosition
   LOCAL nScrollHeight := (aTab[TB_ROWBOTTOM]-1)-(aTab[TB_ROWTOP])

   IF nTotal < 1
	  nTotal := 1
   ENDIF

   IF nCurrent < 1
	  nCurrent := 1
   ENDIF

   IF nCurrent > nTotal
	  nCurrent := nTotal
   ENDIF

   IF lForceUpdate == NIL
	  lForceUpdate := .F.
   ENDIF

   cOldColor := SETCOLOR( aTab[ TB_COLOR ] )

   // Determine the new position
   nNewPosition := ROUND( (nCurrent / nTotal) * nScrollHeight, 0 )

   // Resolve algorythm oversights
   nNewPosition := IF( nNewPosition < 1, 1, nNewPosition )
   nNewPosition := IF( nCurrent == 1, 1, nNewPosition )
   nNewPosition := IF( nCurrent >= nTotal, nScrollHeight, nNewPosition )

   // Overwrite the old position (if different), then draw in the new one
   IF nNewPosition <> aTab[ TB_POSITION ] .OR. lForceUpdate
	  @ (aTab[ TB_POSITION ] + aTab[ TB_ROWTOP ]), aTab[ TB_COLTOP ] SAY ;
		TB_BACKGROUND
	  @ (nNewPosition + aTab[ TB_ROWTOP ]), aTab[ TB_COLTOP ] SAY;
		TB_HIGHLIGHT
	  aTab[ TB_POSITION ] := nNewPosition
   ENDIF

   SETCOLOR( cOldColor )

   RETURN aTab


FUNCTION CALEN
* -> Fun‡„o que ativa o calend rio
LOCAL OLDCUR:=SETCURSOR(0)
LOCAL X_POS:=ROW()
LOCAL Y_POS:=COL()
LOCAL C_COR:=SETCOLOR()
LOCAL DAT_HOJE:=DATE()
LOCAL CA_MES:=MONTH(DAT_HOJE)
LOCAL CA_ANO:=YEAR(DAT_HOJE)
LOCAL CA_DIA:=DAY(DAT_HOJE)
LOCAL CA_DATA:=DAT_HOJE
LOCAL CA_DIA1:=CTOD("01/"+STR(CA_MES,2)+"/"+STR(CA_ANO,4))
LOCAL CA_TELA:=SAVESCREEN(0,0,12,38)
LOCAL C_TEC:=0
LOCAL C_VARDIA:="   1    2    3    4    5    6    7    8    9   10   11   12   13"
C_VARDIA:=C_VARDIA+"   14   15   16   17   18   19   20   21   22   23   24"
C_VARDIA:=C_VARDIA+"   25   26   27   28   29   30   31 "

DO WHILE C_TEC<>27
   SET COLOR TO N/W
   @ 0,0 CLEAR TO 10,38
   @ 0,0 TO 10,38
   SET COLOR TO N/BG
   @ 4,2 SAY " Dom  Seg  Ter  Qua  Qui  Sex  Sab "
   SET COLOR TO +W/W
   IF AT(SUBS(STR(CA_MES+100,3),2),"01 03 05 07 08 10 12")<>0
      M->CA_VAR=C_VARDIA+SPACE(32)
      M->ULT_DIA = 31
   ELSE
      IF CA_MES<>2
         M->CA_VAR=SUBS(C_VARDIA,1,150)+SPACE(32)
         M->ULT_DIA = 30
      ELSE
         IF INT(CA_ANO/4)=CA_ANO/4
            M->CA_VAR=SUBS(C_VARDIA,1,145)+SPACE(32)
            M->ULT_DIA = 29
         ELSE
            M->CA_VAR=SUBS(C_VARDIA,1,140)+SPACE(32)
            M->ULT_DIA = 28
         ENDIF
      ENDIF
   ENDIF
   M->V_AR=IIF(DOW(CA_DIA1)>1,REPL("     ",DOW(CA_DIA1)-1)+M->CA_VAR,M->CA_VAR)
   M->X_X=1
   DO WHILE .T.
      IF LEN(M->V_AR)<M->X_X*35
         EXIT
      ENDIF
      SET COLOR TO +W/W
      M->SEM_ANA = SUBS(M->V_AR,(35*M->X_X)-34,34)
      @ 5+M->X_X,01 SAY " "+M->SEM_ANA+"  "
      SET COLOR TO N/W
      @ 5+M->X_X,00 SAY "³"
      @ 5+M->X_X,38 SAY "³"
      @ 5+M->X_X,2  SAY SUBS(M->SEM_ANA,1,5)
      M->SEM_ANA=" "+M->SEM_ANA
      IF AT(STR(CA_DIA,5),M->SEM_ANA) <> 0
         M->POS = AT(STR(CA_DIA,5),M->SEM_ANA)
         IF M->POS = 1
            SET COLOR TO R/BG
            @ 5+M->X_X,2 SAY STR(CA_DIA,4)
         ELSE
            SET COLOR TO +W/BG
            @ 5+M->X_X,1 + M->POS SAY STR(CA_DIA,4)
         ENDIF
      ENDIF
      M->X_X=M->X_X+1
   ENDDO
   SET COLOR TO N/W
   @ 0,0 TO 5+M->X_X,38
   M->MES_ANO=SUBS("Janeiro  FevereiroMar‡o    Abril    Maio     Junho    Julho    Agosto   Setembro Outubro  Novembro Dezembro ",CA_MES*9-8,9)
   M->MES_ANO=ALLTRIM(STR(DAY(CA_DATA),2))+" de "+TRIM(M->MES_ANO)
   M->MES_ANO=M->MES_ANO+" de "+STR(YEAR(CA_DATA),4)
   @ 2,0+(39-LEN(M->MES_ANO))/2 SAY M->MES_ANO
   C_TEC=MINKEY(0)
   IF C_TEC=28
      DO HELP WITH "CALENDARIO"
   ENDIF
   CA_ANO=CA_ANO+IIF(C_TEC=5,-1,IIF(C_TEC=24,1,0))
   CA_MES=CA_MES+IIF(C_TEC=19,-1,IIF(C_TEC=4,1,0))
   CA_MES=IIF(CA_MES<1,12,IIF(CA_MES>12,1,CA_MES))
   IF CA_DIA > M->ULT_DIA
      CA_DIA = M->ULT_DIA
   ENDIF
   CA_DATA=CTOD(STR(CA_DIA,2)+"/"+STR(CA_MES,2)+"/"+STR(CA_ANO,4))
   CA_DIA1=CTOD("01/"+STR(CA_MES,2)+"/"+STR(CA_ANO,4))
   RESTSCREEN(0,0,12,38,CA_TELA)
ENDDO
SETCOLOR(C_COR)
SETCURSOR(OLDCUR)
@ X_POS,Y_POS SAY ""
RETURN(NIL)
 
FUNCTION CALCU
*
* -> Fun‡„o que ativa a calculadora
CUR:=SETCURSOR(1)
X_POS:=ROW()
Y_POS:=COL()
C_COR:=SETCOLOR()
CA_TELA:=SAVESCREEN(0,53,14,79)
private C_RESULT,;
		C_DEC,;
		C_DIG,;
		C_VAR,;
		C_VERDAD,;
		C_UOPER,;
		C_PERC,;
		OPE_RA
PRIVATE C_ALGA		
SET COLOR TO /BG
@ 1,54 CLEAR TO 13,78
SET COLOR TO W/BG
@ 02,55 SAY REPL(CHR(220),23)
@ 03,55 SAY CHR(219)+SPACE(21)+CHR(219)
@ 04,55 SAY REPL(CHR(223),23)
SET COLOR TO /W
@ 00,53 TO 14,79 DOUBLE
@ 06,55 SAY " 7 "
@ 06,60 SAY " 8 "
@ 06,65 SAY " 9 "
@ 08,55 SAY " 4 "
@ 08,60 SAY " 5 "
@ 08,65 SAY " 6 "
@ 10,55 SAY " 1 "
@ 10,60 SAY " 2 "
@ 10,65 SAY " 3 "
@ 12,55 SAY "  0  "
@ 12,63 SAY "  .  "
SET COLOR TO W/B
@ 06,70 SAY " - "
@ 12,75 SAY " % "
@ 08,70 SAY " + "
@ 08,75 SAY " * "
@ 10,75 SAY " / "
SET COLOR TO W/R
@ 10,70 SAY CHR(17)+CHR(196)+CHR(217)
@ 11,70 SAY "   "
@ 12,70 SAY " = "
@ 06,75 SAY "C/E"
SET COLOR TO W
C_RESULT:=0
C_ALGA:=SPACE(14)
C_DEC:=""
C_DIG:=CHR(0)
C_VAR:="C_ALGA"
C_VERDAD:=.F.
SET COLOR TO W
@ 03,56 SAY " "+STR(C_RESULT,19,4)+" "
C_UOPER:=""
C_PERC:=" "
DO WHILE C_DIG<>CHR(27)
   C_DIG:=CHR(MINKEY(0))
   IF C_DIG==CHR(27)
      EXIT
   ENDif
   C_VAR:=IF(C_DIG==".","C_DEC",C_VAR)
	C_ALGA:=IF(C_DIG=="." .AND. C_ALGA==SPACE(14),SPACE(13)+"0",C_ALGA) 
   IF C_DIG="%"
      IF C_VERDAD
         C_PERC:=IF(C_PERC="%"," ","%")
         SET COLOR TO /W
         @ 03,77 SAY C_PERC
         SET COLOR TO W
      ELSE
         @ 03,57 SAY SPACE(13)+"0.0000"
      ENDIF
   ELSEIF C_DIG $ "0123456789" .AND. LEN(LTRIM(&C_VAR))<>IIF(C_VAR="C_DEC",4,14)
      &C_VAR:=IF(C_VAR="C_DEC",&C_VAR+C_DIG,SUBS(&C_VAR+C_DIG,2))
      @ 03,57 SAY C_ALGA+"."+SUBS(C_DEC+SUBS("00000",LEN(C_DEC)+1),1,4)
      C_VERDAD:=IF(C_VERDAD .AND. C_UOPER $ "="+CHR(13),.F.,C_VERDAD)
   ELSEIF C_DIG $ "+-/*:="+CHR(13)
      IF C_VERDAD
         IF VAL(C_ALGA+"."+C_DEC)<>0
            IF C_PERC="%"
               OPE_RA:=STR(C_RESULT,19,4)+C_UOPER+"("+STR(C_RESULT,19,4)+"*"+C_ALGA+"."+SUBS(C_DEC+SUBS("00000",LEN(C_DEC)+1),1,4)+")/100.000"
            ELSE
               OPE_RA:=STR(C_RESULT,19,4)+C_UOPER+C_ALGA+"."+SUBS(C_DEC+SUBS("00000",LEN(C_DEC)+1),1,4)
            END
            C_RESULT:=&OPE_RA
            @ 03,57 SAY STR(C_RESULT,19,4)
         ENDIF
      ELSEIF C_DIG $ "+-/*"
         C_VERDAD:=.T.
         C_RESULT:=VAL(C_ALGA+"."+C_DEC)
      ENDIF
      SET COLOR TO N/W
      @ 03,55 SAY IF(C_DIG $ "+-/*",C_DIG," ")
      @ 03,77 SAY " "
      SET COLOR TO W
      C_VAR:="C_ALGA"
      C_ALGA:=SPACE(14)
      C_DEC:=""
      C_UOPER:=C_DIG
      C_PERC:=" "
   ELSEIF C_DIG $ "EeCc"
      C_VAR:="C_ALGA"
      C_ALGA:=SPACE(14)
      C_DEC:=""
      C_PERC:=" "
      IF C_DIG $ "Cc"
         C_VERDAD:=.F.
         SET COLOR TO N/W
         @ 03,55 SAY " "
         @ 03,77 SAY " "
         SET COLOR TO W
      END
      @ 03,57 SAY SPACE(13)+"0.0000"
   END
ENDDO
SETCOLOR(C_COR)
RESTSCREEN(0,53,14,79,CA_TELA)
SETCURSOR(CUR)
@ X_POS,Y_POS SAY ""
RETURN(NIL)

FUNCTION PrinterManager()
	LOCAL cOldScreen := SAVESCREEN ( 06,08,10,79 )
	LOCAL nOldCursor := SETCURSOR ()
	LOCAL cOldColors := SETCOLOR ()	
	LOCAL tiprel:=space(1)
	LOCAL GETLIST:={}
	if M->sEsc==18
	   tiprel:="N" 
	else
	   tiprel:="C" 
	end	 
	SETCURSOR(1)
	SetCor (m->cEdicao) 
	Box ( 06,08,09,47,M->fr,127,03,08 )		
	@ 07,10 SAY "[N]ormal ou [C]omprimido   :" GET tiprel PICT "@!"  VALID tiprel=="N" .or. tiprel=="C"
	@ 08,10 SAY "Porta da impressora        :" GET sLpt PICTURE "9"	
	READ
	IF LASTKEY () == 27 .OR. !M_QUERY ( "Confirma altera‡„o ?",23 )	
		RESTSCREEN (06,08,10,79,cOldScreen )
		SETCURSOR ( nOldCursor )
		SETCOLOR ( cOldColors )
		RETURN ( NIL ) 
	ENDIF
	if tiprel=="N"
     M->sEsc:=18 	   
	else
	  M->sEsc:=15 	   
	end
	LPTSET(1,M->sLpt)
	RESTSCREEN (06,08,10,79,cOldScreen )
RETURN(NIL)	

function percent(indice)
   LOCAL comp:=LTRIM(STR(INT((RECNO()/LASTREC())*100))),COR:=SETCOLOR(m->cError3)
	STATIC nPosc
   @ 12,55 SAY comp+" %   "
	SETCOLOR(COR)
	IF MINKEY() == 27
		RETURN(.F.)
	ENDIF	
RETURN(.T.)				
 
FUNCTION VerifyPeriod( not1, not2, campo )
	IF !EMPTY( not1 )
		DBSEEK( DTOS( not1 ), .T. )
	ELSE	
		DBGOTOP()
	ENDIF	
	IF !EMPTY( not2 )
		IF &campo > not2
			M_Display("Per¡odo n„o encontrado",79)
			RETURN ( .F. )
		ENDIF
	ELSE
		IF &campo < not1
			M_Display("Per¡odo n„o encontrado",79)
			RETURN ( .F. )
		ENDIF	
	ENDIF	
RETURN( .T. )		
//
Function ValidaData(dt_inicial,dt_final)
   IF dt_inicial > dt_final
		M_Display("Per¡odo inv lido, verifique !!!",79)
		RETURN ( .F. )
	ENDIF	
Return( .T. )

Function COMPACTAR(arquivo)
	LOCAL cor := SETCOLOR()
	LOCAL tel := SAVESCREEN(0,0,LastRow(),LastCol())
	LOCAL SETD,tamtol,DISPON,cont:=0,OLDARQ,NEWARQ
	If Open(arquivo,.T.)
	   dbgotop()
		tamtol:=(int(recsize()*lastrec()+header()+10))
		dispon:=(diskspace(left(curdrive(),1)))
		if dispon < tamtol
		   setcolor(m->cEdicao)
		   BOX(4,5,8,43,M->FR,127,3,8)
			@ 5,6 SAY "DISPONIVEL = "+ALLTRIM(STR(DISPON,15))+" bytes"
			@ 6,6 SAY "NECESSARIO = "+ALLTRIM(STR(TAMTOL,15))+" bytes"
			@ 7,6 say "ARQUIVO    = "+ARQUIVO+".DBF"
		   m_display("ESPACO INSUFICIENTE  " ,79)
			DBCLOSEAREA()
			RestScreen(0,0,LastRow(),LastCol(),tel)
			setcolor(cor)
			RETURN(.F.)
		end
	   m_message("Aguarde Compactando "+arquivo,23)
		SETD:=SET(_SET_DELETED,.t.)
		OLDARQ:=ARQUIVO+".DBF"
		NEWARQ:=ARQUIVO+".TMP"
		COPY TO &NEWARQ
		DBCLOSEAREA()
		FERASE(OLDARQ)
		FRENAME(NEWARQ,OLDARQ) 
		RestScreen(0,0,LastRow(),LastCol(),tel)
		SET(_SET_DELETED,SETD)
	End
   Retu(.T.)

FUNCTION Todos()
	@ ROW(),COL()+3 SAY "Todos"
RETURN(.T.)	

// Mostra o nome do mˆs corrente
// Parametros - NIL
// Retorno    - MES

FUNCTION DispMonth( dData )
	LOCAL aMonth := {"JANEIRO","FEVEREIRO","MARCO","ABRIL","MAIO","JUNHO",;
						  "JULHO","AGOSTO","SETEMBRO","OUTUBRO","NOVEMBRO","DEZEMBRO"}
RETURN( aMonth [ MONTH ( dData ) ] )

// Verifica o direcionamento da impressÆo
FUNCTION Impres( nCopias )
	IF nCopias == NIL
		nCopias := 1
	ENDIF
	IF M_QUERY ( "Confirma a impressÆo ?", 23 )
		IF ! ( ISPRINTER() )
			IF ! ( Impressora ( nCopias ) )
				M_DISPLAY ( "Impressora com problema, verifique !!!", 79 )
				IF ! ( M_QUERY ( "Tenta novamente ?", 23 ) )
					RETURN ( .F. )
				ELSE
					IF ! ( Impres ( nCopias ) )
						RETURN ( .F. )
					ENDIF	
				ENDIF		
			ENDIF
		ELSE
			Impressora ( nCopias )
		ENDIF
	ELSE
		RETURN ( .F. )
	ENDIF
RETURN ( .T. )					

// Direciona para o arquivo ou impressora
FUNCTION Impressora ( nCopias )
	LOCAL cTela    := SAVESCREEN ( 07, 08, 12, 71 )
	LOCAL nCursor  //:= SETCURSOR ( 3 )
	LOCAL cCor     := SetCor ( m->cEdicao )
	LOCAL cArquivo := SPACE ( 30 )
	LOCAL cArquivo2,CMENS
	LOCAL hArquivo,;
			nErro,;
			GETLIST:={}
	SET PRINTER TO		
	IF nCopias == NIL
		nCopias := 1
	ENDIF	
	IF ! ( M_QUERY ( "Deseja gravar em arquivo", 23 ) )
		RETURN ( .F. )
	ENDIF
	BOX ( 07, 08, 11, 70, m->FR, 127, 3, 8 )
	DO WHILE .T.
		SETCURSOR ( 3 )
	   @ 09, 10    SAY "Entre com o nome do arquivo:"                          
  		@ 09, COL() GET cArquivo PICT "@!" VALID ( ! ( EMPTY ( cArquivo ) ) )
		READ
		SETCURSOR ( 0 )
		IF LASTKEY() = 27
			SetCor ( cCor )
			RESTSCREEN ( 07, 08, 12, 71, cTela )
			RETURN ( .F. )
		ENDIF
		cArquivo2 := UPPER ( TRIM ( cArquivo ) + IF ( AT ( ".", cArquivo ) > 0, "", ".PRN" ) )
		IF FILE ( cArquivo2 )
			IF ! ( M_QUERY ( "Arquivo " + cArquivo2 + " j  existe, deseja reutiliz -lo ?", 79 ) ) 
         	LOOP
         ENDIF
      ENDIF
		hArquivo := FCREATE ( cArquivo2 )
		nErro    := FERROR()
		FCLOSE ( hArquivo )
		ERASE ( cArquivo2 )
		IF nErro # 0
			cMens := "Nome inv lido para arquivo - Erro DOS No. "
     		M_DISPLAY ( cMens + STR ( nErro, 1 ), 79 )
			LOOP
		ENDIF
		EXIT
	ENDDO
	RESTSCREEN ( 07, 08, 12, 71, cTela )
   SET PRINTER TO ( cArquivo )
RETURN ( .T. )

// Cancela a impressÆo
FUNCTION Para_Impressao()
   IF M_QUERY ( "Cancela a impressÆo", 79 )
		RETURN ( .T. )
	ENDIF
RETURN ( .F. )
/*
FUNCTION Criptografa( Pstr, Psenha, Pencript )
   Local Tcript, Tx, Tascii
   Local Tlensenha := Len(Trim(Psenha))
         Tcript :=''
         For Tx := 1 to Len(Pstr)
            If Pencript  // .T. emcripta
               Tascii := Asc( Subs ( Pstr, Tx, 1 ) ) +;
                         Asc( Subs ( Psenha,(Tx % Tlensenha ) + 1,1))
            Else         // .F. decripta
               Tascii := Asc( Subs ( Pstr, Tx, 1 ) ) -;
                         Asc( Subs ( Psenha,(Tx % Tlensenha ) + 1,1))
            EndI
            Tcript := Tcript + Chr(Tascii)
          Next
    Return( Pstr := Tcript)
*/	 
	 
	 
FUNCTION Criptografa( Pstr, Psenha, Pencript )
   Local Tcript, Tx, Tascii
   Local Tlensenha := Len(Trim(Psenha))
         Tcript :=''
         For Tx := 1 to Len(Pstr)
            If Pencript  // .t. emcripta
               Tascii := Asc( Subs ( Pstr, Tx, 1 ) ) +;
                         Asc( Subs ( Psenha,(Tx % Tlensenha ) + 1,1))
            Else
               Tascii := Asc( Subs ( Pstr, Tx, 1 ) ) -;
                         Asc( Subs ( Psenha,(Tx % Tlensenha ) + 1,1))
            EndI
            Tcript := Tcript + Chr(Tascii)
         Next
    Return( Pstr := Tcript)	
	 
FUNCTION Refresca(b)
	B:STABLE := .F.
	RETURN(NIL)

Function Cabecalho(pag,cabtext,cabcamp)
*        @ 01,001                        say &SLOG->l1
*        @ prow(),0001 say chr(14)+m->SNOM+chr(15)+" "
	@ prow()+1,133-LEN(_PAGINA(pag))	say _PAGINA(pag)
*        @ 02,001                        say &SLOG->l2
*        @ 03,001                        say &SLOG->l3
*        @ 04,001                        say &SLOG->l4
        @ Prow(),133-LEN(_DATA) SAY _DATA
	@ prow(),0001 Say chr(14)+CABTEXT+chr(15)+" "
*        @ 05,001                        say &SLOG->l5
	@ 05,133-LEN(_HORA) SAY _HORA
	@ prow(),pcol() 	say chr(27)+chr(50)
	@ 06,01           say repl('-',132)
	IF CABCAMP#NIL
		@ 07,01				say cabcamp 
		@ 08,01           say repl('-',132)	
	ENDIF	
return (nil)

FUNCTION Descanso()
LOCAL cTELA := SAVESCREEN(00,00,24,79)
LOCAL cCoordenada := "08C07D12C11D06B01B02E07C08E09E14C13D08B03B04E09C10E05B04D09C14C15E10B09D04B03D"
LOCAL lVAR := .T.,t,nquadro,cdirecao
LOCAL nCursor := SETCURSOR()
LOCAL cCor := SETCOLOR()
@ 24,00 SAY " "+DTOC(DATE())+" ³ PRESSIONE QUALQUER TECLA PARA CONTINUAR  ³ W&R Informatica 981-7655 " COLOR "N/W"
DO WHILE lVAR
   FOR T := 1 TO 79 STEP 3
      nQuadro := VAL(SUBSTR(cCoordenada,T,2))
      cDirecao := SUBSTR(cCoordenada,T+2,1)
      lVAR := MOVE(cDirecao,nQuadro)
      IF !lVAR
         EXIT
      ENDIF
   NEXT
ENDDO
SETCURSOR(nCursor)
SETCOLOR(cCor)
RESTSCREEN(00,00,24,79,cTELA)
RETURN NIL

***************************************************************************


STATIC FUNCTION MOVE(cDirecao, nQuadro)
LOCA ND,NE,NB,NJ
LOCAL cPosicao1 := "000000000000715001607310032074700480763006407790800151508161531"
LOCAL cPosicao2 := "0832154708481563086415791600231516162331163223471648236316642379"
LOCAL cPosicao  := cPosicao1+cPosicao2
LOCAL cQuadro1  := SUBSTR(cPosicao,nQUADRO*8,8)
LOCAL nCoord1   := VAL(SUBSTR(cQuadro1,01,02))
LOCAL nCoord2   := VAL(SUBSTR(cQuadro1,03,02))
LOCAL nCoord3   := VAL(SUBSTR(cQuadro1,05,02))
LOCAL nCoord4   := VAL(SUBSTR(cQuadro1,07,02))
LOCAL cQuadro   := SAVESCREEN(nCoord1,nCoord2,nCoord3,nCoord4)
LOCAL nC := nJ := nB := nE := nD := 0
IF cDIRECAO = "L"
   SETCOLOR("W/N")
   @ nCoord1,nCoord2 CLEAR TO nCoord3,nCoord4
ELSEIF cDIRECAO = "C"
   FOR nC := 0 TO 7 STEP 2
      RESTSCREEN(nCoord1-nC,nCoord2,nCoord3-nC,nCoord4,cQuadro)
      IF INKEY(.1) <> 0;RETURN .F.;ENDIF
      SETCOLOR("W/N")
      @ nCoord1-nC,nCoord2 CLEAR TO nCoord3-nC,nCoord4
   NEXT
   RESTSCREEN(nCoord1-nC,nCoord2,nCoord3-nC,nCoord4,cQuadro)
ELSEIF cDIRECAO = "B"
   FOR nB := 0 TO 7 STEP 2
      RESTSCREEN(nCoord1+nB,nCoord2,nCoord3+nB,nCoord4,cQuadro)
      IF INKEY(.1) <> 0;RETURN .F.;ENDIF
      SETCOLOR("W/N")
      @ nCoord1+nB,nCoord2 CLEAR TO nCoord3+nB,nCoord4
   NEXT
   RESTSCREEN(nCoord1+nB,nCoord2,nCoord3+nB,nCoord4,cQuadro)
ELSEIF cDIRECAO = "E"
   FOR nE := 0 TO 15 STEP 2
      RESTSCREEN(nCoord1,nCoord2-nE,nCoord3,nCoord4-nE,cQuadro)
      IF INKEY(.1) <> 0;RETURN .F.;ENDIF
      SETCOLOR("W/N")
      @ nCoord1,nCoord2-nE CLEAR TO nCoord3,nCoord4-nE
   NEXT
   RESTSCREEN(nCoord1,nCoord2-nE,nCoord3,nCoord4-nE,cQuadro)
ELSEIF cDIRECAO = "D"
   FOR nD := 0 TO 15 STEP 2
      RESTSCREEN(nCoord1,nCoord2+nD,nCoord3,nCoord4+nD,cQuadro)
      IF INKEY(.1) <> 0;RETURN .F.;ENDIF
      SETCOLOR("W/N")
      @ nCoord1,nCoord2+nD CLEAR TO nCoord3,nCoord4+nD
   NEXT
   RESTSCREEN(nCoord1,nCoord2+nD,nCoord3,nCoord4+nD,cQuadro)
ENDIF
RETURN .T.	

FUNCTION Minkey(nSecs)

   LOCAL nRet    := 0
   LOCAL nDesc_Tela   := 0
   LOCAL nTime, nTELADES,NCURSOR

   IF nSecs == NIL
      nRet := inkey()
   ELSE

      nDesc_Tela := nTime :=  SECONDS()
      WHILE ( nRet := inkey()) == 0 .AND. ;
         IIF (nSecs > 0, ;
            (SECONDS() - nTime) < nSecs, .T.)
         IF (SECONDS()-nDesc_Tela) > M->PTEMPODESC
			   nCursor:=SETCURSOR(0)
            DESCANSO()
            SETCURSOR(nCursor)
            nDesc_Tela := SECONDS()
         ENDIF
      ENDDO
	ENDIF
RETURN( nRet )

// LastKey
FUNCTION Mlastkey(nSecs)

   LOCAL nRet    := 0
   LOCAL nDesc_Tela   := 0
   LOCAL nTime, nTELADES,NCURSOR

   IF nSecs == NIL
      nRet := lastkey()
   ELSE

      nDesc_Tela := nTime :=  SECONDS()
      WHILE ( nRet := lastkey()) == 0 .AND. ;
         IIF (nSecs > 0, ;
            (SECONDS() - nTime) < nSecs, .T.)
         IF (SECONDS()-nDesc_Tela) > M->PTEMPODESC
			   nCursor:=SETCURSOR(0)
            DESCANSO()
            SETCURSOR(nCursor)
            nDesc_Tela := SECONDS()
         ENDIF
      ENDDO
	ENDIF
RETURN( nRet )


// MODULO DE VERIFICACAO DE ARQUIVOS DBF OU DBT E INDICES

FUNCTION SYSARQ(_Sistema) 
Local SQ
IF !FILE("ARQSYS1.NTX")
   IF !INDICES("ARQSYS","ARQSYS1","SISTEMAS")
      RETURN(.F.)
	ENDIF  
ENDIF
IF !FILE("ARQSYS2.NTX")
   IF !INDICES("ARQSYS","ARQSYS2","ARQUIVOS")
      RETURN(.F.)
	ENDIF  
ENDIF
IF !OPEN( "ARQSYS", .F. ) 
   RETURN(.F.)
ENDIF
SET INDEX TO ARQSYS1,ARQSYS2
DBGOTOP()
IF( ARQSYS->(DBSEEK(_Sistema)) )
DO WHIL ALLTRIM(ARQSYS->SISTEMAS)==_Sistema .AND. ARQSYS->(!EOF())
   SQ := ARQSYS->ARQUIVOS
   IF !FILE(ALLTRIM(SQ)+".DBF")
      ALERT( "ARQUIVO "+ARQSYS->ARQUIVOS+"NÇO ENCONTRADO",{"OK"} , "W+/RG+") 
		DBCLOSEALL()
		QUIT
   ENDIF
   DBSKIP()
ENDDO  
DBCLOSEALL()
ENDIF
RETURN(.T.)


FUNCTION ARQNTX(_Arquivo,lModo,lModo2)
Local SQ,_Indices,_Chaves, _condicao,_unico,I
local cTela_x
Local aIndices := {}
IF lModo2==NIL
	lModo2 := .F.
ENDIF	
IF !FILE("ARQSYS1.NTX")
   IF !INDICES("ARQSYS","ARQSYS1","SISTEMAS")
      RETURN(.F.)
	ENDIF  
ENDIF
IF !FILE("ARQSYS2.NTX")
   IF !INDICES("ARQSYS","ARQSYS2","ARQUIVOS+INDICES")
      RETURN(.F.)
	ENDIF  
ENDIF
IF !OPEN( "ARQSYS", .F. ) 
   RETURN(.F.)
ENDIF
SET INDEX TO ARQSYS2,ARQSYS1
ARQSYS->(DBGOTOP())
IF( ARQSYS->(DBSEEK(_Arquivo)) )
	DO WHIL ALLTRIM(ARQSYS->ARQUIVOS)==_Arquivo .AND. ARQSYS->(!EOF())
		IF !EMPTY(ARQSYS->INDICES)
		   SQ := ARQSYS->INDICES
		   IF !FILE(ALLTRIM(SQ)+".NTX") .OR. lModo2
				_Indices := ARQSYS->INDICES
				_Chaves  := ARQSYS->CHAVES
				_Unico   := ARQSYS->UNICO
				_Condicao := ARQSYS->CONDICAO
			   IF !INDICES( _Arquivo, _Indices, _Chaves, _Condicao, _Unico)
		   	    RETURN(.F.)
			   ENDIF  
			ELSE
		  		_Indices := ARQSYS->INDICES	
	   	ENDIF
			AADD(	aIndices , _Indices )
		ENDIF	
	   ARQSYS->(DBSKIP())
	ENDDO  
ELSE
      *  M_DISPLAY("Arquivo "+ _Arquivo +" nao esta cadastrado no sistema",79)
	RETURN(.F.)	
ENDIF	
IF lModo==NIL
	lModo := .F.
ENDIF	
IF !lModo2
	IF !OPEN(_Arquivo, lModo)
	   RETURN(.F.)
	ENDIF
	FOR I := 1  TO LEN(aIndices)
   	 DBSETINDEX(aIndices[I])
	NEXT
ENDIF	
ARQSYS->(DBCLOSEAREA())
RETURN(.T.)


/***
*  TimeAsSeconds( <cTime> ) --> nSeconds
*
*/
FUNCTION TimeAsSeconds( cTime )
   RETURN VAL(SUBSTR(cTime, 1)) * 60 +;
          VAL(SUBSTR(cTime, 4))



/***
*  TimeAsString( <nSeconds> ) --> cTime
*
*/
FUNCTION TimeAsString( nSeconds )
   RETURN  StrZero(INT(Mod(nSeconds / 60, 60)), 2, 0) + ":" +;
           StrZero(INT(Mod(nSeconds, 60)), 2, 0)
			  
FUNCTION PVerifica(aOpcoes)
	LOCAL nX,;
			nEmpty:=0,;
			nNEmpty:=0
	
	FOR nX:=1 TO LEN(aOpcoes)
		IF EMPTY(aOpcoes[nX])
			nEmpty++
		ELSE
			nNEmpty++
		ENDIF
	NEXT			
	
	IF nEmpty == LEN(aOpcoes)
		M_DISPLAY("Informe uma das opcoes",79)
		RETURN(.F.)	
	ENDIF
	IF nNEmpty == LEN(aOpcoes) .OR. nNEmpty>1
		M_DISPLAY("Informe somente uma das opcoes",79)
		RETURN(.F.)
	ENDIF
RETURN(.T.)	
	
FUNCTION ShowZeros(cNota,nTamanho)
	LOCAL nContador,;
			nComprimento,;
			cBranco,;
			nVerifica
	LOCAL lAlfa := .F.
	LOCAL aNumeros := { "0","1","2","3","4","5","6","7","8","9"," " }
	IF nTamanho=NIL 
		nTamanho := 10
	ENDIF	
	FOR nContador=1 TO nTamanho
		nVerifica := ASCAN ( aNumeros , SUBST ( cNota, nContador, 1 ) )
		IF nVerifica = 0
			lAlfa := .T.
			EXIT
		ENDIF
	NEXT
	IF lAlfa .AND. !(LEN ( ALLTRIM ( cNota ) ) == nTamanho - nContador )
		cNota := ALLTRIM ( cNota )
		nComprimento := LEN ( cNota )
		cBranco := SPACE( nTamanho - nComprimento )
		cNota := cBranco + SUBST ( cNota, 1, nComprimento )
	ENDIF	
	IF !lAlfa
		cNota := STRZERO ( INT ( VAL ( cNota ) ), nTamanho )
	ENDIF	
RETURN ( .T. )	

FUNCTION Acessa_Editor()
LOCAL c_Tela   := SAVESCREEN( 0, 0, MAXROW(), MAXCOL() ) ,;
      c_Cursor := SETCURSOR() ,;
		c_Color  := SETCOLOR()
		
RUN C:\TESTE\NE

SETCURSOR( c_Cursor )
SETCOLOR( c_Color )
RESTSCREEN( 0, 0, MAXROW(), MAXCOL(), c_Tela )
RETURN(NIL)

function extenso(total)
private lin, i, j
private unidade [19], dezena [10], centena [10], milhar [12], valor [7]
unidade [1] = ' UM'
unidade [2] = ' DOIS'
unidade [3] = ' TRES'
unidade [4] = ' QUATRO'
unidade [5] = ' CINCO'
unidade [6] = ' SEIS'
unidade [7] = ' SETE'
unidade [8] = ' OITO'
unidade [9] = ' NOVE'
unidade [10] = ' DEZ'
unidade [11] = ' ONZE'
unidade [12] = ' DOZE'
unidade [13] = ' TREZE'
unidade [14] = ' QUATORZE'
unidade [15] = ' QUINZE'
unidade [16] = ' DEZESSEIS'
unidade [17] = ' DEZESSETE'
unidade [18] = ' DEZOITO'
unidade [19] = ' DEZENOVE'
dezena [2] = ' VINTE'
dezena [3] = ' TRINTA'
dezena [4] = ' QUARENTA'
dezena [5] = ' CINQUENTA'
dezena [6] = ' SESSENTA'
dezena [7] = ' SETENTA'
dezena [8] = ' OITENTA'
dezena [9] = ' NOVENTA'
dezena [10] = ' CEM'

centena [1] = ' CENTO'
centena [2] = ' DUZENTOS'
centena [3] = ' TREZENTOS'
centena [4] = ' QUATROCENTOS'
centena [5] = ' QUINHENTOS'
centena [6] = ' SEISCENTOS'
centena [7] = ' SETECENTOS'
centena [8] = ' OITOCENTOS'
centena [9] = ' NOVECENTOS'
centena [10] = ' CEM'

milhar [6] = ' CENTAVO'
milhar [5] = ' REAL'
milhar [4] = ' MIL'
milhar [3] = ' MILHAO'
milhar [2] = ' BILHAO'
milhar [1] = ' TRILHAO'
milhar [12] = ' CENTAVOS'
milhar [11] = ' REAIS'
milhar [10] = ' MIL'
milhar [9] = ' MILHOES'
milhar [8] = ' BILHOES'
milhar [7] = ' TRILHOES'

lin1 = str (total, 21, 2)
for j = 1 to 6
   valor [j] = val (substr (lin1, (j - 1) * 3 + 1, 3))
next
valor [7] = val (substr (lin1, 20, 2))

lin = ' '
zero = .t.

for j = 2 to 7
   if valor [j] > 0
      n = valor [j]

      if ! zero
         lin = lin + ' E'
      endif
      zero = .f.

      if n > 100
         lin = lin + centena [int (n / 100)]
         if n % 100 > 0
            lin = lin + ' E'
         endif
      else
         if n = 100
            lin = lin + dezena [10]

         endif
      endif

      n = n % 100
      if n > 19
         lin = lin + dezena [int (n / 10)]
         if n % 10 > 0
            lin = lin + ' E'
            n = n % 10
            lin = lin + unidade [n]
         endif
      else
         if n > 0
            lin = lin + unidade [n]
         endif
      endif

      if valor [j] > 1
         lin = lin + milhar [j + 5]
      else
         lin = lin + milhar [j - 1]
      endif
   else
      if j = 6 .and. total > 1
         if valor [5] = 0 .and. total >= 1000000
            lin = lin + ' DE'
         endif
         lin = lin + milhar [11]
      endif
   endif
next
return alltrim (lin) + replicate ('*', 110)
