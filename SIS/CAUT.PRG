* ============================================
*       I N V E N T A R I O                  *
* ============================================

#include "SET.CH" 
#include "INKEY.CH"
#include "FUNCKY.CH"

main()

Procedure main

SET PROCEDURE TO c:\trab\util\util.PRG
SET PROCEDURE TO WRLIB
SET FIXED ON
SET DECIMALS TO 3
PUBLIC TELA,grup
PRIVATE cor
grup:=0
cor:=setcolor()
ambiente()
Desktop("Atualizando Cautelas")
tela:=SaveScreen(01,00,23,79)

IF    !ARQNTX("CECCMER",.F.)
      DBCLOSEALL()
      RETURN
ENDIF

RestScreen(01,00,23,79,tela)


select("CECCMER")
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

RestScreen(01,00,23,79,tela)
cls
@ 10,10 say "Pressione um a Tecla"
inkey(0)
Return



