// Sistemas de Controle de Estoque Comercial
// W&R Informatica Ltda
// 10 de Novembro de 1995
// Roberto Falcao Rocha
// Baixas de mercadorias por pedidos

#include "INKEY.CH"

LOCAL cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
		cCor := SETCOLOR(),;
		nCursor := SETCURSOR(0),;
		aDad := {"PEDIDO","LOJA","CLIENTE","VENDEDOR","SUBTOTAL","VDESCONTO","TOTAL","DATAATD","NOTA","SERIE","SUBSERIE"},;
		aCab := {"Pedido","Loja","Cliente","Vendedor","Sub-Total","Desconto","Total","Atendimento","Nota","Serie","Sub-serie"},;
		aPic := {"9999999999","9999","99999","99999","9999999.99","9999999.99","9999999.99","@d","@!","@!","99"}

// Verificando arquivos
IF !ARQNTX("CECCBAL1",.F.) .OR. ;
	!ARQNTX("CECCBAL2",.F.) .OR. ;
   !ARQNTX("CECTLOJ",.F.) .OR. ;
   !ARQNTX("CECCSET",.F.) .OR. ;
	!ARQNTX("CECCVEN",.F.) .OR. ;
	!ARQNTX("CECCLOJ",.F.) .OR. ;
	!ARQNTX("CECCFIS",.F.) .OR. ;	
	!ARQNTX("CECCMOV",.F.) .OR. ;
	!ARQNTX("CECCMER",.F.) 
	DBCLOSEALL()
	RETURN
ENDIF	

SELECT("CECCBAL1")
DBGOTOP()
IF ! ( PASS () == ALLTRIM ( Criptografa ( CECCSET -> PASSWDS, "HAWK", .F. ) ) )
    M_DISPLAY ( "Usu rio nÆo autorizado a visualizar os pedidos", 79 )
    DBCLOSEALL()
    RETURN
ENDIF
HBrowseDB( 1,0,24,79,"Cadastro de pedidos/balcao",aCab,aDad,aPic,NIL,,,.F.,"CECM5000")
DBCLOSEAll()
RETURN

FUNCTION PBalcao( oBrowse )
	LOCAL cCor := SETCOR(m->cEdicao),;
			nCursor := SETCURSOR(1),;
			cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
			nReg := RECNO(),;
			cNotas := SPACE(10),;
			cSerie := SPACE(1),;
			dData := CTOD("  /  /  "),;
			nSubserie := 0,;			
			Getlist:={},;
			lAchou,;
			nPedido:=0,;
			nLoja:=0
			
	xOpcao := Alert("Pesquisa por:",{"Pedidos","Notas","Cancela"})
	
	IF xOpcao == 3
		RETURN(NIL)
	ENDIF	
	
	IF xOpcao == 1
		DISPBOX(05,03,08,75,M->FR)
		@ 06,04 SAY "No. Pedido:";
				  GET nPedido;
				  PICTURE "@K 9999999999";
				  VALID !EMPTY(nPedido)
			  
		@ 07,04 SAY "Loja......:";
				  GET nLoja;
				  PICTURE "@K 9999";
				  VALID lAchou:=Existe(STR(nPedido,10)+STR(nLoja,4),"Pedido nÆo encontrado",.F.,,1,,,,,.T.) 
	ELSE
	
		DISPBOX(05,03,10,75,M->FR)
		@ 06,04 SAY "No. da nota.:";
			  GET cNotas;
			  PICTURE "@K@!";
			  VALID ShowZeros(@cNotas)
			  
	@ 07,04 SAY "Serie.......:";
			  GET cSerie;
			  PICTURE "@K@!"
			  
	@ 08,04 SAY "Sub-serie...:";
			  GET nSubSerie;
			  PICTURE "@K 99"
			  
	@ 09,04 SAY "Data...:";
			  GET dData;
			  PICTURE "@D";
			  VALID lAchou := Existe(cNotas+cSerie+STR(nSubSerie,2)+DTOS(dData),"Nota n„o cadastrada",.F.,,3,,,,,.T.) 					  
			  
	ENDIF			  
			  
	READ		  
		
	SETCURSOR(nCursor)
	SETCOLOR(cCor)
	RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)	
	
	IF LASTKEY()==27
		DBGOTO(nReg)
		oBrowse:refreshAll()
		RETURN(NIL)
	ENDIF	
	
	IF !lAchou
		DBGOTO(nReg)
	ENDIF
		
	oBrowse:refreshAll()
RETURN(NIL)

FUNCTION Atende(oObject)
LOCAL cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
		cCor := SETCOLOR(),;
		nCursor := SETCURSOR(0),;
		aDad := {"PEDIDO","LOJA","MERCADORIA","QTD","PRECOU","PRECOT","DESCONTO"},;
		aCab := {"Pedido","Loja","Mercadoria","Quantidade","Unit rio","Total","DESCONTO"},;
		aPic := {"9999999999","9999","@!","999999.999","9999999.99","9999999.99","999999.99"}
	
	
	SELECT("CECCBAL2")
	SET INDEX TO
	SUBNTX("CECIBAL2.NTX","SUBIBAL2.NTX",STR(CECCBAL1->PEDIDO,10),STR(CECCBAL1->PEDIDO,10),"***",.F.,-1)
	DBSETINDEX("SUBIBAL2.NTX")
	HBrowseDB(6,0,24,79,"Itens do pedido "+ALLTRIM(STR(CECCBAL1->PEDIDO,10)),aCab,aDad,aPic,NIL,,,.F.,"ATENDE2")
	CECCBAL2->(DBCLOSEAREA())
	ARQNTX("CECCBAL2")
	SELECT("CECCBAL1")
	oObject:refreshAll()
RETURN(NIL)

FUNCTION ConfirmaP()
	LOCAL nDesc,;
			cTela:=SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
			nCursor:=SETCURSOR(),;
			cNota := SPACE(10),;
			cSerie:= SPACE(1),;
			nSub:=0,;
			GetList:={}
			
	PRIVATE MES       
	
	IF CECCBAL1->ATENDIDO	
		M_DISPLAY("Pedido ja foi atendido",79)
		RETURN(NIL)
	ENDIF	
	
	IF !Confirma("Confirma o pedido ?",23)
		RETURN(NIL)
	ENDIF	
	
	SETCURSOR(1)
	
	BOX(05,09,09,75,M->FR,127,3,8)
	@ 06,010 SAY "Nota.....:";
			  GET cNota;
			  PICTURE "@K@!";
	    	  VALID ShowZeros(@cNota)
			  
	@ 07,10 SAY "Serie....:";
			  GET cSerie;
			  PICTURE "@K!"
			  
	@ 08,10 SAY "Sub-serie:";
			  GET nSub;
			  PICTURE "@K 99" VALID !Existe(cNota+cSerie+Str(nSub,2),"Nota ja cadastrada",.T.,"CECCFIS",1)
		
	READ
		
		
	
	SETCURSOR(nCursor)
	RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
	
	IF LASTKEY()==27
		RETURN(NIL)	
	ENDIF	
	
	M_MESSAGE("Atualizando arquivos ...",23)
	
	CECCBAL2->(DBGOTOP())
	_lPrimeiro := .T.
	DO WHILE CECCBAL2->PEDIDO == CECCBAL1->PEDIDO .AND. !CECCBAL2->(EOF())
		CECCMER->(DBSEEK(CECCBAL2->MERCADORIA))
		CECCMOV->(Inclui_Registro(.T.))
		// Movimentos
		CECCMOV->(Lock_Registro(.T.))
		CECCMOV->NUMDOCTO   := cNota
		CECCMOV->SERIE      := cSerie
		CECCMOV->SUBSERIE   := nSub
		CECCMOV->NUMPED     := CECCBAL2->PEDIDO
		CECCMOV->MERCADORIA := CECCBAL2->MERCADORIA
		CECCMOV->DESCMERC   := CECCMER->DESCRIM
		CECCMOV->REFERENCIA := CECCMER->REFEREM
		CECCMOV->DATAMOV    := DATE()
		CECCMOV->CODLOJA    := CECCBAL2->LOJA
		CECCMOV->LINHA      := CECCMER->CODLINM
		CECCMOV->TIPOMOV    := "S"
		CECCMOV->CODMOV     := "VE"
		//		CECCMOV->DIVISAO    := CECCMER->CODDIVM
		CECCMOV->ORIGEM     := CECCMER->ORIGEMM
		CECCMOV->UNIDADE    := CECCMER->UNIDADE
		CECCMOV->QUANTMOV   := -CECCBAL2->QTD
		CECCMOV->SALANTMOV  := CECCMER->SALDOEM
		CECCMOV->PRECOMPRA  := CECCMER->PRECCOM
		CECCMOV->TOTVEND    := IF(_lPrimeiro,CECCBAL1->TOTAL,0)
		_lPrimeiro := .F.
		CECCMOV->CUSTOMOV   := ROUND(CECCMER->CMEDM*CECCBAL2->QTD,3)
		CECCMOV->PREVENDA   := CECCMER->PRECVEM
		nDesc := IF(CECCBAL1->VDESCONTO#0,(((CECCBAL2->PRECOU*CECCBAL2->QTD)/CECCBAL1->SUBTOTAL)*CECCBAL1->VDESCONTO),0)
		nDesc := ROUND(nDesc / CECCBAL2->QTD,3)
		CECCMOV->PREVENDIDO := CECCMER->PRECVEM-(ROUND(CECCBAL2->DESCONTO/CECCBAL2->QTD,3) + nDesc)
		CECCMOV->VLDESCITEM := nDesc+ROUND(CECCBAL2->DESCONTO/CECCBAL2->QTD,3)
		_nAliDesc := ROUND((nDesc+ROUND(CECCBAL2->DESCONTO/CECCBAL2->QTD,3)/CECCMER->PRECVEM)*100,2)		
		CECCMOV->ALIDESITEM := _nAliDesc
		CECCMOV->VENDEDOR   := CECCBAL1->VENDEDOR
		CECCMOV->(DBUNLOCK())
		CECCMOV->(DBCOMMIT())
		
		// Lojas
		IF !CECCLOJ->(DBSEEK(STR(CECCBAL2->LOJA,4)+CECCBAL2->MERCADORIA))
			CECCLOJ->(Inclui_Registro(.T.))
		ENDIF
		CECCLOJ->(Lock_Registro(.T.))
		CECCLOJ->SALDOEJ-=CECCBAL2->QTD	
		CECCLOJ->DTUVLOJ:=DATE()
		CECCLOJ->DCUVLOJ:=cNota
		CECCLOJ->(DBUNLOCK())
		CECCLOJ->(DBCOMMIT())
		
		// Mercadoria
		CECCMER->(DBSEEK(CECCBAL2->MERCADORIA))
		CECCMER->(Lock_Registro(.T.))
		CECCMER->SALDOEM-=CECCBAL2->QTD
		CECCMER->DTULTVM:=DATE()
		CECCMER->DCULTVM:=cNota
		CECCMER->(DBUNLOCK())
		CECCMER->(DBCOMMIT())		
				
		SELECT("CECCBAL2")
		DBSKIP()
		
	ENDDO	
	
	CECCFIS->(INCLUI_REGISTRO(.T.))
	CECCFIS->(LOCK_REGISTRO(.T.))
	ceccfis->CLI_FOR  :=  CECCBAL1->CLIENTE    //OK
	cecCFIS->NNOTA    :=  cNota                //OK
	cecCFIS->SERIE    :=  cSerie               //OK 
	cecCFIS->SUBSER   :=  nSub                 //OK 
	cecCFIS->DEMI     :=  DATE()               //OK
	cecCFIS->DENT     :=  CTOD("  /  /    ")     //OK
	cecCFIS->Dsai     :=  DATE()               //OK
	CECCFIS->DATAS    :=  DATE()
	cecCFIS->VLNOT    :=  CECCBAL1->TOTAL      //OK
	cecCFIS->CFO      :=  "512"                //OK
	cecCFIS->CODTRI   :=  1                    //OK
	cecCFIS->ALIICMS  :=  17                   //OK
	cecCFIS->ALIDICMS :=  0                    //OK
	cecCFIS->VLICMS   :=  round(CECCBAL1->TOTAL*(17/100),2) //OK
	cecCFIS->VLDICMS  :=  0                    //OK 
	cecCFIS->VLIPI    :=  0 		             //OK
	cecCFIS->FRETE    :=  0                    //OK 
	cecCFIS->SEGURO   :=  0                    //OK
	cecCFIS->BASICMS  :=  CECCBAL1->TOTAL      //OK
	cecCFIS->BASIPI   :=  0                    //OK
	cecCFIS->NLANFIS  :=  0                    //OK
	cecCFIS->CONPAG   :=  0                    //OK
	CECCFIS->CANCELADA := .F.
	CECCFIS->(DBUNLOCK())
		
	//Tabela de lojas
	M->MES:="VENM"+STRZERO(MONTH(DATE()),2)+"TL"
	CECTLOJ->(DBSEEK(CECCBAL1->LOJA))
	CECTLOJ->(Lock_Registro(.T.))
	CECTLOJ->TOTVENTL += CECCBAL1->TOTAL
	CECTLOJ->COMIGETL += ROUND(CECCBAL1->TOTAL*(CECTLOJ->PCOMGETL/100),2)
	REPL CECTLOJ->&MES WITH CECTLOJ->&MES + CECCBAL1->TOTAL
	CECTLOJ->(DBUNLOCK())
	
	// Vendedores
	CECCVEN->(DBSEEK(STR(CECCBAL1->VENDEDOR,5)+STR(CECCBAL1->LOJA,4)))
	CECCVEN->(Lock_Registro(.T.))
	CECCVEN->VENMES += CECCBAL1->TOTAL
	CECCVEN->TOTVEN += CECCBAL1->TOTAL
	CECCVEN->COMMES += ROUND(CECCVEN->VENMES*(CECCVEN->PCONIS/100),2)
	CECCVEN->TOTCOM += ROUND(CECCVEN->TOTVEN*(CECCVEN->PCONIS/100),2)
	CECCVEN->(DBUNLOCK())
	
	//Balcao 1
	CECCBAL1->(Lock_Registro(.T.))
	CECCBAL1->ATENDIDO := .T.
	CECCBAL1->NOTA := cNota
	CECCBAL1->SERIE := cSerie
	CECCBAL1->SUBSERIE := nSub
	CECCBAL1->DATAATD  := DATE()
	CECCBAL1->(DBUNLOCK())
	DBCOMMITALL()
	
	SELECT("CECCBAL2")
	DBGOTOP()
	RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
	KEYBOARD(K_ESC)
RETURN(NIL)	

Function AtualizationOfAll(oBrowse)
	LOCAL cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL())
	LOCAL lpri := .T.
	IF !M_QUERY("Deseja atualizar todos os pedido pendentes ?",79)
		RETURN(NIL)
	ENDIF	
	SELECT("CECCBAL1")
	DBSETORDER(2)
	DBGOTOP()
	DO WHILE CECCBAL1->(DBSEEK(.F.)) .AND. !EOF()
		M_MESSAGE("Atualizando arquivos ...",23)
		lPri := .F.
		cNota := STRZERO(CECCBAL1->PEDIDO,10)
		cSerie := " "
		nSub := 0
		SELECT("CECCBAL2")
		SET INDEX TO
		SUBNTX("CECIBAL2.NTX","SUBIBAL2.NTX",STR(CECCBAL1->PEDIDO,10),STR(CECCBAL1->PEDIDO,10),"***",.F.,-1)
		DBSETINDEX("SUBIBAL2.NTX")
	
		CECCBAL2->(DBGOTOP())
		_lPrimeiro := .T.
		DO WHILE CECCBAL2->PEDIDO == CECCBAL1->PEDIDO .AND. !CECCBAL2->(EOF())
			CECCMER->(DBSEEK(CECCBAL2->MERCADORIA))
			CECCMOV->(Inclui_Registro(.T.))
			// Movimentos
			CECCMOV->(Lock_Registro(.T.))
			CECCMOV->NUMDOCTO   := cNota
			CECCMOV->SERIE      := cSerie
			CECCMOV->SUBSERIE   := nSub
			CECCMOV->NUMPED     := CECCBAL2->PEDIDO
			CECCMOV->MERCADORIA := CECCBAL2->MERCADORIA
			CECCMOV->DESCMERC   := CECCMER->DESCRIM
			CECCMOV->REFERENCIA := CECCMER->REFEREM
			CECCMOV->DATAMOV    := DATE()
			CECCMOV->CODLOJA    := CECCBAL2->LOJA
			CECCMOV->LINHA      := CECCMER->CODLINM
			CECCMOV->TIPOMOV    := "S"
			CECCMOV->CODMOV     := "VE"
			CECCMOV->DIVISAO    := CECCMER->CODDIVM
			CECCMOV->ORIGEM     := CECCMER->ORIGEMM
			CECCMOV->UNIDADE    := CECCMER->UNIDADE
			CECCMOV->QUANTMOV   := -CECCBAL2->QTD
			CECCMOV->SALANTMOV  := CECCMER->SALDOEM
			CECCMOV->PRECOMPRA  := CECCMER->PRECCOM
			CECCMOV->TOTVEND    := IF(_lPrimeiro,CECCBAL1->TOTAL,0)
			_lPrimeiro := .F.
			CECCMOV->CUSTOMOV   := ROUND(CECCMER->CMEDM*CECCBAL2->QTD,3)
			CECCMOV->PREVENDA   := CECCMER->PRECVEM
			nDesc := IF(CECCBAL1->VDESCONTO#0,(((CECCBAL2->PRECOU*CECCBAL2->QTD)/CECCBAL1->SUBTOTAL)*CECCBAL1->VDESCONTO),0)
			nDesc := ROUND(nDesc / CECCBAL2->QTD,3)
			CECCMOV->PREVENDIDO := CECCMER->PRECVEM-(ROUND(CECCBAL2->DESCONTO/CECCBAL2->QTD,3) + nDesc)
			CECCMOV->VLDESCITEM := nDesc+ROUND(CECCBAL2->DESCONTO/CECCBAL2->QTD,3)
			_nAliDesc := ROUND((nDesc+ROUND(CECCBAL2->DESCONTO/CECCBAL2->QTD,3)/CECCMER->PRECVEM)*100,2)		
			CECCMOV->ALIDESITEM := _nAliDesc
			CECCMOV->VENDEDOR   := CECCBAL1->VENDEDOR
			CECCMOV->(DBUNLOCK())
			CECCMOV->(DBCOMMIT())
			
			// Lojas
			IF !CECCLOJ->(DBSEEK(STR(CECCBAL2->LOJA,4)+CECCBAL2->MERCADORIA))
				CECCLOJ->(Inclui_Registro(.T.))
			ENDIF
			CECCLOJ->(Lock_Registro(.T.))
			CECCLOJ->SALDOEJ-=CECCBAL2->QTD	
			CECCLOJ->DTUVLOJ:=DATE()
			CECCLOJ->DCUVLOJ:=cNota
			CECCLOJ->(DBUNLOCK())
			CECCLOJ->(DBCOMMIT())
			
			// Mercadoria
			CECCMER->(DBSEEK(CECCBAL2->MERCADORIA))
			CECCMER->(Lock_Registro(.T.))
			CECCMER->SALDOEM-=CECCBAL2->QTD
			CECCMER->DTULTVM:=DATE()
			CECCMER->DCULTVM:=cNota
			CECCMER->(DBUNLOCK())
			CECCMER->(DBCOMMIT())		
					
			SELECT("CECCBAL2")
			DBSKIP()
			
		ENDDO	
		
		CECCFIS->(INCLUI_REGISTRO(.T.))
		CECCFIS->(LOCK_REGISTRO(.T.))
		ceccfis->CLI_FOR  :=  CECCBAL1->CLIENTE    //OK
		cecCFIS->NNOTA    :=  cNota                //OK
		cecCFIS->SERIE    :=  cSerie               //OK 
		cecCFIS->SUBSER   :=  nSub                 //OK 
		cecCFIS->DEMI     :=  DATE()               //OK
		cecCFIS->DENT     :=  CTOD("  /  /    ")     //OK
		cecCFIS->Dsai     :=  DATE()               //OK
		CECCFIS->DATAS    :=  DATE()
		cecCFIS->VLNOT    :=  CECCBAL1->TOTAL      //OK
		cecCFIS->CFO      :=  "512"                //OK
		cecCFIS->CODTRI   :=  1                    //OK
		cecCFIS->ALIICMS  :=  17                   //OK
		cecCFIS->ALIDICMS :=  0                    //OK
		cecCFIS->VLICMS   :=  round(CECCFIS->VLNOT*(17/100),2) //OK
		cecCFIS->VLDICMS  :=  0                    //OK 
		cecCFIS->VLIPI    :=  0 		             //OK
		cecCFIS->FRETE    :=  0                    //OK 
		cecCFIS->SEGURO   :=  0                    //OK
		cecCFIS->BASICMS  :=  CECCBAL1->TOTAL      //OK
		cecCFIS->BASIPI   :=  0                    //OK
		cecCFIS->NLANFIS  :=  0                    //OK
		cecCFIS->CONPAG   :=  0                    //OK
		CECCFIS->(DBUNLOCK())
			
		//Tabela de lojas
		M->MES:="VENM"+STRZERO(MONTH(DATE()),2)+"TL"
		CECTLOJ->(DBSEEK(CECCBAL1->LOJA))
		CECTLOJ->(Lock_Registro(.T.))
		CECTLOJ->TOTVENTL += CECCBAL1->TOTAL
		CECTLOJ->COMIGETL += ROUND(CECCBAL1->TOTAL*(CECTLOJ->PCOMGETL/100),2)
		REPL CECTLOJ->&MES WITH CECTLOJ->&MES + CECCBAL1->TOTAL
		CECTLOJ->(DBUNLOCK())
		
		// Vendedores
		CECCVEN->(DBSEEK(STR(CECCBAL1->VENDEDOR,5)+STR(CECCBAL1->LOJA,4)))
		CECCVEN->(Lock_Registro(.T.))
		CECCVEN->VENMES += CECCBAL1->TOTAL
		CECCVEN->TOTVEN += CECCBAL1->TOTAL
		CECCVEN->COMMES += ROUND(CECCVEN->VENMES*(CECCVEN->PCONIS/100),2)
		CECCVEN->TOTCOM += ROUND(CECCVEN->TOTVEN*(CECCVEN->PCONIS/100),2)
		CECCVEN->(DBUNLOCK())
		
		//Balcao 1
		SELECT("CECCBAL1")
		CECCBAL1->(Lock_Registro(.T.))
		CECCBAL1->ATENDIDO := .T.
		CECCBAL1->NOTA := cNota
		CECCBAL1->SERIE := cSerie
		CECCBAL1->SUBSERIE := nSub
		CECCBAL1->DATAATD  := DATE()
		CECCBAL1->(DBUNLOCK())
		CECCBAL1->(DBCOMMIT())
		DBCOMMITALL()
	ENDDO	
	RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
	IF lPri
		M_DISPLAY("Nao existem arquivos para atender",23)
	ENDIF	
	SELECT("CECCBAL2")
	DBCLOSEAREA()
	ARQNTX("CECCBAL2")
	SELECT("CECCBAL1")
	DBSETORDER(1)
	DBGOTOP()
    IF OBROWSE<>NIL
        oBrowse:refreshAll()
        oBrowse:refreshAll()
    ENDIF
RETURN(NIL)	
