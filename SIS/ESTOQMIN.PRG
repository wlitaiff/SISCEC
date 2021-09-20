* ============================================
*       I N V E N T A R I O                  *
* ============================================

#include "SET.CH" 
#include "INKEY.CH"
#include "FUNCKY.CH"

main()

Procedure main

* SET PROCEDURE TO c:\trab\util\util.PRG
SET PROCEDURE TO WRLIB
SET FIXED ON

PUBLIC TELA,grup
PRIVATE cor
grup:=0
cor:=setcolor()
* ambiente()
Desktop("Estoque Minimo")
tela:=SaveScreen(01,00,23,79)

IF    !ARQNTX("CECCMER",.F.) 
      DBCLOSEALL()
      RETURN
ENDIF

RestScreen(01,00,23,79,tela)

// Data da ultima atualizacao : 01/10/98

Select ceccmer
go top
MsgBox("P R O C E S S A N D O")
Do While !EOF()
  
  if !empty(DCULTVM)

     IF SALDOEM < 4

        IF RLOCK()
           REPLACE ESTMINM  WITH 1
        ELSE
           MsgBox3D1("Registro est  sendo utilizado !")
        endif
     Else
        IF RLOCK()
           REPLACE ESTMINM  WITH int(SaldoEm*0.3)
        ELSE
           MsgBox3D1("Registro est  sendo utilizado !")
        endif
     Endif
  Endif
  skip
EndDo

setcolor(cor)

DBCLOSEALL()
MsgBox("F I M  D E  P R O C E S S O - Precione uma Tecla")
INKEY(0)
cls
Return




