/***
*  Array.prg
*  Sample array handling functions.
*  Copyright (c) 1990-1991 Nantucket Corp.  All rights reserved.
*
*  NOTE: compile with /n/w/a/m
*/

#include "Inkey.ch"


// This static maintains the "current row" for ABrowse()
static nRow


/***
*  ABrowse( <aArray>, <nTop>, <nLeft>, <nBottom>, <nRight> ) --> value
*
*  Browse a 2-dimensional array using TBrowse object and
*  return the value of the highlighted array element.
*
*  Authors: Jake Jacob & Fleming Ho
*/

FUNCTION ABrowse( aArray, nT, nL, nB, nR )

   LOCAL n, xRet, nOldNRow, nOldCursor  // Various
   LOCAL o                              // TBrowse object
   LOCAL nKey := 0                      // Keystroke holder


   // Preserve cursor setting, turn off cursor
   nOldCursor := SetCursor( 0 )

   // Preserve static var (just in case), set it to 1
   nOldNRow := nRow
   nRow := 1


   // Handle omitted parameters
   nT := IF( nT == NIL, 0, nT )
   nL := IF( nL == NIL, 0, nL )
   nB := IF( nB == NIL, MAXROW(), nB )
   nR := IF( nR == NIL, MAXCOL(), nR )


   // Create the TBrowse object
   o := TBrowseNew( nT, nL, nB, nR )

   // The "skip" block just adds to (or subtracts from) nRow
   // (see ASkipTest() below)
   o:SkipBlock := { |nSkip|                                             ;
                             nSkip := ASkipTest(aArray, nRow, nSkip),   ;
                             nRow += nSkip,                             ;
                             nSkip                                      ;
                  }

   // The "go top" block sets nRow to 1
   o:GoTopBlock := { || nRow := 1 }

   // The "go bottom" block sets nRow to the length of the array
   o:GoBottomBlock := { || nRow := LEN(aArray) }

   // Create column blocks and add TBColumn objects to the TBrowse
   // (see ABrowseBlock() below)
   FOR n = 1 TO LEN( aArray[1] )
	  o:AddColumn( TBColumnNew("", ABrowseBlock(aArray, n)) )
   NEXT


   // Start the event handler loop
   DO WHILE nKey <> K_ESC .AND. nKey <> K_RETURN

      // Stabilize
      nKey := 0
      DO WHILE .NOT. o:Stabilize()
         nKey := INKEY()
         IF nKey <> 0
            EXIT
         ENDIF
      ENDDO

      IF nKey == 0
         nKey := INKEY(0)
      ENDIF

      // Process the directional keys
      IF o:Stable

         DO CASE
         CASE ( nKey == K_DOWN )
            o:Down()

         CASE ( nKey == K_UP )
            o:Up()

         CASE ( nKey == K_RIGHT )
            o:Right()

         CASE ( nKey == K_LEFT )
            o:Left()

         CASE ( nKey == K_PGDN )
            o:Right()
            o:Down()

         CASE ( nKey == K_PGUP )
            o:Right()
            o:Up()

         CASE ( nKey == K_HOME )
            o:Left()
            o:Up()

         CASE ( nKey == K_END )
            o:Left()
            o:Down()

         ENDCASE

      ENDIF

   ENDDO


   // Set return value
   xRet := IF( nKey == K_RETURN, aArray[nRow, o:ColPos], NIL )

   // Restore cursor setting
   SetCursor( nOldCursor )

   // Restore static var
   nRow := nOldNRow


   RETURN (xRet)


/***
*  ABrowseBlock( <a>, <x> ) -> bColumnBlock
*  Service function for ABrowse().
*
*  Return a set/get block for  <a>[nRow, <x>]
*
*  This function works by returning a block that refers
*  to local variables <a> and <x> (the parameters). In
*  version 5.01 these local variables are preserved for
*  use by the block even after the function has returned.
*  The result is that each call to ABrowseBlock() returns
*  a block which has the passed values of <a> and <x> "bound"
*  to it for later use. The block defined here also refers to
*  the static variable nRow, used by ABrowse() to track the
*  array's "current row" while browsing.
*/

STATIC FUNCTION ABrowseBlock(a, x)

   RETURN ( {|p| IF(PCOUNT() == 0, a[nRow, x], a[nRow, x] := p)} )


/***
*  ASkipTest( <a>, <nCurrent>, <nSkip> ) -> nSkipsPossible
*  Service function for ABrowse().
*
*  Given array <a> whose "current" row is <nCurrent>, determine
*  whether it is possible to "skip" forward or backward by
*  <nSkip> rows. Return the number of skips actually possible.
*/

STATIC FUNCTION ASkipTest(a, nCurrent, nSkip)

   IF ( nCurrent + nSkip < 1 )
      // Would skip past the top...
      RETURN ( -nCurrent + 1 )

   ELSEIF ( nCurrent + nSkip > LEN(a) )
      // Would skip past the bottom...
      RETURN ( LEN(a) - nCurrent )

   END

   // No problem
   RETURN (nSkip)




/***
*  ABlock( <cName>, <nSubx> ) -> bABlock
*
*  Given the name of a variable containing an array, and a
*  subscript value, create a set/get block for the specified
*  array element.
*
*  NOTE: cName must be the name of a variable that is visible
*  in macros (i.e. not a LOCAL or STATIC variable). Also, the
*  variable must be visible anywhere where the block is to be
*  used.
*
*  NOTE: ABlock() may be used to make blocks for a nested array
*  by including a subscript expression as part of cName:
*
*	  // to make a set/get block for a[i]
*	  b := ABlock( "a", i )
*
*	  // to make a set/get block for a[i][j]
*	  b :=- ABlock( "a[i]", j )
*
*  NOTE: this function is provided for compatibility with the
*  version 5.00 Array.prg. See the ABrowseBlock() function
*  (above) for a method of "binding" an array to a block
*  without using a macro.
*
*/
FUNCTION ABlock( cName, nSubx )

LOCAL cAXpr

   cAXpr := cName + "[" + LTRIM(STR(nSubx)) + "]"

   RETURN &( "{ |p| IF(PCOUNT()==0, " + cAXpr + "," + cAXpr + ":=p) }" )


/***
*  AMax( <aArray> ) --> nPos
*  Return the subscript of the array element with the highest value.
*/

FUNCTION AMax( aArray )

   LOCAL nLen, nPos, expLast, nElement


   DO CASE

   // Invalid argument
   CASE VALTYPE( aArray ) <> "A"
      RETURN NIL

   // Empty argument
   CASE EMPTY( aArray )
      RETURN 0

   OTHERWISE
      nLen := LEN( aArray )
      nPos := 1
      expLast := aArray[1]
      FOR nElement := 2 TO nLen
         IF aArray[nElement] > expLast
            nPos := nElement
            expLast := aArray[nElement]
         ENDIF
      NEXT

   ENDCASE

   RETURN nPos


/***
*  AMin( <aArray> ) --> nPos
*  Return the subscript of the array element with the lowest value.
*/

FUNCTION AMin( aArray )

   LOCAL nLen, nPos, expLast, nElement


   DO CASE

   // Invalid argument
   CASE VALTYPE( aArray ) <> "A"
      RETURN NIL

   // Empty argument
   CASE EMPTY( aArray )
      RETURN 0

   OTHERWISE
      nLen := LEN( aArray )
      nPos := 1
      expLast := aArray[1]
      FOR nElement := 2 TO nLen
         IF aArray[nElement] < expLast
            nPos := nElement
            expLast := aArray[nElement]
         ENDIF
      NEXT

   ENDCASE

   RETURN nPos


/***
*  AComp( <aArray>, <bComp>, [<nStart>], [<nStop>] ) --> valueElement
*  Compares all elements of aArray using the bComp block from nStart to
*  nStop (if specified, otherwise entire array) and returns the result.
*  Several sample blocks are provided in Array.ch.
*/
FUNCTION AComp( aArray, bComp, nStart, nStop )
   LOCAL value := aArray[1]

   AEVAL(                                                               ;
          aArray,                                                       ;
          {|x| value := IF( EVAL(bComp, x, value), x, value )},         ;
          nStart,                                                       ;
          nStop                                                         ;
        )

   RETURN( value )


/***
*  Dimensions( <aArray> ) --> aDims
*  Return an array of numeric values describing the dimensions of a
*  nested or multi-dimensional array, assuming the array has uniform
*  dimensions.
*/

FUNCTION Dimensions( aArray )
   LOCAL aDims := {}

   DO WHILE ( VALTYPE(aArray) == "A" )
      AADD( aDims, LEN(aArray) )
      aArray := aArray[1]
   ENDDO

   RETURN (aDims)
