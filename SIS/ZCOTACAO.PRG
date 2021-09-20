*============================================*
*    RELATORIO DE COMPRAS DE CLIENTES        *
*============================================*

#include "SET.CH" 
 
PED()

Procedure PED
PRIVATE vTIPO



* SET PROCEDURE TO c:\trab\util\UTIL.PRG
SET PROCEDURE TO WRLIB

* ambiente()

IF    !ARQNTX("CECCBAL1",.F.) .OR. ;
      !ARQNTX("CECCBAL2",.F.)  
      DBCLOSEALL()
      RETURN
ENDIF



select  CECCBAL1
go top

MsgBox("P r o c e s s a n d o")

Do While !EOF() 

 IF TIPO=" " .AND. !ATENDIDO
   IMPCLI(pedido)
   select CECCBAL1
   IF RLOCK()
      DELETE 
   ELSE
      MsgBox3D1("Registro est  sendo utilizado !")
   endif
 ENDIF

 Skip
EndDo

CLOSE ALL   

Return


 
Procedure IMPCLI(ppedido)
  select CECCBAL2
  go top
  seek Str(ppedido,10)

  do while .not. eof() .and. ppedido=pedido

     IF RLOCK()
        DELETE 
     ELSE
        MsgBox3D1("Registro est  sendo utilizado !")
     endif

    skip
  enddo
return



