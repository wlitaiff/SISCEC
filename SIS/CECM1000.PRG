// Sistemas de Controle de Estoque Comercial
// W&R Informatica Ltda
// 26 de Dezembro de 1996
// Roberto Falcao Rocha
// Acerto de Estoque

#INCLUDE "INKEY.CH"

LOCAL cCor := SETCOR(m->cEdicao),;
		nCursor := SETCURSOR(1),;
		cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
		nReg := RECNO(),;
		nLoja:=0,;
		nVendedor:=0,;
      bPass,;
      bUsuario,;
		aDescItem[50],;
		aCodigo[50],;
		aPrecoU[50],;
		aCodigoS[50],;
		aPrecoUS[50],;
      aSaldo[50],;
      Saldo,;
		SaQuantidade[50],;
		aDescItemS[50],;
		aQuantidade[50],;
		cDoc,;
		xTotE:=0,;
		xTotS:=0,;
		_SAI:=.F.,;
      GetList:={},;
		nI,;
      nPage:=1,;
      lCab:=.T.,;
      n:=0,;
      nLin,;
      cTipo:=space(1),;
      nCliente:=1,;
      cCliente,;
      cCGC,;
      cSuframa,;
      cEndereco,; 
      cInscEst,;
      cVendedor,;
      cObs1:=space(65),;
      cObs2:=space(75),;
      nTotal:=0,;
      nSaldoDis:=0,;
      cTelefone,;
		nX

// Verificando arquivos
IF !ARQNTX("CECTLOJ",.F.) .OR. ;
	!ARQNTX("CECCVEN",.F.) .OR. ;
   !ARQNTX("CECCPAS",.F.) .OR. ;
	!ARQNTX("CECCSET",.F.) .OR. ;
   !ARQNTX("CECCCLI",.F.) .OR. ;
   !ARQNTX("CECCLOJ",.F.) .OR. ;
   !ARQNTX("CECLOGO",.F.) .OR. ;
   !ARQNTX("CECCMER",.F.)
   DBCLOSEALL()
	RETURN
ENDIF	

nLoja := 1
 
AFILL(aCodigo,SPACE(16))
AFILL(aQuantidade,0)
AFILL(aPrecoU,0)
AFILL(aSaldo,0)
AFILL(aDescItem,0)
	
IF FILE("NPEDIDO.MEM")
	RESTORE FROM NPEDIDO ADDITIVE
ELSE
	M->nPed:=0
	SAVE ALL LIKE NPED TO NPEDIDO
ENDIF

***************
bPass :=ALLTRIM(PASS())
SELECT("CECCPAS")
DBSETORDER(2)

IF !DBSEEK(bPass) .or. LASTKEY() = 27 .or. empty(bPass) .or. LEN(bPass) = 1
   M_DISPLAY("Usuario nao Autorizado",79)
   SETCURSOR(nCursor)
   SETCOLOR(cCor)
   RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
   DBCLOSEALL()
   RETURN(NIL)
ELSE
   bUsuario := Criptografa(CECCPAS->NOME,"HAWK",.F.)
ENDIF           
**********************

_SAI := .f.

DO WHILE .T.

	IF !_SAI
		AFILL(aCodigo,SPACE(16))
		AFILL(aQuantidade,0)
		AFILL(aPrecoU,0)
      AFILL(aSaldo,0)
		AFILL(aDescItem,0)
	ENDIF	
	RESTORE FROM NPEDIDO ADDITIVE
	m->nPed++			
	SAVE ALL LIKE NPED TO NPEDIDO
   BOX(03,01,08,79,M->FR,127,3,8)
	BOX(09,00,24,79,M->FR,127,3,8)
   @ 10,01 SAY "[Mercadoria           ][Quantidade]         [Preco Unit.]      [Saldo Atual]"
	@ 22,01 SAY "[                                                            ]"
	@ 23,01 SAY "[                                                            ]"
	cHora := TIME()
   cDoc := STRZERO(M->NPED,8)
	@ 04,02 SAY "Documento No.:"+cDoc
   @ 05,02 SAY "Tipo Movimento (E/S):";                
                GET cTipo;
                PICTURE "@!";
                VALID  (cTipo$"ES")  

	@ 06,02 SAY "Vendedor..:";		  
			  GET nVendedor;
			  PICTURE "@K 99999";
			  VALID !EMPTY(nVendedor) .AND.;
			  Existe(STR(nVendedor,5)+STR(nLoja,4),"Vendedor nÆo cadastrado ou nÆo ‚ desta loja",.F.,"CECCVEN",1,"NOMVEN","@!",ROW(),COL()+1)

   @ 07,02 SAY "Cliente:";
           GET nCliente;
           PICTURE "@K 99999";
           VALID !EMPTY(nCliente) .AND.;
           Existe(nCliente,"Cliente nÆo cadastrado",.F.,"CECCCLI",1,"NOMECLC","@!",ROW(),COL()+1) 
	READ

	IF LASTKEY()==27
		SETCURSOR(nCursor)
		SETCOLOR(cCor)
		RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
		DBCLOSEALL()
		RETURN(NIL)
	ENDIF			  
		
	BOX(09,00,24,79,M->FR,127,3,8)
   @ 10,01 SAY "[Mercadoria           ][Quantidade]         [Preco Unit.]      [Saldo Atual]"
	@ 22,01 SAY "[                                                            ]"
	@ 23,01 SAY "[                                                            ]"
	nI := 1
	_SAI := .F.
	xTotE:=0
   SET CONFIRM ON
	DO WHILE .T.
		@ 11,02 GET aCodigo[nI];
				  PICTURE "@K@!"; 
				  VALID !EMPTY(aCodigo[nI]) .AND.;
				  Existe(aCodigo[nI],"Mercadoria nÆo cadastrada",.F.,"CECCMER",1,"DESCRIM","@!",22,2) .AND.;
                                  Existe(aCodigo[nI], ,.F.,"CECCMER",1,"SALDOEM","@R@K 99,999.999",11,63) .AND.;
                                  EVAL({||aPrecoU[nI] := CECCMER->PRECVEM,.T.})

             //   IF cTipo="A"
             //      @ 11,25 GET aQuantidade[nI];
             //                     PICTURE "@R@K 99,999.999";
             //                     VALID aQuantidade[nI] >= 0  
             //                    // VALID EVAL({||xTotE += aPrecoU[nI] * aQuantidade[nI],.T.})  // !EMPTY(aQuantidade[nI])
             //   ELSE

                @ 11,25 GET aQuantidade[nI];
                                  PICTURE "@R@K 99,999.999";
                                  VALID   (aQuantidade[nI]) > 0 .and.;
                                  IF(ctipo="S",Saldodis(aQuantidade[nI],aCodigo[nI]),.T.)
                                  // VALID EVAL({||xTotE += aPrecoU[nI] * aQuantidade[nI],.T.})  // !EMPTY(aQuantidade[nI])



                @ 11,45 GET aPrecoU[nI];
                                  PICTURE "@R@K 99,999.999";
                                  VALID !EMPTY(aPrecoU[nI]) // .AND. ;
                                //  EVAL({||xTotE += aPrecoU[nI] * aQuantidade[nI],.T.}) 

		READ
                @ 11,63 say "          "

		IF LASTKEY()#27
			nI ++ 
		ENDIF	
		IF LASTKEY()=27 .OR. IF(nI==51,EVAL({||M_DISPLAY("LIMITE DE ITENS ESGOTADO",79),.T.}),.F.)
			IF !M_QUERY("Confirma estes itens ?",23)
				RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
				_sai := .T.
            SETCURSOR(nCursor)
            SETCOLOR(cCor)
            RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
            DBCLOSEALL()
            RETURN(NIL)
			ELSE
				IF (nI-1) == 0
               M_DISPLAY("Este movimento nao possue itens, verifique !!!",79) 
					_sai := .T.
				ENDIF	
				EXIT
			ENDIF	
		ENDIF	
        SCROLL(11,02,21,27,-1)            
	ENDDO			  
	
   IF _SAI
      LOOP
   ENDIF 

 IF M_QUERY("Confirma a impressao ?",23)

     BOX(02,01,05,79,M->FR,127,3,8)
     SETCURSOR(1)
     @ 03,03 SAY "Obs..:" Get cObs1 pict "@S60"
     @ 04,03 say ".....:" get cObs2 pict "@S60"
     Read
     SETCURSOR(0)

     M_MESSAGE("Aguarde imprimindo pedido",23)
     set device to printer

     CECCCLI->(DBSEEK(ncliente))
     cCliente := CECCCLI->NOMECLC
     cCGC := CECCCLI->CGCCPFC
     cSuframa := CECCCLI->INSCSUF
     cEndereco := CECCCLI->ENDEREC
     cInscEst := CECCCLI->INSESTC
     cTelefone := CECCCLI->TELEFOC

     if cTipo="E"
        vTexto:="TIPO DO MOVIMENTO : ENTRADA"
     Else
        vTexto:="TIPO DO MOVIMENTO : SAIDA  "
     Endif

    //    Else
    //        vTexto:="TIPO DO MOVIMENTO : ACERTO "
    //    Endif
     

     cCab:="FICHA EXCLUSIVA PARA ACERTO DE ESTOQUE"

     IF lCab
       Cabecalho(nPage,cCab+" - "+STRZERO(nPed,10))
       @ 07,01 SAY chr(14)+vTexto
       @ 09,01 SAY chr(15)+"Vendedor:"+strzero(nVendedor,3)+" - "+bUsuario
       @ 10,01 SAY chr(14)+"Cliente.:"+ALLTRIM(STR(CECCCLI->CODIGOC,5))+"-"+ALLTRIM(cCliente)
       @ 11,01 SAY chr(15)+"Endereco:"+ALLTRIM(cEndereco)+" - Fone.:"+ALLTRIM(cTelefone)
       @ 12,01 SAY chr(15)+"CGC:"+TRANS(cCGC,"@r 99.999.999/9999-99")+" - Insc. Est.:"+ALLTRIM(cInscEst)+" - Suframa.:"+ALLTRIM(cSuframa)+chr(15)+" "
       @ 13,01 SAY chr(15)+REPL("-",132)
       @ 14,01 SAY "MERCADORIA       DESCRICAO                                     QUANTIDADE      UNIDADE      UNITARIO          TOTAL          DESCONTO"
       @ 15,01 SAY REPL("-",132)
       nLin := 16
       lCab := .F.
     endif

    ntotal:=0
    FOR N:=1 TO (nI-1)

      CECCMER->(DBSEEK(aCodigo[N]))
  
      @ nLin,01  SAY aCodigo[n]
      @ nLin,18  SAY CECCMER->DESCRIM 
      @ nLin,80  SAY CECCMER->UNIDADE
      @ nLin,64  SAY aQuantidade[n]
      @ nLin,88  SAY aPrecoU[n]
      @ nLin,103 SAY aPrecoU[n]*aQuantidade[n]
      nTotal:=nTotal+(aPrecoU[n]*aQuantidade[n])
      nLin++
    Next
    @ nLin+01,95 SAY "Total :" 
    @ nLin+01,103 SAY nTotal
    @ nLin+02,01 SAY CHR(18)+PADR("OBS: "+cObs1,80,"*")
    @ nLin+03,01 SAY CHR(18)+PADR(cObs2,80,"*")
    EJECT
    SET DEVICE TO SCREEN
    SETCURSOR(nCursor)
    SETCOLOR(cCor)
    RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
    DBCLOSEALL()
    RETURN(NIL)
 Endif
  
ENDDO
RETURN(NIL)


Function SaldoDis(nQt,pmercadoria)
  local lStatus:=.T.
  LOCAL cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL())
     IF CECCMER->(!EOF())
        IF !CECCMER->(DBSEEK(pmercadoria)) .OR.;
                (CECCMER->SALDOEM - (CECCMER->CAUTELA)) < nQt
                 // Alterado 23/09/98, foi tirado: + CECCMER->QTDPED
                 lStatus:=.F.
                 SETCURSOR(0)
                 M_DISPLAY("Saldo insuficiente",79)
                 BOX(10,10,15,60,M->FR,127,3,8)
                 nSaldoDis := CECCMER->SALDOEM - (CECCMER->CAUTELA)
                 @ 11,12 SAY [       SALDO ATUAL] + TRANS(CECCMER->SALDOEM, [@E@R 99,999.99])
                 @ 12,12 SAY [CAUTELAS PENDENTES] + TRANS(CECCMER->CAUTELA, [@E@R 99,999.99])
                 //  @ 13,12 SAY [  PEDIDO PENDENTES] + TRANS(CECCMER->QTDPED,  [@E@R 99,999.99])
                 @ 13,12 SAY [  SALDO DISPONIVEL] + TRANS(nSaldoDis,        [@E@R 99,999.99])
                 INKEY(0)
                 RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
                 SETCURSOR(1)
        endif
     Endif

Return(lStatus)
