/***
*  Keyboard.prg
*  Sample keyboard routines.
*  Copyright (c) Nantucket Corporation, 1990.  All rights reserved.
*  Craig Ogg
*
*  Note: Compile with /N/W options
*/

/***
*  InKeyWait( <nSecs> ) --> nInkeyCode
*  Similar to INKEY(), except services SET KEYs
*
*/
FUNCTION InKeyWait( nSecs )
   LOCAL nKey
   LOCAL bKeyBlock

   nKey := INKEY( nSecs )

   IF (bKeyBlock := SETKEY(nKey)) != NIL 
      EVAL(bKeyBlock, PROCNAME(2), PROCLINE(2))
   ENDIF

   RETURN( nKey )

