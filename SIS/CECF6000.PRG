// Sistemas de Controle de Estoque Comercial
// W&R Informatica Ltda
// 09 de Julho de 1996
// Roberto Falcao Rocha
// ImpressÆo de boletos bancarios

LOCAL cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
		cCor := SETCOLOR(),;
		nCursor := SETCURSOR(),;
		nNota := 0,;
		x:=0,;
		cTelao
		
		IF !ARQNTX("CECCBOL") .OR.;
			!ARQNTX("CECCSET") .OR.;
			!ARQNTX("CECCCLI")
			RETURN(NIL)
		ENDIF			
		
		MOR := CECCSET->MORA
		INI := CECCSET->INIE
		
		SELECT("CECCBOL")
		
		SETCOLOR(cEdicao)
		Box(16,12,18,75,fr,127,03,08)
		SETCURSOR(1)
		DO WHILE .T.
			@ 17,14 SAY "Entre com o numero da nota fiscal:" GET nNota PICTURE "9999999999" VALID !EMPTY(nNota)
			READ
			IF LASTKEY()==27
				SETCOLOR(cCor)
				SETCURSOR(nCursor)
				RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
				DBCLOSEALL()
				RETURN
			ENDIF
			IF !DBSEEK(STRZERO(nNota,10))
				M_DISPLAY("Nota nÆo emitida ou nÆo existem boletos para esta nota",79)
				LOOP
			ENDIF		
			IF !M_QUERY("Confirma a emissao do(s) boleto(s) para esta nota ?",23)
				LOOP
			ENDIF
			cTelao := SAVESCREEN(0,0,MAXROW(),MAXCOL())
			M_MESSAGE("Aguarde , imprimndo boleto(s) ...",23)
			SET DEVICE TO PRINT
			@ PROW(),PCOL() SAY CHR(27)+CHR(67)+CHR(24)
			X:=1
			DO WHILE CECCBOL->NOTA == STRZERO(nNota,10) .AND. !CECCBOL->(EOF())
				@ 03,05 SAY "MANAUS/AM"
				@ 03,58 SAY CECCBOL->VENCIMENTO
				@ 07,00 SAY DATE()
				@ 07,12 SAY NOTA+"/"+STR(X,1)+"-"+INI
				@ 09,21 SAY "R$"
				@ 09,56 SAY "R$ "+TRANS(VALOR,"@R@E 9,999,999.99")
				@ 12,05 SAY "COBRAR &MOR% AO DIA DE MORA POR ATRAZO"
				@ 14,05 SAY "NOTA FISCAL FATURA No. "+CECCBOL->NOTA
				CECCCLI->(DBSEEK(CECCBOL->CLIENTE))
				@ 17,10 SAY CECCCLI->NOMECLC
				@ 18,10 SAY CECCCLI->ENDEREC
				@ 19,10 SAY "CGC No. "+TRANS(CECCCLI->CGCCPFC,"@R 99.999.999/9999-99")
				X++
				EJECT
				DBSKIP()
			ENDDO	
			@ PROW(),PCOL() SAY CHR(27)+CHR(64)
			SET DEVICE TO SCREEN
			RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTelao)
		ENDDO		
		
