local cMercadoria,;
		nSaldoEstoq,;
		dDtUltCompra,;
		dDtUltVenda ,;
		cDoctoCompra,;
		cDoctoVenda 
set proce to wrlib	
IF !ARQNTX("CECCMER",.F.) .OR. ;
	!ARQNTX("CECCLOJ",.T.)
	DBCLOSEALL()
	RETURN
ENDIF	
SELECT("CECCLOJ")
ZAP
//
SELECT("CECCMER")
DO WHILE !EOF()
	nLoja:=1
	cChave:=str(nloja,4)+codigom
	//
	cMercadoria :=Codigom
	nSaldoEstoq :=SaldoEM
	dDtUltCompra:=Dtultcm
	dDtUltVenda :=Dtultvm
	cDoctoCompra:=Dcultcm
	cDoctoVenda :=Dcultvm
	//
	If SaldoEm = 0
		DbSkip()
		Loop
	Endif
	Select("CECCLOJ")
	//If !DbSeek(cChave)
		IF Inclui_Registro(.T.)
			Lock_Registro(.T.)
			CECCLOJ->CODILOJ := nLoja
			CECCLOJ->MERCLOJ := CMERCADORIA
			CECCLOJ->DTUCLOJ := dDtultCompra 
			CECCLOJ->DTUVLOJ := dDTultVenda
			CECCLOJ->DCUCLOJ := cDoctoCompra
			CECCLOJ->DCUVLOJ := cDoctoVenda
			CECCLOJ->SALDOEJ := nSaldoEstoq
			DBUNLOCK()
			DBCOMMIT()
		ENDIF
	//EndIf
	SELECT("CECCMER")
	DbSkip()
EndDo
dbcloseall()
return(nil)