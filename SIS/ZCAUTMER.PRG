* ============================================
*       I N V E N T A R I O                  *
* ============================================

#include "SET.CH" 
#include "INKEY.CH"
#include "FUNCKY.CH"

main()

Procedure main


SET PROCEDURE TO WRLIB
Desktop("Atualizando Cautelas")

IF    !ARQNTX("CECCMER",.F.)
      DBCLOSEALL()
      RETURN
ENDIF

Select("CECCMER")
GO TOP

Do while  !EOF()
   
  if cautela <> 0
      IF RLOCK()
          REPLACE cautela WITH 0
      ELSE
         MsgBox3D1("Registro est  sendo utilizado !")
      endif
  Endif

  SKIP
EndDo
close all
cls
@ 10,10 say "Pressione um a Tecla"
inkey(0)
Return



