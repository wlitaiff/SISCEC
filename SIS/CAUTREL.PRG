* ============================================
*    Relatorio : Sa¡da de Mercadoria 
* ============================================

#include "SET.CH" 

main()

Procedure main
PRIVATE tela,Pag
PUBLIC TELA
public MEMSAGEM
pag=1
//
SET PROCEDURE TO c:\trab\util\UTIL.PRG
ambiente()
tela:=SaveScreen(01,00,23,79)
ABRIR()
RestScreen(01,00,23,79,tela)
select  cx
go top
mensagem:="RELATORIO DE CAUTELAS PENDENTES"

Do While .T.

 IF  ISPRINTER()
     MsgBox(" Imprimindo ...")
     set devi to printer
     DO NORMAL
     DO C_CALTELA WITH MENSAGEM,80
     CABCALTELA()
     set print on
     Imp_MER()
     EXIT
     RestScreen(01,00,23,79,tela)
 ENDIF
EndDo

fechar()  
set devi to screen
set print off
cls
@ 10,10 say "F I M  D E  P R O C E S S O"
Return



// Procedimento para abrir arquivos
Procedure ABRIR

 Use CECCBAL1 alias CX SHARED NEW 
 if neterr()=.T.
     MsgBox3d1("Aquivo nao esta Disponivel : CECCBAL1")
 endif

 if .not. file("CECIBAL7.NTX") 
     MsgBox3d1("Aquivo nao esta Disponivel : CECIBAL1")
 else   
     set index to CECIBAL7
 endif

return


// Procedimento para imprir os dados

Procedure Imp_MER()
LOCAL tecla,ParaImp,mensagem,lin,VCLI
lin:=12
tecla:=0
VCLI:=0

// Processar apenas a faixa pedida no periodo.
Go Top
mensagem:="RELATORIO DE CAUTELAS PENDENTES"

do while .not. eof()      

 if atendido=.F. .and. tipo=="C" .AND. DELETED()=.F.
    
    tecla:=inkey()
    ParaImp:=StoPrinter(tecla)
    if ParaImp=.T. 
       tecla:=0
       return
    else
       tecla:=0
    endif
    //
    IF lin >=58
       lin:=12
       DO NORMAL
       DO RODAPE WITH 80,' ',PAG,0
       DO C_CALTELA WITH MENSAGEM,80
       CABCALTELA()
    ENDIF

     @ lin,02 SAY strzero(CLIENTE,5)
     @ lin,15 SAY strzero(PEDIDO,8) 
     @ lin,25 SAY space(40)
     lin:=lin+1
 endif
Skip
ENDDO

DO RODAPE WITH 80,' ',PAG,0
RETURN
 

