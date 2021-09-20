// Sistemas de Controle de Estoque Comercial
// W&R Informatica Ltda
// 30 de Abril de 1996
// Roberto Falcao Rocha
// Modulo de mensagens de cortesia para impressora fiscal

LOCAL nAtributo1:=0,;
		nAtributo2:=0,;
		nAtributo3:=0,;
		cMens1:=SPACE(40),;
		cMens2:=SPACE(40),;
		cMens3:=SPACE(40),;
		cMensagem,;
		GetList:={},;
		cTela :=SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
		nCursor := SETCURSOR(1),;
		bTamanho := {|cVar,nTam| cVar := SPACE(nTam),.T. }

IF !ARQNTX("CECCSET",.F.)
	RETURN
ENDIF	
DO WHILE .T.
	BOX(08,03,12,75,M->FR,127,3,8)
	
	@ 09,04 SAY "Atributo.:";
			  GET nAtributo1;
			  PICTURE "9";
			  VALID (nAtributo1>=0 .AND. nAtributo1<=2) .AND. IF(nAtributo1#0,EVAL(bTamanho,@cMens1,IF(nAtributo1=1,30,40)),.T.)
	@ 09,17 SAY "Linha1.:";
			  GET cMens1;
			  PICTURE "@!"
			  
	@ 10,04 SAY "Atributo.:";
			  GET nAtributo2;
			  PICTURE "9";
			  VALID (nAtributo2>=0 .AND. nAtributo2<=2) .AND. IF(nAtributo2#0,EVAL(bTamanho,@cMens2,IF(nAtributo2=1,30,40)),.T.)
	@ 10,17 SAY "Linha2.:";
			  GET cMens2;
			  PICTURE "@!"
			  
	@ 11,04 SAY "Atributo.:";
			  GET nAtributo3;
			  PICTURE "9";
			  VALID (nAtributo3>=0 .AND. nAtributo3<=2) .AND. IF(nAtributo3#0,EVAL(bTamanho,@cMens3,IF(nAtributo3=1,30,40)),.T.)
	@ 11,17 SAY "Linha3.:";
			  GET cMens3;
			  PICTURE "@!"		  		  
	
	READ
	
	IF LASTKEY()==27
		RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
		SETCURSOR(nCursor)
		DBCLOSEALL()
		RETURN
	ENDIF	
	
	IF !Confirma("Confirma os dados",23)
		LOOP
	ENDIF
	
	cMensagem := ""
	IF !EMPTY(cMens1)
		cMensagem += STRZERO(nAtributo1,1)+cMens1
	ENDIF	
	IF !EMPTY(cMens2)
		cMensagem += STRZERO(nAtributo2,1)+cMens2
	ENDIF	
	IF !EMPTY(cMens3)
		cMensagem += STRZERO(nAtributo3,1)+cMens3
	ENDIF	
	
	CECCSET->(LOCK_REGISTRO(.T.))
	CECCSET->MENSAGEM := cMensagem
	CECCSET->(DBUNLOCK())
	CECCSET->(DBCOMMIT()) 		
ENDDO	
RETURN