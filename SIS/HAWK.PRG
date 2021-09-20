// Hawk SoftWare - Roberto Falc„o Rocha - Phone - (092) 671 3585
// 03/12/93
// Relat¢rio de Estoque por local

// Declara‡”es locais
LOCAL cOldColor  := SETCOLOR()
LOCAL nOldCursor 

LOCAL nTipoTC,;
		nTipoTU,;
		nTipoTQ,;
		i,j,l

LOCAL nTotGerC,;
		nTotGerU,;
		nItenGer
		
LOCAL aTipOriVC := ARRAY ( 99, 99 )
LOCAL aTipOriQC := ARRAY ( 99, 99 )
LOCAL aTipOriVU := ARRAY ( 99, 99 )

LOCAL cOldScreen ,;
		aPro       ,;
		nLin       ,;
		nTotus     ,;
		nTot       ,;
		nLocal     ,;
		cOldDisplay,;
		nTotal     ,;
		nTotalus   ,;
		cod_old    ,;
		Cus_UnUS   ,;
		Cus_UnCR   ,;
		lCab		  ,;
		pg			  ,;
		cont	

// Inicializar os vetores
AFILL ( aTipOriQC, 0 )
AFILL ( aTipOriVU, 0 )
AFILL ( aTipOriVC, 0 )

// Cria arquivos de ¡ndices caso n„o existam
// Arquivo de tabela de locais
IF !FILE( "SIPILOC1.NTX" )
	Indices( "SIPTLOC","SIPILOC1","COD" )
ENDIF

// Arquivo de tabela de origens
IF !FILE( "SIPIORI1.NTX" )
	Indices( "SIPTORI","SIPIORI1","CORG" )
ENDIF

// Arquivo de tabela de tipos
IF !FILE( "SIPITIP1.NTX" )
	Indices( "SIPTTIP","SIPITIP1","TIPO" )
ENDIF

// Arquivo de locais 
IF !FILE( "SIPILOC.NTX" )
	Indices( "SIPCLOC","SIPILOC","STR(LOCAL,3)+PRODU" )
ENDIF

// Arquivo de materiais
IF !FILE( "SIPIMAT1.NTX" )	
	Indices( "SIPCMAT","SIPIMAT1","CDMT" )
ENDIF	

// Abre arquivo de locais
IF !Open( "SIPCLOC",.F. )
	DBCLOSEALL()
	RETURN( NIL )
ENDIF
SET INDEX TO SIPILOC

// Verifica se o arquivo est  vazio
IF EOF()
	M_DISPLAY("Arquivo de locais est  vazio",79)
	DBCLOSEALL()
	RETURN(NIL)
ENDIF

// Abre arquivo de logos
IF !Open(sLog,.F.)
   RETURN ( NIL )
ENDIF

// Abre tabela de origens
IF !Open ( "SIPTORI", .F. )
	DBCLOSEALL()
	RETURN ( NIL )
ENDIF	
SET INDEX TO SIPIORI1

// Abre tabela de tipos
IF !Open ( "SIPTTIP", .F. )
	DBCLOSEALL()
	RETURN ( NIL )
ENDIF	
SET INDEX TO SIPITIP1

// Abre tabela de locais	
IF !Open( "SIPTLOC",.F. )
	DBCLOSEALL()
	RETURN( NIL )
ENDIF
SET INDEX TO SIPILOC1

// Abre arquivo de materiais
IF !Open( "SIPCMAT",.F. )
	DBCLOSEALL()
	RETURN( NIL )
ENDIF
SET INDEX TO SIPIMAT1

// Mostra cusor
nOldCursor := SETCURSOR(1)
// Salva tela
cOldScreen := SAVESCREEN( 16,12,19,79 )

DO WHILE .T.
   SELECT ( "SIPCLOC" )
	nLocal := 0
	SetCor ( "B/W, W+/Bg , , , B/W" )
	Box ( 16, 12, 18, 78, fr, 127, 03, 08 )
	@ 17,14 SAY "Local [0]=Todos...:" GET nLocal PICTURE "99" ;
	VALID ( IF ( NLOCAL > 0, Existe ( nLocal, "Local n„o cadastrado", .F., ;
	"SIPTLOC", 1, "DSC", "@!", ROW(), COL() + 1 ) .AND. Existe ( STR ( nLocal,2), ;
	"Local sem Estoque", .F., "SIPCLOC", 1 ) , Todos() ) )
	READ
	IF LASTKEY() == 27 
		RESTSCREEN ( 16, 12, 19, 79, cOldScreen )			
		SetCor ( cOldColor )
		SETCURSOR ( nOldCursor )
		DBCLOSEALL()
		RETURN ( NIL )
	ENDIF	
	RESTSCREEN ( 16, 12, 19, 79, cOldScreen )			
	SETCURSOR(0)
	cOldDisplay := SAVESCREEN ( 03, 00, 23, 79 )
	IF ( nLocal > 0, DBSEEK ( STR ( nLocal, 3 ) ), DBGOTOP() )
	cod_old := LOCAL
	lCab := .T.
	pg := 0
	cont := 0
	NTOTALUS:=0
	NTOTAL:=0
	nTotGerC := 0
	nTotGerU := 0
	IF ! ( Impres() )
		LOOP
	ENDIF			
	M_MESSAGE ( "Imprimindo ...", 23 )
	SET DEVICE TO PRINT
	@ PROW(),PCOL() SAY CHR(sEsc)
	SETPRC(0,0)
	DO WHILE IF ( nLocal == 0, !EOF(), ( LOCAL == nLocal .AND. !EOF() ) )
		IF QUANT=0
			DBSKIP()
			LOOP
		ENDIF	
		IF INKEY() = 27
			IF Para_Impressao()
				EXIT 
			ENDIF
		ENDIF	
		IF lCab .OR. cod_old # SIPCLOC -> LOCAL	
			pg++
			vLen := "PAGINA :"+STRZERO(PG,4)
			vDat := "DATA :"+DTOC(DATE())
			VhOR := "HORA :"+TIME()
			@ 01,01  SAY &sLog->l1
			@ 01,PCOL()+3 SAY sNom
			@ 01,133-LEN(vLen)  say vLen
			@ 02,01  say &sLog->l2
			@ 03,01  say &sLog->l3
			@ 03,133-len(VdAT) say vdat
			@ 04,01  say &sLog->l4
			@ 04,40 SAY CHR(27)+"W"+CHR(1)+"SALDO DE ESTOQUE POR LOCAL"+CHR(27)+"W"+CHR(0)
			@ 05,01  say &sLog->l5
			@ 05,133-LEN(VhOR) SAY VhOR
			@ PROW(),PCOL() SAY CHR(27)+CHR(50)
			@ 06,1 SAY REPLICATE("-",132)
			SELECT("SIPTLOC")
			DBSEEK(SIPCLOC->LOCAL)
			SELECT("SIPCLOC")
			@ 07,1  say PADC("LOCAL -> "+ALLTRIM(STR(sipcloc->local,2))+" : "+ALLTRIM(siptloc->dsc),132)
			@ 07,1  say PADC("LOCAL -> "+ALLTRIM(STR(sipcloc->local,2))+" : "+ALLTRIM(siptloc->dsc),132)
			@ 08,1  SAY REPLICATE("-",132)
			@ PROW()+1,1 SAY "PARTNUMBER----  DESCRICAO---------------------  QUANTIDADE-  UN  CUSTO UNIT.CR$--  CUSTO TOT. CR$--  CUSTO UNIT.US$ CUSTO TOT. US$--"
			@ 10,00 say replicate("-",132)
			nLin:=11
			lCab := .F.
		ENDIF
		cod_old:=siptloc->cod
	   aPro := PRODU 
		SELECT( "SIPCMAT" )
		DBSEEK ( aPro )
		CUS_UNCR:=0
		CUS_UNUS:=0
		DO CASE
			CASE sTcu == 5
			   CUS_UNCR := CSTAND
				CUS_UNUS := CSTANDUS
			CASE sTcu == 6
				CUS_UNCR := CFOB
				CUS_UNUS := CFOBUS
			CASE sTcu == 7	
				CUS_UNCR := CMUNIT
				CUS_UNUS := CMUNITUS
		ENDCASE		
		SELECT( "SIPCLOC" )
		nTotus := Round(CUS_UNUS * QUANT,2)
		nTot   := Round(CUS_UNCR * QUANT,2)
		@ nLin,001 SAY PRODU PICTURE "XXXXXXXXXXXXX"
		@ nLin,017 SAY SIPCMAT->DSC1
		@ nLin,049 SAY QUANT          PICT "@r@E 999,999,999"
		@ nLin,062 SAY SIPCMAT->UNUS   
		@ nLin,066 SAY CUS_UNCR       PICT "@r@E 999,999,999.9999"
		@ nLin,084 SAY nTot           PICT "@r@E 99999,999,999.99"
		@ nLin,102 SAY CUS_UNUS       PICT "@r@E 99,999,999.999"
		@ nLin,117 SAY nTotus         PICT "@r@E 9,999,999,999.99"
		IF !EMPTY(SIPCMAT->DSC2)
 		   NLIN++
		   @ NLIN,17 SAY SIPCMAT->DSC2
		END
		nTotal   += nTot
		nToTalUS += nTotus 
		nTotGerC += nTot
		nTotGerU += nTotus
		aTipOriVC [ SIPCMAT-> TIPO, SIPCMAT -> CORG ] += nTot
		aTipOriQC [ SIPCMAT-> TIPO, SIPCMAT -> CORG ] += QUANT
		aTipOriVU [ SIPCMAT-> TIPO, SIPCMAT -> CORG ] += nTotus
		nLin++
		CONT++
		nItenGer++
		DBSKIP()
		/*@ nLin,084 SAY nTot           PICT "@E 99999,999,999.99"
		@ nLin,102 SAY CUS_UNUS       PICT "@E 99,999,999.999"
		@ nLin,117 SAY nTotus         PICT "@E 9,999,999,999.99"
		*/
		if eof() .or. cod_old#sipcloc->local
			@ NLIN,1 SAY REPL("=",132)
			NLIN++
			@ nlin,001 SAY "TOTAL DO LOCAL ==> "+STR(cont,5)+" ITENS"
	      @ NLIN,081 SAY NTOTAL PICT      "@E 9999,999,999,999.99"
			@ nLin,115 SAY ntotalus picture "@E 99,999,999,999.99"
			@ nlin,001 SAY "TOTAL DO LOCAL ==> "+STR(cont,5)+" ITENS"
	      @ NLIN,081 SAY NTOTAL PICT      "@E 9999,999,999,999.99"
			@ nLin,115 SAY ntotalus picture "@E 99,999,999,999.99"
			NTOTALUS:=0
			NTOTAL:=0
			CONT:=0
		ENDIF
	ENDDO
	nLin++
	@ nLIN,1 SAY PADC("<  RESUMO GERAL  >",132,"*") 
	nLin++
	@ nLin,001 say "TOTAL GERAL DO ESTOQUE ==> "+STR(nItenGer,6)+" ITENS"
	@ NLIN,081 SAY nTotGerC    PICT    "@E 9999,999,999,999.99"
	@ nLin,115 say nTotGerU  picture "@E 99,999,999,999.99"
	@ nlin,001 say "TOTAL GERAL DO ESTOQUE ==> "+STR(nItenGer,6)+" ITENS"
	@ NLIN,081 SAY nTotGerC    PICT    "@E 9999,999,999,999.99"
	@ nLin,115 say nTotGerU  picture "@E 99,999,999,999.99"
	nLin++
	
	// Resumo tipo / origem
	lRes := .F.
	FOR i = 1 TO 99
		nLin++
		nTipoTC := 0
		nTipoTU := 0
		nTipoTQ := 0
		FOR j = 1 TO 99
			nTipoTC += aTipOriVC [ i ] [ j ]
			nTipoTU += aTipOriVU [ i ] [ j ]
			nTipoTQ += aTipOriQC [ i ] [ j ]
		NEXT	
		IF nTipoTC + nTipoTU + nTipoTQ == 0
			EXIT
		ENDIF
		SIPTTIP -> ( DBSEEK ( i ) )
		nRep := 21 - ( LEN ( ALLTRIM ( SIPTTIP -> DESC ) ) + 1 ) 
		@ nLin,01 SAY "TOTAL DO STATUS : " + STR ( i, 2 ) + " = " ;
		+ ALLTRIM ( SIPTTIP -> DESC ) + REPLICATE ( "-", nRep ) + ">"
		@ nLin, 49  SAY nTipoTQ PICTURE "@R@E 999,999,999"
		@ nlin, 84  SAY nTipoTC PICTURE "@R@E 999,999,999,999.99"
		@ nLin, 117 SAY nTipoTU PICTURE "@R@E 99,999,999,999.99"
		FOR l = 1 TO 99
			IF aTipOriVC [ i ] [ l ] # 0 .OR. aTipOriQC [ i ] [ l ] # 0 .OR.;
				aTipOriVU [ i ] [ l ] # 0
				lRes := .T.
			ENDIF
			IF lRes
				nLin++
				SIPTORI -> ( DBSEEK ( l ) )
				nRep := 21 - ( LEN ( ALLTRIM ( SIPTORI -> DESC ) ) + 1 ) 
				@ nLin,01 SAY "TOTAL DA ORIGEM : " + STR ( l, 2 ) + " = " ;
				+ ALLTRIM ( SIPTORI -> DESC ) + REPLICATE ( "-", nRep ) + ">"
				@ nLin, 49  SAY aTipOriQC [ i ] [ l ] PICTURE "@R@e 999,999,999"
				@ nLin, 84  SAY aTipOriVC [ i ] [ l ] PICTURE "@R@E 999,999,999,999.99"
				@ nLin, 117 SAY aTipOriVU [ i ] [ l ] PICTURE "@R@E 99,999,999,999.99"
				lRes := .F.
			ENDIF
		NEXT
	NEXT
	EJECT
	nTotGerC:=nTotGerU:=nItenGer:=cont:=ntotalus:=ntotal:=0
	AFILL ( aTipOriVC, 0 )
	AFILL ( aTipOriVU, 0 )
	AFILL ( aTipOriQC, 0 )
	SET DEVICE TO SCREEN
ENDDO