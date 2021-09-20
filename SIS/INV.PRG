* ============================================
*       I N V E N T A R I O                  *
* ============================================

#include "SET.CH" 
#include "INKEY.CH"

main()

Procedure main

SET PROCEDURE TO c:\trab\util\util.PRG
SET FIXED ON
SET DECIMALS TO 2
PUBLIC TELA,grup
PRIVATE cor
grup:=0
cor:=setcolor()
ambiente()
Desktop("I N V E N T A R I O ")
tela:=SaveScreen(01,00,23,79)
AbraArqList() 
RestScreen(01,00,23,79,tela)
select  PRODUTO
GO TOP

Do While .T.

  Pega_dados()
  RestScreen(01,00,23,79,tela)
  if lastkey()==27
      if MsgBox3d2("Deseja Finalizar")=1
          fechar()
          EXIT
      else
          Loop
      ENDIF
  endif
  Processo(grup)

EndDo
setcolor(cor)
cls
Return

// Procedimento para pegar dados
Procedure Pega_dados() 

  Win(10,23,13,50,"Especifique o Grupo")
  set cursor on
  @ 12,30 SAY " Grupo :" get grup  picture "99-99"  valid .not. empt(grup)   when  DwnMsg("Digite o Grupo Desejado")
  read
  if lastkey()=27
      RestScreen(01,00,23,79,tela)
      return
  endif
  set cursor off
  RestScreen(01,00,23,79,tela)
Return

// Procedimento para abrir arquivos

Procedure AbraArqList

Use CECCMER alias PRODUTO SHARED NEW 
 if neterr()=.T.
    MsgBox3d1("Aquivo nao esta Disponivel: CECCMER")
 endif
        
* IF .NOT. FILE("CECIMER6.NTX")
*     MsgBox("Indexando Arquivo dos Grupos : CECIMER6")
*     index on STR(CODLINM,4)+CODIGOM to CECIMER6
* else
*     set index to CECIMER6
* endif

 IF .NOT. FILE("CECIMER9.NTX")
     MsgBox("Indexando Arquivo dos Grupos : CECIMER9")
     index on STR(CODLINM,4)+DESCRIM to CECIMER9
 else
     set index to CECIMER9
 endif

return



// Procedimento para imprir a Lista de Pre‡os

Procedure Processo(pgrup)

LOCAL VSTATUS,VQTD,OPCAO
vqtd:=0
VStatus:=space(1)
VStatus:="C"

seek Str(pgrup,4)

if .not. found()
   MsgBox1("Grupo nao Encontrado: "+strzero(pgrup,4))
*   @ 02,10 say "Grupo nao Encontrado: "+strzero(pgrup,4)
   return
endif

Do while  CODLINM = pgrup .and. !EOF()
   
   Frame (04,04,10,76,"Dados da Mercadoria")
   @ 06,07 say "Mercadoria   : "+codigom
   @ 06,48 say "Grupo: "+strzero(pgrup,4)
   @ 07,07 say "Descri‡Æo    : "+descrim
   @ 08,07 say "Pre‡o a vista: "+TRANSFORM(PRECVEM,"999,999.99")
   @ 08,48 say "Pre‡o a Prazo:"+TRANSFORM(PRECVEM2,"999,999.99")
   @ 09,07 say "Qtd. Atual   : "+TRANSFORM(SALDOEM,"999,999.99")

   frame(11,04,19,76,"Dados do Invent rio")
   set cursor on
   set confirm on
   @ 13,07 SAY "Status:"          get vstatus  picture "@!"          valid (vstatus$"APC") when  DwnMsg("Registro: Anterior[A], Proximo[P], Continua[C]")
   @ 14,07 SAY "Quantidade Real:" get Vqtd     picture "999,999.99"                        when  DwnMsg("Digite a Quantidade Real")
   read

   if LASTKEY()==27
      RestScreen(01,00,23,79,tela)
      return
   endif

   if vstatus=="A"
      SKIP -1
      LOOP
   Endif

   if vstatus=="P"
      SKIP 1
      LOOP
   endif

   @ 17,18 say "Quantidade Real :"+TRANSFORM(Vqtd,"999,999.999")+"  Deseja Gravar ?" 
   
   opcao:=linButton2()
   IF opcao==1

       IF RLOCK()
           REPLACE SALDOEM  WITH Vqtd
       ELSE
          MsgBox3D1("Registro est  sendo utilizado !")
       endif
   Else
       Loop
   endif

   SKIP
   
EndDo
RestScreen(01,00,23,79,tela)
Return


