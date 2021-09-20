set date germ
set dele on
clea 
//
SELE 1
USE CECCPAG
index on str(fornecedor,5)+duplicata to ipag
set inde to ipag
//
m_DISPLAY("Aguarde, Processando...",23)
//
Do While .Not. eof()
	//
	cKey:=Str(Fornecedor,5)+Duplicata
	nFor:=CECCPAG->Fornecedor
	Do While ceccpag->Fornecedor==nFor
		cDup    := ceccpag->Duplicata
		nSequen := 0
		Do While ceccpag->Duplicata==cDup
			nSequen := nSequen + 1
			cNewDup := Int(Val(Duplicata))
			cNewDup := StrZero(cNewDup,7)+"/"+StrZero(nSequen,2)
			ceccpag->newduplic:=cNewDup
			DbSkip()
		Enddo
	Enddo
EndDo
dbcloseall()
clea
m_DISPLAY("Aguarde, Processando...",23)
return(NIL)
