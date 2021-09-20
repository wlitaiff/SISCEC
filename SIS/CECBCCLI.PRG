*================================================*
*    RELATORIO DE COMPRAS DE CLIENTES [CONSULTA] *
*================================================*

PRIVATE tela, Dti,Dtf,totgeral,vtot,ncliente,SUBTOTAL,aRegistro,aCab,aPic,cor
PUBLIC TELA

AREGISTRO := {}
aCab:={"Dt. do Movimento","Nota Fiscal","Mercadoria","Descricao","Quantidade","Preco Unitario","Preco Total"}
aPic:={"@D","@!","@!","@!","@R@E 99,999.99","@R@E 99,999.99","@R@E 999,999,999.99"}

IF !ARQNTX('CECCBAL1') .OR.;
   !ARQNTX('CECCBAL2') .OR.;
	!ARQNTX('CECCCLI') 
	DBCLOSEALL()
	RETURN
ENDIF		
cor:=setcolor()
tela:=SaveScreen(01,00,23,79)

//
select('CECCBAL1')
DBSETORDER(4)
set relation to cliente into CECCCLI
DBSETORDER(4)
go top
PEGA_CLI()
if lastkey() ==27
   RestScreen(01,00,23,79,tela)
   dbcloseALL()
   set relation to
   setcolor(cor)
   Return
endif
totgeral:=0
SUBTOTAL:=0
consulta(dti,dtf,ncliente,vtot)
RestScreen(01,00,23,79,tela)
dbcloseALL()
set relation to
setcolor(cor)

Return

// Procedimento para pegar o per¡do e o Cliente

Procedure PEGA_CLI

  BOX(10,15,16,50,M->FR,127,3,8)
  Dti:=date()
  Dtf:=date()
  ncliente:=0
  vtot:="N"
  set cursor on
  @ 11,18 SAY " Data Inicial :"      get dti      picture "99/99/99"  valid .not. Dti>date() .and. .not. empt(Dti)
  @ 12,18 SAY " Data Final   :"      get dtf      picture "99/99/99"  valid .not. Dtf<Dti .and. .not. empt(Dtf)
  @ 13,18 SAY " Somente o Total  :"  get vtot     picture "@!"        valid (vtot$"SN")
  @ 14,18 SAY " Codigo do Cliente:"  get ncliente PICTURE "@K 99999";
                                                  VALID !EMPTY(ncliente) .AND.;
                                                  Existe(ncliente,"Cliente nÆo cadastrado",.F.,"CECCCLI",1,"NOMECLC","@!",ROW(),COL()+2) 
  
  READ
  set cursor off

Return


// Procedimento para MOSTRAR  dados

Procedure consulta(pdti,pdtf,pcodcli,ptot)
LOCAL VALOR,COD,NOME,CGC,DATA,op,PRI  
PRI:="S"
tecla:=0
SELECT("CECCBAL1")
DBSETORDER(4)
DBSEEK(Dtos(pdti),.T.)

BOX(01,01,22,79,M->FR,127,3,8) 
M_MESSAGE([P R O C E S S A N D O ...],23)

do while .not. eof() .and. DATAATD <= pdtf
	
  if CLIENTE == pcodcli .and. serie="F" .and. atendido=.T. .and. Cancelado=.F.

        IF PRI="S"
           COD:="C¢digo:"+STRZERO(Cliente,5)
           NOME:="RazÆo Social: "+CECCCLI->NOMECLC
           CGC :="C.G.C.:"+CECCCLI->CGCCPFC
           DATA:="Per¡odo: "+DTOC(pdti)+" a "+DTOC(pdtf)

           @ 02, 03 say NOME
           @ 03, 03 say COD
           @ 03, 17 say CGC
           @ 03, 45 say DATA
           pri:="N"
        endif

        IMPCLI(pedido,dataatd,nota,ptot)
        select("CECCBAL1")

  EndIf
Skip
ENDDO

if ptot="S"
   if TotGeral <> 0
      valor:=Transform(TotGeral,"999,999,999.99")
      M_DISPLAY("TOTAL DA COMPRA: "+Valor,79)
     * Alert("TOTAL DA COMPRA: "+Valor)
      return
   else
      M_DISPLAY("NÆo houve compra neste per¡odo",79)
      return
   endif
endif

IF LEN(AREGISTRO)<>0 //.and. TotGeral<>0 
        
        AADD(aRegistro,{NIL,"==========","===============","TOTAL GERAL ======================>>",NIL,NIL,TotGeral})
        HBrowseAR(04,01,22,79,"Compras de Cliente",aCab,aRegistro,aPic)
ELSE
        M_DISPLAY("NÆo houve compra neste per¡odo",79)
        
ENDIF	

RETURN


Procedure IMPCLI(ppedido,pdata,pnf,ptot)
  local op1, SubTotal,subvalor,PRI
  SubTotal:=0
  PRI:="S"
  seleCT([CECCBAL2])
  go top
  seek Str(ppedido,10)
        
  do while .not. eof() .and. ppedido=pedido

     SubTotal:=SubTotal+precot
     totgeral:=totgeral+precot

     if ptot="N" 
        AADD(aRegistro,{pdata,pnf,Mercadoria,Descricao,qtd,precou,precot})
     endif
     skip
  enddo
                                        
  if LEN(aRegistro)#0
     AADD(aRegistro,{nil,"----------","---------------","Total da Nota -------------------->>",nil,nil,SubTotal})
     AADD(aRegistro,{nil,nil,nil,nil,nil,nil,nil})
  Endif

return



