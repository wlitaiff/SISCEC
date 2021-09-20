// Hawk SoftWare - Roberto Falc„o Rocha - Phone - (092) 671 3585
// 30/11/93
// Varia‡”es de invent rio por  rea

// Declara‡”es locais
LOCAL qtd_con,;
		qtd_fis,;
		qtd_var,;
		cus_con,;
		cus_fis,;
		val_var,;
		cuc_ori,;
		cuf_ori,;
		cus_uni,;
		vld_ori,;
		vld_tot,;
		cuc_tot,;
		cuf_tot,;
		vlf_tot,;
		vls_tot,;
		ite_ori,;
		ite_var,;
		ite_fal,;	
		ite_sob,;
		ite_tot,;
		tot_ite,;
		tot_fis,;
		c_totcon,;
		c_totfis
		
LOCAL aEscolha,;
		nEscolha,;
		aArea,;
		nArea,;
		nPagina,;
		nLinhaM,;
		cTela,;
		lCabecalho,;	
		vLen,;
		vDat,;
		vHor,;
		ite_con,;
		item_var,;
		utra1,;
	   cfob1,;
   	desc1,;
	   orig1

// Declara‡äes
lCabecalho := .T.
nPagina := nLinha := TOT_FIS := 0		
qtd_con := 0
qtd_fis := 0
qtd_var := 0
cus_con := 0
cus_fis := 0
val_var := 0
cuc_ori := 0
cuf_ori := 0
cus_uni := 0
vld_ori := 0
vld_tot := 0
cuc_tot := 0
cuf_tot := 0
vlf_tot := 0
vls_tot := 0
ite_ori := 0
ite_var := 0
ite_fal := 0	
ite_sob := 0
ite_tot := 0
tot_ite := 0
tot_fis := 0
item_var:= 0
c_totcon := 0
c_totfis := 0
// Verifica ¡ndices

// Arquivo de Movimentos

IF !FILE("SIPIMOV1.NTX")
	IF !Indices("SIPCMOV","SIPIMOV1","CODIGOM","CODMOVM > 40 .AND. CODMOVM < 50" )       // PODE SAIR
		RETURN ( NIL )
	ENDIF	
ENDIF	

// Arquivo de materiais
IF !FILE ( "SIPIMAT1.NTX" )
	IF ! ( Indices ( "SIPCMAT", "SIPIMAT1", "CDMT" ) )
		RETURN ( NIL )
	ENDIF	
ENDIF	

// Arquivo de invent rio
IF !FILE ( "SIPIINV1.NTX" )
	IF ! ( Indices ( "SIPCINV", "SIPIINV1", "CDMT" ) )
		RETURN ( NIL )
	ENDIF	
ENDIF	

// Verifica a op‡„o
nArea := 0
aEscolha := {"Area","Geral","Cancela"}
aArea    := {"Recebimento","Almoxarifado","Cancela","Recupera‡„o","F brica","Refugo"}
nEscolha := Alert ( "Varia‡„o de invent rio ?", aEscolha )
IF nEscolha == 3
	RETURN ( NIL )
ENDIF	 		
IF nEscolha == 1
	nArea := Alert ( "Qual a area ?", aArea )
	IF nArea == 6
		RETURN ( NIL )
	ENDIF			
ENDIF	

IF !M_QUERY ( "Confirma impress„o ?", 23 )
	RETURN ( NIL )
ENDIF

// Abre arquivo de logos
IF !Open( slog,.F. )
	DBCLOSEALL()
	RETURN( NIL )
ENDIF

// Abre arquivo de invent rio
IF !OPEN ( "SIPCINV", .F. )
	DBCLOSEALL()
	RETURN ( NIL )
ENDIF	
SET INDEX TO SIPIINV1

// Abre arquivo de MOVIMENTOS
IF !OPEN ( "SIPCMOV", .F. )
	DBCLOSEALL()
	RETURN ( NIL )
ENDIF	
SET INDEX TO SIPIMOV1

// Abre arquivo de materiais
IF !OPEN ( "SIPCMAT", .F. )
	DBCLOSEALL()
	RETURN ( NIL )
ENDIF	
SET INDEX TO SIPIMAT1

// Configura impress„o
Impressora ( 1 )
cTela := SAVESCREEN ( 0, 0, LASTROW(), LASTCOL() )
M_MESSAGE ( "Imprimindo! Aguarde...", 23 )
SET DEVICE TO PRINT	

DO WHILE !EOF()
	IF INKEY() == 27
		IF Para_Impressao()
			EXIT
		ENDIF
	ENDIF		
	IF SIPCMAT -> TIPO == 1 .OR. SIPCMAT -> TIPO == 2
		DBSKIP()
		LOOP
	ENDIF	
	IF lCabecalho
		nPagina ++
		vLen := "PAGINA :"+STRZERO(nPagina,4)
	   vDat := "DATA :"+DTOC(DATE())
		vHor := "HORA :"+TIME()
	   @ 01,001 SAY &sLog->l1
		@ 01,PCOL()+3 SAY sNom
		@ 01,133-LEN(vLen)  say vLen
		@ 02,001 SAY &sLog->l2
		@ 03,001 SAY &sLog->l3
		@ 03,133-len(VdAT) say vdat
		@ 04,001 SAY &sLog->l4
		@ 04,33 SAY CHR(27)+"W"+CHR(1)+"VARIACOES DE INVENTARIO" + IF ( nArea # 0, " - " + aArea [ nArea ], "" ) + CHR ( 27 ) + "W" + CHR ( 0 )
		@ 05,001 SAY &sLog->l5
		@ 05,133-LEN(vHor) SAY vHor
		@ PROW(),PCOL() SAY CHR(27)+CHR(50)
		@ 06,001 SAY REPL("-",132)
		@ 07,01 SAY "                                                     ESTOQUES(QT.)---------        VARIACOES----------------------------------------"
		@ 08,01 SAY "CODIGO--------  OR.  DESCRICAO---------------------  CONTABIL--  FISICO----   UN   QUANTIDADE   ENTRADA---   3%--------   NCM-------"  
		@ 09,01 SAY REPL("-",132)
		nLinha := 10
		lCabecalho := .F.
	ENDIF	
	DO CASE
		CASE sTcu == 5
         cus_uni := CSTA
      CASE sTcu == 6
         cus_uni := CFOB
      CASE sTcu == 7
         cus_uni := CMUNIT
	ENDCASE		
	// Vari veis cont beis
   ite_con := CDMT
   utra1   := UNUS
	cfob1   := CFOB
   desc1   := DSC1
	desc2   := DSC2
   orig1   := CORG	
	// Verifica saldo contabil do iten
	DO CASE
		CASE nArea == 0
			qtd_con := QT2 + QT3 + QT4 + QT5 + QT6  && Saldo geral (Rec+Alm+Ncm+Pro+Ref)
      CASE nArea == 1
        	qtd_con := QT2          					 && Saldo recebimento
		CASE nArea == 2
      	qtd_con := QT3						          &&Saldo almoxarifado
		Case nArea == 3
			qtd_con := QT4     					       &&Saldo Recuperacao
		Case nArea == 4
      	qtd_con := QT5          					 &&Saldo Fabrica
		Case nArea == 5
      	qtd_con := QT6           					 &&Saldo Refugo
	ENDCASE		
	// Verifica saldo fisico do iten
	SELECT ( "SIPCINV" )
	IF !DBSEEK ( ite_con )
      qtd_fis := 0
   ELSE
		// Verifica saldo fisico do iten
		DO CASE
			CASE nArea == 0
				qtd_fis := QT2 + QT3 + QT4 + QT5 + QT6  && Saldo geral (Rec+Alm+Ncm+Pro+Ref)
	      CASE nArea == 1
	        	qtd_fis := QT2          					 && Saldo recebimento
			CASE nArea == 2
	      	qtd_fis := QT3						          &&Saldo almoxarifado
			Case nArea == 3
				qtd_fis := QT4     					       &&Saldo Recuperacao
			Case nArea == 4
		    	qtd_fis := QT5          					 &&Saldo Fabrica
			Case nArea == 5
	      	qtd_fis := QT6           					 &&Saldo Refugo
		ENDCASE	
		// Numero de itens
		Tot_fis++					
   ENDIF
	nNCM := QT4
	//
	SELECT ( "SIPCMAT" )
   // Varia‡„o das quantidades
   qtd_var := qtd_con - qtd_fis
	 //*************************** Custos ***********************************
   cuc_ori := qtd_con * cus_uni      &&Custo da Origem(contabil)
   cus_con := qtd_con * cus_uni      &&Custo Contabil
   cus_fis := qtd_fis * cus_uni      &&Custo Inventario
   val_var := qtd_var * cus_uni      &&Custo Tot. da variacao
   //*************************** Totais ***********************************
   c_totcon := c_totcon + cus_con    &&Custo total contabil(saldo antes inv.)
   c_totfis := c_totfis + cus_fis    &&Custo total fisico(inventariado)
   ite_tot  := ite_tot  + 1
	IF QTD_VAR > 0
		SELECT("SIPCMOV")
		DBSEEK(ite_con)
		nEntrada := 0
		DO WHILE CODIGOM==ITE_CON .AND. !EOF()
			nEntrada += QTDMM
			DBSKIP()
		ENDDO	
		SELECT("SIPCMAT")
	ENDIF	
   //*************************** Custos ***********************************
   cuc_ori := qtd_con * cus_uni      &&Custo da Origem(contabil)
   cus_con := qtd_con * cus_uni      &&Custo Contabil
   cus_fis := qtd_fis * cus_uni      &&Custo Inventario
   val_var := qtd_var * cus_uni      &&Custo Tot. da variacao
   //*************************** Totais ***********************************
   ite_tot  := ite_tot  + 1
	//
   IF Qtd_var#0  .and. cus_con # 0  //Imprimir somente os c/ variacao
		@ nLinha,001 say ite_con
      @ nLinha,017 say CORG PICTURE "99"
      @ nLinha,022 say DSC1
      @ nLinha,054 say qtd_con PICTURE "@E 99,999,999"
      @ nLinha,066 say qtd_fis PICTURE "@E 99,999,999"
      @ nLinha,079 say UNUS
      @ nLinha,084 say qtd_var PICTURE "@E 99,999,999"
		IF QTD_VAR > 0
			@ nLinha,097 say nEntrada  picture "@e 99,999,999"
			@ nLinha,110 say (nEntrada*3)/100  picture "@e 99,999,999"
		ENDIF
		IF QTD_VAR < 0	
			@ nLinha,123 say nNCM  picture "@e 99,999,999"
		ENDIF	
		IF !EMPTY(DSC2)
			@ ++nLinha,022 say DSC2
		ENDIF	
		//*************************** Faltas ***********************************
	   If qtd_var > 0
   	   vlf_tot := vlf_tot + val_var         &&Vl. total das faltas
	      ite_fal := ite_fal + 1               &&Tot. de itens c/ falta
	   ENDIF
   	//*************************** Sobras ***********************************
 	  	IF qtd_var < 0
	      vls_tot := vls_tot + val_var            &&Vl. total das sobras
   	   ite_sob := ite_sob + 1                  &&To. de itens c/ sobra
	   ENDIF
		nLinha++
		Item_Var++
   ENDIF
	// Numero de itens
   tot_ite++   
	IF nLinha > 59
		lCabecalho := .T.
	ENDIF	
	DBSKIP()
ENDDO	
//
nLinha++
nLinha++
@ nLinha,001 SAY "TOTAL CONTABIL===>"
@ nLinha,021 SAY Tot_Ite PICTURE "@R@E 999,999"
@ nLinha,030 SAY "ITENS"
@ nLinha,090 SAY "CR$ "
@ nLinha,110 SAY C_totcon PICTURE "@R@E 9999,999,999,999.99"
nLinha++
nLinha++
//
@ nLinha,001 say "TOTAL FISICO=====>"
@ nLinha,021 say Tot_Fis pict "@R@E 999,999"
@ nLinha,030 say "ITENS"
@ nLinha,090 say "CR$ "
@ nLinha,110 say C_totfis PICTURE "@R@E 9999,999,999,999.99"
nLinha++
nLinha++
//
@ nLinha,001 say "TOTAL DE FALTAS==>"
@ nLinha,021 say ite_fal PICTURE "@R@E 999,999"
@ nLinha,030 say "ITENS"
@ nLinha,090 say "CR$ "
@ nLinha,110 say vlf_tot PICTURE "@R@E 9999,999,999,999.99"
nLinha++
nLinha++
//
@ nLinha,001 say "TOTAL DE SOBRAS==>"
@ nLinha,021 SAY ite_sob PICTURE "@R@E 999,999"
@ nLinha,029 say "ITENS"
@ nLinha,090 say "CR$ "
@ nLinha,110 say vls_tot PICTURE "@R@E 9999,999,999,999.99"
nLinha++
nLinha++
@ nLinha,001 say "TOTAL DE ITENS COM VARIACAO==>"
@ nLinha,040 say item_var pict "@RE 999,999"
@ nLinha,053 say "ITENS"
EJECT
SET DEVICE TO SCREEN
RESTSCREEN ( 0, 0, LASTROW(), LASTCOL(), cTela )
DBCLOSEALL()
RETURN ( NIL )