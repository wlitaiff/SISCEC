MAIN()

PROCEDURE MAIN
LOCAL CONT
ABRIR()
SELECT MERCADORIA
GO TOP
CONT:=0
DO WHILE !EOF()

   IF RLOCK()

      REPLACE CAUTELA WITH 0
    
   ENDIF
   CONT:=CONT+1
   @ 20,20 SAY "PROCESSANDO: "+STRZERO(CONT,20)
   Skip
EndDo
CLOSE ALL
return

PROCEDURE ABRIR

 Use ceccmer alias mercadoria SHARED NEW
 if neterr()=.T.
    MsgBox3d1("Aquivo de Mercadorias nao esta Disponivel !")
 ELSE
    if .not. file("CECIMER1.NTX") 
        MsgBox("Indexando Arquivo de Mercadoria...") 
        index on codigom to CECIMER1.NTX
    else   
        set index to CECIMER1.NTX
    endif
 ENDIF

return


