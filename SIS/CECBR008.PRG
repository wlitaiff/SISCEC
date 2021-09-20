// W&R Inform tica Ltda.
// SYSCEC 
// Relatorio das pendencias por clientes
// Manaus , 19 de Agosto de 1997
// Waldemir Litaiff Vasconcelos

#include "HAWK.CH"
#include "HBROWSE.CH"

LOCAL 		nCli,;
		cCor :=SETCOLOR(),;
                cTela:=SAVESCREEN(0,0,MAXROW(),MAXCOL()),;
		nCursor := SETCURSOR()
		
PRIVA nTot_Sldoc := nTot_Vldoc := nTot_Debit := 0,;
		nToR_Sldoc := nToR_Vldoc := nToR_Debit := 0,;
		nTot_Item := 0,;
		nToR_Item := 0,;
		nLin ,;
		lImpCli

SET PROCEDURE TO BPLIB
SET DATE BRITISH
// Abrir Arquivos
IF !ARQNTX("CECCCLI",.F.) .OR. ;
   !ARQNTX("CECLOGO",.F.) .OR. ;
	!ARQNTX("CECCREC",.F.)  
	!ARQNTX("CECCPTG",.F.)  
	DBCLOSEALL()
	RETURN
ENDIF
//

DO WHILE .T.

	SETCOLOR("B/W,W+/BG,,,B/W")
        CLS                                  
        @ 13,02 SAY [PROCESSANDO]
	//
        IF LASTKEY()=27
             SETCOLOR(cCor)
             RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
              EXIT
	ENDIF
	//
	cTela0 := SAVESCREEn(0,0,MAXROW(),MAXCOL())
	//
        
        Imp_TodosClientes()
	//
EndDo	
RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
DBCLOSEALL()
RETURN

/************************** Funcoes para ImpressÆo ************************/
/**
**/

FUNCTION Imp_TodosClientes()

   PUBLIC       lCab       := .T.,;
		nPage      := 1,;
		nLin       := 0,;
                lImpCli    := .T.,;
                reg        :=0

   SET DEVICE TO PRINTER

   IMP()

  // Total Geral
   nLin++
   @ NLIN,00 SAY REPL('-',80)
   nLin++
   @ nLin,01 say [TOTAL GERAL--->>>]
   @ nLin,24 say nToR_Vldoc pict "@E 99,999,999.99"
   @ nLin,48 say nToR_Sldoc pict "@E 99,999,999.99"
   @ nLin,62 say nToR_Debit pict "@E 99,999,999.99"
   nLin++
   @ nLin,00 say repl([=],80)
	//
   EJECT
   SET DEVICE TO SCREEN
   CLS
   @ 10,30 SAY "FIM DE PROCESSO"
   RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela0)

RETURN


Procedure imp()

   PUBLIC       nTotal     := 0,;
                nCont      := 0,;
                Ano        := 0,;
                PRI        :=.T.,;
                Ano         ,;
                nNOTA      :=SPACE(10),;
                CODIGO     := 0,;
                NOME       :=SPACE(30)
   

   SELECT("CECCREC")
   SET ORDER to 3
   GO TOP

   DO WHILE !EOF()
        
        IF LASTKEY()=27
              EXIT
	ENDIF

        IF PRI
           nNOTA:=DOCDUPR
*           ano:=year(DTVENCR)
           PRI:=.F.
        ENDIF

        IF DOCDUPR=nNOTA  .AND. year(DTVENCR) >= 1997 .AND. year(DTEMISR) >= 1997 .and. STATUSR=" "

           IF INKEY()==27
              EXIT
           ENDIF

           IF lCab 
              Cabecalho(nPage,"NF. REPETIDAS      - ("+DTOC(DATE())+"-"+DTOC(DATE())+")")
              @PROW(),PCOL() SAY CHR(18) 
              @07,01 SAY "-EMISSAO-  -DOCUMENTO-  --VL.DOCTO--  VENCIMENTO  --VL.PAGO--  ---DEBITO---  BC"
              //          99/99/9999  9999999/99   999.999,99   99/99/9999  999.999,99    999.999,99   99
              //                         01                           13           27           39          51            65           78
              @08,00 SAY REPL("-",80)
              nLin := 09
              lCab := .F.
              nPage++
           ENDIF
                  
           // Preparar para imprimir detalhes

           *If lImpCli
           *     nLin++
           *     @ nLin,000 SAY CHR(15)+ ""
           *    @ nLin,001 SAY chr(14)+"CLIENTE..:"+STR(CODCLIR,5)+"="+NOME+chr(18)+""
           *    lImpCli := .F.
           *    nLin++
           *    EndIf
			//
			//			01				13           27           39          51            65           78
           nLin++
           @ nLin,001 SAY DTEMISR
           @ nLin,013 say DOCDUPR
           @ nlin,027 say VLDOCTR                                                   pict "@E 999,999.99"
           @ nLin,039 say DTVENCR
           @ nLIn,051 say (VLDOCTR - SLDOCTR) pict "@E 999,999.99"
           @ nLin,065 SAY SLDOCTR                                                   pict "@E 999,999.99"
           @ nLin,078 say CODBANR
           // Calculos de Totais
           nCont++
           nTot_Vldoc += VLDOCTR
           nTot_Sldoc += (VLDOCTR - SLDOCTR)
           nTot_Debit += SLDOCTR
           nTot_Item++ 
           nToR_Vldoc += VLDOCTR
           nToR_Sldoc += (VLDOCTR - SLDOCTR)
           nToR_Debit += SLDOCTR
           nToR_Item++ 

          If nLin > 55
              lCab := .T.
              nLin := 0
          EndIf

          SKIP

        ELSE
           nNOTA:=DOCDUPR
           *   Dt:=DTVENCR
       ENDIF

      SKIP         

   ENDDO
       
   IF nCont>0
       nLin ++
       @ NLIN,00 SAY REPL('-',80)
       nLin++
       @ nLin,001 say [TOTAL DO CLIENTE--->>>]
       @ nLin,027 say nTot_Vldoc pict "@E 999,999.99"
       @ nLin,051 say nTot_Sldoc pict "@E 999,999.99"
       @ nLin,065 say nTot_Debit pict "@E 999,999.99"
       nLin++
       @ nLin,00 say repl([-],80)
       nLin++
       nTot_Vldoc:=0
       nTot_Sldoc:=0
       nTot_Debit:=0
       nCont:=0
   ENDIF

   If nLin > 55
      lCab := .T.
     nLin := 0
   EndIf

   lImpCli := .T.
               
		//
   If nLin > 55
      lCab    := .T.
      lImpCli := .T.
   EndIf


RETURN(NIL)
	
