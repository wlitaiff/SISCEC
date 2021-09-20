
#include "Fileman.ch"
#include "Directry.ch"
#include "Inkey.ch"
#include "Memoedit.ch"
#include "Achoice.ch"

STATIC aFileMan, aFileList
STATIC hScrollBar, nMenuItem, nTagged
STATIC nEl, nRel, lReloadDir, nFileItem
MEMVAR GetList

/***
*  FileMan( <nRowTop>, <nColumnTop>, <nRowBottom>, 
*     [<cColorString>], [<cDefaultPath>] ) --> cDOSFileName
*
*/
FUNCTION FileMan( nRowTop, nColumnTop, nRowBottom, ;
                  cColorString, cDefaultPath )
   LOCAL lSetScore

   // Set the default values
   nMenuItem   := 1
   nTagged     := 0
   nFileItem   := 1
   nEl         := 1
   nRel        := 1
   lReloadDir  := .T.
   aFileMan    := {}
   aFileList   := {}

   // Create the array
   aFileMan := ARRAY( FM_ELEMENTS )

   // Resolve parameters
   IF nRowTop = NIL
      nRowTop := 0
   ELSE
      IF nRowTop > (MAXROW() - 7)
         nRowTop := MAXROW() - 7
      ENDIF
   ENDIF
   aFileMan[ FM_ROWTOP ] := nRowTop

   IF nColumnTop = NIL
      nColumnTop := 0
   ELSE
      IF nColumnTop > (MAXCOL() - 52)
         nColumnTop := MAXROW() - 52
      ENDIF
   ENDIF
   aFileMan[ FM_COLTOP ] := nColumnTop

   IF nRowBottom = NIL
      nRowBottom := 0
   ELSE
      IF nRowBottom > MAXROW()
         nRowBottom := MAXROW()
      ENDIF
   ENDIF
   aFileMan[ FM_ROWBOTTOM ] := nRowBottom
   aFileMan[ FM_COLBOTTOM ] := nColumnTop + 15

   // Color string for FileMan()
   IF cColorString = NIL
      cColorString := SETCOLOR()
   ENDIF
   aFileMan[ FM_COLOR ] := cColorString

   // Save the old color
   aFileMan[ FM_OLDCOLOR ] := SETCOLOR( aFileMan[ FM_COLOR ] )

   // Save the old work area
   aFileMan[ FM_OLDSELECT ] := SELECT()

   // Set the scoreboard
   lSetScore := SET( _SET_SCOREBOARD, .F. )

   // Save the screen
   aFileMan[ FM_OLDSCREEN ] := SAVESCREEN( aFileMan[ FM_ROWTOP    ],;
                                           aFileMan[ FM_COLTOP    ],;
                                           aFileMan[ FM_ROWBOTTOM ],;
                                           aFileMan[ FM_COLBOTTOM ]+3)

   CreateScreen()                   // Create the initial screen, etc.
   GetFiles()                       // Call the actual file chooser

   // Restore the screen
   RESTSCREEN( aFileMan[ FM_ROWTOP    ], ;
               aFileMan[ FM_COLTOP    ], ;
               aFileMan[ FM_ROWBOTTOM ], ;
               aFileMan[ FM_COLBOTTOM ]+3, ;
               aFileMan[ FM_OLDSCREEN ] )
   // Restore the color
   SetColor( aFileMan[ FM_OLDCOLOR ] )

   // Reset the old scoreboard stuff
   SET( _SET_SCOREBOARD, lSetScore )

   // Restore the work area
   SELECT ( aFileMan[ FM_OLDSELECT ] )

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

   DO WHILE !lDone
      IF lReloadDir
         nEl   := 1
         nRel  := 1
         IF !LoadFiles()
            // A problem occured loading the file names; tell the user
            ErrorBeep()
            // Message( "ERROR: No files found!  Press any key..." )
            INKEY( 300 )
            IF YesOrNo( "Would you like to try another path? (Y/N)", "Y" )
               GetNewPath( aFileMan[ FM_PATH ] )
               IF LASTKEY() == K_ESC
                  lDone := .T.
               ELSE
                  LOOP
               ENDIF
            ELSE
               lDone := .T.
            ENDIF
         ELSE
            lReloadDir := .F.
         ENDIF
      ENDIF
      // Time to display the files and act on the response's
      TabUpdate( hScrollBar, nEl, LEN( aFileList ), .T. )
      nCurrent := ACHOICE( aFileMan[ FM_ROWTOP ]+1, ;
                           aFileMan[ FM_COLTOP ]+1, ;
                           aFileMan[ FM_ROWBOTTOM ]-1, ;
                           aFileMan[ FM_COLBOTTOM ], ;
                           aFileList, .T., "ProcessKey", nEl, nRel )

      nFileItem := nCurrent
      nLastKey := LASTKEY()

      DO CASE
		
         CASE nLastKey == K_ESC
            aFileMan[ FM_RETURNFILE ] := ""
            lDone := .T.

         CASE nLastKey == K_ENTER
            // First let's assign the filename and path to aFileMan
            aFileMan[ FM_RETURNFILE ] :=  aFileList[ nCurrent ]
            // Ok, here's the biggee
            DO CASE
               CASE nMenuItem == MN_LOOK
                  LookAtFile()
            ENDCASE

         CASE nLastKey == K_F5
            TagAllFiles()

         CASE nLastKey == K_F6
            UnTagAllFiles()

           CASE nLastKey == K_SPACE
              // Can't tag directories
               IF SUBSTR( aFileList[ nCurrent ], 14, 1 ) == " "
                  // It isn't tagged, let's tag it
                  aFileList[ nCurrent ] := STUFF( aFileList[ nCurrent ], ;
                                           14, 1, FM_CHECK )
                  nTagged++
               ELSE
                  // It's already tagged, let's remove the check mark
                  aFileList[ nCurrent ] := STUFF( aFileList[ nCurrent ], ;
                                           14, 1, " " )
                  nTagged--
               ENDIF
      ENDCASE
   ENDDO

   RETURN NIL

/***
*  LoadFiles() --> lReturnValue 
*
*
*/
STATIC FUNCTION LoadFiles
   LOCAL aDirectory := {}, nItem := 0, lReturnValue := .T.
   LOCAL nNumberOfItems := 0, cFileString := ""

   // Let the user know what's going on
   // Message( "Loading the current directory..." )
   @ aFileMan[ FM_ROWTOP ] + 3, aFileMan[ FM_COLTOP ] + 2 CLEAR TO ;
     aFileMan[ FM_ROWBOTTOM ] - 3, aFileMan[ FM_COLBOTTOM ] - 4

   // Load up aFileList with the current directory information
   aDirectory := DIRECTORY( aFileMan[ FM_PATH ], "D" )
   nNumberOfItems := IF( VALTYPE( aDirectory ) != "A", 0, LEN( aDirectory ) )
   aFileList := {}                  // Wipe out the old aFileList

   // Check to see if any files actually made it
   IF nNumberOfItems < 1
      // Problem!
      lReturnValue := .F.

   ELSE
      // Let the user know what's going on
     // Message( "Sorting the current directory..." )

      // Sort the current aDirectory array
      ASORT( aDirectory,,, { | x, y | x[ F_NAME ] < y[ F_NAME ] } )

      // Let the user know what's going on
      // Message( "Processing the current directory..." )

      // Now drop it into the array to be displayed with ACHOICE()
      FOR nItem := 1 TO nNumberOfItems
         AADD( aFileList, padr( aDirectory[ nItem, F_NAME ],15))
		NEXT

   ENDIF

   // Clean up the message area before we leave
   // Message( aFileMan[ FM_PATH ] )

   RETURN( lReturnValue )

/***
*  ProcessKey( <nStatus>, <nElement>, <nRelative> ) --> nReturnValue
*
*
*/
FUNCTION ProcessKey( nStatus, nElement, nRelative )
   LOCAL nReturnValue := AC_CONT    // Set the default handler to continue

   // Update the global element/relative with the passed versions
   nEl  := nElement
   nRel := nRelative

   DO CASE
   CASE nStatus == AC_IDLE
        TabUpdate( hScrollBar, nElement, LEN( aFileList ) )
      
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
*  GetNewPath( <cPath> ) --> cNewPath
*
*
*/
STATIC FUNCTION GetNewPath( cPath )
   LOCAL cOldColor := SETCOLOR( aFileMan[ FM_COLOR ] )
   cPath := PADR( cPath, 45 )
   @ aFileMan[ FM_ROWBOTTOM ] - 1, aFileMan[ FM_COLTOP ] + 2 GET ;
     cPath PICTURE "@!@S45@K"
   READ

   cPath := LTRIM(TRIM(cPath))

   IF RIGHT( cPath, 1 ) == "\"
      cPath += "*.*"
   ENDIF
   IF RIGHT( cPath, 1 ) == ":"
      cPath += "\*.*"
   ENDIF

   aFileMan[ FM_PATH ] := cPath

   
   SETCOLOR( cOldColor )
   RETURN( TRIM( cPath ) )

/***
*  YesOrNo( <cMessage>, <cDefault> ) --> lYesOrNo
*
*
*/
STATIC FUNCTION YesOrNo( cMessage, cDefault )
   LOCAL cOldColor := SETCOLOR( aFileMan[ FM_COLOR ] )
   LOCAL lYesOrNo

   @ aFileMan[ FM_ROWBOTTOM ] - 1, aFileMan[ FM_COLTOP ] + 2 SAY ;
     TRIM( SUBSTR( cMessage, 1, ;
         (aFileMan[FM_COLBOTTOM] - aFileMan[FM_COLTOP] - 8 )) ) GET ;
         cDefault PICTURE "Y"
   READ

   lYesOrNo := (UPPER( cDefault ) == "Y")
   SETCOLOR( cOldColor )

   RETURN (lYesOrNo)

/***
*  ClearMessage() --> NIL
*
*
*/
STATIC FUNCTION ClearMessage
   LOCAL cOldColor := SETCOLOR( aFileMan[ FM_COLOR ] )
   @ aFileMan[ FM_ROWBOTTOM ] - 1, aFileMan[ FM_COLTOP ] + 2 CLEAR TO ;
     aFileMan[ FM_ROWBOTTOM ] - 1, aFileMan[ FM_COLBOTTOM ] - 4

   SETCOLOR( cOldColor )

   RETURN NIL

/***
*  ErrorBeep() --> NIL
*
*
*/
STATIC FUNCTION ErrorBeep
   LOCAL nCount := 0

   FOR nCount := 1 TO 2
      TONE( 300, 1 )
      TONE( 499, 1 )
   NEXT

   RETURN NIL

/***
*  CreateScreen() --> NIL
*
*
*/
STATIC FUNCTION CreateScreen

   LOCAL cFrameType  := FM_SINGLEFRAME
   LOCAL cBorderType := FM_SINGLEBORDER
   LOCAL nRow        := 0

   // Draw the primary box
   @ aFileMan[ FM_ROWTOP ], aFileMan[ FM_COLTOP ] CLEAR TO ;
     aFileMan[ FM_ROWBOTTOM ], aFileMan[ FM_COLBOTTOM ]+1
   @ aFileMan[ FM_ROWTOP ], aFileMan[ FM_COLTOP ], ;
     aFileMan[ FM_ROWBOTTOM ], aFileMan[ FM_COLBOTTOM ]+1 BOX cFrameType

   // Create the scrolling thumb tab and assign it to our global static
   hScrollBar := TabNew( aFileMan[ FM_ROWTOP ],;
                         aFileMan[ FM_COLBOTTOM ]+1,;
                         aFileMan[ FM_ROWBOTTOM ],;
                         aFileMan[ FM_COLOR ], 1 )
   TabDisplay( hScrollBar )

   RETURN NIL

/***
*  DisplayMenu() --> NIL
*
*
*/
STATIC FUNCTION DisplayMenu

   LOCAL cOldColor := SETCOLOR(), nCol := aFileMan[ FM_COLTOP ] + 2
   LOCAL cItemName

   @ aFileMan[ FM_ROWTOP ] + 1, aFileMan[ FM_COLTOP ] + 2 SAY ;
     "Look  Copy  Rename  Delete  Print  Open"
   SETCOLOR( "I" )
   DO CASE
   CASE nMenuItem == MN_LOOK
      nCol := aFileMan[ FM_COLTOP ] + 2
      cItemName := "Look"

   CASE nMenuItem == MN_COPY
      nCol := aFileMan[ FM_COLTOP ] + 8
      cItemName := "Copy"

   CASE nMenuItem == MN_RENAME
      nCol := aFileMan[ FM_COLTOP ] + 14
      cItemName := "Rename"

   CASE nMenuItem == MN_DELETE
      nCol := aFileMan[ FM_COLTOP ] + 22
      cItemName := "Delete"

   CASE nMenuItem == MN_PRINT
      nCol := aFileMan[ FM_COLTOP ] + 30
      cItemName := "Print"

   CASE nMenuItem == MN_OPEN
      nCol := aFileMan[ FM_COLTOP ] + 37
      cItemName := "Open"

   ENDCASE

   @ aFileMan[ FM_ROWTOP ] + 1, nCol SAY cItemName

   SETCOLOR( cOldColor )

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

STATIC FUNCTION TabDisplay( aTab )
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


/***
*  UpPath( <cPath> ) --> ?
*
*
*/
STATIC FUNCTION UpPath( cPath )
   LOCAL cFileSpec

   cFileSpec := RIGHT( cPath, LEN( cPath ) - RAT( "\", cPath ) )
   cPath     := LEFT( cPath, RAT( "\", cPath ) - 1 )
   cPath     := LEFT( cPath, RAT( "\", cPath ) )
   cPath     += cFileSpec

   RETURN (cPath)

/***
*  GetFileExtension( <cFile> ) --> cFileExtension
*
*
*/
STATIC FUNCTION GetFileExtension( cFile )
   RETURN( UPPER( SUBSTR( cFile, AT( ".", cFile ) + 1, 3 ) ) )

/***
*  LookAtFile() --> NIL
*
*
*/
STATIC FUNCTION LookAtFile
   LOCAL cExtension := ""
   LOCAL cOldScreen := SAVESCREEN( 0, 0, MAXROW(), MAXCOL() )

   IF AT( "D", SUBSTR( aFileList[ nFileItem ], 43, 6 ) ) <> 0
      // Looks like a directory, let's load it...
      DO CASE
      CASE SUBSTR( aFileList[ nFileItem ], 1, 3 ) == ".  "
         // That's the current directory!
         GetNewPath( aFileMan[ FM_PATH ] )
      CASE SUBSTR( aFileList[ nFileItem ], 1, 3 ) == ".. "
         GetNewPath( UpPath( aFileMan[ FM_PATH ]))

      OTHERWISE
         GetNewPath( SUBSTR( aFileMan[ FM_PATH ], 1, ;
            RAT( "\", aFileMan[ FM_PATH ])) + ;
            TRIM(SUBSTR(aFileList[nFileItem],1,12)) + "\*.*")
      ENDCASE
      lReloadDir := .T.
   ELSE
      // Must be a file.  Let's load the proper viewer and take a look
      cExtension := GetFileExtension( SUBSTR(aFileList[nFileItem],1,12) )

      DO CASE
      CASE cExtension == "DBF"
         DBFViewer( aFileMan[ FM_RETURNFILE ] )

      OTHERWISE
         GenericViewer( aFileMan[ FM_RETURNFILE ] )

      ENDCASE

      // Restore the screen
      RESTSCREEN( 0, 0, MAXROW(), MAXCOL(), cOldScreen )

   ENDIF
   RETURN NIL

/***
*  CopyFile() --> NIL
*
*
*/
STATIC FUNCTION CopyFile
   LOCAL cNewName := "", cOldName := "", lKeepGoing := .F., cNewFile := ""
   LOCAL nCurrent := 0, cCurrentFile := "", nCount := 0
   LOCAL cOldScreen := SAVESCREEN( aFileMan[ FM_ROWTOP ] + 3,;
                                   aFileMan[ FM_COLTOP ] + 2,;
                                   aFileMan[ FM_ROWTOP ] + 6,;
                                   aFileMan[ FM_COLTOP ] + 51 )
   
   IF AT( "<dir>", aFileList[ nFileItem ] ) = 0

      TONE( 800, 1 )

      IF nTagged > 0
         IF YesOrNo( "Copy marked files? (Y/N)", "N" )
            lKeepGoing := .T.
         ENDIF
      ELSE
         @ aFileMan[ FM_ROWTOP ] + 3 + nRel, aFileMan[ FM_COLTOP ] + 1 SAY;
           CHR( 16 )
         @ aFileMan[ FM_ROWTOP ] + 3 + nRel, aFileMan[ FM_COLBOTTOM ] - 3 SAY;
           CHR( 17 )
         IF YesOrNo( "Copy this file? (Y/N)", "N" )
            lKeepGoing := .T.
         ENDIF
      ENDIF


      // Draw the box
      @ aFileMan[ FM_ROWTOP ] + 3, aFileMan[ FM_COLTOP ] + 2, ;
        aFileMan[ FM_ROWTOP ] + 6, aFileMan[ FM_COLTOP ] + 51 BOX;
        FM_DOUBLEFRAME
      @ aFileMan[ FM_ROWTOP ] + 4, aFileMan[ FM_COLTOP ] + 3 CLEAR TO ;
        aFileMan[ FM_ROWTOP ] + 5, aFileMan[ FM_COLTOP ] + 50

      cNewName := cOldName := PADR( SUBSTR( aFileMan[ FM_PATH ], 1, ;
                              RAT( "\", aFileMan[ FM_PATH ] ) ) + ;
                              TRIM( SUBSTR( aFileList[ nFileItem ], 1, 12 ) ),;
                              45 )

      IF lKeepGoing

         IF nTagged > 0

            cNewName := PADR( SUBSTR( aFileMan[ FM_PATH ], 1, RAT( "\", ;
                                aFileMan[ FM_PATH ] ) ), 45 )
            @ aFileMan[ FM_ROWTOP ]+4, aFileMan[ FM_COLTOP ]+4 SAY;
              "Copy marked files to..."
            @ aFileMan[ FM_ROWTOP ]+5, aFileMan[ FM_COLTOP ]+4 GET;
              cNewName PICTURE "@!@S46@K"
            READ
            IF LASTKEY() <> K_ESC
               cNewName := TRIM( cNewName )
               IF RIGHT( cNewName, 1 ) <> "\"
                  cNewName += "\"
               ENDIF
               FOR nCurrent := 1 TO LEN( aFileList )
                  IF SUBSTR( aFileList[ nCurrent ], 14, 1 ) == FM_CHECK
                     cCurrentFile := SUBSTR( aFileMan[ FM_PATH ], 1, ;
                                     RAT( "\", aFileMan[ FM_PATH ])) + ;
                                     TRIM( SUBSTR( aFileList[ nCurrent ], 1, 12))
                     cNewFile := cNewName + ;
                                 TRIM( SUBSTR( aFileList[ nCurrent ], 1, 12))
                     COPY FILE ( cCurrentFile ) TO ( cNewFile )
                     aFileList[ nCurrent ] := STUFF( aFileList[ nCurrent ], ;
                                              14, 1, " " )
                     nTagged--
                     nCount++
                     IF INKEY() = K_ESC
                        EXIT
                     ENDIF
                  ENDIF
               NEXT
               @ aFileMan[ FM_ROWTOP ] + 4, aFileMan[ FM_COLTOP ] + 3 CLEAR TO ;
                 aFileMan[ FM_ROWTOP ] + 5, aFileMan[ FM_COLTOP ] + 50
               @ aFileMan[ FM_ROWTOP ]+4, aFileMan[ FM_COLTOP ]+4 SAY;
                 LTRIM(STR( nCount )) + IF( nCount > 1, " files copied.  ", ;
                                        " file copied.  " ) + "Press any key..."
               INKEY(0)
            ENDIF
         ELSE
            @ aFileMan[ FM_ROWTOP ]+4, aFileMan[ FM_COLTOP ]+4 SAY;
              "Copy current file to..."
            @ aFileMan[ FM_ROWTOP ]+5, aFileMan[ FM_COLTOP ]+4 GET;
              cNewName PICTURE "@!@S46@K"
            READ
            IF LASTKEY() <> K_ESC
               IF RIGHT( cNewName, 1 ) == "\"
                  cNewName += TRIM( SUBSTR( cOldName, RAT( "\", cOldName) ;
                              + 1, 12 ))
               ENDIF
               COPY FILE ( cOldName ) TO ( cNewName )
               @ aFileMan[ FM_ROWTOP ] + 4, aFileMan[ FM_COLTOP ] + 3 CLEAR TO ;
                 aFileMan[ FM_ROWTOP ] + 5, aFileMan[ FM_COLTOP ] + 50
               @ aFileMan[ FM_ROWTOP ]+4, aFileMan[ FM_COLTOP ]+4 SAY;
                 "1 file copied.  Press any key..."
               INKEY(0)
            ENDIF

         ENDIF

         lReloadDir := .T.
      ENDIF
   ENDIF


   RESTSCREEN( aFileMan[ FM_ROWTOP ] + 3, ;
               aFileMan[ FM_COLTOP ] + 2, ;
               aFileMan[ FM_ROWTOP ] + 6, ;
               aFileMan[ FM_COLTOP ] + 51,;
               cOldScreen )

   @ aFileMan[ FM_ROWTOP ] + 3 + nRel, aFileMan[ FM_COLTOP ] + 1 SAY;
     CHR( 32 )
   @ aFileMan[ FM_ROWTOP ] + 3 + nRel, aFileMan[ FM_COLBOTTOM ] - 3 SAY;
     CHR( 32 )

   RETURN NIL

/***
*  RenameFile() --> NIL
*
*
*/
STATIC FUNCTION RenameFile
   LOCAL cNewName := "", cOldName := ""
   LOCAL cOldScreen := SAVESCREEN( aFileMan[ FM_ROWTOP ] + 3,;
                                   aFileMan[ FM_COLTOP ] + 2,;
                                   aFileMan[ FM_ROWTOP ] + 6,;
                                   aFileMan[ FM_COLTOP ] + 51 )

   IF AT( "<dir>", aFileList[ nFileItem ] ) = 0

      // Draw the box
      @ aFileMan[ FM_ROWTOP ] + 3, aFileMan[ FM_COLTOP ] + 2, ;
        aFileMan[ FM_ROWTOP ] + 6, aFileMan[ FM_COLTOP ] + 51 BOX;
        FM_DOUBLEFRAME
      @ aFileMan[ FM_ROWTOP ] + 4, aFileMan[ FM_COLTOP ] + 3 CLEAR TO ;
        aFileMan[ FM_ROWTOP ] + 5, aFileMan[ FM_COLTOP ] + 50

      cNewName := cOldName := PADR( SUBSTR( aFileMan[ FM_PATH ], 1, ;
                              RAT( "\", aFileMan[ FM_PATH ] ) ) + ;
                              TRIM( SUBSTR( aFileList[ nFileItem ], 1, 12 ) ),;
                              45 )

      TONE( 800, 1 )

      @ aFileMan[ FM_ROWTOP ] + 4, aFileMan[ FM_COLTOP ] + 4 SAY "Rename " +;
        SUBSTR( cNewName, 1, 38 )
      @ aFileMan[ FM_ROWTOP ] + 5, aFileMan[ FM_COLTOP ] + 4 SAY "To" GET;
        cNewName PICTURE "@!@S43@K"
      READ

      IF LASTKEY() <> K_ESC
         IF FILE( cNewName )
            ErrorBeep()
            @ aFileMan[ FM_ROWTOP ] + 4, aFileMan[ FM_COLTOP ] + 3 CLEAR TO ;
              aFileMan[ FM_ROWTOP ] + 5, aFileMan[ FM_COLTOP ] + 50
            @ aFileMan[ FM_ROWTOP ] + 4, aFileMan[ FM_COLTOP ] + 4 SAY ;
              "ERROR: That file already exists!"
            @ aFileMan[ FM_ROWTOP ] + 5, aFileMan[ FM_COLTOP ] + 4 SAY ;
               "Press any key..."
            INKEY( 0 )
         ELSE
            lReloadDir := .T.
            RENAME ( TRIM( cOldName ) ) TO ( TRIM( cNewName ) )
         ENDIF
      ENDIF

   ENDIF

   RESTSCREEN( aFileMan[ FM_ROWTOP ] + 3, ;
               aFileMan[ FM_COLTOP ] + 2, ;
               aFileMan[ FM_ROWTOP ] + 6, ;
               aFileMan[ FM_COLTOP ] + 51,;
               cOldScreen )

   RETURN NIL

/***
*  DeleteFile() --> NIL
*
*
*/
STATIC FUNCTION DeleteFile

   LOCAL nCurrentFile := 0, cFile := ""

   TONE( 800, 1 )
   IF nTagged > 0
      IF YesOrNo( "Delete marked files? (Y/N)", "N" )
         lReloadDir := .T.
         FOR nCurrentFile := 1 TO LEN( aFileList )
            cFile := SUBSTR( aFileMan[ FM_PATH ], 1, ;
                     RAT( "\", aFileMan[ FM_PATH ] ) ) + ;
                     TRIM( SUBSTR( aFileList[ nCurrentFile ], 1, 12 ) )
            IF SUBSTR( aFileList[ nCurrentFile ], 14, 1 ) == FM_CHECK
               ERASE ( cFile )
            ENDIF
         NEXT
         INKEY( 300 )
         nTagged := 0
      ENDIF
   ELSE
      IF AT( "<dir>", aFileList[ nFileItem ] ) = 0
         cFile := SUBSTR( aFileMan[ FM_PATH ], 1, ;
                  RAT( "\", aFileMan[ FM_PATH ] ) ) + ;
                  TRIM( SUBSTR( aFileList[ nFileItem ], 1, 12 ) )
         @ aFileMan[ FM_ROWTOP ] + 3 + nRel, aFileMan[ FM_COLTOP ] + 1 SAY;
           CHR( 16 )
         @ aFileMan[ FM_ROWTOP ] + 3 + nRel, aFileMan[ FM_COLBOTTOM ] - 3 SAY;
           CHR( 17 )
         IF YesOrNo( "Delete this file? (Y/N)", "N" )
            ERASE ( cFile )
            lReloadDir := .T.
         ENDIF
      ENDIF
   ENDIF

   @ aFileMan[ FM_ROWTOP ] + 3 + nRel, aFileMan[ FM_COLTOP ] + 1 SAY;
     CHR( 32 )
   @ aFileMan[ FM_ROWTOP ] + 3 + nRel, aFileMan[ FM_COLBOTTOM ] - 3 SAY;
     CHR( 32 )


   RETURN NIL

/***
*  PrintFile() --> NIL
*
*
*/
STATIC FUNCTION PrintFile
   LOCAL cFile := SUBSTR( aFileMan[ FM_PATH ], 1, ;
                  RAT( "\", aFileMan[ FM_PATH ] ) ) + ;
                  TRIM( SUBSTR( aFileList[ nFileItem ], 1, 12 ) )

   TONE( 800, 1 )

   @ aFileMan[ FM_ROWTOP ] + 3 + nRel, aFileMan[ FM_COLTOP ] + 1 SAY;
     CHR( 16 )
   @ aFileMan[ FM_ROWTOP ] + 3 + nRel, aFileMan[ FM_COLBOTTOM ] - 3 SAY;
     CHR( 17 )

   IF YesOrNo( "Print this file?", "N" )

      IF ISPRINTER()
         COPY FILE ( cFile ) TO PRN
         EJECT
      ELSE
         ErrorBeep()
         INKEY( 20 )
      ENDIF

   ENDIF


   @ aFileMan[ FM_ROWTOP ] + 3 + nRel, aFileMan[ FM_COLTOP ] + 1 SAY;
     CHR( 32 )
   @ aFileMan[ FM_ROWTOP ] + 3 + nRel, aFileMan[ FM_COLBOTTOM ] - 3 SAY;
     CHR( 32 )


   RETURN NIL

/***
*  DBFViewer( <cDatabase> ) --> cDatabase
*  View the contents of a database file in a window
*
*/
STATIC FUNCTION DBFViewer( cDatabase )
   LOCAL cRecords := ""

   USE (cDatabase) ALIAS LookFile SHARED NEW READONLY

   IF !NETERR()

      @ 0, 0, MAXROW(), MAXCOL() BOX FM_DOUBLEFRAME
      cRecords := "Number of records: " + LTRIM( STR( RECCOUNT() ) )
      @ 0, MAXCOL() - 2 SAY "]"
      @ 0, (MAXCOL()-2)-LEN( cRecords )-3 SAY "[" + SPACE( LEN( cRecords ) + 2 )
      @ 0, (MAXCOL()-2)-LEN( cRecords )-1 SAY cRecords
      @ 0, 1 SAY "[ " + TRIM(cDatabase) + " ]"
      @ MAXROW(),  INT((MAXCOL()-48)/2) SAY ;
      "[ Use " + CHR(27) + CHR(18) + CHR(26)+" to move through data.  (Esc to Exit) ]"

      DBEDIT( 1, 1, MAXROW()-1, MAXCOL()-1 )

      // Close the file and select the old work area
      USE
      SELECT ( aFileMan[ FM_OLDSELECT ] )

   ENDIF

   RETURN (cDatabase)

/***
*  GenericViewer( <cFile> ) --> cFile
*  View the contents of a text file (?)
*
*/
#define GV_BLOCKSIZE    50000

STATIC FUNCTION GenericViewer( cFile )

   LOCAL cBuffer := "", nHandle := 0, nBytes := 0
 
   cBuffer := SPACE( GV_BLOCKSIZE )
   nHandle := FOPEN( cFile )

   IF FERROR() != 0
      cBuffer := "Error reading file!"
   ELSE
      nBytes = FREAD( nHandle, @cBuffer, GV_BLOCKSIZE )
   ENDIF
   FCLOSE( nHandle )

   cBuffer := RTRIM( cBuffer )

   @ 0, 0 CLEAR TO MAXROW(), MAXCOL()
   @ 0, 0, MAXROW(), MAXCOL() BOX FM_DOUBLEFRAME
   @ 0, 1 SAY "[ " + TRIM(cFile) + " ]"
   @ MAXROW(),  INT((MAXCOL()-48)/2) SAY ;
   "[ Use "+CHR(27)+CHR(18)+CHR(26)+" to move through data.  (Esc to Exit) ]"
   MEMOEDIT( cBuffer, 1, 2, MAXROW() - 1, MAXCOL() - 1, .F., "MemoUDF" , 300 )

   RETURN( cFile )

#undef GV_BLOCKSIZE

/***
*  MemoUDF( <nMode>, <nLine>, <nColumn> ) --> 
*  
*
*/
FUNCTION MemoUDF( nMode, nLine, nColumn )
   RETURN( ME_DEFAULT )

/***
*  TagAllFiles() --> NIL
*  Tag all files in the current directory
*
*/
STATIC FUNCTION TagAllFiles
   
   LOCAL nCurrent
   nTagged := 0
   
   FOR nCurrent := 1 TO LEN( aFileList )
      IF AT( "D", SUBSTR( aFileList[ nCurrent ], 43, 6 ) ) == 0
         aFileList[ nCurrent ] := STUFF( aFileList[ nCurrent ], ;
                                         14, 1, FM_CHECK )
         nTagged++
      ENDIF
   NEXT
   
   RETURN NIL

/***
*  UnTagAllFiles() --> NIL
*  Untag all tagged files in the current directory
*
*/
STATIC FUNCTION UnTagAllFiles

   LOCAL nCurrent
   nTagged := 0

   FOR nCurrent := 1 TO LEN( aFileList )
      aFileList[ nCurrent ] := STUFF( aFileList[ nCurrent ], 14, 1, " " )
   NEXT

   RETURN NIL

