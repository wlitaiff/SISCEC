/*
/ ***************************************
/  Modulo : Lista de precos de produtos
/  Parametros: fornecedor,linha,divisao,
/  material + % de preco p/ 30 dias
/ ***************************************
 */
 
#define fr "ÖÄ·º½ÄÓº"


LOCAL nLinha  := 1,;
		oPprint := {"Fornecedor/Linha","Fornecedor/Codigo","Cancela"},;
		cCor := SETCOLOR("B/W,W+/BG,,,B/W"),;
	   nCursor := SETCURSOR(1),;
	   cTela   := SAVESCREEN(0,0,MAXROW(),MAXCOL())
		
PUBLIC  PRECO30 := 0
			   
IF !FILE("SCEIMAT3.NTX")
   IF !INDICES("SCECMAT","SCEIMAT3","FORNECEDOR+LINHA+DIVISAO+CODIGO")
      RETURN(NIL)
	ENDIF  
ENDIF
IF !INDICES("SCECMAT","SCEIMAT4","FORNECEDOR+CODIGO")
   RETURN(NIL)
ENDIF
IF !OPEN( "SCECMAT", .F. ) 
   RETURN(NIL)
ENDIF
SET INDEX TO SCEIMAT3,SCEIMAT4

//SETCOLOR("B/W,B/W,,,W+/BG+")
DO WHILE .T.
	Box(16,06,18,75,fr,127)
	@ 17,08 SAY "Percentual para Preco 30 dias OU Preco com Desconto:" get preco30 picture "999.99"
	READ
	//
	IF LASTKEY()==27
		RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
		SETCURSOR(nCursor)
		SETCOLOR(cCor)
		DBCLOSEALL()
		RETURN(NIL)
	ENDIF
	//
	oPescolha := Alert("Qual sua opcao pela lista de precos?",oPprint)
	If oPescolha == 3
		RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
		SETCURSOR(nCursor)
		SETCOLOR(cCor)
		DBCLOSEALL()
		RETURN(NIL)
	EndIf
	If oPescolha == 2
		Set index to sceimat4
	else
		Set index to sceimat3
	endif
	//	 
	IF !IMPRES()
		LOOP
	ENDIF
	cTelao := SAVESCREEN(0,0,MAXROW(),MAXCOL())
	M_MESSAGE("Aguarde, Imprimindo relat¢rio ...",23)
	SET DEVICE TO PRINT
	@ 0,000 SAY CHR(18)
	DO WHIL SCECMAT->(!EOF()) 
   	IF nLinha == 1
	  	   CABEC()
			nLinha := 6
			IF FOLIDI( nLinha )
		   	nLinha += 1
			ENDIF
		ENDIF	
		IF INKEY()==27
			IF Para_Impressao()
				EXIT
			ENDIF
		ENDIF
   	@ nLINHA,000 SAY SCECMAT->CODIGO	
   	@ nLINHA,016 SAY SCECMAT->DESCRICAO	
  		@ nLINHA,046 SAY SCECMAT->UNIDADE	
  	 	@ nLINHA,049 SAY SCECMAT->PRVENDA PICTURE "99,999,999.99"
   	@ nLINHA,063 SAY ROUND((SCECMAT->PRVENDA*(1+if(preco30=0,0,PRECO30/100))),2) PICTURE "99,999,999.99"					
   	nLINHA ++
		OldDivisao    := SCECMAT->DIVISAO
		OldLinha      := SCECMAT->LINHA
		OldFornecedor := SCECMAT->FORNECEDOR		
		SCECMAT->(DBSKIP())
		IF oPescolha == 1
			IF OldDivisao != SCECMAT->DIVISAO  .OR.  OldLinha != SCECMAT->LINHA  .OR.  OldFornecedor != SCECMAT->FORNECEDOR			
	   		nLINHA += 1
	   		FOLIDI(nLinha)
				nLinha += 1	
			ENDIF	
		ELSE
			IF OldFornecedor != SCECMAT->FORNECEDOR			
				nLINHA += 1
	   		FOLIDI(nLinha)
				nLinha += 1	
			ENDIF
		ENDIF
		IF nLinha >= 60
	   	nLinha := 1
		ENDIF 	
	ENDDO
	EJECT
	SET DEVICE TO SCREEN
	RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTelao)
	//
ENDDO
RETURN

FUNCTION CABEC()
@ 1,000 SAY CHR(18)
@ 1,000 SAY CHR(27)+"W"+CHR(1)
@ 1,000 SAY PADR('MAGAZINE SIRIA',80)
@ 1,000 SAY PADC('LISTA DE PRECOS',40)
@ 1,000 SAY CHR(15)
@ 2,000 SAY CHR(27)+"W"+CHR(0)                        
@ 2,000 SAY CHR(18)
@ 2,000 SAY PADL(DATE(),80)
@ 3,000 SAY REPL("-",80)
@ 4,000 SAY "---CODIGO----- ----------DESCRICAO----------- UN ----PRECO---- "+if(preco30<0,"PR.C/ DESCONTO","-PRECO(30 D.)-")
RETURN(NIL)

FUNCTION FOLIDI(nLin)
@ nLin,000 SAY CHR(15)
@ nLin,000 SAY CHR(27)+"W"+CHR(1)
@ nLin,000 SAY if(oPescolha==1,"FORNECEDOR--> " + SCECMAT->FORNECEDOR + " LINHA--> " + SCECMAT->LINHA + " DIVISAO--> " + SCECMAT->DIVISAO,"FORNECEDOR--> " + SCECMAT->FORNECEDOR)
@ nLin,000 SAY if(oPescolha==1,"FORNECEDOR--> " + SCECMAT->FORNECEDOR + " LINHA--> " + SCECMAT->LINHA + " DIVISAO--> " + SCECMAT->DIVISAO,"FORNECEDOR--> " + SCECMAT->FORNECEDOR)
@ nLin,PCOL()+1 SAY CHR(27)+"W"+CHR(0)
@ nLin,000 SAY CHR(18)
RETURN(.T.)
