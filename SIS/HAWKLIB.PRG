

#include "INKEY.CH"
#include "SETCURS.CH"
#include "FILEMAN.CH"
#include "DIRECTRY.CH"
#include "MEMOEDIT.CH"
#include "ACHOICE.CH"
#include "SET.CH"
#include "box.ch"

#define MY_HSEP	"ƒ¬ƒ"
#define MY_CSEP	" ≥ "
#define MY_FSEP   "ƒ¡ƒ"
#define fr1       "⁄ƒø≥Ÿƒ¿≥ "
#define fr        "⁄ƒø≥Ÿƒ¿≥ "

//set key -11 to calcu()

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
        BOX(_row+3, _col2, _row+5, _col2+5,m_frame(),_pback)
        print(_row+4,_col2+1," OK ",_pback)
        inkey(0)
        restscreen(_row-2,_col-1,_row+9,_col+_pstrlen+2,_pscreen)
        setcursor(_cursor)
		  SetCor(teste)
return(0)   

Function Cabeca(pag,cabtext,cabcamp)
local vLen,vHor,vDat
	vLen := "PAGINA :"+STRZERO(PAG,4)
	vHor := "HORA :"+TIME()
	vDat := "DATA :"+DTOC(DATE())
	@ 01,001 			 say LOGOPCI->l1
/*	@ prow(),PCOL()+3  say SNOM*/
	@ prow(),133-LEN(VLEN) say vLen
	@ 02,001 			 say LOGOPCI->l2
	@ 03,001 			 say LOGOPCI->l3
	@ prow(),133-LEN(VDAT) SAY vDat
	@ 04,001 			 say LOGOPCI->l4
	@ prow(),36 	    say chr(27)+"W"+CHR(1)+CABTEXT+chr(27)+"W"+CHR(0)
	@ 05,001 			 say LOGOPCI->l5
	@ 05,133-LEN(vHor) SAY vHor
	@ prow(),pcol() 	 say chr(27)+chr(50)
/*	@ 06,01            say repl('-',132)*/
/*	@ 07,01			    say cabcamp 
	@ 08,01            say repl('-',132)*/
return (nil)	

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
        print(row+4, col3+1, " NÜo ", pfore)
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
              print(row+4, col3+1, " NÜo ",pfore)
              box(row+3, col2, row+5, col2+6, m_frame(), pback)
              print(row+4, col2+1, " Sim ", pback)
              setshadow(o)
           ELSEIF (! pactive )
                  o := setshadow(.F.)
                  box(row+3, col2, row+5, col2+6, m_frame(), pfore)
                  print(row+4, col2+1, " Sim ", pfore)
                  box(row+3, col3, row+5, col3+6, m_frame(), pback)
                  print(row+4, col3+1," NÜo ",pback)
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
  do while inkey()!=27
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
  m_display("Acesso cancelado pelo usu†rio",79)
  restscreen( 0, 0,lastrow(),lastcol(),cTela_x)
  return(.F.)
  
function lock_arquivo(modo)
  local cTela_x
  if flock()
     return .t.
  endif
  cTela_x := savescreen( 0, 0,lastrow(),lastcol())
  m_message("Aguarde... Acessando arquivo",23)
  do while modo .or. inkey()#27
     if flock()
        restscreen( 0, 0,lastrow(),lastcol(),cTela_x)
        return(.t.)
     endif
  enddo
  m_display("Acesso cancelado pelo usu†rio",79)
  restscreen( 0, 0,lastrow(),lastcol(),cTela_x)
  return .F.

function lock_registro(modo)
  local cTela_x
  If rlock()
     return .T.
  endif
  cTela_x := savescreen( 0, 0,lastrow(),lastcol())
  m_message("Aguarde... Acessando Registro",23)
  do while modo .or. INKEY()#27 
     If rlock()
        restscreen( 0, 0,lastrow(),lastcol(),cTela_x)
        return .T.
     endif
  enddo
  m_display("Acesso cancelado pelo usu†rio",79)
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
  do while modo .or. inkey()!=27
     append blank
     if !neterr()
        restscreen( 0, 0,lastrow(),lastcol(),cTela_x)
        return .T.
     endif
  enddo
  m_display("Acesso cancelado pelo usu†rio",79)
  restscreen( 0, 0,lastrow(),lastcol(),cTela_x)
RETURN(.F.)  

Func Existe (var,mens,vf,area,ordem,var2,mascara,x,y,PROXIMO)
	local volta,aat,ordem_ant,cor
	if AREA # NIL
	  aat:=Select()
	  Select(area)
	end
	IF ORDEM # NIL
	  ordem_ant:=Indexord()
	  dbSetOrder(ordem)
	end
	If dbSeek(var)
		volta = .T.
		If vf  
			M_Display(mens,79)
		EndI	
	Else
		volta = .F.
		If !vf
			M_Display(mens,79)
		EndI
		IF PROXIMO # NIL
		  if M_QUERY("Posiciona no Mais Proximo ?",79)		
		     dbseek(var,.T.)  
		     volta = .t.
		  end
		END
	EndI
	If VAR2 # NIL .and. volta
		@ x,y Say &var2 Pict mascara
	EndI	
	if AREA # NIL
	 Select(aat)
	endif
	if ORDEM # NIL
	 dbsetorder(ordem_ant)
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
Local quadro01
	Set Curs Off
	SetCor("N/N")
	Clea Scre
	quadro01:="€ﬂ€€€‹€€"
	SetCor("W/B")
	@ 00,00 Clea To 24,79
	@ 00,01 Say Padc(titulo,79)
	SetCor("W+/Bg")
	@ 02,00 Clea To 23,79
	SetCor("B/Bg")
	@ 02,00,23,79 Box quadro01
	SetCor("N/W")
	@ 24,00 Clea To 24,79
	@ 24,00 Say "    - Menus          - MovimentaáÑo        - Confirma         - Sair"
	SetCor("W+/W")
	@ 24,01 Say "F10"
	@ 24,16 Say Chr(24)+Chr(25)+Chr(26)+Chr(27)
	@ 24,39 SAY Chr(17)+Chr(196)+Chr(217)
	@ 24,56 SAY "ALT-X"
	SetCor("B/Bg")
/*	bc_inic() */
	@ 07,25 SAY " €€€€€€€      €€€€€€     €€€  "
	@ 08,25 SAY " €€€∞∞€€€    €€€∞∞€€€    €€€∞ "
	@ 09,25 SAY " €€€∞ €€€∞  €€€€∞  ∞∞∞   €€€∞ "
   @ 10,25 SAY " €€€∞ €€€∞  €€€€∞        €€€∞ "
	@ 11,25 SAY " €€€∞ €€€∞   €€€∞ €€€    €€€∞ "
	@ 12,25 SAY " €€€€€€€∞∞    €€€€€€∞∞   €€€∞ "
   @ 13,25 SAY " €€€∞∞∞∞∞      ∞∞∞∞∞∞     ∞∞∞ " 
   @ 14,25 SAY " €€€∞                         "
   @ 15,25 SAY "  ∞∞∞                         "
/*	 BC_GABJAN(.0, .0, .9, .9,"","S:\CLBC30\EX\MONTAN16.PCX")
    nTela := Savescreen( 8,10, 15, 70 )
	 BC_FIM()
	 Restscreen( 8, 10, 15, 70, nTela)   */
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

Func Dos
Local getcur,tela
	getcur := SETCURSOR(1)
	tela = SaveScreen(0,0,lastrow(),lastcol())
	CLS
	? "     Digite EXIT para retornar"
	! COMMAND.COM
	RestScreen(0,0,24,79,tela)
	SetCursOR(getcur)
Retu(NIL)						

Function Indices(arquivo,indice,chave,condicao)
	Local cor,tel,volta
	volta := .f.
	cor := SetCor()
	tel := SaveScreen(0,0,LastRow(),LastCol())
	If Open(arquivo,.T.)
	   m_message("Aguarde Indexando "+indice+" ...          ",23)
		if PCOUNT()<4
		   INDEX ON &chave TO &indice eval percent() 
		else
		   INDEX ON &chave TO &indice FOR (condicao) eval percent() 
		end
		volta := .t.	
		DBCLOSEAREA()
		RestScreen(0,0,LastRow(),LastCol(),tel)
	EndI
Retu(volta)



FUNCTION Pass()
 	// Declaraá‰es
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
		cTecla := INKEY ( 0 )
		SETCOLOR ( "W+/B" )
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
      @ nLinha + 2, c SAY "ﬁ"
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
	INKEY ( 0 )
	SETCURSOR ( nCursor )
	SetCor ( cCor)
	RESTSCREEN ( nLinha - 2, nColuna - 1, nLinha + 9, nColuna + nTamanho + 1, cTela )
RETURN ( UPPER ( ALLTRIM ( cSenha ) ) )

FUNCTION FileMan( nRowTop, nColumnTop,aFiles,cColorString)
Local nMenuItem   := 1 ,;
 	   nTagged     := 0 ,;
	   nFileItem   := 1 ,;
	   nEl         := 1 ,;
	   nRel        := 1 ,;
	   lReloadDir  := .T. ,;
	   aFileMan    := {}

   // Create the array
   aFileMan := ARRAY( FM_ELEMENTS )

   // Resolve parameters
   aFileMan[ FM_ROWTOP ] := nRowTop
   aFileMan[ FM_COLTOP ] := nColumnTop
   aFileMan[ FM_ROWBOTTOM ] :=NROWTOP+IF(LEN(AFILES)>8,8,LEN(AFILES)+1)
   aFileMan[ FM_COLBOTTOM ] := nColumnTop+LEN(AFILES[1])

   // Color string for FileMan()
   aFileMan[ FM_COLOR ] := cColorString
   // Save the old color
   aFileMan[ FM_OLDCOLOR ] := SETCOLOR( aFileMan[ FM_COLOR ] )


   // Save the screen
   aFileMan[ FM_OLDSCREEN ] := SAVESCREEN( aFileMan[ FM_ROWTOP    ],;
                                           aFileMan[ FM_COLTOP    ],;
                                           aFileMan[ FM_ROWBOTTOM ]+2,;
                                           aFileMan[ FM_COLBOTTOM ]+2)

   CreateScreen()          // Create the initial screen, etc.
   GetFiles()              // Call the actual file chooser

   // Restore the screen
   RESTSCREEN( aFileMan[ FM_ROWTOP    ], ;
               aFileMan[ FM_COLTOP    ], ;
               aFileMan[ FM_ROWBOTTOM ]+2, ;
               aFileMan[ FM_COLBOTTOM ]+2, ;
               aFileMan[ FM_OLDSCREEN ] )
   // Restore the color
   SetColor( aFileMan[ FM_OLDCOLOR ] )

   // Back to the real world!
   RETURN( aFileMan[ FM_RETURNFILE ] )

/***
*  GetFiles() --> NIL
*
*
*/
   STATIC FUNCTION GetFiles
   LOCAL lDone       := .F.            // Primary loop point
   LOCAL nCurrent    := 0              // ACHOICE() result
   LOCAL nLastKey    := 0              // Last value in LASTKEY()
	Local nFileItem
   Local aFileMan 
	Local hScrollBar
	
   TabUpdate(hScrollBar, nEl, LEN(aFiles), .T. )
   nCurrent := ACHOICE( aFileMan[ FM_ROWTOP ]+1, ;
                        aFileMan[ FM_COLTOP ]+1, ;
                        aFileMan[ FM_ROWBOTTOM ]-1, ;
                        aFileMan[ FM_COLBOTTOM ], ;
                        aFiles, .T., "ProcessKey", nEl, nRel )

      nFileItem := nCurrent
      nLastKey  := LASTKEY()
      aFileMan[ FM_RETURNFILE ] := 0 
      DO CASE
         CASE nLastKey == K_ENTER
            // First let's assign the filename and path to aFileMan
            aFileMan[ FM_RETURNFILE ] := nCurrent 
				 // Ok, here's the biggee

      ENDCASE
   RETURN (aFileMan[ FM_RETURNFILE ])

/***
*  ProcessKey( <nStatus>, <nElement>, <nRelative> ) --> nReturnValue
*
*
*/
FUNCTION ProcessKey( nStatus, nElement, nRelative )
   LOCAL nReturnValue := AC_CONT    // Set the default handler to continue
   Local nEl,nRel
   // Update the global element/relative with the passed versions
   nEl  := nElement
   nRel := nRelative

   DO CASE
   CASE nStatus == AC_IDLE
	
        TabUpdate( hScrollBar, nElement, LEN( aFiles ) )
      
   CASE nStatus == AC_HITTOP .OR. nStatus == AC_HITBOTTOM
      // Tried to go too far!
      TONE( 900, 1 )

   CASE nStatus == AC_EXCEPT
      // Keystroke exception
      DO CASE
      CASE LASTKEY() == K_ESC
         nReturnValue := AC_ABORT

      CASE LASTKEY() == K_HOME
         KEYBOARD CHR( K_CTRL_PGUP )
         nReturnValue := AC_CONT

      CASE LASTKEY() == K_END
         KEYBOARD CHR( K_CTRL_PGDN )
         nReturnValue := AC_CONT

      CASE UPPER(CHR(LASTKEY())) $ ;
         "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890 " .OR. ;
         LASTKEY() == K_DEL .OR. LASTKEY() == K_ENTER .OR. ;
         LASTKEY() == K_F5 .OR. LASTKEY() == K_F6

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
	Local aFileMan ,;
	      hScrollBar
   // Draw the primary box
	BOX(aFileMan[ FM_ROWTOP ], aFileMan[ FM_COLTOP ],;
   aFileMan[ FM_ROWBOTTOM ], aFileMan[ FM_COLBOTTOM ]+1,fr1,127,3,8)
	  
   setcolor(cor) 
   // Create the scrolling thumb tab and assign it to our global static
   hScrollBar := TabNew( aFileMan[ FM_ROWTOP ],;
                         aFileMan[ FM_COLBOTTOM ]+1,;
                         aFileMan[ FM_ROWBOTTOM ],;
                         aFileMan[ FM_COLOR ], 1 )
   TabDisplay(hScrollBar)

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
* -> FunáÑo que ativa o calend†rio
LOCAL OLDCUR:=SETCURSOR(0)
LOCAL X_POS:=ROW()
LOCAL Y_POS:=COL()
LOCAL C_COR:=SETCOLOR()
LOCAL DAT_HOJE:=DATE()
LOCAL CA_MES:=MONTH(DAT_HOJE)
LOCAL CA_ANO:=YEAR(DAT_HOJE)
LOCAL CA_DIA:=DAY(DAT_HOJE)
LOCAL CA_DATA:=DAT_HOJE
LOCAL CA_DIA1:=CTOD("01/"+STR(CA_MES,2)+"/"+SUBS(STR(CA_ANO,4),3))
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
      @ 5+M->X_X,00 SAY "≥"
      @ 5+M->X_X,38 SAY "≥"
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
   M->MES_ANO=SUBS("Janeiro  FevereiroMaráo    Abril    Maio     Junho    Julho    Agosto   Setembro Outubro  Novembro Dezembro ",CA_MES*9-8,9)
   M->MES_ANO=ALLTRIM(STR(DAY(CA_DATA),2))+" de "+TRIM(M->MES_ANO)
   M->MES_ANO=M->MES_ANO+" de "+STR(YEAR(CA_DATA),4)
   @ 2,0+(39-LEN(M->MES_ANO))/2 SAY M->MES_ANO
   C_TEC=INKEY(0)
   CA_ANO=CA_ANO+IIF(C_TEC=5,-1,IIF(C_TEC=24,1,0))
   CA_MES=CA_MES+IIF(C_TEC=19,-1,IIF(C_TEC=4,1,0))
   CA_MES=IIF(CA_MES<1,12,IIF(CA_MES>12,1,CA_MES))
   SET CENTURY ON
   IF CA_DIA > M->ULT_DIA
      CA_DIA = M->ULT_DIA
   ENDIF
   CA_DATA=CTOD(STR(CA_DIA,2)+"/"+STR(CA_MES,2)+"/"+STR(CA_ANO,4))
   CA_DIA1=CTOD("01/"+STR(CA_MES,2)+"/"+SUBS(STR(CA_ANO,4),3))
   SET CENTURY OFF
   RESTSCREEN(0,0,12,38,CA_TELA)
ENDDO
SETCOLOR(C_COR)
SETCURSOR(OLDCUR)
@ X_POS,Y_POS SAY ""
RETURN(NIL) 

FUNCTION CALCU
*
* -> FunáÑo que ativa a calculadora
LOCAL CUR:=SETCURSOR(1)
LOCAL X_POS:=ROW()
LOCAL Y_POS:=COL()
LOCAL C_COR:=SETCOLOR()
LOCAL CA_TELA:=SAVESCREEN(0,53,14,79)
Local C_RESULT ,;
      C_ALGA,;
		C_DEC,;
		C_DIG,;
		C_VAR,;
		C_VERDAD,;
		C_UOPER,;
		C_PERC,;
		OPE_RA
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
   C_DIG:=CHR(INKEY(0))
   IF C_DIG=CHR(27)
      EXIT
   END
   C_VAR:=IF(C_DIG=".","C_DEC",C_VAR)
   C_ALGA:=IF(C_DIG="." .AND. C_ALGA=SPACE(14),SPACE(13)+"0",C_ALGA)
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






				
function percent()
   LOCAL comp:=LTRIM(STR(INT((RECNO()/LASTREC())*100))),COR:=SETCOLOR("W+/B")
   @ 12,55 SAY comp+" %"
	SETCOLOR(COR)
   RETURN(.T.)				

FUNCTION VerifyPeriod( not1, not2, campo )
	IF !EMPTY( not1 )
		DBSEEK( DTOS( not1 ), .T. )
	ELSE	
		DBGOTOP()
	ENDIF	
	IF !EMPTY( not2 )
		IF campo > not2
			M_Display("Per°odo nÑo encontrado",79)
			RETURN ( .F. )
		ENDIF
	ELSE
		IF campo < not1
			M_Display("Per°odo nÑo encontrado",79)
			RETURN ( .F. )
		ENDIF	
	ENDIF	
RETURN( .T. )		 
//
Function ValidaData(dt_inicial,dt_final)
   IF dt_inicial > dt_final
		M_Display("Per°odo inv†lido, verifique!",79)
		RETURN ( .F. )
	ENDIF	
Return( .T. )

Function COMPACTAR(arquivo)
	LOCAL cor := SETCOLOR()
	LOCAL tel := SAVESCREEN(0,0,LastRow(),LastCol())
	LOCAL SETD,tamtol,DISPON,cont:=0
	Local OLDARQ,;
			NEWARQ
	If Open(arquivo,.T.)
	   dbgotop()
		tamtol:=(int(recsize()*lastrec()+header()+10))
		dispon:=(diskspace(left(curdrive(),1)))
		if dispon < tamtol
		   setcolor("b/w,w+/bg,,,b/w")
		   BOX(4,5,8,43,fr,127,3,8)
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

// Mostra o nome do màs corrente
// Parametros - NIL
// Retorno    - MES

FUNCTION DispMonth( dData )
	LOCAL aMonth := {"JANEIRO","FEVEREIRO","MARCO","ABRIL","MAIO","JUNHO",;
						  "JULHO","AGOSTO","SETEMBRO","OUTUBRO","NOVEMBRO","DEZEMBRO"}
RETURN( aMonth [ MONTH ( dData ) ] )




// Verifica o direcionamento da impress∆o
FUNCTION Impres( nCopias )
	IF nCopias == NIL
		nCopias := 1
	ENDIF
	IF M_QUERY ( "Confirma a impress∆o ?", 23 )
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
	LOCAL cTela   := SAVESCREEN ( 07, 08, 12, 59 )
	LOCAL nCursor := SETCURSOR ( 3 )
	LOCAL cCor    := SetCor ( "B/W, W+/BG, , , B/W" )
	LOCAL cArquivo := SPACE ( 12 )
	LOCAL hArquivo,;
			nErro  ,;
			cMens 
	Local GETLIST := {}		
	
	SET PRINTER TO		
	IF nCopias == NIL
		nCopias := 1
	ENDIF	
	IF ! ( M_QUERY ( "Deseja gravar em arquivo", 23 ) )
		RETURN ( .F. )
	ENDIF
	BOX ( 07, 08, 11, 58, fr, 127, 3, 8 )
	DO WHILE .T.
	   @ 09, 10    SAY "Entre com o nome do arquivo:"
  		@ 09, COL() GET cArquivo PICT "@!" VALID ( ! ( EMPTY ( cArquivo ) ) )
		READ
		IF LASTKEY() = 27
			SETCURSOR ( nCursor )
			SetCor ( cCor )
			RESTSCREEN ( 07, 08, 12, 59, cTela )
			RETURN ( .F. )
		ENDIF
  		cArquivo = UPPER ( TRIM ( cArquivo ) + IF ( AT ( ".", cArquivo ) > 0, "", ".PRN" ) )
		IF FILE ( cArquivo )
			IF ! ( M_QUERY ( "Arquivo " + cArquivo + " j† existe, deseja reutiliz†-lo ?", 79 ) ) 
         	LOOP
         ENDIF
      ENDIF
		hArquivo := FCREATE ( cArquivo )
		nErro    := FERROR()
		FCLOSE ( hArquivo )
		ERASE ( cArquivo )
		IF nErro # 0
			cMens := "Nome inv†lido para arquivo - Erro DOS No. "
     		M_DISPLAY ( cMens + STR ( nErro, 1 ), 79 )
			LOOP
		ENDIF
		EXIT
	ENDDO
	RESTSCREEN ( 07, 08, 12, 59, cTela )
   SET PRINTER TO ( cArquivo )
RETURN ( .T. )

// Cancela a impress∆o
FUNCTION Para_Impressao()
   IF M_QUERY ( "Cancela a impress∆o", 79 )
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
        print(row+2, col+pstrlen-9, " NÑo ", pfore)
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
				  print(row+2, col+pstrlen-9, " NÑo ", pfore)
				  print(row+2, col+4, "     ", pback)
		        print(row+2, col+4, " Sim ", pback)
              setshadow(o)
           ELSEIF (! pactive )
                  o := setshadow(.F.)
						print(row+2, col+4, "     ", pfore)
						print(row+2, col+4, " Sim ", pfore)
						print(row+2, col+pstrlen-9, "     ", pback)
				      print(row+2, col+pstrlen-9, " NÑo ", pback)
                  setshadow(o)
           ENDIF
           IF (retflag)
              exit
           ENDIF
        ENDDO
        restscreen(row-2,col-1,row+9,col+pstrlen+1,psscreen)
        return( pactive )		  
		  
Func Help(par1,par2,par3)
  local Tela_help:=savescreen(0,0,lastrow(),lastcol())
  local cur_ant:=setcursor(0) 
  local cor_ant:=setcor()
  LOCAL nAchoice,AREA:=SELECT()
  Local cabfor,dadfor,picfor
  Local cabmat,dadmat,picmat
  Local cabpro,dadpro,picpro
  Local cabfas,dadfas,picfas
  Local cabdef,daddef,picdef
  Local WorkIndice
  Public  aFileMan, aFileList,AFILES
  Public  hScrollBar, nMenuItem, nTagged
  Public  nEl, nRel, lReloadDir, nFileItem
  if par1 == "HELP"
     Retu(nil)
  end
  do case
     case PAR1 == "BROWSE"
       box(5,30,16,75,fr,127,3,8)
       setcor("b/w")
		 @ 06,31 say "Teclas:           AáÑo:                     "
		 @ 07,31 say "ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ"     
  		 @ 08,31 say "Ctrl+Page_Up     ≥ Inicio do Arquivo        "
  		 @ 09,31 say "Ctrl+Page_Down   ≥ Fim do Arquivo           "
		 @ 10,31 SAY "ALT+F            ≥ Congelar campo           "
		 @ 11,31 SAY "ALT+R            ≥ Restaurar tela de dados  "
		 @ 12,31 SAY "ALT+V            ≥ Visualizar descricao     "
		 @ 13,31 SAY CHR(24)+CHR(25)+CHR(26)+CHR(27)
		 @ 13,48 SAY "≥"
		 @ 13,49 SAY "Movimentos"
		 @ 14,31 SAY "F11              ≥ Calend†rio               "
		 @ 15,31 SAY "F12              ≥ Calculadora              "
		 M_SQUEAK()
  		 inkey(0)
  	 case par1 == NIL .and. par2 == NIL .AND. par3 == nil
  	    box(3,04,18,44,fr,127,3,8)  
  		 setcor("b/w")
  		 @ 04,05 say "ESCOLHA SUA OPCAO DIGITANDO A LETRA QUE"
  		 @ 05,05 say "SE ENCONTRA EM DESTAQUE (VERMELHO)   NA"       
  		 @ 06,05 say "PARTE SUPERIOR DO SEU VIDEO.           "
  		 @ 08,05 say "OBS - CASO SEU MONITOR SEJA MONO, DIGI-"
  		 @ 09,05 say "TE A PRIMEIRA LETRA (MAIUSCULA).       "
  		 @ 11,05 say "EXEMPLO - 1   Para escolher a opáao  de"   
  		 @ 12,05 say "[Engenharia] digite a letra <E>        "
  		 @ 14,05 say "EXEMPLO - 2   Para escolher a opáao  de"   
  		 @ 15,05 say "[Estoque/Custo] digite a letra <E>     "
  		 @ 17,05 say "    - Tecle [ESC] p/ Retornar -        "
  	    inkey(0)
	 CASE (PAR1 == "INCLUSAO" .AND. PAR3 == "WR1")               ;
	      .OR. (PAR1 == "SQTGREC1" .AND. PAR3 == "CFORNECEDOR" ) ;
		   .OR. (PAR1 == "SQTGREC2" .AND. PAR3 == "CFORNECEDOR" ) ;
			.OR. (PAR1 == "SQTGREC3" .AND. PAR3 == "CFORNECEDOR" ) ;
			.OR. (PAR1 == "SQTGREC4" .AND. PAR3 == "CFORNECEDOR" )
			 			 
         cabfor := { "CODIGO","APELIDO" } 
         dadfor := { "CFOR",  "APELIDO" } 
		   picfor := { "99999999","@!" }
			SELECT("SIPCFOR")
			DBSETORDER(2)
			SIPCFOR->(DBGOTOP())
  			HBrowseDB( 18,0,23,79," TABELA DE FORNECEDOR " ,cabfor ,dadfor, picfor,,,.F. )
			DBSETORDER(1)			
			
	 CASE ((PAR1 == "INCLUSAO" .AND. PAR3 == "WN1")  ;
	      .OR. (PAR1 == "INCLUSAO".AND. PAR3 == "WNL1")) ;
 			.OR. (PAR1 == "SQTGNCM1" .AND. PAR3 == "CPRODUTO" );
 			.OR. (PAR1 == "SQTGNCM2" .AND. PAR3 == "CPRODUTO" );
 			.OR. (PAR1 == "SQTGNCM3" .AND. PAR3 == "CPRODUTO" );
 			.OR. (PAR1 == "SQTGNCM4" .AND. PAR3 == "CPRODUTO" );
 			.OR. (PAR1 == "SQTGNCA1" .AND. PAR3 == "CPRODUTO" );
 			.OR. (PAR1 == "SQTGNCA2" .AND. PAR3 == "CPRODUTO" );
 			.OR. (PAR1 == "SQTGNCA3" .AND. PAR3 == "CPRODUTO" );
 			.OR. (PAR1 == "SQTGNCA4" .AND. PAR3 == "CPRODUTO" );
 			.OR. (PAR1 == "SQTGNCL1" .AND. PAR3 == "CPRODUTO" );
 			.OR. (PAR1 == "SQTGNCL2" .AND. PAR3 == "CPRODUTO" );
 			.OR. (PAR1 == "SQTGNCL3" .AND. PAR3 == "CPRODUTO" );
 			.OR. (PAR1 == "SQTGNCL4" .AND. PAR3 == "CPRODUTO" )															
			
         cabpro := { "CODIGO","DESCRICAO" } 
         dadpro := { "CPRO","DESPRO" }        
			picpro := { "@!","@!" }	
			
			SELECT("SIPCPRO")
			DBSETORDER(4)
			SIPCPRO->(DBGOTOP())
  			HBrowseDB( 18,0,23,79," TABELA DE PRODUTOS " ,cabpro ,dadpro, picpro,,,.F. )						
			DBSETORDER(1)			
			
	 CASE (PAR1 == "INCLUSAO" .AND. ( PAR3 == "WN2"  .OR.  PAR3 == "WR2" .OR. PAR3 == "WNL2" ) ) ;
  			.OR. (PAR1 == "SQTGNCM1" .AND. PAR3 == "CCOMPONENTE" )	;								
 			.OR. (PAR1 == "SQTGNCM2" .AND. PAR3 == "CCOMPONENTE" )	; 								
 			.OR. (PAR1 == "SQTGNCM3" .AND. PAR3 == "CCOMPONENTE" )	;								
 			.OR. (PAR1 == "SQTGNCM4" .AND. PAR3 == "CCOMPONENTE" )	;								
 			.OR. (PAR1 == "SQTGREC1" .AND. PAR3 == "CCOMPONENTE" )	;								
 			.OR. (PAR1 == "SQTGREC2" .AND. PAR3 == "CCOMPONENTE" )	;								
			.OR. (PAR1 == "SQTGREC3" .AND. PAR3 == "CCOMPONENTE" )	;								
			.OR. (PAR1 == "SQTGREC3" .AND. PAR3 == "CCOMPONENTE" )												
 			
         cabmat := { "CODIGO","DESCRICAO" } 
			dadmat := { "CDMT","DSC1"}
			picmat := { "@!","@!" }	
/*			dadmat := { TBColumnNew( "CODIGO", FIELDWBLOCK( "SIPTENG->COMPONENTE",select() ) )  ,;	
                    TBColumnNew( "DESCRICAO",FIELDWBLOCK( "SIPCMAT->DSC1" ,select() ) )          	}	                    			*/
							
			SELECT("SIPCMAT")
			DBSETORDER(5)               
			SIPCMAT->(DBGOTOP())        
  			HBrowseDB( 18,0,23,79," TABELA DE MATERIAIS " ,cabmat ,dadmat, picmat,,,.F. )								
         DBSETORDER(1)
	 CASE (PAR1 == "INCLUSAO" .AND. ( PAR3 == "WN6" .OR. PAR3 == "WNL6")) ;
	 		.OR. (PAR1 == "SQTGNCM1" .AND. PAR3 == "CFASE" )	;											
			.OR. (PAR1 == "SQTGNCM2" .AND. PAR3 == "CFASE" )	;											
			.OR. (PAR1 == "SQTGNCM3" .AND. PAR3 == "CFASE" )	;											
			.OR. (PAR1 == "SQTGNCM4" .AND. PAR3 == "CFASE" )												
	 
         cabfas := { "CODIGO","DESCRICAO" } 
         dadfas := { "CODIGO","DESCRICAO" }        
			picfas := { "@!","@!" }	
			SELECT("SQTTFAS")
			DBSETORDER(2)
			SQTTFAS->(DBGOTOP())
  			HBrowseDB( 18,0,23,79," TABELA DE FASE " ,cabfas ,dadfas, picfas,,,.F. )								
 			DBSETORDER(1)
	 CASE (PAR1  == "INCLUSAO" .AND. ( PAR3 == "WN7" .OR. PAR3 == "WNL7".OR. PAR3 == "WR6" ) ) ;
			.OR. (PAR1 == "SQTGREC1" .AND. PAR3 == "CDEFEITO" )						;						
			.OR. (PAR1 == "SQTGREC2" .AND. PAR3 == "CDEFEITO" )						;						
			.OR. (PAR1 == "SQTGREC3" .AND. PAR3 == "CDEFEITO" )						;						
			.OR. (PAR1 == "SQTGREC4" .AND. PAR3 == "CDEFEITO" )						;						
			.OR. (PAR1 == "SQTGNCM1" .AND. PAR3 == "CDEFEITO" )						;						
			.OR. (PAR1 == "SQTGNCM2" .AND. PAR3 == "CDEFEITO" )						;						
			.OR. (PAR1 == "SQTGNCM3" .AND. PAR3 == "CDEFEITO" )						;						
      	.OR. (PAR1 == "SQTGNCM4" .AND. PAR3 == "CDEFEITO" )	
		
         cabdef := { "CODIGO","DESCRICAO" } 
         daddef := { "COD","DSC" }        
			picdef := { "@!","@!" }	
			SELECT("SIPTDEF")
			DBSETORDER(2)
			SIPTDEF->(DBGOTOP())
  			HBrowseDB( 18,0,23,79," TABELA DE DEFEITO " ,cabdef ,daddef, picdef,,,.F. )											
			DBSETORDER(1)
	OTHERWISE
       box(5,30,18,75,fr,127,3,8)
       setcor("b/w")
		 @ 06,31 say "Teclas:           AáÑo:                     "
		 @ 07,31 say "ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ"     
  		 @ 08,31 say "Ctrl+Page_Up     ≥ Inicio do Arquivo        "
  		 @ 09,31 say "Ctrl+Page_Down   ≥ Fim do Arquivo           "
		 @ 10,31 SAY "ALT+F            ≥ Congelar campo           "
		 @ 11,31 SAY "ALT+R            ≥ Restaurar tela de dados  "
		 @ 12,31 SAY "ALT+V            ≥ Visualizar descricao     "
		 @ 13,31 SAY CHR(24)+CHR(25)+CHR(26)+CHR(27)
		 @ 13,48 SAY "≥ Movimentos     "
		 @ 14,31 SAY "F1               ≥ Help                     "
		 @ 15,31 SAY "F2               ≥ Acesso a entrada de dados"
		 @ 16,31 SAY "F3               ≥ Impressao de laudo       "
    	 @ 17,31 SAY "F4               ≥ Consulta de forne/produto"
		 M_SQUEAK()
  		 inkey(0)			
  END
  setcor(cor_ant)
  setcursor(cur_ant)
  SELECT(AREA)
  restscreen(0,0,lastrow(),lastcol(),Tela_help )

  Retu(nil)
  
// Display de barra com titulo centralizado e opcao de cor 
/* cCor vetor { linha de enfeite e fundo, cor do titulo e fundo do mesmo } */

FUNCTION BarTitulo( LinI, ColI, ColF, Titulo , Cor)
Local cCor
cCor := SETCOLOR()
SETCOLOR( Cor[1] )
Dispbox( LinI, ColI, LinI, ColF, B_SINGLE )
@ LinI,ColI SAY '|'
@ LinI,ColF SAY '|'
SETCOLOR( Cor[2] )
@ LinI,ColI SAY PADC(Titulo,(ColF-ColI)+1)
SETCOLOR( cCor )
RETURN(NIL) 

FUNCTION ConsDesc()
Local Descr := space(30)
Local telas,cCor,WorKarea
Local GETLIST := {}
cCor := SETCOLOR()
WorKarea := ALIAS(SELECT())
SAVE SCREEN TO TELAS 
SETCOLOR("Bg+/w,w+/b,,,w+/b")
Dispbox( 10, 15, 12, 65, B_SINGLE+' ') 
@ 11,18 SAY 'Descriá∆o: ' GET Descr PICT '@!' VALID Existe(ALLTRIM(Descr),"Descricao n∆o encontrada",.F.,WorKarea )    
READ
RESTORE SCREEN FROM TELAS
SETCOLOR(cCor)
RETURN(NIL)


/* Pesquisa o lote digitado no recebimento na tabela de NQA p/ verificar o No.
    de amostras e de defeitos aceitos p/ cada especificaá∆o de lote */
  
FUNCTION PesqLote( _Qtd, _Nqa ) 
Local WorKarea,_Amos,_Def
WorKarea := ALIAS(SELECT())
SELECT("SQTTNQA")
DBSETORDER(3)
SQTTNQA->(DBGOTOP())
IF ( SQTTNQA->(DBSEEK( STR(_Nqa,5,2) )) )
DO WHIL _Nqa == SQTTNQA->NQA .AND. SQTTNQA->(!EOF())
	IF _Qtd <= SQTTNQA->TAMALOTE 
         _Amos := SQTTNQA->AMOSTRA		
			_Def  := SQTTNQA->ACEITO
			IF _Qtd >0
     			m_display("PEGUE "+ALLTRIM(STR(_Amos))+" AMOSTRAS",79) 
    			m_display("ACEITµVEL ATê "+ALLTRIM(STR(_Def))+" DEFEITOS",15) 
			ENDIF	
			EXIT
	ENDIF
	SQTTNQA->(DBSKIP())
ENDDO
ELSE
 m_display("PRODUTO COM  N.Q.A. INVµLIDO ",79) 
ENDIF
SELECT( WorKarea )
DBSETORDER(1)
RETURN(.T.)

Function CalcDef( nCodPart, nNqa )
Local nOldOrdem := INDEXORD()
Local nOldArea  := ALIAS(SELECT())
Local nTamLote := 0 ,;
      nDefeito := 0 ,;
		_Def := 0

SELECT("SQTTINS")
SQTTINS->(DBGOTOP())
DBSETORDER(1)
If ( SQTTINS->(DBSEEK(nCodPart)) )
  	nTamLote := SQTTINS->QUANTIDADE
	nDefeito := SQTTINS->QUANTDEF
Else
	SELECT(nOldArea)
	DBSETORDER(nOldOrdem)
	RETURN(.T.)  
Endif	
SELECT("SQTTNQA")
DBSETORDER(3)
SQTTNQA->(DBGOTOP())
IF (SQTTNQA->(DBSEEK( STR(nNqa,5,2) )))
	DO WHIL nNqa == SQTTNQA->NQA .AND. SQTTNQA->(!EOF())
		IF nTamLote <= SQTTNQA->TAMALOTE 
			_Def  := SQTTNQA->ACEITO
			EXIT	
		ENDIF		
		SQTTNQA->(DBSKIP())
	ENDDO
ENDIF
SELECT("SQTTINS")
IF nDefeito >_Def
   m_display ("Item Merece Inspeá∆o Detalhada",79)
   /* 	SQTTINS->DETALHADO  := 'S'*/
ENDIF
SELECT(nOldArea)
DBSETORDER(nOldOrdem)
Return(.t.) 

FUNCTION PesqComp(nProduto,nComponente)
Local nOldOrdem := INDEXORD()
Local nOldArea  := ALIAS(SELECT())
SELECT("SIPTENG")
DBSETORDER(1)
IF ( SIPTENG->(DBSEEK(nProduto+nComponente)) )
     SELECT(nOldArea)
	  DBSETORDER(nOldOrdem)
 	  RETURN(.T.) 
ELSE 	
  M_DISPLAY("Componente N∆o Pertence ao produto",79)
ENDIF	
RETURN(.F.)

FUNCTION PesqOp( _nOp, nProduto )
Local nOldOrdem := INDEXORD()
Local nOldArea  := ALIAS(SELECT())
SELECT("SIPTCOP")
DBSETORDER(1)
IF ( SIPTCOP->(DBSEEK(ALLTRIM(_nOp))) )
	DO WHIL SIPTCOP->NOP == _nOp .AND. SIPTCOP->(!EOF())
      IF SIPTCOP->PRO == nProduto
         SELECT(nOldArea)  
		   DBSETORDER(nOldOrdem)
		   RETURN(.T.) 
		ENDIF
	   SIPTCOP->(DBSKIP())
	ENDDO
	M_DISPLAY(" Produto N∆o Pertence a OP ",79)
ELSE	
	M_DISPLAY(" OP nao encontrada ou nao efetivada ",79)
ENDIF	
RETURN(.F.)


/* funcao que imprime graficos */

FUNCTION GRAFICO(nVet1,nDef,nLegenda,nvettit,nvetleg)			
Local nVet2 := {"",""}
Local nCord,;
      wdesc,;
		I,;
		GETLIST := {}
		
&& Vetor com os parametros de impressao
declare vetpar[10]
vetpar[1]  = 9    && Indica que o vetor tem 9 parametros a alterar.
vetpar[2]  = 0    && Orientacao do desenho: 0 = dimensao horizontal
                  && correspondendo `a maior dimensao da area util do papel.
vetpar[3]  = 80   && Largura = 50 colunas.
vetpar[4]  = 1    && Numero de paginas = 1.
vetpar[5]  = 1    && Densidade = 0
vetpar[6]  = 0    && Positivo ( cor 0 branca, cor 1 preta).
vetpar[7]  = 1    && Utilizar a LPT1.
vetpar[8]  = 5    && Uma pagina = 4,00 polegadas 4
vetpar[9]  = 50   && (reservado) 0
vetpar[10] = 27   && ESC aborta impressao.


declare Vvetleg[2],Vvettit[2]
Vvetleg[1] = "TESTE"
Vvetleg[2] = "TESTE1"

Vvettit[1] = "Grafico Impresso com as Cores Defaults"
Vvettit[2] = "ok"

BC_INICTR(60, vetpar)    && inicia sessao de impressao
BC_GCORES(2)     && Seleciona programacao automatica de cores (p/ impressao)
                   && OBS: obrigatorio aciona-la ANTES da abertura de janela.
						 
BC_GABJAN()						 
BC_GDGRAF(23, "", -1 ) 
BC_GDGRAD(15, 2) 
BC_GEIXOS2 (,"","Defeito","Quantidade")
BC_GLINHA(nVet1,"",nDef,Nvetleg,Nvettit)       
nCord := .65
for i := 1 to len(nLegenda)
    SIPTDEF->(DBGOTOP())
    IF ( SIPTDEF->(DBSEEK(nLegenda[I,1])) )
		 wdesc := substr(SIPTDEF->DSC,1,10)
	    BC_TEXTM(.04,nCord,ltrim(str(nLegenda[i,1],5))+' '+wdesc)
		 nCord :=(nCord-.03)
    ENDIF	 
next		
? " Imprimindo o terceiro grafico (ESC interrompe a impressao) ..."
BC_INICTR(20)      && finaliza sessao de impressao: retorna ao
                   && modo 20 e envia o grafico para a impressora.
? ""
? " Impressao do terceiro grafico completada. Pressione qq. tecla p/ finalizar."
inkey(0)
BC_GFEJAN()
eject           
RETURN(NIL)

   
FUNCTION GRAFICO1(nVet1,nVet2,nDef,nLegenda,nvettit,nvetleg,nTipgraf,aPartnumber)			
local nCord,;
      wdesc,;
		I,;
		lCord,;
		GETLIST := {}

&& Vetor com os parametros de impressao
declare vetpar[10]
vetpar[1]  = 9    && Indica que o vetor tem 9 parametros a alterar.
vetpar[2]  = 0    && Orientacao do desenho: 0 = dimensao horizontal
                  && correspondendo `a maior dimensao da area util do papel.
vetpar[3]  = 80   && Largura = 50 colunas.
vetpar[4]  = 1    && Numero de paginas = 1.
vetpar[5]  = 1    && Densidade = 0
vetpar[6]  = 0    && Positivo ( cor 0 branca, cor 1 preta).
vetpar[7]  = 1    && Utilizar a LPT1.
vetpar[8]  = 5    && Uma pagina = 4,00 polegadas 4
vetpar[9]  = 50   && (reservado) 0
vetpar[10] = 27   && ESC aborta impressao.


declare Vvetleg[2],Vvettit[2]
Vvetleg[1] = "TESTE"

Vvettit[1] = "Grafico Impresso com as Cores Defaults"
Vvettit[2] = "ok"

BC_INICTR(60, vetpar)    && inicia sessao de impressao
BC_GCORES(2)     && Seleciona programacao automatica de cores (p/ impressao)
                 && OBS: obrigatorio aciona-la ANTES da abertura de janela.

Lcord := 1
for i:=1 to 20
    BC_TEXTM(Lcord,,' ')
	 Lcord := Lcord -.05 
next
BC_GDMOLD(2,2,.001)						 
BC_GABJAN()						 
BC_DMOUSE(2)
BC_GDGRAF(23, "", -1 ) 
BC_GDGRAD(15, 2) 
BC_GDMOLD(2,2,.001)	 
BC_GDPLEGE(1,2,.01,.35,.2,.4 )
BC_GDMOLD(2,2,.001)						 
BC_GDPTITU(1,.1,.9,.8,.15)   
/*BC_GDTITU(15,.012,.024)*/
BC_GEIXOS2 ("","","Defeito","Quantidade")
if len(nVet2) # 0  
   IF nTipgraf == 'B'
		BC_GBARRA(nVet1,nVet2,"",nDef,Nvetleg,Nvettit)       
   ELSEIF nTipgraf == 'A'
		BC_GAREA(nVet1,nVet2,"",nDef,Nvetleg,Nvettit)       
   ELSEIF nTipgraf == 'L'
		BC_GLINHA(nVet1,nVet2,"",nDef,Nvetleg,Nvettit)       
	ENDIF
else
   IF nTipgraf == 'B'
	  	BC_GBARRA(nVet1,"",nDef,Nvetleg,Nvettit)       
   ELSEIF nTipgraf == 'A'
	  	BC_GAREA(nVet1,"",nDef,Nvetleg,Nvettit)       
   ELSEIF nTipgraf == 'L'
	  	BC_GLINHA(nVet1,"",nDef,Nvetleg,Nvettit)       
	ENDIF
ENDIF
BC_DMOUSE(2)
nCord := .65
for i := 1 to len(nLegenda)
	IF VALTYPE(nLegenda[I,1]) == 'C'
		BC_TEXTM(.04,nCord,ltrim(nLegenda[i,1])+' '+nLegenda[i,2])
		nCord :=(nCord-.03)
	ELSEIF VALTYPE(nLegenda[I,1]) == 'N'	
		BC_TEXTM(.04,nCord,ltrim(str(nLegenda[i,1],5))+' '+ALLTRIM(nLegenda[i,2]))
		nCord :=(nCord-.03)	
	ENDIF	
next	

/*IF VALTYPE(nLegenda[1]) == 'N'
	for i := 1 to len(nLegenda)
	    SIPTDEF->(DBGOTOP())
	    IF ( SIPTDEF->(DBSEEK(nLegenda[I,1])) )
			 wdesc := substr(SIPTDEF->DSC,1,10)
		    BC_TEXTM(.04,nCord,ltrim(str(nLegenda[i,1],5))+' '+wdesc)
			 nCord :=(nCord-.03)
	    ENDIF	 
	next		*/
/*ELSE 
   SELECT("SIPCMAT")
	for i := 1 to len(nLegenda)
       SIPCMAT->(DBGOTOP())
       IF SIPCMAT->(DBSEEK(nLegenda[I,1])) 
	       BC_TEXTM(.03,nCord,ALLTRIM(STR(I))+ '-'+ ALLTRIM(nLegenda[I,1]))
			 nCord :=(nCord-.03)
		 ENDIF
   next		
	SELECT("SQTCNCM") 
ENDIF    */
BC_INICTR(20)     && finaliza sessao de impressao: retorna ao
                  && modo 20 e envia o grafico para a impressora.
						
BC_GCORES(0)
/*IF aPartnumber != NIL     //.or. LEN(aPartnumber)>0 
   gracom(aPartnumber)
ENDIF*/
eject           
RETURN(NIL)			

FUNCTION TESTIMP()
Local Retorna
IF !ISPRINTER()
   RETORNA := .F.
ELSE
 RETORNA := .T.	
ENDIF
RETURN(Retorna)

FUNCTION DDOS()
LOCAL OldScreen := SAVESCREEN(0,0,MAXROW(),MAXCOL())
M_DISPLAY( " DIGITE EXIT PARA RETORNAR AO PROGRAMA ",32)
@ 0,0 CLEAR TO MAXROW(),MAXCOL()
!C:\DOS\COMMAND.COM
RESTSCREEN(0,0,MAXROW(),MAXCOL(),OldScreen)
RETURN(NIL)

FUNCTION COMPACTA( ESCOLHA )
IF ESCOLHA     == 91
   ARQNTX("SQTCNCM",.T.)
ELSEIF ESCOLHA == 92
   ARQNTX("SQTCREC",.T.)
ELSEIF ESCOLHA == 93
   ARQNTX("SQTCNCA",.T.)
ELSEIF ESCOLHA == 94
   ARQNTX("SQTCNCL",.T.)	
ELSEIF ESCOLHA == 95
   ARQNTX("SQTTFAS",.T.)
ELSEIF ESCOLHA == 96
   ARQNTX("SIPTDEF",.T.)
ELSEIF ESCOLHA == 97
   ARQNTX("SIPCFOR",.T.)
ELSEIF ESCOLHA == 98
   ARQNTX("SQTCMAT",.T.)
ENDIF
M_DISPLAY( " ARQUIVO COMPACTADO ",79 )
PACK	
DBCLOSEALL()
RETURN(NIL)

FUNCTION INDEXACAO( ESCOLHA )
IF ESCOLHA     == 79
   IF FILE( "SQTINCM*.NTX" )
	   DELETE FILE SQTINCM*.NTX
	ENDIF	
   ARQNTX("SQTCNCM",.T.)
ELSEIF ESCOLHA == 80
   IF FILE( "SQTIREC*.NTX" )
	   DELETE FILE SQTIREC*.NTX
	ENDIF	
   ARQNTX("SQTCREC",.T.)	
ELSEIF ESCOLHA     == 81
   IF FILE( "SQTINCA*.NTX" )
	   DELETE FILE SQTINCA*.NTX
	ENDIF	
   ARQNTX("SQTCNCA",.T.)
ELSEIF ESCOLHA     == 82
   IF FILE( "SQTINCL*.NTX" )
	   DELETE FILE SQTINCL*.NTX
	ENDIF	
   ARQNTX("SQTCNCL",.T.)		

ELSEIF ESCOLHA == 83
   IF FILE( "SQTIFAS*.NTX" )
	   DELETE FILE SQTIFAS*.NTX
	ENDIF			
   ARQNTX("SQTTFAS",.T.)
ELSEIF ESCOLHA == 84
   IF FILE( "SIPIDEF*.NTX" )
   	DELETE FILE SIPIDEF*.NTX
	ENDIF			
   ARQNTX("SIPTDEF",.T.)
ELSEIF ESCOLHA == 85
   IF FILE( "SIPIFOR*.NTX" )
   	DELETE FILE SIPIFOR*.NTX
	ENDIF			
   ARQNTX("SIPCFOR",.T.)
ELSEIF ESCOLHA == 86
   IF FILE( "SIPIMAT*.NTX")
   	DELETE FILE SIPIMAT*.NTX
	ENDIF	
   ARQNTX("SQTCMAT",.T.)
ENDIF
DBCLOSEALL()
RETURN(NIL)

function gracom(aPartnumber)
LOCAL FORN,WDESFOR := ' ',;
      DEFEITO := {},;
		nItem ,;
		nCord,;
		WDESC ,;
		I,;
		GETLIST := {}
set devi to print
nCord := prow()+1
@ nCord,02 say 'Componentes com o defeito acima analisado .'
nCord := nCord + 1
SELECT("SIPCMAT")
aPartnumber := ASORT(aPartnumber,,, {|x,y| x > y })
for i := 1 to len(aPartnumber)
    DBSETORDER(1)
    SIPCMAT->(DBGOTOP())
    IF ( SIPCMAT->(DBSEEK(aPartnumber[I])) )
		 wdesc := substr(SIPCMAT->DSC1,1,20)
		 FORN := SIPCMAT->CFOR 
		 SELECT("SIPCFOR")
		 DBSETORDER(1)
       IF ( SIPCFOR->(DBSEEK(FORN)) )
          WDESFOR := SIPCFOR->APELIDO		 
			 SELECT("SIPCMAT")	 
		 ENDIF
	    @ nCord,02 say ltrim(aPartnumber[I])+' '+wdesc 
	    @ nCord,38 say 'Fornecedor: ' + alltrim(SUBSTR(WDESFOR,1,20))
		 SELECT("SQTCNCM")
		 DBSETORDER(8)
		 SQTCNCM->(DBGOTOP())
		 SQTCNCM->(DBSEEK(aPartnumber[I]))
		 DO WHILE aPartnumber[I] == SQTCNCM->COMPONENTE .AND. SQTCNCM->(!EOF())
          nItem := ASCAN(Defeito,{|aDef| aDef[1]=SQTCNCM->DEFEITO }) 
			 IF nItem == 0
				 AADD(DEFEITO,{SQTCNCM->DEFEITO,SQTCNCM->QTREC+SQTCNCM->QTPRO})          
			 ELSE
				 DEFEITO[nItem,1]+= SQTCNCM->QTREC+SQTCNCM->QTPRO          			   
			 ENDIF	 
		 ENDDO
		 FOR I := 1 TO LEN(DEFEITO)
           @ nCord,50 SAY DEFEITO[I,2] 		     
           @ nCord,PCOL()+2 SAY 'de ' + ALLTRIM(STR(DEFEITO[I,1],5)) 		     
			  IF PCOL() >= 132
				  nCord := nCord + 1
			  ENDIF	  
		 NEXT
		 nCord := nCord + 1
    ENDIF	 
next		
set devi to screen
set print off
return(nil)

FUNCTION CONSUL()
LOCAL CODIGO := SPACE(14) ,;
      CODIGO1 := 0 ,; 
      DESCRICAO := SPACE(30),;
		nTela := SAVESCREEN( 0,0,MAXROW(),MAXCOL()),;
		nCor := SETCOLOR(),;
		nOrder := INDEXORD(),;
      nCursor := SETCURSOR(),;
		GETLIST := {}
		
SETCOLOR("B/W,W+/BG+,,,w/B")		
DispBox(08,18,14,63,fr) 		
SETCURSOR(1)
DO WHIL .T.
IF ALIAS(SELECT()) == "SIPCFOR"  .OR.  ALIAS(SELECT()) == "SQTCREC"
   @ 10,21 SAY 'CODIGO: ' GET CODIGO1 PICT '99999999'
ELSE
   @ 10,21 SAY 'CODIGO: ' GET CODIGO PICT '@!' 
ENDIF
   @ 12,21 SAY 'DESCRICAO:' GET DESCRICAO PICT '@!'
READ
IF LASTKEY() == 27
	RESTSCREEN( 0,0,MAXROW(),MAXCOL(),nTela)
	SETCOLOR(nCor)
	DBSETORDER(nOrder)
	RETURN(.F.)
ENDIF	
IF ( !EMPTY(DESCRICAO) .AND. !EMPTY(CODIGO) ) .OR.  ( !EMPTY(DESCRICAO) .AND. !EMPTY(CODIGO1) )
   M_DISPLAY( "APENAS UMA DAS OPCOES DEVE SER COLOCADA",79)
	LOOP
ENDIF
EXIT
ENDDO
SETCURSOR(0)
IF ALIAS(SELECT()) == "SIPCFOR"
   IF !EMPTY(CODIGO1)
	   DBSETORDER(1)
 		IF SIPCFOR->(DBSEEK(CODIGO1))
			RESTSCREEN( 0,0,MAXROW(),MAXCOL(),nTela)
			SETCOLOR(nCor)
			DBSETORDER(nOrder)		
		   RETURN(.T.)
		ELSE
		   M_DISPLAY(" CODIGO NAO ENCONTRADO ",79)	
		ENDIF		
	ELSE
	   IF SIPCFOR->(DBSEEK(ALLTRIM(DESCRICAO)))
			RESTSCREEN( 0,0,MAXROW(),MAXCOL(),nTela)
			SETCOLOR(nCor)
			DBSETORDER(nOrder)
		   RETURN(.T.)
		ELSE
		   M_DISPLAY(" DESCRICAO NAO ENCONTRADO ",79)	
		ENDIF
	ENDIF	
ELSEIF ALIAS(SELECT()) == "SIPCMAT"
   IF !EMPTY(CODIGO)
	   DBSETORDER(1)
 		IF SIPCMAT->(DBSEEK(CODIGO))
			RESTSCREEN( 0,0,MAXROW(),MAXCOL(),nTela)
			SETCOLOR(nCor)
			DBSETORDER(nOrder)
		   RETURN(.T.)
		ELSE
		   M_DISPLAY(" CODIGO NAO ENCONTRADO ",79)	
		ENDIF		
	ELSE
	   IF SIPCMAT->(DBSEEK(ALLTRIM(DESCRICAO)))
			RESTSCREEN( 0,0,MAXROW(),MAXCOL(),nTela)
			SETCOLOR(nCor)
			DBSETORDER(nOrder)		
		   RETURN(.T.)
		ELSE
		   M_DISPLAY(" DESCRICAO NAO ENCONTRADO ",79)	
		ENDIF
	ENDIF	   
ELSEIF ALIAS(SELECT()) == "SIPCPRO"	
   IF !EMPTY(CODIGO)
	   DBSETORDER(1)
 		IF SIPCPRO->(DBSEEK(CODIGO))
			RESTSCREEN( 0,0,MAXROW(),MAXCOL(),nTela)
			SETCOLOR(nCor)
			DBSETORDER(nOrder)
		   RETURN(.T.)
		ELSE
		   M_DISPLAY(" CODIGO NAO ENCONTRADO ",79)	
		ENDIF		
	ELSE
	   IF SIPCPRO->(DBSEEK(ALLTRIM(DESCRICAO)))
			RESTSCREEN( 0,0,MAXROW(),MAXCOL(),nTela)
			SETCOLOR(nCor)
			DBSETORDER(nOrder)		
		   RETURN(.T.)
		ELSE
		   M_DISPLAY(" DESCRICAO NAO ENCONTRADO ",79)	
		ENDIF
	ENDIF	   
ELSEIF ALIAS(SELECT()) == "SQTCREC"	
	IF !EMPTY(CODIGO1)
	   DBSETORDER(2)
 		IF SQTCREC->(DBSEEK(STR(CODIGO1,8)))
			RESTSCREEN( 0,0,MAXROW(),MAXCOL(),nTela)
			SETCOLOR(nCor)
			DBSETORDER(nOrder)
		   RETURN(.T.)
		ELSE
		   M_DISPLAY(" CODIGO NAO ENCONTRADO ",79)	
		ENDIF		
	ELSE
	   IF SQTCREC->(DBSEEK(ALLTRIM(DESCRICAO)))
			RESTSCREEN( 0,0,MAXROW(),MAXCOL(),nTela)
			SETCOLOR(nCor)
			DBSETORDER(nOrder)		
		   RETURN(.T.)
		ELSE
		   M_DISPLAY(" DESCRICAO NAO ENCONTRADO ",79)	
		ENDIF
	ENDIF	   	
ELSEIF ALIAS(SELECT()) == "SQTCNCM"	
   IF !EMPTY(CODIGO)
	   DBSETORDER(1)
 		IF SQTCNCM->(DBSEEK(CODIGO))
			RESTSCREEN( 0,0,MAXROW(),MAXCOL(),nTela)
			SETCOLOR(nCor)
			DBSETORDER(nOrder)
		   RETURN(.T.)
		ELSE
		   M_DISPLAY(" CODIGO NAO ENCONTRADO ",79)	
		ENDIF		
	ELSE
	   IF SQTCNCM->(DBSEEK(ALLTRIM(DESCRICAO)))
			RESTSCREEN( 0,0,MAXROW(),MAXCOL(),nTela)
			SETCOLOR(nCor)
			DBSETORDER(nOrder)		
		   RETURN(.T.)
		ELSE
		   M_DISPLAY(" DESCRICAO NAO ENCONTRADO ",79)	
		ENDIF
	ENDIF	   	
ENDIF
RESTSCREEN( 0,0,MAXROW(),MAXCOL(),nTela)
SETCOLOR(nCor)
DBSETORDER(nOrder)
RETURN(.F.)