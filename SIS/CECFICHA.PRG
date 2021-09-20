#include "HAWK.CH"
LOCAL Getlist:={},cCod,cCus,cCor,cTela,cTelcon,cTelprt
LOCAL aTotLoc,aReg1,aReg2,aMovs,aNmov,aTmp,aLocal
LOCAL nSaldo,i,nOldSd,nCus,nTsal,nCalSd,nMode,dLimite,dat_mov,dat_lim,nCusVl
cCor :=Setcor()
cTela:=SAVESCREEN(0,0,24,79)
//
// Abrir Arquivos
//
IF !ARQNTX("CECCMER",.F.) .OR. ;
	!ARQNTX("CECCMOV",.F.) .OR. ;
	!ARQNTX("CECCLOJ",.F.) .OR. ;
	!ARQNTX("CECCFOR",.F.) .OR. ;
	!ARQNTX("CECTLOJ",.F.) 
	DBCLOSEALL()
	RETURN
ENDIF
//
cCod:=SPACE(16)
nLoc:=0
Box(2,01,06,79,fr,127,3,8)
Box(6,01,20,79,fr,127,3,8)
@ 6,01 SAY 'Ç' COLOR 'W+/W'
@ 6,79 SAY '¶' COLOR 'W+/W'
SELECT("CECCMOV")
DBSETORDER(3)
DO WHILE .T.
	Setcor("b/w,w+/bg,,,b/w")
	@ 24,0
	SETCURSOR(1)
	@ 3,2 SAY 'Mercadoria.:' GET cCod PICT "@!@K" VALID Existe(cCod,'C¢digo N„o Cadastrado !',.F.,'CECCMER',1,'descrim','@!',ROW(),COL()+1,.F.) .AND. Existe(cCod,'C¢digo sem movimentos !',.F.,'ceccmov',3)
	@ 4,2 SAY 'Loja.......:' GET nLoc PICT '9999' VALID VerifLoc(nLoc,cCod)
	READ
	SETCURSOR(0)
	IF LASTKEY()=27
		Setcor(cCor)
		RESTSCREEN(0,0,24,79,cTela)
		EXIT
	ENDIF
	@ 04,35 SAY 'Referencia: ' + ceccmer->REFEREM
	@ 05,02 SAY 'Origem    : ' + if(ceccmer->origemm="N","NACIONAL","IMPORTADO")
	//
	IF (nMode:=ALERT(" Imprime Hist¢rico ?",{" N„o "," Sim "}))=0
		LOOP
	ENDIF
	nCusVl:=CECCMER->CMEDM     // CUSTO MEDIO
	nSal_Inicio := 0
	nOldSd:=nSaldo:= CECCMOV->SALANTMOV
	__nCont:=0
	aReg1:={}
	aReg2:={}
	aMovs:={}
	aNmov:={}
	aTotloc:={}
	aLocal :={}
	aTmp   :={}
	dLimite:=DATE()-365
	cTelcon:=SAVESCREEN(0,0,24,79)
	@ 20,3     SAY '´' COLOR 'W+/W'
	@ 20,COL() SAY 'Montando Hist¢rico ... ' COLOR 'W+*/W'
	@ 20,COL() SAY 'Ã' COLOR 'W+/W'
	//
	SELECT("CECCMOV")
	dbseek(ccod)
	nQTM := nCTM := nDTM := 0
	nPagina := 0
	LCAB := .T.
	if nMode==2
		SET DEVICE TO PRINT
	ENDIF	
	DO WHILE CECCMOV->MERCADORIA == CCOD .AND. !CECCMOV->(EOF())   // Montar Array pelo movimento gerando saldo anterior
		IF LASTKEY()=27
			Setcor(cCor)
			RESTSCREEN(0,0,24,79,cTela)
			if nMOde == 2
				set device to screen
			ENDIF	
			EXIT
		ENDIF
		if nMode==2
		IF LCAB 
			nPagina ++
			SET DEVICE TO PRINT
			@ PROW(),PCOL() SAY CHR(18)	
		   @ 01,79-LEN(_PAGINA(nPagina))  say _PAGINA(nPagina)
			@ 02,01 SAY PADC("FICHA KARDEX",79)
		   @ 02,79-len(_DATA) say _DATA
		   @ 03,79-LEN(_HORA) SAY _HORA
			@ 04,01 SAY REPL("-",79)
			@ 05,01 SAY "MERCADORIA.:"+alltrim(cCod)+"-"+CECCMER->DESCRIM
			@ 06,01 SAY REPL("-",79)
			@ 07,01 SAY "DATA       LJ CM DOCUMENTO       QUANTIDADE SALDO"
			@ 08,01 SAY REPL("-",79)
			NLIN := 9
			LCAB := .F.
		ENDIF	
		ENDIF	
		IF __nCont<4001
			IF NMODE==2
				@ nLin,01 SAY DATAMOV
				@ NLIN,12 SAY STRZERO(CODLOJA,2)
				@ NLIN,15 SAY CODMOV
				@ NLIN,18 SAY NUMDOCTO+" "+SERIE+" "+STRZERO(SUBSERIE,2)
				@ NLIN,34 SAY QUANTMOV
				@ NLIN,45 SAY If(TIPOMOV="A",QUANTMOV,SALANTMOV+QUANTMOV)
				NLIN++
				IF NLIN>60
					LCAB := .T.
				ENDIF			
			ENDIF	
			AADD(aReg1,{DATAMOV,NUMDOCTO+" "+SERIE+" "+STRZERO(SUBSERIE,2), ;
				         CODMOV,QUANTMOV,CUSTOMOV,PREVENDA,PREVENDIDO,VLDEScITEM,;
							If(TIPOMOV="A",QUANTMOV,SALANTMOV+QUANTMOV),SALANTMOV,VENDEDOR,USUARIO})
			nQTM += QUANTMOV
			nCTM += CUSTOMOV
			nDTM += VLDESCITEM				
		ENDIF
		IF __nCont>4000                   /// Estouro do Array
			IF NMODE==2
				@ nLin,01 SAY DATAMOV
				@ NLIN,12 SAY STRZERO(CODLOJA,2)
				@ NLIN,15 SAY CODMOV
				@ NLIN,18 SAY NUMDOCTO+" "+SERIE+" "+STRZERO(SUBSERIE,2)
				@ NLIN,34 SAY QUANTMOV
				@ NLIN,45 SAY If(TIPOMOV="A",QUANTMOV,SALANTMOV+QUANTMOV)
				NLIN++
				IF NLIN>60
					LCAB := .T.
				ENDIF			
			ENDIF	
			AADD(aReg2,{DATAMOV,NUMDOCTO+" "+SERIE+" "+STRZERO(SUBSERIE,2), ;
				         CODMOV,QUANTMOV,CUSTOMOV,PREVENDA,PREVENDIDO,VLDEScITEM,;
							If(TIPOMOV="A",QUANTMOV,SALANTMOV+QUANTMOV),SALANTMOV,VENDEDOR,USUARIO})
			nQTM += QUANTMOV
			nCTM += CUSTOMOV
			nDTM += VLDESCITEM								
		ENDIF
		__nCont++
		CECCMOV->(DBSKIP())
	ENDDO
	IF __nCont<4000
		AADD(aReg1,{NIL,"TOTALIZACAO",NIL,nQTM,nCTM,NIL,NIL,nDTM,NIL,NIL,NIL,NIL})
	ELSE	
		AADD(aReg2,{NIL,"TOTALIZACAO",NIL,nQTM,nCTM,NIL,NIL,nDTM,NIL,NIL,NIL,NIL})
	ENDIF	
	IF NMODE==2
		@ NLIN,01 SAY REPL("-",79)
		SET DEVICE TO SCREEN
	ENDIF	
	// Mostrar 
	aCab := { "DataMov",;
	"Documento",;
	"Mov.",;
	 "Qt.Mov.",;
	 "Custo Mov.",;
	  "Pr.Venda",;
	 "Pr.Vendido",;
	 "Desconto",;
	 "Saldo atual",;
	 "Saldo anterior",;
	 "Vendedor",;
	 "Usuario" }
				 
	aPic := { "@D",;
	 "@!",;
	 "@!",;
	 "@R 99,999.9999",;
	 "@R 99,999,999.99",;
	 "@R 999,999.99",;
	 "@R 99,999,999.99",;
	 "@R 99,999,999.99",;
	 "@R 99,999.9999",;
	 "@R 99,999.9999",;
	 "@R 99999",;
	 "@!" }
				 
	cObs := "Entradas:                    Saidas:                  Saldo: "  			 

	HBrowseAR(02,00,24,79,"Mercadoria:"+cCOD+"-"+ALLTRIM(ceccmer->Descrim),aCab,aReg1,aPic)
	IF __nCont>4000
		HBrowseAR(02,00,24,79,"Mercadoria:"+cCOD+"-"+ALLTRIM(ceccmer->Descrim),aCab,aReg2,aPic)
	ENDIF	
	//
	RESTSCREEN(0,0,24,79,cTelcon)
ENDDO
DBCLOSEALL()
RETURN

FUNCTION VERIFMAT(cCod)
IF !ceccmer->(DBSEEK(cCod))
	ALERT('Mercadoria N„o Cadastrada !')
	RETURN(.F.)
ENDIF
IF !ceccmov->(DBSEEK(ceccmer->cdmt))
	ALERT('Mercadoria sem movimentos !')
	RETURN(.F.)
ENDIF
@ 3,28 SAY ceccmer->descrim
RETURN(.T.)

FUNCTION VERIFLOC(nLoc,cCod)
IF EMPTY(nLoc)
	@ 4,16 SAY 'Geral'+SPACE(25)
	RETURN(.T.)
ENDIF
IF !cectloj->(DBSEEK(nLoc))
	ALERT('Loja N„o Encontrada !')
	RETURN(.F.)
ENDIF
IF !ceccloj->(DBSEEK(STR(nloc,4)+cCod))
	ALERT('Material Sem Saldo Neste Local !')
	//RETURN(.F.)
ENDIF
@ 4,19 SAY cectloj->nomlojtl
RETURN(.T.)

FUNCTION PRINTCONTROL(lHead)
STATIC nPagina,lCancel,nLin
IF !lCancel=NIL
	RETURN(.F.)
ENDIF
IF (nPagina=NIL.OR.PCOUNT()=6)
	nPagina:=0
ENDIF
IF nKey=27
	IF Para_Impressao()
		lCancel=.F.
		RETURN(.F.)
	ENDIF
ENDIF		
IF lHead
	nPagina++
	@ 01,01  SAY &sLog->l1
   @ 01,PCOL()+3 SAY sNom
   @ 01,133-LEN(_PAGINA(nPagina))  say _PAGINA(nPagina)
   @ 02,01  say &sLog->l2
   @ 03,01  say &sLog->l3
   @ 03,133-len(_DATA) say _DATA
   @ 04,01  say &sLog->l4
   @ 04,38 SAY CHR(27)+"W"+CHR(1)+"  F I C H A   C A R D E X"+CHR(27)+"W"+CHR(0)
   @ 05,01  say &sLog->l5
   @ 05,133-LEN(_HORA) SAY _HORA
   @ prow(),pcol() say chr(27)+chr(50)
   @ 06,01 SAY REPLICATE("-",132)
	@ 07,01 SAY "Codigo :"+CECCMER->CODIGOM+" -> "+CECCMER->DESCRIM
	@ 07,80 SAY "Local  :"+IF(EMPTY(nLoc),'00 GERAL',IF(SSLC==1,SIPTLOC->SUBL,STR(SIPTLOC->COD))+' '+siptloc->dsc)
	@ 08,01 SAY "Periodo:"+DTOC(dLimite)+' A '+DTOC(DATE())
	@ 09,01 SAY 'Data     CM Local Documento  Qdt. Mov.   Cus. Mov.   Saldo (Qt)  Saldo (Vl)'
	@ 10,01 SAY REPL("-",132)
	nlin := 11
	__nCont:=0
ENDIF

RETURN(.T.)