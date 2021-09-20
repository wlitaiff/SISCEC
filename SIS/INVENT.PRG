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
*SET PROCEDURE TO BPLIB
SET FIXED ON
SET DECIMALS TO 3
PUBLIC TELA,grup
PRIVATE cor
grup:=0
cor:=setcolor()
ambiente()
Desktop("I N V E N T A R I O ")
tela:=SaveScreen(01,00,23,79)

IF    !ARQNTX("CECCMER",.F.) .OR. ;
      !ARQNTX("CECCMOV",.F.) .OR. ;
      !ARQNTX("CECCLOJ",.F.)  
      DBCLOSEALL()
      RETURN
ENDIF

RestScreen(01,00,23,79,tela)

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
DBCLOSEALL()
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


// Procedimento para imprir a Lista de Pre‡os

Procedure Processo(pgrup)

LOCAL VSTATUS,VQTD,OPCAO
vqtd:=0
VStatus:=space(1)
VStatus:="C"

select("CECCMER")
set index to CECIMER9
GO TOP

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
   @ 13,07 SAY "Status:"          get vstatus  picture "@!"          valid (vstatus$"APC")  when  DwnMsg("Registro: Anterior[A], Proximo[P], Continua[C]")
   @ 14,07 SAY "Quantidade Real:" get Vqtd     picture "999,999.999"                        when  DwnMsg("Digite a Quantidade Real")
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

      Gravar(CODIGOM,Vqtd,CODLINM,UNIDADE,DESCRIM)
      SELECT("CECCMER")
     
   Else
       Loop
   endif

   SKIP
EndDo

RestScreen(01,00,23,79,tela)
Return


Procedure Gravar(Codigo,Pqtd,Grupo,Un,Desc)

  Select("CECCLOJ")
  DBSETORDER(2)
  If !DbSeek(codigo)
     IF Inclui_Registro(.T.)
        Lock_Registro(.T.)
        CECCLOJ->CODILOJ := 1
        CECCLOJ->MERCLOJ := Codigo
        CECCLOJ->DTUCLOJ := date() 
        CECCLOJ->DTUVLOJ := date()
        CECCLOJ->DCUCLOJ := "INVENTAR"
        CECCLOJ->DCUVLOJ := "INVENTAR"
        CECCLOJ->SALDOEJ := Pqtd
        DBUNLOCK()
        DBCOMMIT()
     ENDIF
  Else
        Lock_Registro(.T.)
        CECCLOJ->DTUCLOJ := date() 
        CECCLOJ->DCUCLOJ := "INVENTAR"
        CECCLOJ->SALDOEJ := Pqtd
        DBUNLOCK()
        DBCOMMIT()
  EndIf


  Select("CeccMov")
  if inclui_registro(.t.)
      if lock_registro(.t.)
         ceccmov->mercadoria:= Codigo
         ceccmov->numdocto := "INVENTARIO"
         ceccmov->descmerc := Desc
         ceccmov->linha    := Grupo 
         ceccmov->datamov  := date()
         ceccmov->datadocto:= date() 
         ceccmov->tipomov  := "A"
         ceccmov->codmov   := "RQ"
         ceccmov->codloja  := 1
         ceccmov->unidade  := Un
         ceccmov->quantdoc := Pqtd
         ceccmov->quantmov := Pqtd 
*         ceccmov->salantmov:= Pqtd
         dbcommit()
         dbunlock()
      Endif
  Endif
Return

*         ceccmov->fornecedor:= NFOR
*         ceccmov->serie    := cSerie
*         ceccmov->subserie := nSubSerie
*         ceccmov->origem   := m_origem
*         ceccmov->prazopag := nPag
*         ceccmov->formapag := nFormaPaga
*         ceccmov->totvend := if(_lPrimeiro,nValorNota,0)
*         ceccmov->customov := nCustoMov
*         ceccmov->prevenda := ceccmer->precvem
*         ceccmov->prevendido := IF(cMovimento=="VE",Round(Precoitem/nQNota,2),0)
*         ceccmov->vendedor   := IF(cMovimento=="VE",nCodVendedor,0)
*         ceccmov->usuario    := bUsuario
*         ceccmov->alidesitem := nAlicotaDesconto
*         ceccmov->vldescitem := Round(nValor*(nAlicotaDesconto/100),2)
*         ceccmov->alimcsitem := nIcmsAlicota
*         ceccmov->vlicmsitem := Round(nValor*(nIcmsAlicota/100),2) 
*         ceccmov->custofob := Round(nValor/nQnota,2)
*         ceccmov->precompra:= Round(nValor/nQnota,2)
*         ceccmov->despeitem:= m_despite
*         ceccmov->cusmedant:= cusM_an_Cr


