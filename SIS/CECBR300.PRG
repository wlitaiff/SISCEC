// Sistemas de Controle de Estoque Comercial
// W&R Informatica Ltda
// 04 de Dezembro de 1995
// Roberto Falcao Rocha
// Relat¢rio Clientes

#include "HAWK.CH"
#include "HBROWSE.CH"


LOCAL cTela := SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
		cCor := SETCOLOR(),;
		nCursor := SETCURSOR(1),;
		lCab:=.T.,;
		nPage:=0,;
                  dti:=0,;
		nLin:=0,;
		cTela2
							 
SET PROCEDURE TO BPLIB
SET DATE BRITISH


IF  !ARQNTX("CECCCLI",.F.) 
     DBCLOSEALL()
     RETURN
ENDIF	

DBSETORDER(2)

*IF !IMPRES()
*        DBCLOSEALL()
*        RETURN
*ENDIF

dti:=date()
CLS
@ 10,10 SAY "Entre com a data Base:" get dti  picture "99/99/99"
Read
cls

@ 20,20  Say "Imprimindo, aguarde ..."
	
SET DEVICE TO PRINT
@ PROW(),PCOL() SAY "Rolapecas - RELATORIO"
	
DBGOTOP()
	
DO WHILE !EOF()

  IF INKEY()==27
     EXIT
  ENDIF                                    

  IF int((dti - CECCCLI->DTUCOMP)/365) >=1 .AND. ((dti - CECCCLI->DT1COMP)/365) >=1 .AND. DELETED()=.F.

		IF lCab
			nPage++
                        Cabecalho(nPage,"CLIENTES SEM MOVIMENTACAO A MAIS DE UM ANO",;
                        "CODIGO NOME                                     ENDERECO                                 TELEFONE     FAX   DATA COMPRA")
			nLin := 9
			lCab := .F.
		ENDIF
		
		@ nLin,01 SAY CECCCLI->CODIGOC
		@ nLin,08 SAY CECCCLI->NOMECLC
		@ nLin,49 SAY CECCCLI->ENDEREC
		@ nLin,90 SAY CECCCLI->TELEFOC
                @ nLin,100 SAY CECCCLI->FAXCLIC
                @ nLin,112 SAY CECCCLI->DTUCOMP
		
		DBSKIP()
		nLin++
                IF nLin>59
                    lCab := .T.
		ENDIF

  ENDIF
  DBSKIP()
ENDDO
EJECT	
DBCLOSEALL()
SET DEVICE TO SCREEN
RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
RETURN
	
                                                         
