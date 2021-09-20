// Sistemas de Controle de Estoque Comercial
// W&R Informatica Ltda
// 30 de Abril de 1996
// Roberto Falcao Rocha
// Modulo REDUCAO Z

IF M_QUERY("Confirma a reducao Z",79)
	M_DISPLAY("Esta leitura impedira que voce venda mais alguma coisa hoje",79)
	IF M_QUERY("Tem certeza que voce que confirma a redu‡Æo Z",79)
		IF M_QUERY("Confirma a reducao Z",79)
			SET DEVICE TO PRINT
			SET PRINTER TO IFSWEDA
			@ PROW(),PCOL() SAY CHR(27)+".14}"
			SET PRINTER TO
			SET DEVICE TO SCREEN
		ENDIF
	ENDIF
ENDIF
RETURN(NIL)	