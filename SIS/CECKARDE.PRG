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
cCod:=SPACE(14)
nLoc:=0
Box(2,01,06,79,fr,127,3,8)
Box(6,01,20,79,fr,127,3,8)
@ 6,01 SAY 'Ç' COLOR 'W+/W'
@ 6,79 SAY '¶' COLOR 'W+/W'
DO WHILE .T.
	Setcor("b/w,w+/bg,,,b/w")
	@ 24,0
	SETCURSOR(1)
	@ 3,2 SAY 'Mercadoria.:' GET cCod PICT "@!@K" VALID Existe(cCod,'C¢digo N„o Cadastrado !',.F.,'CECCMER',1,'descrim','@!',3,19,.F.) .AND. Existe(cCod,'C¢digo sem movimentos !',.F.,'ceccmov')
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
	aMovs:={0,0}
	aNmov:={0,0}
	aTotloc:={}
	aLocal :={}
	aTmp   :={}
	dLimite:=DATE()-365
	cTelcon:=SAVESCREEN(0,0,24,79)
	@ 20,3     SAY '´' COLOR 'W+/W'
	@ 20,COL() SAY 'Montando Hist¢rico ... ' COLOR 'W+*/W'
	@ 20,COL() SAY 'Ã' COLOR 'W+/W'
	//
	DO WHILE !CECCMOV->(EOF())   // Montar Array pelo movimento gerando saldo anterior
	   //dat_mov = strzero(year(sipcmoa->datam))+strzero(month(sipcmoa->datam))+strzero(day(sipcmoa->datam)) 
		//dat_lim = strzero(year(dLimite))+strzero(month(dLimite))+strzero(day(dLimite)) 
		IF (!EMPTY(nLoc).AND.CECCMOV->CODLOJA#CECTLOJ->CODLOJTL)   //.OR.dat_mov<dat_lim
			CECCMOV->(DBSKIP())
			IF CECCMOV->MERCADORIA#cCod
				EXIT
			ENDIF
			LOOP
		ENDIF
		IF LASTKEY()=27
			Setcor(cCor)
			RESTSCREEN(0,0,24,79,cTela)
			EXIT
		ENDIF
		IF CECCMOV->QUANTMOV > 0
			nOldSd:=nOldSd - CECCMOV->QUANTMOV
			aMovs[1]:=aMovs[1] + CECCMOV->QUANTMOV
			aNmov[1]++
		ELSE
			nOldSd:=nOldSd - CECCMOV->QUANTMOV
			aMovs[2]:=aMovs[2] - CECCMOV->QUANTMOV
			aNmov[2]++
		ENDIF
		IF __nCont<4000
			AADD(aReg1,CECCMOV->(RECNO()))
		ENDIF
		IF __nCont>4000                   /// Estouro do Array
			AADD(aReg2,CECCMOV->(RECNO()))
		ENDIF
		__nCont++
		IF nMode=2
			IF LEN(ALOCAL)=0
				AADD(aLocal,CECCMOV->CODLOJA)
				aTmp:={CECCMOV->CODLOJA}
				AADD(aTotloc,aTmp)
			ELSEIF ASCAN(aLocal,CECCMOV->CODLOJA)=0
				AADD(aLocal,CECCMOV->CODLOJA)
				aTmp:={CECCMOV->CODLOJA}
				AADD(aTotloc,aTmp)
			ELSE                          /// Local Existe !
				aTotloc[(ASCAN(aLocal,CECCMOV->CODLOJA)),2] += CECCMOV->QUANTMOV
				aTotloc[(ASCAN(aLocal,CECCMOV->CODLOJA)),3] += 1
			ENDIF
		ENDIF
		CECCMOV->(DBSKIP())
		IF CECCMOV->MERCADORIA#cCod
			EXIT
		ENDIF
	ENDDO
	// Mostrar 
	IF nMode=2
		aTotloc:=ASORT(aTotloc,,,{ |x,y| x[1] < y[1] })
	ENDIF
	SETCOLOR('W+/BG')
	@ 06,02 SAY "Data     CM Local Documento  Qdt. Mov.   Cus. Mov.   Saldo (Qt)  Saldo (Vl)"
   //////////   01/01/01 12 12345 1234567890 123,122.901 123,567.901 123,567.901 1231,111.34
	SETCOLOR('W+/W')
	ACHOICE(08,05,14,40,aLocal)
	@ 20,02,22,78 BOX '´ Ã³³ ³³ '
	Setcor("b/w,w+/bg,,,b/w")
	@ 20,3 SAY ' Movimentos  : '+STRZERO(__nCont,6)+'         Entradas : '+STRZERO(aNmov[1],6)+'      Sa¡das : '+STRZERO(aNmov[2],6)+'     ' COLOR 'GR+/W'
	@ 21,3 SAY ' Saldo Atual : '+TRANS(nSaldo,'@E 999,999,999')+' Entradas : '+TRANS(aMovs[1],'@E 999,999,999')+' Sa¡das : '+TRANS(aMovs[2],'@E 999,999,999') COLOR 'GR+/W'
	@ 22,3 SAY ' Custo       : '+TRANS(Round(nSaldo*nCusVl,2),'@E 999,999,999.99')+' Saldo In¡cio do Per¡odo : '+TRANS(nOldSd,'@E 999,999,999') COLOR 'GR+/W'
	__nCont:=0
	nCalSd := nOldSd
	IF nMode=2
		cTelprt:=SAVESCREEN(08,00,16,79)
		m_message ( "Imprimindo Hist¢rico Selecionado ...", 23 )
		SET DEVICE TO PRINT
		@ 0,0 SAY CHR(SESC)
		Printcontrol(INKEY(),.T.,nCus,nLoc,dLimite,0)
		nCord:=12
	ELSE
		nCord:=7
	ENDIF
	FOR i=1 TO LEN(aReg1)
		CECCMOV->(DBGOTO(aReg1[i]))
		IF CECCMOV->QUANTMOV >=0
			SETCOR("R/W")
		ELSE
			SETCOR("B/W")
		ENDIF		
		//
		nCalSd := nCalSd + CECCMOV->QUANTMOV
		If CECCMOV->codmov="IV"
			nCalSd := CECCMOV->QUANTMOV
		EndIf
		//
		@ nCord+__nCont,2 SAY DTOC(ceccmov->datamov)+' '+ceccmov->codmov+' '+strzero(ceccmov->codloja,4)+' '+ceccmov->numdocto+' '+;
		TRANS(ceccmov->quantmov,'@E@R 999,999.999')+' '+TRANS(ceccmov->customov,'@E@R 99999999.99')+' '+;
		TRANS(nCalSd,'@E@R 999,999.999')+' '+TRANS(Round(nCalSd*(ceccmov->customed),2),'@E@R 999999999.99')
		//
		IF nMode=2
			@ PROW(),083        SAY NumOpM
			@ PROW(),PCOL()+001 SAY IF(LEN(aTotloc)<i,' ',' '+STR(aTotloc[i,1],2)+'    '+STRZERO(aTotloc[i,3],4)+'    '+TRANS(aTotloc[i,2],'@E 999,999,999'))  	
		ENDIF
		__nCont++
		IF (nMode=1.AND.__nCont>12.AND.i<LEN(aReg1))
			__nCont:=0
			@ 24,1 SAY 'TECLE <-Ù'
			TONE(350,2)
			INKEY(0)
			@ 07,02 CLEAR TO 19,78
			@ 24,0
		ENDIF
		IF nMode=2
			IF !Printcontrol(INKEY(),(PROW()>58),nCus,nLoc,dLimite)
				EXIT
			ENDIF
		ENDIF
	NEXT
	FOR i=1 TO LEN(aReg2)
		IF nMode=2
			IF !Printcontrol(INKEY(),(PROW()>58),nCus,nLoc,dLimite)
				EXIT
			ENDIF
		ENDIF
		sipcmoa->(DBGOTO(aReg2[i]))
		IF ceccmov->Quantmov>=0
			SETCOR("R/w")
		ELSE
			SETCOR("B/w")
		ENDIF		
		If ceccmov->codmov="IV"
			nCalSd:= ceccmov->quantmov
		Else
			nCalSd:=nCalSd + ceccmov->quantmov
			nCalSd:=nCalSd + ceccmov->quantmov
		EnDiF
		//
		@ nCord+__nCont,2 SAY DTOC(ceccmov->datamov)+' '+ceccmov->codmov+' '+strzero(ceccmov->codloj,4)+' '+ceccmov->numdocto+' '+;
		TRANS(ceccmov->quantmov,'@E@R 999,999.999')+' '+TRANS(ceccmov->customov,'@E@R 99999999.99')+' '+;
		TRANS(nCalSd,'@E@R 999,999.999')+' '+TRANS(Round(nCalSd*(ceccmov->customed),2),'@E@R 999999999.99')
		//
		__nCont++
		IF (nMode=1.AND.__nCont>12.AND.i<LEN(aReg2))
			__nCont:=0
			@ 24,1 SAY 'TECLE <-Ù'
			TONE(350,2)
			INKEY(0)
			@ 07,02 CLEAR TO 19,78
			@ 24,0
		ENDIF
	NEXT
	IF nMode=2
		IF PROW()>55
			EJECT
			Printcontrol(INKEY(),.T.,nCus,nLoc,dLimite)
		ENDIF
		@ PROW()+2,3 SAY ' Resumo do Historico : '
		@ PROW()+2,3 SAY ' Movimentos  : '+STRZERO(LEN(aReg1)+LEN(aReg2),6)+'         Entradas : '+STRZERO(aNmov[1],6)+'      Sa¡das : '+STRZERO(aNmov[2],6)+'     '
		@ PROW()+1,3 SAY ' Saldo Atual : '+TRANS(nSaldo,'@E 999,999,999')+' Entradas : '+TRANS(aMovs[1],'@E 999,999,999')+' Sa¡das : '+TRANS(aMovs[2],'@E 999,999,999')
		@ PROW()+1,3 SAY ' Custo       : '+TRANS(round(nSaldo*nCusVl,2),'@E 999,999,999.99')+' Saldo In¡cio do Per¡odo : '+TRANS(nOldSd,'@E 999,999,999')
		EJECT
		SET DEVICE TO SCREEN
		RESTSCREEN(08,00,16,79,cTelprt)
	ENDIF
	@ 24,1 SAY 'FIM DE HISTàRICO - TECLE <-Ù'
	TONE(290,3)
	INKEY(0)
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

FUNCTION PRINTCONTROL(nKey,lHead,nCus,nLoc,dLimite)
STATIC nPagina,lCancel
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
	@ 07,01 SAY "Codigo :"+sipcmat->cdmt+" -> "+sipcmat->dsc1+sipcmat->dsc2
	@ 07,80 SAY "Local  :"+IF(EMPTY(nLoc),'00 GERAL',IF(SSLC==1,SIPTLOC->SUBL,STR(SIPTLOC->COD))+' '+siptloc->dsc)
	@ 08,01 SAY "Periodo:"+DTOC(dLimite)+' A '+DTOC(DATE())
 //@ 09,01 SAY '  Data   CM Local Documento    Entrada      Saida       Saldo        Custo '+;
	@ 09,01 SAY 'Data     CM Local Documento  Qdt. Mov.   Cus. Mov.   Saldo (Qt)  Saldo (Vl)'+;
	IF(nCus==1,'R$  ','US$ ')+'N§ O.Producao  LC  N§Mov.  Cus.Tot.Local '
	@ 10,01 SAY REPL("-",132)
	__nCont:=0
ENDIF
RETURN(.T.)