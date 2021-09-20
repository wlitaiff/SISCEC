// Sistemas de Controle de Estoque Comercial
// W&R Informatica Ltda
// 30 de Abril de 1996
// Roberto Falcao Rocha
// Modulo leitura X

IF M_QUERY("Confirma a leitura X",79)
	SET DEVICE TO PRINT
	SET PRINTER TO IFSWEDA
	@ PROW(),PCOL() SAY CHR(27)+".13}"
	SET PRINTER TO
	SET DEVICE TO SCREEN
ENDIF
RETURN(NIL)	