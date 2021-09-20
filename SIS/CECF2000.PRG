// Sistemas de Controle de Estoque Comercial
// W&R Informatica Ltda
// 30 de Abril de 1996
// Roberto Falcao Rocha
// Modulo cancelamento do ultimo cupom fiscal

IF M_QUERY("Confirma o cancelamento do cupom",79)
	SET DEVICE TO PRINT
	SET PRINTER TO IFSWEDA
	@ PROW(),PCOL() SAY CHR(27)+".05}"
	SET PRINTER TO
	SET DEVICE TO SCREEN
ENDIF
RETURN(NIL)	