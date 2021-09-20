*================================================*
*    RELATORIO DE COMPRAS DE CLIENTES [CONSULTA] *
*================================================*

PRIVATE tela, Dti,Dtf,totgeral,vtot,ncliente,SUBTOTAL,aRegistro,aCab,aPic,cor
PUBLIC TELA

AREGISTRO := {}
aCab:={"Dt. do Movimento","Nota Fiscal","Mercadoria","Descricao","Quantidade","Preco Unitario","Preco Total"}
aPic:={"@D","@!","@!","@!","@R@E 9,999.99","@R@E 9,999.99","@R@E 999,999,999.99"}

IF !ARQNTX('CECCMOV') .OR.;
	!ARQNTX('CECCCLI') 
	DBCLOSEALL()
	RETURN
ENDIF

cor:=setcolor()
tela:=SaveScreen(01,00,23,79)

//
 select('CECCMOV')
 DBSETORDER(9) // Verificar o indice (novo indece criado)
 set relation to FORNECEDOR into CECCCLI
*DBSETORDER(9)  // verificar o indice
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
LOCAL VALOR,COD,NOME,CGC,DATA,op,PRI,Prctot,Qtd,MOV,PRECO,TOT
Qtd:=0
Prctot:=0
TOT:=0
PRI:="S"
tecla:=0
PRECO:=0

select('CECCMOV')
DBSETORDER(9)  
go top

*DBSEEK(Dtos(pdti),.T.)
MOV:="VE"
DBSEEK(STRZERO(PCODCLI,5)+Dtos(pdti),.T.)

BOX(01,01,22,79,M->FR,127,3,8) 
M_MESSAGE([P R O C E S S A N D O ...],23)

do while .not. eof() .and. DATAMOV <= pdtf
	
  if pcodcli > FORNECEDOR
     EXIT
  ENDIF

  if pcodcli = FORNECEDOR
    IF PRI="S"
       COD:="C¢digo:"+STRZERO(FORNECEDOR,5)
       NOME:="RazÆo Social: "+CECCCLI->NOMECLC
       CGC :="C.G.C.:"+CECCCLI->CGCCPFC
       DATA:="Per¡odo: "+DTOC(pdti)+" a "+DTOC(pdtf)

       @ 02, 03 say NOME
       @ 03, 03 say COD
       @ 03, 17 say CGC
       @ 03, 45 say DATA
       pri:="N"
    ENDIF

    if CODMOV="CV".OR. CODMOV="VE"

        Prctot:=QUANTMOV * PREVENDIDO

       SubTotal:=SubTotal+Prctot
       totgeral:=totgeral+Prctot
       Qtd:=ABS(QUANTMOV)
       PRECO:=ABS(PREVENDIDO)
       TOT:=ABS(Prctot)
       If ptot="N" 
          AADD(aRegistro,{DATAMOV,NUMDOCTO,MERCADORIA,DESCMERC,qtd,PRECO,TOT})
       endif
    ENDIF
  ENDIF
  SKIP
ENDDO

if ptot="S"
   if TotGeral <> 0
*      valor:=Transform(TotGeral,"999,999,999.99")
      M_DISPLAY("TOTAL DA COMPRA: "+Transform(TotGeral,"999,999,999.99"),79)
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
    M_DISPLAY("NÆo houve compra neste per¡odo [OK]",79)
        
ENDIF	

RETURN



