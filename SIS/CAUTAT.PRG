* ============================================
*     
* ============================================

#include "SET.CH" 

main()

Procedure main
LOCAL CONT2
PUBLIC CONT1

// SET PROCEDURE TO c:\trab\util\UTIL.PRG
SET PROCEDURE TO WRLIB
CONT2:=0
CONT1:=0

IF    !ARQNTX("CECCMER",.F.) .OR. ;
      !ARQNTX("CECCBAL1",.F.) .OR. ;
      !ARQNTX("CECCBAL2",.F.)  
      DBCLOSEALL()
      RETURN
ENDIF

select  CECCBAL1
Set index to CECIBAL7
go top

Do While .NOT. EOF()

   PROCBAL2(PEDIDO)
   select  CECCBAL1
   CONT2:=CONT2+1
   @ 18,10 SAY "Procesando Cautelas: "+strzero(cont2,10)
   
   SKIP

EndDo

CLOSE ALL   
Return

// Procedimento para imprir os dados

Procedure PROCBAL2(PPEDIDO)
LOCAL CONT
CONT:=0

SELECT CECCBAL2
Set index to cecibal2
Go Top

SEEK STR(PPEDIDO,10)

IF !FOUND()
   MsgBox("PEDIDO NAO ENCONTRADO"+STRZERO(PPEDIDO,10))
   RETURN
ENDIF

DO WHILE !EOF() .AND. PPEDIDO=PEDIDO

   PROCMER(MERCADORIA,QTD)
   SELECT ceccbal2
   CONT:=CONT+1
   @ 19, 10 SAY "Processando pedido ceccbal2: "+strzero(cont,10)
   
   skip

enddo
RETURN
 

PROCEDURE PROCMER(PMERC,PQTD)
 LOCAL VALOR
 VALOR:=0

 SELECT CECCMER
 Set index to CECIMER1
 GO TOP

 SEEK PMERC
 
 IF FOUND()
     VALOR:=PQTD+CAUTELA

     IF RLOCK()
        REPLACE CAUTELA WITH VALOR
        CONT1:=CONT1+1
        @ 20,10 SAY "ATUALIZANDO CAUTELA: "+STRZERO(CONT1,10)
     ELSE
        MsgBox1("Registro est  sendo utilizado !")
        
     endif
 ELSE

     MSGBOX("MERCADORIA NAO ENCONTRADA: "+PMERC)

 ENDIF

RETURN
