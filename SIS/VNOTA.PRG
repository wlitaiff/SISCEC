clear scree
if !file("ARQ_ITE.NTX")
	use arq_ite
	index on nfiscal to arq_ite
endif	

if !file("VNOTA.NTX")
	use sipcmod
	index on nnotad to vnota
endif	
use
if ALERT("Deseja Imprimir Notas ?",{"Sim","Nao"})==1
	imp:=.t.
else
	imp:=.f.	
endif
if lastkey()==27
	return
endif

sele 2
	use arq_ite
	set index to arq_ite
sele 1
	use sipcmod
	set index to vnota 
	
//if !imp
//	repl all ncad with space(1)	
//endif	
/*
lin:=100	
if imp
	set device to print
endif	
do while !eof()
	if lin>60
		@ 03,10 say "NOTA--------------        ITENS-(SIP)        ITENS-(ANT)" 
		lin:=05
	endif
	nota:=sipcmod->nnotad
	itemsip:=itemold:=0
	enc:=.t.
	/////sistema antigo
	sele 2
	if dbseek(nota)
		do while nfiscal==nota 
			itemold++
			dbskip()
		enddo
	else 
		enc:=.f.	
	endif
	sele 1
	///////////////////
	dbskip()
	do while sipcmod->nnotad==nota
		if tipregd==2
			itemsip++
		endif	
		dbskip()
	enddo
	if itemsip#itemold
		lin++
		@ lin,10 say nota 
		@ lin,36       say itemsip pict "@E 999,999,999"
		if enc
			@ lin,55       say itemold pict "@E 999,999,999"
		else
			@ lin,55       say 'N. ENCONTROU CADASTRADO'
			xreg:=recno()
			repl all ncad with '*' for nnotad==nota .and. tipregd==2
			dbgoto(xreg)
		endif	
	endif	
enddo	
set device to screen
return*/
//if imp
//	set device to screen
//else
set devi to print
	dbgotop()
	nota:=nnotad
	lin:=100
	do while !eof()	
		if lin > 58 
			@ 03,01 say 'NOTA FISCAL   SERIE   PARTNUMBER----   N.-FR'
			lin:=4
		endif	
		if sipcmod->ncad == '*'
			if sipcmod->nnotad # nota
				lin ++
				nota := sipcmod->nnotad
			endif
			lin++
			@ lin,2  say sipcmod->nnotad
			@ lin,15 say sipcmod->sernotd+'/'+alltrim(strzero(sipcmod->subserd,2))
			@ lin,23 say sipcmod->codited
			@ lin,40 say str(sipcmod->nboleto,5)
		endif
		dbskip()
	enddo
set devi to scree	

return
	
 	