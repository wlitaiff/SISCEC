* =======================================
*   Alterar Mercadoria                  *
* =======================================

#include "SET.CH" 
#include "INKEY.CH"

main()

Procedure main

SET PROCEDURE TO WRLIB
* SET PROCEDURE TO c:\trab\util\util.PRG
set deleted on
PUBLIC TELA,gMER
PRIVATE cor
gmer:=space(16)
cor:=setcolor()
* ambiente()
Desktop("Alterar C¢dogo da Mercadoria")
tela:=SaveScreen(01,00,23,79)
RestScreen(01,00,23,79,tela)


Use CodAntgo alias Antigo SHARED NEW

IF    !ARQNTX("CECCMER",.F.) .OR. ;
      !ARQNTX("CECCLOJ",.F.)  
      DBCLOSEALL()
      RETURN
ENDIF

Do While .T.

  Pega_dados()
  RestScreen(01,00,23,79,tela)
  if lastkey()==27
      if MsgBox3d2("Deseja Finalizar")=1
          DBCLOSEALL()
          EXIT
      else
          Loop
      ENDIF
  endif
  Processo(gmer)

EndDo
setcolor(cor)
cls
Return

// Procedimento para pegar dados
Procedure Pega_dados() 

  Win(10,23,13,56,"Especifique a Mercadoria")
  set cursor on
  @ 12,25 SAY " Mercadoria:" get gmer PICTURE "@!"  valid .not. empt(gmer)   when  DwnMsg("Digite a Mercadoria Desejada")
  read
  if lastkey()=27
      RestScreen(01,00,23,79,tela)
      return
  endif
  set cursor off
  RestScreen(01,00,23,79,tela)
Return



// Procedimento para imprir a Lista de Pre‡os

Procedure Processo(pmer)

LOCAL VSTATUS,VMER,OPCAO,NREG
Cod_Novo:=SPACE(16)
VStatus:=space(1)
VStatus:="C"
NREG:=0

Select CECCMER
Set index to CECIMER1
go top

seek pmer

if .not. found()
   MsgBox1("Mercadoria nao Encontrada: "+pmer)
   return
endif

Do while  .T. 
   
   Frame (04,04,23,76,"Dados da Mercadoria")
   @ 06,07 say "Mercadoria   : "+codigom
   @ 06,48 say "Grupo: "+strzero(CODLINM,4)
   @ 07,07 say "Descri‡Æo    : "+descrim
   @ 08,07 say "Pre‡o a vista: "+TRANSFORM(PRECVEM,"999,999.99")
   @ 08,48 say "Pre‡o a Prazo:"+TRANSFORM(PRECVEM2,"999,999.99")
   @ 09,07 say "Qtd. Atual   : "+TRANSFORM(SALDOEM,"999,999.99")

   frame(11,04,19,76,"Dado a ser Alterado")
   set cursor on
   set confirm on
   @ 13,07 SAY "Status:"          get vstatus  picture "@!"    valid (vstatus$"APC")      when  DwnMsg("Registro: Anterior[A], Proximo[P], Continua[C]")
   @ 14,07 SAY "C¢digo Novo:" get Cod_Novo     picture "@!"    valid .NOT. empt(Cod_novo) when  DwnMsg("Digite a o Novo C¢digo")
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

   @ 17,18 say "Novo C¢digo: "+Cod_novo+"  Deseja Gravar ?"

   NREG:=RECNO()
   if existe_Mer(Cod_novo)==.F.  
      
      GO NREG

      opcao:=linButton2()
      IF opcao==1
         
         IF RLOCK()
            REPLACE CODIGOM WITH Cod_novo  // Atualizar no CECCMER
         ELSE
            MsgBox3D1("Registro est  sendo utilizado !")
         endif

         AltLoja(1,pmer,Cod_novo)             // Atualizar o CECCLOJ - Usado no balcao.
         Gravar(pmer,Cod_novo,date())         // Gravar o Codigo Antigo

         Select CECCMER
      Else
         Loop
      endif

   Else
      MsgBox1("Mercadoria j  Cadastrada")
      Loop
   Endif
   GO NREG
EndDo
RestScreen(01,00,23,79,tela)
Return

FUNCTION EXISTE_MER(PMERC)
 GO TOP
 SEEK PMERC
 IF FOUND()
    RETURN(.T.)
 ELSE
    RETURN(.F.)
 ENDIF

RETURN

Procedure AltLoja(Loja,Cod_mer,pCod_novo)

 Select CECCLOJ 
 Set index to CECILOJ1
 go top

 SEEK Str(Loja,4)+Cod_MER
 if .not. found()
   MsgBox1("Mercadoria nao Encontrada no CECCLOJ - Chame o Valdo: "+Cod_mer)
   return
 endif

 If RLOCK()
    REPLACE MERCLOJ WITH pCod_novo    // Atualizando o CECCLOJ
 ELSE
    MsgBox3D1("Registro est  sendo utilizado no CECCLOJ !")
 endif
Return

Procedure Gravar(merc,mer_novo,pdata)

  Select antigo 
  Append Blank
  Replace cod_ant With merc
  Replace cod_nov With mer_novo
  Replace data    With pdata
  
Return

