
// Gera arquivo para confeccao de graficos
// Alex - 01/07/95

#define FR "ÖÄ·º½ÄÓº "

LOCAL cTela:=SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
      cTela1 ,;
		cCor:=SETCOLOR("B/W,W+/Bg,,,B/W"),;
		nCursor:=SETCURSOR(1) ,;
		cFornecedor := 0 ,;
		cDatin :=  CTOD('  /  /  ') ,;
		cDatfi :=  CTOD('  /  /  ') ,;
		cComponente := SPACE(14)      ,;
		cDefeito := 0   ,;
		cFase := 0   ,;
		nQuantidade:=0 ,;
		wdesc ,;
		cArquivo:=SPACE(30) ,;
		aDefeito:={}  ,;
		aLegenda:={}  ,;
		dDataI := dDataF := CTOD('  /  /  '),;
		aDef ,nItem,x,y, nCord,I,OK,wFor,wPro,wDef,;
		H_bot_A,H_bot_B,nTecla,;
		cod_bot := 0,;
		H_bot_C,;
		H_bot_D,;
		H_bot_E

ARQNTX("SIPCMAT",.F.)
ARQNTX("SIPTDEF",.F.)
ARQNTX("SIPCFOR",.F.)
ARQNTX("SIPCPRO",.F.)
ARQNTX("SQTTFAS",.F.)
ARQNTX("SQTCREC",.F.)
ARQNTX("SIPTENG",.F.)
SELECT("SQTCREC")

DO WHILE LASTKEY() # 27
   SELECT("SQTCREC")
	DBSETORDER(6)
   SQTCREC->(DBGOTOP())	
	DispBox(08,18,15,63,FR)
	@ 10,22 SAY 'Fornecedor..:' GET cFornecedor PICTURE '99999999' VALID Existe(cFornecedor,"Fornecedor nÆo cadastrado",.F.,"SIPCFOR") .AND. EVAL({|| wFor:=SIPCFOR->APELIDO ,.T.})
	@ 11,22 SAY 'Componente..:' GET cComponente PICTURE '@!' VALID EVAL({||IIF(!EMPTY(cComponente),Existe(cComponente,"Componente nÆo cadastrado",.F.,"SIPCMAT") .AND. EVAL({||wPro:=SIPCMAT->DSC1, .T.}), .T.) })
	@ 12,22 SAY 'Defeito ....:' GET cDefeito  PICTURE '99999' VALID EVAL({||IIF(!EMPTY(cDefeito),Existe(cDefeito,"Defeito nÆo cadastrado",.F.,"SIPTDEF") .AND. EVAL({|| wDef:=SIPTDEF->DSC,.T.}), .T. )  })
	@ 13,22 SAY 'Periodo ....:' GET cDatin  PICTURE "@D"    
	@ 13,col()+5 GET cDatfi PICTURE "@D"                   
	READ
	IF LASTKEY() == 27
	   EXIT
	ENDIF 
   cTela1 := SAVESCREEN( 0, 0, MAXROW(), MAXCOL())
	M_DISPLAY( "Verificando arquivo " ,79)
  	IF SQTCREC->(DBSEEK(STR(cFornecedor,8)))
		DO WHILE  SQTCREC->FORNECEDOR == cFornecedor .AND. SQTCREC->(!EOF()) 
/*		   @ 20,2 SAY SQTCREC->DATA
			@ 21,2 SAY SQTCREC->FORNECEDOR
			@ 22,2 SAY SQTCREC->PARTNUMBER
			@ 23,2 SAY SQTCREC->DEFEITO
			INKEY(0)  	*/
		   IF !EMPTY(cComponente) 
				IF SQTCREC->PARTNUMBER # cComponente
		      	SQTCREC->(DBSKIP())
					LOOP
				ENDIF
			ENDIF
	  	   IF !EMPTY(cDefeito) 
			   IF SQTCREC->DEFEITO # cDefeito 
			      SQTCREC->(DBSKIP())
					LOOP
				ENDIF
			ENDIF	
		   IF !EMPTY(cDatin) .AND. !EMPTY(cDatfi) 
			   IF SQTCREC->DATA < cDatin .OR. SQTCREC->DATA > cDatfi 
			      SQTCREC->(DBSKIP())
					LOOP
				ENDIF
			ENDIF		
			nItem:=ASCAN(aDefeito,{|aDef| aDef[1]=SQTCREC->DEFEITO }) 
			IF nItem == 0
				AADD(aDefeito,{ SQTCREC->DEFEITO, SQTCREC->QUANTIDADE })
	  		ELSE
	   		aDefeito[nItem,2]+= SQTCREC->QUANTIDADE
			ENDIF	
			SQTCREC->(DBSKIP())
		ENDDO	
  	ENDIF	
	IF LEN(aDefeito) == 0
		SETCURSOR(nCursor)
 		RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela1)		
		M_DISPLAY("Defeitos nao encotrados",79)
	   LOOP
	ENDIF
   SETCURSOR(0)
	// Tenta inicializar o modo grafico no modo 640x480 c/ 256 cores
	Tplaca := BC_CPLACA()
	ok = BC_INIC(BC_CPLACA())
	if ok = 0
	   SETCOLOR("W+/N")
	   ? "ERRO. Codigo retornado pela BC_ERRO: "
	   ?? BC_ERRO()
	   ? "OBS: este exemplo funciona apenas no modo 640x480 c/ 256 cores."
		INKEY(0)
		BC_FIM()                  && finaliza contexto grafico da CLBC
		RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
		DBCLOSEALL()
   	Return
	endif
	
	declare  vettit[2]   
	vetleg := {}
	BC_GABJAN(.0, .0, 1, 1 )         //"","S:\CLBC30\EX\cordi256.pcx" ) 	//MONTAN16.PCX")
//	BC_GDGRAF(23, "", -1)   //,,19,20)    // define cenario transparente
/*  	BC_GDGRAD(15, 2) */              // ativa grade nos graficos
	vetleg := {"Qualidade"}
	vettit[1] =PADC("Grafico dos maiores defeitos do Fornecedor:",50)
	vettit[2] =PADC(alltrim(str(cFornecedor,8))+' '+wFor,50)
	aDefeito := ASORT(aDefeito,,, { |x,y| x[2] > y[2] })
	aLegenda := aDefeito
	defp := {}
	defq := {}
	DEF  := {}
	teste := {}
*	AADD(DEF,"")       
	FOR nItem:=1 TO len(aDefeito)  
		AADD(DEF,alltrim(str(aDefeito[nItem,1],5)))
		AADD(DEFP,aDefeito[nItem,2])
	NEXT	
*	AADD(DEF,"")    
	BC_GDMOLD(3,2,.001)	 	
   BC_GDPLEGE(1,2,.01,.35,.2,.4 )
	BC_GDPTITU(1,.1,.9,.8,.15)    //,,.9)
	BC_GDTITU(15,.012,.024)
	BC_GDGRAF(23, "", 3,"")
   BC_GEIXOS2 ("","","Defeito","Quantidade")
	BC_GAREA(DEFP,"",def,vetleg,vettit,9)         
	nTipgraf := 'A'
	SELECT("SIPTDEF")
   DBSETORDER(1)
   SIPTDEF->(DBGOTOP())
	nCord := .65
	aLegenda := ASORT(aLegenda,,, { |x,y| x[1] < y[1] })
	for i := 1 to len(aLegenda)
       SIPTDEF->(DBGOTOP())
	    IF ( SIPTDEF->(DBSEEK(aLegenda[I,1])) )
			 wdesc := substr(SIPTDEF->DSC,1,10)
	       BC_TEXTM(.04,nCord,ltrim(str(aLegenda[i,1],5))+' '+wdesc)
			 nCord :=(nCord-.03)
	    ENDIF	 
   next		
	Hbot_A := BC_CRIABOT(.02,.25,"","",2,ASC("I"),"~Imprimi")
   Hbot_B := BC_CRIABOT(.02,.20,"","",2,ASC("S")," ~Saida ")
   Hbot_C := BC_CRIABOT(.02,.15,"","",2,ASC("L")," ~Linha ")
   Hbot_D := BC_CRIABOT(.02,.10,"","",2,ASC("A")," ~Area  ")
   Hbot_E := BC_CRIABOT(.02,.05,"","",2,ASC("B")," ~Barra ")	
	DO WHIL .T.
		BC_LEMOUSE(@cod_bot,"",@nTecla) 
		IF cod_bot == Hbot_A
	      GRAFICO1(DEFP,teste,def,aLegenda,vettit,vetleg,nTipgraf)
			BC_GFEJAN()
			BC_ELIMBOT()
			BC_GABJAN(.0, .0, 1, 1 )  
			BC_GCORES(0)
			BC_DMOUSE(0)
			BC_GDMOLD(3,2,.001)	 	
		   BC_GDPLEGE(1,2,.01,.35,.2,.4 )
			BC_GDPTITU(1,.1,.9,.8,.15)  
		 	BC_GDTITU(15,.012,.024) 
		   BC_GDGRAF(23, "", 3,"")  
	   	BC_GEIXOS2 ("","","Defeito","Quantidade")    					
			IF nTipgraf == 'A'
			 	BC_GAREA(DEFP,"",DEF,vetleg,vettit,9)              			
			ELSEIF nTipgraf == 'B'
			 	BC_GBARRA(DEFP,"",DEF,vetleg,vettit,9)              			
			ELSEIF nTipgraf == 'L'
			 	BC_GLINHA(DEFP,"",DEF,vetleg,vettit,9)              			
			ENDIF
			nCord := .65
			aLegenda := ASORT(aLegenda,,, { |x,y| x[1] < y[1] })
			for i := 1 to len(aLegenda)
		       SIPTDEF->(DBGOTOP())
			    IF ( SIPTDEF->(DBSEEK(aLegenda[I,1])) )
					 wdesc := substr(SIPTDEF->DSC,1,10)
			       BC_TEXTM(.04,nCord,ltrim(str(aLegenda[i,1],5))+' '+wdesc)
					 nCord :=(nCord-.03)
			    ENDIF	 
		   next	
	 		Hbot_A := BC_CRIABOT(.02,.25,"","",2,ASC("I"),"~Imprimi")
		   Hbot_B := BC_CRIABOT(.02,.20,"","",2,ASC("S")," ~Saida ")
		   Hbot_C := BC_CRIABOT(.02,.15,"","",2,ASC("L")," ~Linha ")
		   Hbot_D := BC_CRIABOT(.02,.10,"","",2,ASC("A")," ~Area  ")
		   Hbot_E := BC_CRIABOT(.02,.05,"","",2,ASC("B")," ~Barra ")
		ENDIF
		IF cod_bot == Hbot_B
         exit   
		ENDIF		
		IF cod_bot # Hbot_A .and. cod_bot # Hbot_B
			BC_GFEJAN()
			BC_ELIMBOT()
			BC_GABJAN(.0, .0, 1, 1 )  
			BC_GDMOLD(3,2,.001)	 	
		   BC_GDPLEGE(1,2,.01,.35,.2,.4 )
			BC_GDPTITU(1,.1,.9,.8,.15)  //,,.9)
		 	BC_GDTITU(15,.012,.024) 
		   BC_GDGRAF(23, "", 3,"")  
		   BC_GEIXOS2 ("","","Defeito","Quantidade")    		
			IF cod_bot == Hbot_C
			 	BC_GLINHA(DEFP,"",DEF,vetleg,vettit,9)              
				nTipgraf := 'L'
			ENDIF		
			IF cod_bot == Hbot_D
				 	BC_GAREA(DEFP,"",DEF,vetleg,vettit,9)              
					nTipgraf := 'A'
			ENDIF		
			IF cod_bot == Hbot_E
			 	BC_GBARRA(DEFP,"",DEF,vetleg,vettit,9)              
				nTipgraf := 'B'
			ENDIF		
			nCord := .65
			aLegenda := ASORT(aLegenda,,, { |x,y| x[1] < y[1] })
			for i := 1 to len(aLegenda)
		       SIPTDEF->(DBGOTOP())
			    IF ( SIPTDEF->(DBSEEK(aLegenda[I,1])) )
					 wdesc := substr(SIPTDEF->DSC,1,10)
			       BC_TEXTM(.04,nCord,ltrim(str(aLegenda[i,1],5))+' '+wdesc)
					 nCord :=(nCord-.03)
			    ENDIF	 
		   next	
			Hbot_A := BC_CRIABOT(.02,.25,"","",2,ASC("I"),"~Imprimi")
	  	 	Hbot_B := BC_CRIABOT(.02,.20,"","",2,ASC("S")," ~Saida ")
	  	 	Hbot_C := BC_CRIABOT(.02,.15,"","",2,ASC("L")," ~Linha ")
	  	 	Hbot_D := BC_CRIABOT(.02,.10,"","",2,ASC("A")," ~Area  ")
	  		Hbot_E := BC_CRIABOT(.02,.05,"","",2,ASC("B")," ~Barra ")
		ENDIF	
	ENDDO	
/* BC_LIMPA(0)*/
	BC_GFEJAN()
	BC_ELIMBOT()
	BC_FIM()                 // Finaliza contexto grafico da CLBC
	BC_LIBCTR(Tplaca)       // Libera a placa de video p/ proximo grafico
	RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela1)
	aDefeito := {}
ENDDO	
DBCLOSEALL()
RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
SETCURSOR(nCursor)
SETCOLOR(cCor)
RETURN(NIL)

			
