// Manaus, 12/03/95
// Roberto Falcao Rocha
// Livro de entrada de mercadorias

LOCAL dData1:=CTOD("  /  /  "),;
		dData2:=CTOD("  /  /  "),;
		cLoja:=SPACE(2),;
		lCab := .T.,;
		nLin := 1,;
		nPage := 0,;
		nTot1,;
		nTot2,;
		nTotT1,;
		nTotT2,;
		cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL())

DBCLOSEALL()

USE EMPRHAWK NEW
IF !FILE("EMPRHAWK.NTX")
	INDEX ON EMP TO EMPRHAWK
ENDIF
SET INDEX TO EMPRHAWK	

USE MOV_ICM NEW
IF !FILE("ICMSHAWK.NTX")
	INDEX ON DTOS(DATA)+LOJA TO ICMSHAWK
ENDIF	
SET INDEX TO ICMSHAWK

USE SIVE0006 NEW
IF !FILE("FORNHAWK.NTX")
	INDEX ON CODFO TO FORNHAWK
ENDIF	
SET INDEX TO FORNHAWK

SELECT("MOV_ICM")

DO WHILE .T.
	COR("GETS")
	SETCURSOR(1)
	TABELA(15,50,19,78)
	
	@ 16,51 SAY "Inicio:";
			  GET dData1;
			  PICTURE "@D"
	
	@ 17,51 SAY "Final.:";
			  GET dData2;
			  PICTURE "@D"
			  
	@ 18,51 SAY "Loja..:";
			  GET cLoja;
			  PICTURE "@!"		  		  
	
	READ		  
	
	IF LASTKEY()==27
		DBCLOSEALL()
		RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
		RETURN
	ENDIF	
	
	IF EMPTY(dData1)
		DBGOTOP()
	ELSE
		DBSEEK(dData1,.T.)
	ENDIF
	
	IF DATA>dData1
		MENSAGEM("Per¡do sem entradas")
		LOOP					   
	ENDIF
	
	lCab := .T.
	nPage:=1
	nLin:=1
	nTot1:=nTot2:=nTotT1:=nTotT2:=0
	SET DEVICE TO PRINT
	@ PROW(),PCOL() SAY CHR(15)
	DO WHILE DATA<=dData2 .AND. !EOF()
		IF INKEY()==27
			SET DEVI TO SCREEN
	      M->SAI_DA=PERGUNTA("Continua a impress„o ?")
   	   MENSAGEM("Tecle <ESC> para pausa ou interrup‡„o")
         IF M->SAI_DA="N"
            EXIT
         ENDIF
			SET DEVI TO PRINT
		ENDIF
		
		IF LOJA#cLoja
			DBSKIP()
			LOOP
		ENDIF	
		
		IF lCab 
			SELECT("EMPRHAWK")
			DBSEEK(cLoja)
			SELECT("MOV_ICM")
			@ 01,01 SAY "------------------------------------------------------------------------------------------------------------------------------------"
			@ 02,01 SAY "|                               REGISTRO DE ENTRADAS                                 |          CODIGO DE VALORES FISCAIS          |"                                         
			@ 03,01 SAY "| FIRMA.....:                                                                        |---------------------------------------------|"        
			@ 03,15 SAY EMPRHAWK->NOME
			@ 04,01 SAY "| INSC. EST.:                          CGC(MF).:                                     |1-OP. COM CREDITO DE IMPOSTO                 |"    
			@ 04,15 SAY EMPRHAWK->INSCEST
			@ 04,50 SAY EMPRHAWK->CGC
			@ 05,01 SAY "| FOLHA.....:                          MES OU PERIODO/ANO.:                          |2-OP. S/ CRED. DE IMP. ISENTAS/NAO TRIBUTADAS|"
			@ 05,15 SAY STRZERO(nPage,3)
			@ 05,61 SAY DTOC(dData1)+"-"+DTOC(dData2)
			@ 06,01 SAY "|                                                                                    |3-OP. SEM CREDITO DE IMPOSTO-OUTRAS          |"
			@ 07,01 SAY "|----------------------------------------------------------------------------------------------------------------------------------|"
			@ 08,01 SAY "|        |           DOCUMENTOS FISCAIS                  |          |  CODIFICACAO  |   |    ICMS VALORES FISCAIS     |            |"
			@ 09,01 SAY "|  DATA  |-----------------------------------------------|  VALOR   |---------------|COD|-----------------------------|            |"
			@ 10,01 SAY "|   DE   |  |SERIE|      |  DATA   |  |     CODIGO       |          |        |      |   |   BASE    |     |           | OBSERVACAO |"
			@ 11,01 SAY "| ENTRADA|ES| SUB |NUMERO|   DO    |UF|       DO         | CONTABIL |CONTABIL|FISCAL|(a)|    DE     |ALIQ |  IMPOSTO  |            |"         
			@ 12,01 SAY "|        |  |SERIE|      |DOCUMENTO|  |    EMITENTE      |          |        |      |   | CALCULO   |     |           |            |"
			@ 13,01 SAY "|--------|--|-----|------|---------|--|------------------|----------|--------|------|---|-----------|-----|-----------|------------|"
			nPage++
			nLin := 14
			lCab := .F.
		ENDIF
		@ nLin,01 SAY "|"+DTOC(DATA)
		@ nLin,10 SAY "|NF"
		@ nLin,13 SAY "|"+SUBST(SERIE,1,1) // Serie/Sub-Serie
		@ nLin,19 SAY "|"+NOTA
		@ nLin,26 SAY "|" // Data de emissao
		SELECT("SIVE0006")
		DBSEEK(MOV_ICM->CODFOR)
		SELECT("MOV_ICM")
		@ nLin,36 SAY "|"+SIVE0006->ESTADO
		@ nLin,39 SAY "|"+SIVE0006->CGC
		@ nLin,58 SAY "|"+TRANS(TOTAL_NOT,"9999999.99")
		@ nLin,69 SAY "|"  // CODIFICAO CONTABIL
		@ nLin,78 SAY "|" // Codificacao fiscal
		@ nLin,85 SAY "|1"
		@ nLin,89 SAY "|"+TRANS(VALORB,"99999999.99")
		@ nLin,101 SAY "|"+TRANS(ICMPERCENT,"99.99")
		@ nLin,107 SAY "|"+TRANS(ICMS,"99999999.99")
		@ nLin,119 SAY "|"
		@ nLin,132 SAY "|"
		nLin++
		nTot1+=VALORB
		nTot2+=ICMS
		DBSKIP()
		IF nLin > 55
			@ nLin,01 SAY "|        |  |     |      |         |  |                  |          |        |      |   |           |     |           |            |"
			@ nLin,79 SAY "TOTAL"
			@ nLin,90 SAY  TRANS(nTot1,"99999999.99")
			@ nLin,107 SAY TRANS(nTot2,"99999999.99")
			nTotT1+=nTot1
			nTotT2+=nTot2
			nTot1:=nTot2:=0
			@ PROW()+1,01 SAY REPL("-",132)
			lCab := .T.
		ENDIF	
	ENDDO
	@ nLin,01 SAY REPL("-",132)
	nLin++
	@ nLin,69 SAY "TOTAL GERAL"
	@ nLin,90 SAY  TRANS(nTotT1,"99999999.99")
	@ nLin,107 SAY TRANS(nTotT2,"99999999.99")
	EJECT
	SET DEVICE TO SCREEN
ENDDO	
					
		
		
		
		
			