Local	loc,;
		ndc,;
		uni,;
		grava,;
		cTela,;
		qt1,;
		qt2,;
		qt3,;
		dta,;
		cod,;
		ct
local getlist:={}		 
//
IF  !ARQNTX("CECCINV",.F.) .OR. ;
    !ARQNTX("CECCLOI",.F.) .OR. ;
    !ARQNTX("CECTLOJ",.F.) .OR. ;
	 !ARQNTX("CECTRINV",.F.)
    DbCloseAll()
	 Return(nil)
ENDIF
//
cTela := SAVESCREEN(01,01,22,78)
Box(07,05,21,74,"ÖÄ·º½ÄÓº ",atoattr("W+/W"),3,6)
@ 07,26 SAY " Lan‡amento de Invent rio " color "GR+/B,W+/BG"
//
ct := alert( 'Qual a contagem', {' 1¦ ',' 2¦ ',' 3¦ ', ' Cancela'} )
//
If ct = 4
   DBCLOSEALL()
	RESTSCREEN(01,01,22,78,cTela)	
	RETURN(NIL)
EndIf

SetCor("B/W,W+/BG,,,B/W") 
cod  := space(14)
loc  := 0
uni  := space(3)
dta  := date()
SELECT("CECTRINV")
DO WHILE .T.
	SETCURSOR(1)
	@ 08,07 say "C¢digo:"  get cod pict "@!K"  valid Existe(cod,"C¢digo N„o Cadastrado...",.F.,"CECCINV",1,"DESCRIM","@!",8,30) .AND. !empty(cod)      
	@ 08,63 say "Unid..:"
	@ 09,07 say "Ficha.:"  get ndc pict "@E 999,999"  
	@ 10,07 say "Loja..:"  get loc pict "9999"  valid (Existe(loc,"Loja N„o Cadastrada...",.F.,"CECTLOJ",1,"NOMLOJTL","@!",10,20) .AND. !EMPTY (loc) )
	@ 10,58 say "Data..:"		   			
	Read
	If Lastkey()=27
		RESTSCREEN(01,01,22,78,cTela)	
		DbCloseAll()
		return (nil)
	EndIf
	SELECT("CECTRINV")
	If !(DbSeek(Str(loc,4)+cod))
		grava:=.T.      // Inclui no TRINV
		dta := date()
		uni := space(3)
		qt1 := 0
		qt2 := 0
		qt3 := 0
	Else
		grava:=.F.    // ja existe retorna com os dados
		qt1 := CECTRINV->quant1 
		qt2 := CECTRINV->quant2 
		qt3 := CECTRINV->quant3
		dta := CECTRINV->data    
		uni := CECTRINV->unidade
		ndc := CECTRINV->nficha
	EndIf	
	//
	@ 11,06 to 11,73 color "W+/W"
	@ 17,06 to 17,73 color "W+/W"				
	@ 11,05 say 'Ç'  color "W+/W"
	@ 11,74 say '¶'  color "W+/W"
	@ 17,05 say 'Ç'  color "W+/W"
	@ 17,74 say '¶'  color "W+/W"
	//
   @ 08,63   	 say "Unid.: "             get uni pict "!!!" Valid uni == (CECCINV->UNIDADE)
	@ 09,07      say "Ficha.:"             get ndc pict "@E 999,999"     
	@ 10,58      say "Data..:"		   		get dta pict "@D "             WHEN EMPTY(DTA)
	@ 12,07 		 say "1¦ Contagem.:"       get qt1 pict "@E 9999,999.999" WHEN CT=1
	@ 14,07      say "2¦ Contagem.:"       get qt2 pict "@E 9999,999.999" WHEN CT=2
	@ 16,07      say "3¦ Contagem.:" 	   get qt3 pict "@E 9999,999.999" WHEN CT=3
	READ
	IF LASTKEY()==27
		LOOP
	ENDIF
	IF Confirma ( "Grava Este Registro ? ", 23 )
			LOCK_REGISTRO(.T.)			
			IF grava     
				IF !INCLUI_REGISTRO(.T.)
					ALERT("NÆo foi poss¡vel gravar os dados. Tente novamente")
					LOOP
				ENDIF
			ENDIF
			CECTRINV->MERCAD   := cod
			CECTRINV->LOJA     := loc
			CECTRINV->NFICHA 	 := ndc
			CECTRINV->QUANT1   := qt1
			CECTRINV->QUANT2   := qt2
			CECTRINV->QUANT3   := qt3
			CECTRINV->DATA     := dta			
			CECTRINV->UNIDADE  := uni
			CECTRINV->STATUS   := " "
			DBCOMMIT()
			DBUNLOCK()
			SELECT("CECCINV")
	ENDIF	
ENDDO
RESTSCREEN(01,01,22,78,cTela)	
setcursor(0)
DBCLOSEALL()
RETURN (NIL)
