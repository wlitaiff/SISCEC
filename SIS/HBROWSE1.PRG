// *****************
// Hawk Browser v1.0
// Copyright (c) 1994,1995 - Hawk Software
// Roberto Falc„o Rocha

#include "INKEY.CH"
#include "CURSOR.CH"
#include "HBROWSE.CH"
#include "BOX.CH"

STATIC nLinhaV

// Funcao HBrowseDB
// Parametros:
//            nLinI       -> Linha inicial da janela
//            nColI       -> Coluna inicial da janela
//            nLinF       -> Linha final da janela
//            nColF       -> Coluna final da janela
//            cTitulo     -> Titulo do Browse
//            aCabecalhos -> Vetor com o cabecalho do Objeto Browse
//            aDados      -> Vetor com os nomes do campo ou "code blocks" a serem apresentados
//            aFormatos   -> Vetor com as "pictures" a serem apresentadas
//            nTR         -> Tempo de "refresh"
//            lEspecial   -> Verificador de opcao
// Objetivo:  Cria um Objeto TBrowse

FUNCTION HBrowseDB( nLinI, nColI, nLinF, nColF, cTitulo, aCabecalhos, aDados, aFormatos, nTR, lEspecial )
	LOCAL oBrowse  ,;
			oColuna  ,;
			cTela    ,;
			nCursor  ,;
			cCor     ,;
			nContador,;
			nTecla   ,;
			nLLRc    ,;
			nLRec    ,;
			nTempo	,;
			nSpace1  ,;
			nSpace2  ,;
			aJanela  ,;
			aDisplay ,;
			hBarra   ,;
			_nLin    ,;
			_nCol    ,;
         wbox := CHR(218)+CHR(196)+CHR(191)+CHR(179)+CHR(217)+CHR(196)+CHR(192)+CHR(179)+' ',;
			TEXTO    ,;
		 	TELAS    ,;
			CAMPO
	
	// Tempo de "refresh"
	IF nTR == NIL
		nTR := 10
	ENDIF	
	
	// Tipo de Browse
	IF lEspecial == NIL
		lEspecial := .T.
	ENDIF	
	
	// Verifica linhas e colunas
	// Linha inicial
	IF nLinI < 0
		nLinI := -nLinI
	ENDIF	
	IF nLinI > MAXROW()
		nLinI := MAXROW()
	ENDIF	
	// Coluna inicial
	IF nColI < 0
		nColI := -nColI
	ENDIF	
	IF nColI > MAXCOL()
		nColI := MAXCOL()
	ENDIF	
	// Linha Final
	IF nLinF < 0
		nLinF := -nLinF
	ENDIF	
	IF nLinF > MAXROW()
		nLinF := MAXROW()
	ENDIF	
	// Coluna Final
	IF nColF < 0
		nColF := -nColF
	ENDIF	
	IF nColF > MAXCOL()
		nColF := MAXCOL()
	ENDIF	
	
	// Valida parametros de linha e coluna (PARTE I)
	IF nLinI > nLinF
		nAux  := nLinF
		nLinF := nLinI 	
		nLinI := nAux
	ENDIF	
	IF nColI > nColF
		nAux := nColF
		nColF := nColI 	
		nColI := nAux
	ENDIF	
	
	// Valida parametros de linha e coluna (PARTE II)
	IF (nLinF - nLinI) + 1 < HB_MINLIN
		IF nLinI > MAXROW() - nLinF
			nLinI -= HB_MINLIN - ((nLinF - nLinI) + 1)
		ELSE
			nLinF += HB_MINLIN - ((nLinF - nLinI) + 1)
		ENDIF
	ENDIF			
	IF (nColF - nColI) + 1 < HB_MINCOL
		IF nColI > MAXCOL() - nColF
			nColI -= HB_MINCOL - ((nColF - nColI) + 1)
		ELSE
			nColF += HB_MINCOL - ((nColF - nColI) + 1)
		ENDIF
	ENDIF			
		
	// Salva tela, cursor e cores para posterior restaura‡„o
	cTela := SAVESCREEN( nLinI, nColI, nLinF, nColF )
	nCursor := SETCURSOR( APAGADO )		
	cCor    := SETCOLOR()
	
	// Cria a tela do Browse
	aDisplay := HBDisplay(nLinI,nColI,nLinF,nColF,cTitulo)
	hBarra  := aDisplay[HB_BARRA]
	nSpace1 := aDisplay[HB_SPACE1]
	nSpace2 := aDisplay[HB_SPACE2]
	nEl := 1
	
	// Cria um objeto TBrowse
	oBrowse := TBrowseDB( nLinI+1, nColI+1, nLinF-2, nColF-1 )
	
	// Separadores
	oBrowse : headSep := HB_HEADSEP
	oBrowse : colSep  := HB_COLSEP
	oBrowse : footSep := HB_FOOTSEP
	oBrowse : colorSpec := HBC_DADOS+HBC_DELETADO
	
	// Cria objeto TBColumn
	IF lEspecial

		FOR nContador := 1 TO LEN( aDados )
		
			 oColuna := TBColumnNew( aCabecalhos[nContador], FIELDWBLOCK( aDados[nContador], SELECT() ) )
   		 oBrowse : addColumn( oColuna )
			 IF aFormatos#NIL
		 	    oColuna : picture := aFormatos[nContador]
	       ENDIF	
			 oColuna : colorBlock := { || IF(DELETED(),{1,2},{4,3}) }
		
		NEXT
		
	ELSE
	
		FOR nContador := 1 TO LEN( aDados )
		
			oBrowse : addColumn( aDados[nContador] )
			IF aFormatos#NIL
				aDados[nContador] : picture := aFormatos[nContador]
			ENDIF	
			aDados[nContador] : colorBlock := { || IF(DELETED(),{1,2},{4,3}) }
			
		NEXT
		
	ENDIF
	
	// Define vetor com as variaveis e objetos a serem usadas pela funcoes auxiliares
	aJanela := {oBrowse,cTela,cTitulo,.F.}
	
	// Loop para verifica‡„o das multiplas teclagens

	DO WHILE .T.
	
		// Estabiliza o objeto TBrowse
		DO WHILE !( oBrowse : stabilize() )
			nTecla := INKEY()
			IF nTecla # 0 // Alguma tecla foi pressionada durante a estabiliza‡„o.
				EXIT		  // Abandona estabiliza‡„o para executar a tecla.
			ENDIF
		ENDDO	
		
		// Verifica se objeto TBrowse esta est vel
		IF oBrowse : stable
			
			// Pega posi‡Æo do cursor
			_nCol := COL()
			_nLin := ROW()
			
			// Atualiza barra de rolagem
			AtuBarra( hBarra, nEl, LASTREC() )
					
			// Informa o registro corrente/numeros de registro existentes no arquivo
			nLRec := LEN( STR( RECNO() ) )	
			nLLRc := LEN( STR( LASTREC() ) )
			cRegistros := "Reg: " + ALLTRIM( STR( RECNO(), nLRec ) ) + "/" + ALLTRIM( STR( LASTREC(), nLLRc ) )
			SETCOLOR(HBC_STATUS )
			DEVPOS( nLinF-1, nColI )
			DEVOUT( SUBST(cRegistros + SPACE( nSpace1 - LEN(cRegistros) ),1,nSpace1 ) )
			
			// Informa se o registro esta deletado
			IF DELETED()
				SETCOLOR( HBC_DELETADO )
				DEVPOS( nLinF-1, nColI + nSpace1 )
				DEVOUT( SUBST(PADR("Registro deletado",(nColF - nSpace1) + 1),1,nSpace2 ) )
				SETCOLOR(HBC_DADOS)
			ELSE
				SETCOLOR( HBC_RODAPE )
				DEVPOS( nLinF-1, nColI + nSpace1 )
				DEVOUT( SPACE( nSpace2 ) )
				SETCOLOR(HBC_DADOS)
			ENDIF	
			
			// Verifica se foi alcancado o inicio ou o fim do arquivo
			IF oBrowse : hitTop .OR. oBrowse : hitBottom
				TONE( 3600, .2 )
				TONE( 3700, .2 )
			ENDIF	
			
			// Espera tecla ser pressionada
			// Resfresca os dados do TBrowse
			DO WHILE (nTecla := INKEY()) == 0
				IF nTempo == NIL
					nTempo := SECONDS()
				ENDIF
				IF (SECONDS() - nTempo) >=	nTR
					nTecla := K_ALT_R
					EXIT
				ENDIF	
			ENDDO	
			
			nTempo := SECONDS()
			
 		ENDIF
		
		// Processa teclas pressionadas	
		DO CASE
			CASE nTecla == K_UP            //Seta para cima
				oBrowse : up()
				nEl--
			CASE nTecla == K_DOWN	       //Seta para baixo
				oBrowse : down()
				nEl++
			CASE nTecla == K_LEFT			 //Seta para esquerda
				oBrowse : left()
			CASE nTecla == K_RIGHT		    //Seta para direita
				oBrowse : right()		
			CASE nTecla == K_HOME		    //Primeira coluna do TBrowse (vis¡vel)
				oBrowse : home()
			CASE nTecla == K_END			    //Ultima coluna do TBrowse (vis¡vel)
				oBrowse : end()	
			CASE nTecla == K_PGUP			 //Uma tela para cima
				oBrowse : pageUp()	      
				nEl := nEl - ( (nLinF - 3) - (nLinI + 3) )
			CASE nTecla == K_PGDN          //Uma tela para cima
				oBrowse : pageDown()
				nEl := nEl + ( (nLinF - 3) - (nLinI + 3) )
		 	CASE nTecla == K_CTRL_PGUP     //Inicio do arquivo
				oBrowse : goTop()
				nEl := 1
			CASE nTecla == K_CTRL_PGDN     //Inicio do arquivo
				oBrowse : goBottom()
				nEl := LASTREC()
			CASE nTecla == K_CTRL_HOME     //Primeira coluna real
				oBrowse : panHome()
			CASE nTecla == K_CTRL_END		 //Ultima coluna real
				oBrowse : panEnd()					
			CASE nTecla == K_CTRL_LEFT     //Desloca janela para esquerda 
				oBrowse : panLeft()
			CASE nTecla == K_CTRL_RIGHT    //Desloca janela para direita
				oBrowse : panRight()
			CASE nTecla	== K_ALT_R         // Refresca a edi‡„o dos dados
				oBrowse : refreshAll()		
			CASE nTecla == K_ALT_DIR	    // Aumenta o tamanho da coluna
				oBrowse:getColumn(oBrowse:colPos):width :=;
				oBrowse:colWidth( oBrowse:colPos) + 1
				oBrowse:configure()	
			CASE nTecla == K_ALT_ESQ       // Diminui o tamanho da coluna
				oBrowse:getColumn(oBrowse:colPos):width :=;
				oBrowse:colWidth( oBrowse:colPos) - 1
				oBrowse:configure()		
			CASE nTecla == K_ENTER
				IF RLOCK()
					SETCURSOR(1)
					oColumn := oBrowse:getColumn( oBrowse:colPos ) 
*					IF IF(TYPE(_Var := EVAL( oColumn:block ) ) == "N",.T.,_Var#"<memo>")
               _Var := EVAL( oColumn:block ) 
					IF VALTYPE( _Var ) == "N" .OR. _Var#"<memo>"
						oGet  := GETNEW( _nLin, _nCol , oColumn:block,, oColumn:picture,oBrowse:colorSpec )
   					READMODAL( { oGet } )
					ELSE 
						SAVE SCREEN TO TELAS
  	         		SetCor("W+/B,W+/BG+,,,RG+/B")
		    			Dispbox(14,0,21,79,wbox)
						CAMPO := acabecalhos[oBrowse:ColPos]
     	      		texto :=memoedit( &CAMPO , 15, 1, 20, 78, .T. )
	         		EVAL(oColumn:block,texto)
					Endif 	
					IF UPDATED()
						DBCOMMIT()
						DBUNLOCK()
						oBrowse:refreshCurrent()
					ENDIF	
 					SETCURSOR(APAGADO)
               RESTORE SCREEN FROM TELAS
				ELSE
					Alert("Opera‡Æo nÆo pode ser completada",{"OK"})
				ENDIF		
   		CASE nTecla == -1
			     Inclusao( oBrowse )
			CASE nTecla == K_ALT_MINUS     // Menu do Tbrowse
				
				aJanela := HBMenu( aJanela )				
				
				// Restaura dados alterados
				oBrowse := aJanela[HB_OBJETO]
				cTela   := aJanela[HB_TELA]
				nLinI := oBrowse:nTop    - 1
				nColI := oBrowse:nLeft   - 1
				nLinF := oBrowse:nBottom + 2
				nColF := oBrowse:nRight  + 1
				aDisplay:=HBDisplay(nLinI,nColI,nLinF,nColF,cTitulo)
				hBarra :=aDisplay[HB_BARRA]
				nSpace1:=aDisplay[HB_SPACE1]
				nSpace2:=aDisplay[HB_SPACE2]
				
				IF aJanela[HB_FECHA]
					RESTSCREEN( nLinI, nColI, nLinF, nColF, cTela )
					SETCURSOR( APAGADO )		
					cCor    := SETCOLOR()	
					EXIT
				ENDIF
					
			CASE nTecla == K_ESC          //Abandona TBrowse
				RESTSCREEN( nLinI, nColI, nLinF, nColF, cTela )
				SETCURSOR( APAGADO )		
				cCor    := SETCOLOR()	
				EXIT
		ENDCASE		
		
		// Atualiza barra de rolagem
		AtuBarra( hBarra, nEl, LASTREC() )		
		
	ENDDO		
RETURN( NIL )

// Funcao HBrowseAr
// Parametros:
//            nLinI       -> Linha inicial da janela
//            nColI       -> Coluna inicial da janela
//            nLinF       -> Linha final da janela
//            nColF       -> Coluna final da janela
//            cTitulo     -> Titulo do Browse
//            aCabecalhos -> Vetor com o cabecalho do Objeto Browse
//            aDados      -> Vetor com os "code blocks" a serem apresentados
//            aFormatos   -> Vetor com as "pictures" a serem apresentadas
//            aEspecial   -> Vetor especial
// Objetivo:  Cria um Objeto TBrowse

FUNCTION HBrowseAr( nLinI, nColI, nLinF, nColF, cTitulo, aCabecalhos, aDados, aFormatos, aEspecial )
	LOCAL oBrowse  ,;
			oColuna  ,;
			cTela    ,;
			nCursor  ,;
			cCor     ,;
			nContador,;
			nTecla   ,;
			nLLRc    ,;
			nLRec    ,;
			nTempo	,;
			nSpace1  ,;
			nSpace2  ,;
			aJanela  ,;
			aDisplay ,;
			lEspecial,;
			hBarra
	
		
	// Tipo de Browse
	IF aEspecial == NIL
		lEspecial := .F.
	ELSE
		lEspecial := .T.	
	ENDIF	
	
	// Verifica linhas e colunas
	// Linha inicial
	IF nLinI < 0
		nLinI := -nLinI
	ENDIF	
	IF nLinI > MAXROW()
		nLinI := MAXROW()
	ENDIF	
	// Coluna inicial
	IF nColI < 0
		nColI := -nColI
	ENDIF	
	IF nColI > MAXCOL()
		nColI := MAXCOL()
	ENDIF	
	// Linha Final
	IF nLinF < 0
		nLinF := -nLinF
	ENDIF	
	IF nLinF > MAXROW()
		nLinF := MAXROW()
	ENDIF	
	// Coluna Final
	IF nColF < 0
		nColF := -nColF
	ENDIF	
	IF nColF > MAXCOL()
		nColF := MAXCOL()
	ENDIF	
	
	// Valida parametros de linha e coluna (PARTE I)
	IF nLinI > nLinF
		nAux  := nLinF
		nLinF := nLinI 	
		nLinI := nAux
	ENDIF	
	IF nColI > nColF
		nAux := nColF
		nColF := nColI 	
		nColI := nAux
	ENDIF	
	
	// Valida parametros de linha e coluna (PARTE II)
	IF (nLinF - nLinI) + 1 < HB_MINLIN
		IF nLinI > MAXROW() - nLinF
			nLinI -= HB_MINLIN - ((nLinF - nLinI) + 1)
		ELSE
			nLinF += HB_MINLIN - ((nLinF - nLinI) + 1)
		ENDIF
	ENDIF			
	IF (nColF - nColI) + 1 < HB_MINCOL
		IF nColI > MAXCOL() - nColF
			nColI -= HB_MINCOL - ((nColF - nColI) + 1)
		ELSE
			nColF += HB_MINCOL - ((nColF - nColI) + 1)
		ENDIF
	ENDIF			
		
	// Salva tela, cursor e cores para posterior restaura‡„o
	cTela := SAVESCREEN( nLinI, nColI, nLinF, nColF )
	nCursor := SETCURSOR( APAGADO )		
	cCor    := SETCOLOR()
	
	// Cria a tela do Browse
	aDisplay := HBDisplay(nLinI,nColI,nLinF,nColF,cTitulo)
	hBarra  := aDisplay[HB_BARRA]
	nSpace1 := aDisplay[HB_SPACE1]
	nSpace2 := aDisplay[HB_SPACE2]
	nEl := 1
	
	// Cria um objeto TBrowse
	oBrowse := TBrowseNew( nLinI+1, nColI+1, nLinF-2, nColF-1 )
	
	// Separadores
	oBrowse : headSep := HB_HEADSEP
	oBrowse : colSep  := HB_COLSEP
	oBrowse : footSep := HB_FOOTSEP
	oBrowse : colorSpec := HBC_DADOS+HBC_DELETADO
	
	nLinhaV := 1
	
	// Cria objeto TBColumn
	IF !lEspecial
		
		FOR nContador := 1 TO LEN( aCabecalhos )
				
			oColuna := TBColumnNew( aCabecalhos[nContador], VetorBloco( aDados,nContador ) )
			oBrowse : addColumn( oColuna )
			oColuna : picture := aFormatos[nContador]
			
		NEXT
		
	ELSE
	
		FOR nContador := 1 TO LEN( aCabecalhos )
		
			oBrowse : addColumn( aEspecial[nContador] )
			aDados[nContador] : picture := aFormatos[nContador]
			aDados[nContador] : colorBlock := { || IF(DELETED(),{1,2},{4,3}) }
			
		NEXT
		
	ENDIF
	
	// Define variaveis particulares do Browse
	oBrowse:goTopBlock := { || nLinhaV := 1 }
	oBrowse:goBottomBlock := { || nLinhaV := LEN(aDados) }
	oBrowse:skipBlock := { | nSaltos | PulaVetor( nSaltos,aDados) }
	
	
	// Define vetor com as variaveis e objetos a serem usadas pela funcoes auxiliares
	aJanela := {oBrowse,cTela,cTitulo,.F.}
	
	// Loop para verifica‡„o das multiplas teclagens

	DO WHILE .T.

		// Estabiliza o objeto TBrowse
		DO WHILE !( oBrowse : stabilize() )
			nTecla := INKEY()
			IF nTecla # 0 // Alguma tecla foi pressionada durante a estabiliza‡„o.
				EXIT		  // Abandona estabiliza‡„o para executar a tecla.
			ENDIF	
		ENDDO	
		
		// Verifica se objeto TBrowse esta est vel
		IF oBrowse : stable
			
			// Atualiza barra de rolagem
			AtuBarra( hBarra, nEl, LEN(aDados) )
					
			// Informa o registro corrente/numeros de registro existentes no arquivo
			nLRec := LEN( STR( nLinhaV ) )	
			nLLRc := LEN( STR( LEN(aDados) ) )
			cRegistros := "Reg: " + ALLTRIM( STR( nLinhaV, nLRec ) ) + "/" + ALLTRIM( STR( LEN( aDados ), nLLRc ) )
			SETCOLOR(HBC_STATUS )
			DEVPOS( nLinF-1, nColI )
			DEVOUT( SUBST(cRegistros + SPACE( nSpace1 - LEN(cRegistros) ),1,nSpace1 ) )
			
			// Verifica se foi alcancado o inicio ou o fim do arquivo
			IF oBrowse : hitTop .OR. oBrowse : hitBottom
				TONE( 3600, .2 )
				TONE( 3700, .2 )
			ENDIF	
			
			// Espera tecla ser pressionada
			DO WHILE (nTecla := INKEY()) == 0
			ENDDO	
			
		ENDIF
		
		// Atualiza barra de rolagem
			AtuBarra( hBarra, nEl, LEN(aDados) )
			
		// Processa teclas pressionadas	
		DO CASE
			CASE nTecla == K_UP            //Seta para cima
				oBrowse : up()
				nEl--
			CASE nTecla == K_DOWN	       //Seta para baixo
				oBrowse : down()
				nEl++
			CASE nTecla == K_LEFT			 //Seta para esquerda
				oBrowse : left()
			CASE nTecla == K_RIGHT		    //Seta para direita
				oBrowse : right()		
			CASE nTecla == K_HOME		    //Primeira coluna do TBrowse (vis¡vel)
				oBrowse : home()
			CASE nTecla == K_END			    //Ultima coluna do TBrowse (vis¡vel)
				oBrowse : end()	
			CASE nTecla == K_PGUP			 //Uma tela para cima
				oBrowse : pageUp()	      
				nEl := nEl - ( (nLinF - 3) - (nLinI + 3) )
			CASE nTecla == K_PGDN          //Uma tela para cima
				oBrowse : pageDown()
				nEl := nEl + ( (nLinF - 3) - (nLinI + 3) )
		 	CASE nTecla == K_CTRL_PGUP     //Inicio do arquivo
				oBrowse : goTop()
				nEl := 1
			CASE nTecla == K_CTRL_PGDN     //Inicio do arquivo
				oBrowse : goBottom()
				nEl := LEN( aDados )
			CASE nTecla == K_CTRL_HOME     //Primeira coluna real
				oBrowse : panHome()
			CASE nTecla == K_CTRL_END		 //Ultima coluna real
				oBrowse : panEnd()					
			CASE nTecla == K_CTRL_LEFT     //Desloca janela para esquerda 
				oBrowse : panLeft()
			CASE nTecla == K_CTRL_RIGHT    //Desloca janela para direita
				oBrowse : panRight()
			CASE nTecla == K_ALT_DIR	    // Aumenta o tamanho da coluna
				oBrowse:getColumn(oBrowse:colPos):width :=;
				oBrowse:colWidth( oBrowse:colPos) + 1
				oBrowse:configure()	
			CASE nTecla == K_ALT_ESQ       // Diminui o tamanho da coluna
				oBrowse:getColumn(oBrowse:colPos):width :=;
				oBrowse:colWidth( oBrowse:colPos) - 1
				oBrowse:configure()		
			CASE nTecla == K_ALT_MINUS     // Menu do Tbrowse
				
				aJanela := HBMenu( aJanela )				
				
				// Restaura dados alterados
				oBrowse := aJanela[HB_OBJETO]
				cTela   := aJanela[HB_TELA]
				nLinI := oBrowse:nTop    - 1
				nColI := oBrowse:nLeft   - 1
				nLinF := oBrowse:nBottom + 2
				nColF := oBrowse:nRight  + 1
				aDisplay:=HBDisplay(nLinI,nColI,nLinF,nColF,cTitulo)
				hBarra :=aDisplay[HB_BARRA]
				nSpace1:=aDisplay[HB_SPACE1]
				nSpace2:=aDisplay[HB_SPACE2]
				
				
				IF aJanela[HB_FECHA]
					RESTSCREEN( nLinI, nColI, nLinF, nColF, cTela )
					SETCURSOR( APAGADO )		
					cCor    := SETCOLOR()	
					EXIT
				ENDIF
					
			CASE nTecla == K_ESC          //Abandona TBrowse
				RESTSCREEN( nLinI, nColI, nLinF, nColF, cTela )
				SETCURSOR( APAGADO )		
				cCor    := SETCOLOR()	
				EXIT
		ENDCASE		
		
		// Atualiza barra de rolagem
		AtuBarra( hBarra, nEl, LEN(aDados) )		
		
	ENDDO		
RETURN( NIL )   

// Cria um code block para vetores
STATIC FUNCTION VetorBloco( aVetor, nColuna )
RETURN { || aVetor[nLinhaV][nColuna] }	

// Saltas as linha do vetor
STATIC FUNCTION PulaVetor( nSaltos, aVetor )

	LOCAL nPulos := 0
	
	IF nLinhaV + nSaltos < 1
		nPulos := -nLinhaV + 1
		nLinhaV := 1
	ELSEIF nLinhaV + nSaltos > LEN (aVetor )
		nPulos := LEN(aVetor) - nLinhaV	
		nLinhaV := LEN(aVetor)
	ELSE
		nPulos := nSaltos
		nLinhaV += nSaltos
	ENDIF

RETURN(nPulos)			


STATIC FUNCTION HBDisplay(nLinI,nColI,nLinF,nColF,cTitulo)
	LOCAL aDisplay := ARRAY(3)
	LOCAL nSpace1,nSpace2
	
	// T¡tulo
	SETCOLOR(HBC_TITULO) 
	@ nLinI,nColI SAY " Ä ³"
	@ nLinI,nColI+4 SAY SUBST(PADC( cTitulo, (( nColF - nColI ) + 1) - 4 ),1,((nColF - nColI) + 1) - 4)
	SETCOLOR(HBC_DADOS)
	@ nLinI+1,nColI CLEAR TO nLinI+1,nColF
	DISPBOX(nLinI+2,nColI,nLinF-2,nColF,B_SINGLE+" ")
	TecFun(nLinF,nColI,SUBST(PADL("^F^1 - Help  ^F^2 - Inclui  ^F^3 - Consulta  ^E^s^c - Sa¡da",( nColF - nColI ) + 6),1,(nColF - nColI) + 6))
	SETCOLOR(HBC_STATUS)
	nSpace1 := INT(((nColF - nColI) + 1) * HB_RELSTATUS)
	nSpace2 := INT(((nColF - nColI) + 1) * HB_RELRODAPE)
	DO WHILE .T.
		IF nSpace1 + nSpace2 < ( (nColF - nColI) + 1 )
			nSpace1 ++
		ELSEIF nSpace1 + nSpace2 > ( (nColF - nColI) + 1 )
			nSpace2 --
		ELSE	
			EXIT
		ENDIF	
	ENDDO	
	@ nLinF-1,nColI SAY SPACE(nSpace1)
	SETCOLOR(HBC_RODAPE)
	@ nLinF-1,nColI + nSpace1 SAY SPACE(nSpace2)
	SETCOLOR(HBC_DADOS)
	
	// Cria barra de rolagem 
	aDisplay[HB_BARRA] := Barra( nLinI + 2, nColF, nLinF - 2 )
	MostraBarra( aDisplay[HB_BARRA] )
	aDisplay[HB_SPACE1] := nSpace1
	aDisplay[HB_SPACE2] := nSpace2
RETURN(aDisplay)	

FUNCTION TecFun(nLin,nCol,cTexto)
	LOCAL aPos:={},;
			nPos:=0,;
			nX:=0
	DO WHILE ((nPos := AT("^",cTexto)) # 0 )
		AADD(aPos,nPos)
		cTexto := STUFF(cTexto,nPos,1,"")
	ENDDO	
	SETCOLOR(HBC_FUNCOES)
	@ nLin,nCol SAY cTexto
	SETCOLOR(HBC_TECLAS)
	FOR nX:=1 TO LEN(aPos)
		@ nLin,(nCol + aPos[nX]) - 1 SAY SUBST(cTexto,aPos[nX],1)
	NEXT	
RETURN(NIL)	
	
STATIC FUNCTION HBMenu( aJanela )
	LOCAL nLinI := aJanela[HB_OBJETO]:nTop    -1
	LOCAL nColI := aJanela[HB_OBJETO]:nLeft   -1
	LOCAL nLinF := aJanela[HB_OBJETO]:nBottom +2
	LOCAL nColF := aJanela[HB_OBJETO]:nRight  +1
	LOCAL mLinI := nLinI
	LOCAL mColI := nColI
	LOCAL nOpcao := 0 
	LOCAL cTela
	
	// Torna difente a cor do t¡tulo para diferenciar
	SETCOLOR(HBC_MBROWSE) 
	@ nLinI,nColI SAY " Ä ³"
	
	// Calcula coordenadas para o menu "-"
	IF (MAXROW() - nLinI + 1) < 9
		mLinI := nLinI - 9
	ENDIF
	IF (MAXCOL() - nColI + 1) < 13
		mColI := nColI - 13
	ENDIF
	
	// Salva a tela do menu
	cTela := SAVESCREEN(mLinI+1,mColI,mLinI+8,mColI+15)
	
	// Menu de opcoes		
	@ mLinI+1,mColI TO mLinI+8,mColI+15
	@ mLinI+6,mColI SAY     "ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´"
	@ mLinI+2,mColI+1 PROMPT "Mover         "
	@ mLinI+3,mColI+1 PROMPT "Tamanho       "
	@ mLinI+4,mColI+1 PROMPT "Minimizar     "
	@ mLinI+5,mColI+1 PROMPT "Maximizar     "
	@ mLinI+7,mColI+1 PROMPT "Fechar     Esc"
	MENU TO nOpcao
	
	// Restaura tela do menu
	RESTSCREEN(mLinI+1,mColI,mLinI+8,mColI+15,cTela)
	
	// Verifica a opcao escolhida
	DO CASE
		CASE nOpcao==1
			aJanela := HBMove(aJanela)
		CASE nOpcao==2
			aJanela := HBTamanho(aJanela)	
		CASE nOpcao==3	
			aJanela[HB_OBJETO]:nBottom	:= nLinI + (HB_MINLIN - 3)
			aJanela[HB_OBJETO]:nRight  := nColI + (HB_MINCOL - 2)
			RESTSCREEN(nLinI,nColI,nLinF,nColF,aJanela[HB_TELA])
			aJanela[HB_TELA]:=SAVESCREEN( nLinI,nColI,nLinI + (HB_MINLIN - 1),nColI+(HB_MINCOL - 1))
		CASE nOpcao==4
			aJanela[HB_OBJETO]:nTop    := 1
			aJanela[HB_OBJETO]:nLeft   := 1
			aJanela[HB_OBJETO]:nBottom	:= MAXROW()-2
			aJanela[HB_OBJETO]:nRight  := MAXCOL()-1
			RESTSCREEN(nLinI,nColI,nLinF,nColF,aJanela[HB_TELA])
			aJanela[HB_TELA]:=SAVESCREEN( 0,0,MAXROW(),MAXCOL())
		CASE nOpcao==5
			aJanela[HB_FECHA] := .T.	
	ENDCASE		
	
	// Restaura tela do titulo	
	SETCOLOR(HBC_TITULO) 
	@ (aJanela[HB_OBJETO]:nTop-1),(aJanela[HB_OBJETO]:nLeft-1) SAY " - ³" 
	
RETURN(aJanela)	

STATIC FUNCTION HBMove( aJanela )

	LOCAL nLinI := aJanela[HB_OBJETO]:nTop    - 1
	LOCAL nColI := aJanela[HB_OBJETO]:nLeft   - 1
	LOCAL nLinF := aJanela[HB_OBJETO]:nBottom + 2
	LOCAL nColF := aJanela[HB_OBJETO]:nRight  + 1
	LOCAL nTecla
	LOCAL cTelaB := aJanela[HB_TELA]
	LOCAL cTelaA
	LOCAL lVer
	
	// Muda titulo para diferenciar
	SETCOLOR(HBC_MVBROWSE) 
	@ nLinI,nColI SAY "<->³" 	 	
	
	// Salva tela para movimenta-la
	cTelaA := SAVESCREEN( nLinI,nColI,nLinF,nColF )
	
	// Processa tecla pressionadas
	DO WHILE (nTecla := INKEY(0)) # K_ESC
		
		// Verifica se comando e v lido
		lVer := .T.
		
		// Verifica tecla pressionada
		DO CASE
			CASE nTecla == K_UP
				IF nLinI	- 1 < 0
					Som(.F.)
					lVer := .F.
				ELSE	
					RESTSCREEN( nLinI,nColI,nLinF,nColF,cTelaB )
					nLinI--
					nLinF--
				ENDIF	
			CASE nTecla == K_DOWN
				IF nLinF	+ 1 > MAXROW()
					Som(.F.)
					lVer := .F.
				ELSE	
					RESTSCREEN( nLinI,nColI,nLinF,nColF,cTelaB )
					nLinI++
					nLinF++
				ENDIF	
			CASE nTecla == K_LEFT
				IF nColI	- 1 < 0
					Som(.F.)
					lVer := .F.
				ELSE	
					RESTSCREEN( nLinI,nColI,nLinF,nColF,cTelaB )
					nColI--
					nColF--
				ENDIF			
			CASE nTecla == K_RIGHT
				IF nColF	+ 1 > MAXCOL()
					Som(.F.)
					lVer := .F.
				ELSE	
					RESTSCREEN( nLinI,nColI,nLinF,nColF,cTelaB )
					nColI++
					nColF++
				ENDIF			
			CASE nTecla == K_ENTER
				Som(.T.)
				EXIT
			OTHERWISE
				Som(.F.)
				lVer := .F.
		ENDCASE						
		
		IF lVer
			cTelaB := SAVESCREEN( nLinI,nColI,nLinF,nColF )
			RESTSCREEN( nLinI,nColI,nLinF,nColF,cTelaA )
		ENDIF	
		
	ENDDO
	aJanela[HB_OBJETO]:nTop    := nLinI + 1
	aJanela[HB_OBJETO]:nLeft   := nColI + 1
	aJanela[HB_OBJETO]:nBottom := nLinF - 2
	aJanela[HB_OBJETO]:nRight  := nColF - 1
	aJanela[HB_TELA] := cTelaB
	
	// restaura t¡tulo
	SETCOLOR(HBC_MBROWSE) 
	@ nLinI,nColI SAY " - ³" 	 	
	
RETURN(aJanela)
	
FUNCTION Som( lTipo )
	IF lTipo 
		TONE(300,1)		
		TONE(100,1)		
		TONE(300,1)		
		TONE(100,1)		
	ELSE
		TONE(100,3)
	ENDIF
RETURN(NIL)			

STATIC FUNCTION HBTamanho( aJanela )
	LOCAL mLinI:=nLinI := aJanela[HB_OBJETO]:nTop    - 1
	LOCAL mColI:=nColI := aJanela[HB_OBJETO]:nLeft   - 1
	LOCAL mLinF:=nLinF := aJanela[HB_OBJETO]:nBottom + 2
	LOCAL mColF:=nColF := aJanela[HB_OBJETO]:nRight  + 1
	LOCAL cTela := aJanela[HB_TELA]
	LOCAL cTelaP:=cTela
	LOCAL cTelaA:= SAVESCREEN(nLinI,nColI,nLinF,nColF)
	LOCAL cTelaM
	LOCAL nTecla
	LOCAL cPosicao := "SDIE"
	LOCAL nPos     := 1
	LOCAL cPos     := SUBST(cPosicao,nPos,1)
	LOCAL nColore
	
	DISPBOX(nLinI,nColI,nLinF,nColF,B_SINGLE,HBC_MOVER)
	cTelaM := SAVESCREEN(nLinI,nColI,nLinF,nColF)
	
	cTelaM := Atributo(nLinI,nColI,nLinF,nColF,cTelaM,cPos)			
	RESTSCREEN(nLinI,nColI,nLinF,nColF,cTelaM)
	
	// Processa tecla pressionadas
	DO WHILE (nTecla := INKEY(0)) # K_ESC
		
		// Verifica se comando e v lido
		lVer := .T.
		
		// Verifica tecla pressionada
		DO CASE
			
			CASE nTecla == K_TAB
				lVer := .F.
				nPos++
				IF nPos>4
					nPos := 1
				ENDIF
				cPos := SUBST(cPosicao,nPos,1)
				
				// Muda borda dos lados para identificar o lado a ser redimensionado
				DO CASE
		
					CASE cPos == "S"
						
						cTelaM := Atributo(nLinI,nColI,nLinF,nColF,cTelaM,"E")			
						cTelaM := Atributo(nLinI,nColI,nLinF,nColF,cTelaM,cPos)			
						
					CASE cPos == "D"	
						
						cTelaM := Atributo(nLinI,nColI,nLinF,nColF,cTelaM,"S")			
						cTelaM := Atributo(nLinI,nColI,nLinF,nColF,cTelaM,cPos)			
						
					CASE cPos == "I"
						
						cTelaM := Atributo(nLinI,nColI,nLinF,nColF,cTelaM,"D")			
						cTelaM := Atributo(nLinI,nColI,nLinF,nColF,cTelaM,cPos)			

					CASE cPos == "E"
					
						cTelaM := Atributo(nLinI,nColI,nLinF,nColF,cTelaM,"I")			
						cTelaM := Atributo(nLinI,nColI,nLinF,nColF,cTelaM,cPos)			
				
				ENDCASE		
				
				// Restaura a tela mudando o lado a ser redimensionado
				RESTSCREEN(nLinI,nColI,nLinF,nColF,cTelaM)
				
			CASE nTecla == K_UP .AND. (cPos=="S" .OR. cPos=="I")
				IF ( nLinI - 1 < 0 .AND. cPos=="S" ) .OR. ((nLinF - nLinI) < HB_MINLIN .AND. cPos=="I" )
					Som(.F.)
					lVer := .F.
				ELSE	
					RESTSCREEN(nLinI,nColI,nLinF,nColF,cTela)
					IF cPos == "S"
						nLinI--
					ELSE
						nLinF--
					ENDIF	
				ENDIF	
			CASE nTecla == K_DOWN .AND. (cPos=="S" .OR. cPos=="I")
				IF (nLinF - nLinI < HB_MINLIN .AND. cPos=="S") .OR. (nLinF	+ 1 > MAXROW() .AND. cPos=="I")
					Som(.F.)
					lVer := .F.
				ELSE
					RESTSCREEN(nLinI,nColI,nLinF,nColF,cTela)
					IF cPos == "S"
						nLinI++
					ELSE
						nLinF++
					ENDIF
				ENDIF	
			CASE nTecla == K_LEFT .AND. (cPos=="E" .OR. cPos=="D")
				IF ( nColI - 1 < 0 .AND. cPos=="E" ) .OR. ((nColF - nColI) < HB_MINCOL .AND. cPos=="D" )
					Som(.F.)
					lVer := .F.
				ELSE	
					RESTSCREEN(nLinI,nColI,nLinF,nColF,cTela)
					IF cPos == "E"
						nColI--
					ELSE
						nColF--
					ENDIF	
				ENDIF	
			CASE nTecla == K_RIGHT .AND. (cPos=="E" .OR. cPos=="D")
				IF (nColF - nColI < HB_MINCOL .AND. cPos=="E") .OR. (nColF + 1 > MAXCOL() .AND. cPos=="D")
					Som(.F.)
					lVer := .F.
				ELSE
					RESTSCREEN(nLinI,nColI,nLinF,nColF,cTela)
					IF cPos == "E"
						nColI++
					ELSE
						nColF++
					ENDIF
				ENDIF	
			CASE nTecla == K_ENTER
				Som(.T.)
				EXIT
			OTHERWISE
				Som(.F.)
				lVer := .F.
		ENDCASE						
		
		IF lVer
			cTela := SAVESCREEN(nLinI,nColI,nLinF,nColF)
			RESTSCREEN(mLinI,mColI,mLinF,mColF,cTelaA)
			DISPBOX(nLinI,nColI,nLinF,nColF,B_SINGLE,HBC_MOVER)
			cTelaM := SAVESCREEN(nLinI,nColI,nLinF,nColF)
			
			// Muda borda dos lados para identificar o lado a ser redimensionado
			cTelaM := Atributo(nLinI,nColI,nLinF,nColF,cTelaM,cPos)			
			RESTSCREEN(nLinI,nColI,nLinF,nColF,cTelaM)
		ENDIF
		
	ENDDO
	RESTSCREEN(mLinI,mColI,mLinF,mColF,cTelaP)
	aJanela[HB_OBJETO]:nTop    := nLinI + 1
	aJanela[HB_OBJETO]:nLeft   := nColI + 1
	aJanela[HB_OBJETO]:nBottom := nLinF - 2
	aJanela[HB_OBJETO]:nRight  := nColF - 1
	aJanela[HB_TELA] := cTela
	
RETURN(aJanela)
		
		
// Muda o atributo das bordas de uma area predefinida		
STATIC FUNCTION Atributo(nLinI,nColI,nLinF,nColF,cTelaM,cPos)

	LOCAL nAtributo,nFundo,nCor,cNovoAtr,x
	
	// Muda borda dos lados para identificar o lado a ser redimensionado
	DO CASE

		CASE cPos == "S"
			
			FOR x:=1 TO (nColF-nColI)+1
				// Cima
				nAtributo:=ASC(SUBST(cTelaM,((((nColF-nColI)+1)*1+x)-((nColF-nColI)+1))*2,1))
				nFundo   :=INT(nAtributo/16)
				nCor     :=(nAtributo-INT(nAtributo/16))-(15*nFundo)
				cNovoAtr :=CHR(nCor*16+nFundo)
				cTelaM   := STUFF(cTelaM,((((nColF-nColI)+1)*1+x)-((nColF-nColI)+1))*2,1,cNovoAtr)
			NEXT
					
		CASE cPos == "D"	
			
			FOR x:=1 TO (nLinF-nLinI)+1
				// Direita
				nAtributo:=ASC(SUBST(cTelaM,((((nColF-nColI)+1)*x+((nColF-nColI)+1))-((nColF-nColI)+1))*2,1))
				nFundo:=INT(nAtributo/16)				
				nCor:=(nAtributo-INT(nAtributo/16))-(15*nFundo)
				cNovoAtr:=CHR(nCor*16+nFundo)
				cTelaM := STUFF(cTelaM,((((nColF-nColI)+1)*x+((nColF-nColI)+1))-((nColF-nColI)+1))*2,1,cNovoAtr)
			NEXT	
						
		CASE cPos == "I"
			
			FOR x:=1 TO (nColF-nColI)+1
				// Baixo
				nAtributo:=ASC(SUBST(cTelaM,((((nColF-nColI)+1)*((nLinF-nLinI)+1)+x)-((nColF-nColI)+1))*2,1))
				nFundo:=INT(nAtributo/16)				
				nCor:=(nAtributo-INT(nAtributo/16))-(15*nFundo)
				cNovoAtr:=CHR(nCor*16+nFundo)
				cTelaM := STUFF(cTelaM,((((nColF-nColI)+1)*((nLinF-nLinI)+1)+x)-((nColF-nColI)+1))*2,1,cNovoAtr)
			NEXT	
						
		CASE cPos == "E"
		
			FOR x:=1 TO (nLinF-nLinI)+1
				// Esquerda
				nAtributo:=ASC(SUBST(cTelaM,((((nColF-nColI)+1)*x+1)-((nColF-nColI)+1))*2,1))
				nFundo:=INT(nAtributo/16)				
				nCor:=(nAtributo-INT(nAtributo/16))-(15*nFundo)
				cNovoAtr:=CHR(nCor*16+nFundo)
				cTelaM := STUFF(cTelaM,((((nColF-nColI)+1)*x+1)-((nColF-nColI)+1))*2,1,cNovoAtr)				
			NEXT	
			
		ENDCASE		
		
RETURN(cTelaM)		


// Cria uma barra de rolagem
FUNCTION Barra( nLinI, nColI, nLinF, cCor )
   // Cria nova barra de rolagem
   LOCAL aBarra := ARRAY( HBB_ELEMENTOS )

   aBarra[ HBB_INILIN ]	:= nLinI
   aBarra[ HBB_INICOL ]	:= nColI
   aBarra[ HBB_FINLIN ] := nLinF
   aBarra[ HBB_FINCOL ] := nColI

   // Cor da barra
   IF cCor == NIL
	  cCor := HBC_DADOS
   ENDIF
   aBarra[ HBB_COR ] 	:= cCor

	nIniPos := 1
   aBarra[ HBB_POSICAO ]	:= nIniPos

RETURN(aBarra)


// Mostra a barra criada
FUNCTION MostraBarra( aBarra )
   LOCAL cCor, nLinha

   cCor := SETCOLOR( aBarra[ HBB_COR ] )

   // Imprime as setas
   @ aBarra[ HBB_INILIN ], aBarra[ HBB_INICOL ] SAY HBB_SETACIMA
   @ aBarra[ HBB_FINLIN ], aBarra[ HBB_FINCOL ] SAY HBB_SETABAIXO

   // Imprime o fundo 
   FOR nLinha := (aBarra[ HBB_INILIN ]+ 1) TO (aBarra[ HBB_FINLIN ] - 1)
	  @ nLinha, aBarra[ HBB_INICOL ] SAY HBB_FUNDO
   NEXT

   SETCOLOR( cCor )

RETURN(aBarra)
		
// Atualiza posi‡Æo da barra
FUNCTION AtuBarra( aBarra, nPosicao, nTotal )
   LOCAL cCor, nNovaPosicao
   LOCAL nTamanho := (aBarra[HBB_FINLIN]-1)-(aBarra[HBB_INILIN])

   IF nTotal < 1
	  nTotal := 1
   ENDIF

   IF nPosicao < 1
	  nPosicao := 1
   ENDIF

   IF nPosicao > nTotal
	  nPosicao := nTotal
   ENDIF

   cCor := SETCOLOR( aBarra[ HBB_COR ] )

   // Determina nova posicao
   nNovaPosicao := ROUND( (nPosicao / nTotal) * nTamanho, 0 )

   // Verifica nova posicao
   nNovaPosicao := IF( nNovaPosicao < 1, 1, nNovaPosicao )
   nNovaPosicao := IF( nPosicao == 1, 1, nNovaPosicao )
   nNovaPosicao := IF( nPosicao >= nTotal, nTamanho, nNovaPosicao )

   // Atualiza a nova posicao 
   @ (aBarra[ HBB_POSICAO ] + aBarra[ HBB_INILIN ]), aBarra[ HBB_INICOL ] SAY ;
	HBB_FUNDO
	@ (nNovaPosicao + aBarra[ HBB_INILIN ]), aBarra[ HBB_INICOL ] SAY;
	HBB_BARRA
	aBarra[ HBB_POSICAO ] := nNovaPosicao
   SETCOLOR( cCor )

RETURN(aBarra)





  
