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
       * Box(11,01,15,79,fr,127,3,8)
	SETCOLOR("B/W,W+/BG,,,B/W")
	SETCURSOR(1)
        
        dDataI:=dDataF:=Ctod([  /  /  ])
					  
	@ 13,02 SAY [Data inicial.:];
                     GET dDataI;
                         PICTURE "@D"
	
	@ 14,02 SAY [Data Final...:];
                     GET dDataF;
                         PICTURE "@D"
                          // VALID IF(!EMPTY(dDataI) // ,IF(dDataF<dDataI,EVAL({||M_DISPLAY("Data final menor que data inicial",79),.F.}),.T.),.T.)
	READ
	//
	SETCURSOR(0)
	IF LASTKEY()=27
		SETCOLOR(cCor)
		RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
		EXIT
	ENDIF
	//
	cTela0 := SAVESCREEn(0,0,MAXROW(),MAXCOL())
	//
   *     IF !IMPRES()
   *             DBCLOSEALL()
   *             RETURN
   *     ENDIF
	//
   *     M_MESSAGE([Aguarde! Imprimindo...],23)
	//
        Imp_TodosClientes(dDataI,dDataF)
	//
EndDo	
RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela)
DBCLOSEALL()
RETURN

/************************** Funcoes para ImpressÆo ************************/
/**
**/

FUNCTION Imp_TodosClientes(dDataInicial,dDataFinal)

   PUBLIC       lCab       := .T.,;
		nPage      := 1,;
		nLin       := 0,;
                lImpCli    := .T.,;
                reg        :=0

*   SELECT("CECCCLI")
*   SET ORDER to 2
*   GO TOP
   SET DEVICE TO PRINTER

*   DO WHILE !EOF()

      
*      IMP(CODIGOC,NOMECLC,dDataInicial,dDataFinal)
       IMP(dDataInicial,dDataFinal)
*      SELECT("CECCCLI")
*      SKIP

*   ENDDO
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
   RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTela0)

RETURN


Procedure imp(dDataI,dDataF)

   PUBLIC       nTotal     := 0,;
                nCont      := 0,;
                CODIGO     := 0,;
                NOME       :=SPACE(30)  
*   CODIGO,NOME
   NOME:="METALFINO"
   CODIGO:=306

   SELECT("CECCREC")
   SET ORDER to 4
   GO TOP

   SEEK STRZERO(CODIGO,5)

   if found()
        go top
        SET SOFTSEEK ON
        SEEK (STRZERO(CODIGO,5)+DTOS(dDataI))
        SET SOFTSEEK OFF
   else
        return
   end

   DO WHILE !EOF() .AND. DTEMISR<=dDataF .AND. CODCLIR<=CODIGO
		//
         IF CODCLIR=CODIGO  

               * IF STATUSR=" "  

                    IF INKEY()==27
				EXIT
                    ENDIF

                    IF lCab 
                          Cabecalho(nPage,"CLIENTES PENDENTES - ("+DTOC(dDataI)+"-"+DTOC(dDataF)+")")
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

                    If lImpCli
                         nLin++
                         @ nLin,000 SAY CHR(15)+ ""
                         @ nLin,001 SAY chr(14)+"CLIENTE..:"+STR(CODCLIR,5)+"="+NOME+chr(18)+""
                         lImpCli := .F.
                         nLin++
			EndIf
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
               * ENDIF 
		//
         ENDIF
         SKIP

   ENDDO
	//
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
	
