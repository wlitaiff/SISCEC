/** FUNCAO.: Registro de inventario por c¢digo/referencia  ***
*** AUTOR..: W.L.V                                         ***
*** DATA...: 16-02-1998              UPGRADE..: 			  ***
*************************************************************/
// Controle de tela
//
Local Cur := setcursor(1)
local Cor := setcor()
local cOldscreen:=SaveScreen(0,0,lastrow(),lastcol())
local Tel
// Variaveis
Local _Sai       := .F.,;
		nTotal     := 0,;
		dDia       := 0,;
		lCab       := .T.,;
		nPage      := 1,;
		nLin       := 0
//
local Num_folha  := 2
local Cont_Lin   := 5
local Clfiscal   := 0
local Origem     := 0
local Status     := 0
local Tot_Orig   :=Tot_Stat     :=Tot_Clas    :=Tot_Itens    :=Tot_Quant    :=Tot_CustUni :=Tot_CustTot:=0
local Tots_Orig  :=Tots_Quant   :=Tots_Quant  :=Tots_CustUnit:=Tots_CustTot :=tot_impres  :=0
local Totf_Quant :=Totf_CustUnit:=Totf_CustTot:=Totr_Qt      :=Totr_Cu     :=Totr_Ct:=Cus_Uni:=0
local Classif,;
      Recebe
//  
local Tot_Ori[100]
Afill(Tot_Ori,0)
//
nTcus   := {" FOB "," MEDIO "," CIF ","CANCELA"}
nTcusto := {" REAL "," DOLAR ","CANCELA"}

//
//Classif := {"CODIGO ","N.B.M","CANCELA"}
//Recebe := Alert("Listagem Por: ",Classif)
//IF Recebe == 3 
//   RestScreen(0,0,lastrow(),lastcol(),cOldScreen)
//	SETCURSOR(Cur)
//	SetCor(cor)
//	DBCLOSEALL()
//	RETURN(NIL)
//End	
//   
// Selecao e abertura dos arquivos
IF !ARQNTX("CECCINV",.F.) .OR. ;
   !ARQNTX("CECLOGO",.F.) .OR. ;
	!ARQNTX("CECCLOJ",.F.)  
	DBCLOSEALL()
	RETURN
ENDIF
//
TEL := Titulo(02,00,23,79,"Registro de inventario - Modelo 7","gr+/b","N+/Bg",quadro02)
SetCor ( "B/W,W+/BG,,,B/W" )
//
SELECT("CECCINV")
Do Whil .T.
   SETCURSOR(1)
   nUm_Folha := 2
	data := ctod("  /  /  ")	
	Tel1 := SAVESCREEN(16,12,20,76)
   Box(16,12,19,75,fr,127,03,08)
	@ 17,14 SAY  "Informe o numero da pagina inicial..:" GET num_folha PICTURE "999" VALID !EMPTY(num_folha)
	@ 18, 14 SAY "Data do invent rio..................:" GET data PICTURE "@D" VALID ( ! ( EMPTY ( data ) ) )
	Read
	IF LASTKEY() == 27
		RestScreen(0,0,lastrow(),lastcol(),cOldScreen)
		SETCURSOR(Cur)
		SetCor(cor)
		DBCLOSEALL()
		RETURN(NIL)
	ENDIF
	RecC    := Alert("Qual o Tipo de Custo? ",nTcus)
	RecCus  := Alert("Qual a Moeda ? ",nTcusto )
	IF RecCus == 3
		RestScreen(0,0,lastrow(),lastcol(),cOldScreen)
		SETCURSOR(Cur)
		SetCor(cor)
		LOOP
	ENDIF	
	RESTSCREEN(16,12,20,76,Tel1)
	// Seta impressora
	IF ! ( Impres() )
		LOOP
	ENDIF
	Cur := setcursor(0)
   // *** PROCESSO
	cont_lin := 5
   M_message("Imprimindo, aguarde...",23)
   SET DEVICE TO PRINT
        SELECT("CECCINV")
  	Do While !EOF()
   	If INKEY()==27
			IF PARA_IMPRESSAO()
			   RestScreen(0,0,lastrow(),lastcol(),cOldScreen)
        		SETCURSOR(Cur)
        		SetCor(cor)
        		DBCLOSEALL()
				SET DEVICE TO SCREEN
        		RETURN(NIL)
		 	END
    	End
		// Cabe‡alho
		IF lCab 
			Cabecalho(nPage,"REGISTRO DE INVENTARIO - MODELO 7 - "+ DispMonth( Data ) + "/" + STR(YEAR(Data)))
			//@PROW(),PCOL() SAY CHR(18) 
			@07,01 SAY "CODIGO--------  OR  DESCRICAO-------------------------------  SALDO-------- UN  CUSTO-UNITARIO-  CUSTO-TOTAL------"
			@08,01 SAY REPL("-",132)
			nLin := 08
			lCab := .F.
			nPage++
		ENDIF
		//
                Quant := CECCINV->SaldoEm         
		DO CASE
		   CASE Recc = 3
                                Cus_Uni =  CECCINV->Ccifm
		   CASE Recc = 1 
                                Cus_Uni = CECCINV->cFobm
		   CASE Recc = 2
                                Cus_uni = CECCINV->cMedm
		ENDCASE
		//		
		Custotal := Round(cus_uni*Quant,2)       //Calculo do custo total
		//
		If Custotal == 0   
		   Skip
			/******If Origem#corg  .AND. TOT_ORIG#0 
			   nLin++
				@ nLin,01 say 'TOTAL DO STATUS----------->'
				@ nLin,01 say 'TOTAL DO STATUS----------->'
				@ nLin,35 say Tot_Stat
				@ nLin,47 say 'ITEM(NS)'
	      	@ nLin,116 say Tots_CustTot  pict '@E 99,999,999,999.99'
	      	Tot_Stat:=Tots_Quant:=Tots_Quant:=Tots_CustUnit:=Tots_CustTot:=0
	         Status:=tipo
	  			nLin ++
	  			@ nLin,001 say 'TOTAL DA ORIGEM----------->'
				@ nLin,001 say 'TOTAL DA ORIGEM----------->'
	  			@ nLin,035 say Tot_Orig
	 			@ nLin,047 say 'ITEM(NS)'
				@ nLin,116 say Tot_CustTot  pict '@E 99,999,999,999.99'
				Tot_Orig:=Tot_Quant:=Tot_Quant:=Tot_CustUnit:=Tot_CustTot:=0
				Origem := Corg
			endif	
			If Status#tipo .AND. TOT_STAT#0
				nLin++
				@ nLin,01 say 'TOTAL DO STATUS----------->'
				@ nLin,01 say 'TOTAL DO STATUS----------->'
				@ nLin,35 say Tot_Stat
				@ nLin,47 say 'ITEM(NS)'
	      	@ nLin,116 say Tots_CustTot  pict '@E 99,999,999,999.99'
	      	Tot_Stat:=Tots_Quant:=Tots_Quant:=Tots_CustUnit:=Tots_CustTot:=0
   	      Status:=tipo
	      Endif        ****************/
			//
			Tot_Itens++
		   Loop
		Endif
		//
		// Imprimir Itens com Saldo
		//	01 17  21 63 77 81 98                
		//
		nLin ++ 
      @ nLin,001 say CECCINV->CODIGOM
                @ nLin,017 say CECCINV->ORIGEMM
                @ nLin,021 say CECCINV->DESCRIM
		@ nLin,063 say QUANT            	pict '@E 99999,999.999'
                @ nLin,077 say CECCINV->UNIDADE
		@ nLin,081 say Cus_Uni  				pict '@E 99,999,999.9999'
   	@ nLin,098 say Custotal 				pict '@E 99,999,999,999.99 '
		//
	   //  Calculo dos Totais e Resumo por Origem
		//
   	Tot_Orig ++                && Calculo do total de itens da origem
   	Tot_Stat ++                && Calculo do total de itens do status
		Tot_Clas ++                && Calculo do total de itens da classif. fiscal
		Tot_Itens++                && Calculo do total de geral de itens 
		Tot_Impres++               && Itens Impressos
		Tot_Quant    += Quant      && Calculo do total de quantidade p/ orig.
		Tot_CustUnit += cus_uni    && Calculo do total de custo unitario p/ orig.
		Tot_CustTot  += Custotal   && Calculo do total de custo total p/ orig.
   	Tots_Quant   += Quant      && Calculo do total de quantidade p/ status
   	Tots_CustUnit+= cus_uni    && Calculo do total de custo unitario p/ status
   	Tots_CustTot += Custotal   && Calculo do total de custo total p/ status
		Totf_Quant   += Quant      && Calculo do total de quantidade p/ cl.fiscal
		Totf_CustUnit+= cus_uni    && Calculo do total de custo unitario p/ cl.fiscal
		Totf_CustTot += Custotal   && Calculo do total de custo total p/ cl.fiscal
		Totr_Qt      += Quant
		Totr_Cu      += cus_uni
		Totr_Ct      += Custotal
		// 
   	SKIP
		/****If Origem#corg  .AND. TOT_ORIG#0 
		   nLin++
			@ nLin,01 say 'TOTAL DO STATUS----------->'
			@ nLin,01 say 'TOTAL DO STATUS----------->'
			@ nLin,35 say Tot_Stat
			@ nLin,47 say 'ITEM(NS)'
      	@ nLin,116 say Tots_CustTot  pict '@E 99,999,999,999.99'
      	Tot_Stat:=Tots_Quant:=Tots_Quant:=Tots_CustUnit:=Tots_CustTot:=0
         Status:=tipo
  			nLin ++
  			@ nLin,001 say 'TOTAL DA ORIGEM----------->'
			@ nLin,001 say 'TOTAL DA ORIGEM----------->'
  			@ nLin,035 say Tot_Orig
 			@ nLin,047 say 'ITEM(NS)'
			@ nLin,116 say Tot_CustTot  pict '@E 99,999,999,999.99'
			Tot_Orig:=Tot_Quant:=Tot_Quant:=Tot_CustUnit:=Tot_CustTot:=0
			Origem := Corg
		endif	
		If Status#tipo .AND. TOT_STAT#0
			nLin++
			@ nLin,01 say 'TOTAL DO STATUS----------->'
			@ nLin,01 say 'TOTAL DO STATUS----------->'
			@ nLin,35 say Tot_Stat
			@ nLin,47 say 'ITEM(NS)'
      	@ nLin,116 say Tots_CustTot  pict '@E 99,999,999,999.99'
      	Tot_Stat:=Tots_Quant:=Tots_Quant:=Tots_CustUnit:=Tots_CustTot:=0
         Status:=tipo
      Endif**************/
		//
		//
		If nLin > 62
			lCab := .T.
		EndIf	
	Enddo			
  	// Total Geral 
	nLin++
	@ nLin,001 say 'TOTAL GERAL--------------->'
	@ nLin,001 say 'TOTAL GERAL--------------->'
	@ nLin,038 say Tot_Itens pict "@E 999,999"
	@ nLin,047 say 'ITEM(NS) LIDOS'
	@ nLin,067 say Tot_Impres pict "@E 999,999"
	@ nLin,075 say "ITEM(NS) IMPRESSOS"
  	@ nLin,116 say TotR_Ct   pict '@E 99,999,999,999.99'
  	// ********************* Resumo por origem ***************************
	Eject
  	Set Device to Screen
	Cur := setcursor(1)
	RestScreen(0,0,lastrow(),lastcol(),cOldScreen)
End  
// Finalizar
Setcursor(cur)
Setcor(cor)
Set device to screen
RestScreen(0,0,lastrow(),lastcol(),cOldScreen)
Dbcloseall()
Return(nil)
// FIM
