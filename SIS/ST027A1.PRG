**** Relatorio do registro de inventario modelo 7
**** por AREA/CLAS.FISCAL/CODIGO
USE STTRmat
INDEX ON STR(AREA,1)+str(CLAFIS,10)+CODMAT  TO TRMAT
CLEAR
close data
sele 1
Use STTRmat INDEX trMAT
sele 2
use stcdinv inde stininv
sele 3
use sttbori index stinori
Sele 2
FOLHA=2
@ 01,01 to 24,79 double
@ 02,03 say 'RELATORIO DE INVENTARIO POR AREA/CL.FISCAL/CODIGO'
@ 23,02 say 'Mensagem :'
Do Whil .t.
   Resp=' '
   @ 04,03 Say 'Qaual o Numero da Pagina Inicial? ' Get Folha pict '9999'
   Read
   if Lastkey()=27
      Close data
      Retur
   Endif
   @ 23,12 say 'Confirma ?(S=sim;N=nao)=='+ch get resp pict '@!'
   read
   If resp='N'
      @ 23,12 clea to 23,78
      Loop
   Else
      Exit
   Endif
EndDo
@ 23,12 clea to 23,78
@ 23,12 say 'Prepare a impressora e tecle Enter !'
inkey(0)
Do While !Isprinter()
   @ 23,12 CLEA TO 23,78
   @ 23,12 say 'Impressora desativada. Prepare-a e tecle Enter !'
   inkey(0)
   IF LASTKEY()=27
      CLOSE DATA
      RETURN
   ENDIF
Enddo
@ 23,12 clear to 23,78
@ 23,12 say 'F10 - Interrompe o relatorio.'
sele 1
Ct_Lin = 5
Co_area= Area
Cl_fis = Clafis
Cus_Uni= 0
Cus_Tot= 0
Cus_Tot1=0
Cus_Tot2=0
Cus_TotR=0
F = 'UMA'
Declare Tot_Ori[100]
Afill(Tot_Ori,0)
SET DEVICE TO PRINT
Do While !EOF()
   If INKEY()=-9
      EXIT
   Endif
   sele 1
   Co_area= Area
   Cl_fis = Clafis
   Nom_are= space(12)
   do case
      case Co_area=2
         Nom_are='RECEBIMENTO '
      CASE CO_AREA=3
         NOM_ARE='ALMOXARIFADO'
      CASE CO_AREA=4
         NOM_ARE='RECUPERACAO '
      CASE CO_AREA=5
         NOM_ARE='FABRICA     '
      CASE CO_AREA=6
         NOM_ARE='REFUGO      '
   ENDCASE
   Do While Co_area=Area .and. !EOF()
      If INKEY()=-9
         EXIT
      Endif

      Cl_fis = Clafis
      Do While Cl_fis = Clafis
         If INKEY()=-9
            EXIT
         Endif

         If Ct_Lin=5
           @ 01,01 say USUARIO+SPACE(30)+ 'ST027A=REGISTRO DE INVENTARIO - MODELO 7 DE  '+DTOC(DATA)+SPACE(14)+'FOLHA '+STR(Folha,5)
           @ 03,01 say 'CAP-ST027A'+SPACE(40)+'EM :'+SPACE(8)+'    AS :'+SPACE(9)+'HS'
           @ 03,55 say DATE()
           @ 03,71 say TIME()
           @ 04,35 SAY 'AREA='+nom_are
           @ 05,01 say 'CODIGO--------  O./S.  DESCRICAO------------------------------------  CL.FISCAL-  QUANTIDADE  UT  CUSTO-UNITARIO-  CUSTO-TOTAL------'
         Endif
         Cod_item=codmat
         sele 2
         seek cod_item
         descri= Subs(DESC,1,45)
         ut    = UTRA
         endere= LALM
         DO CASE
            CASE TESCUS=0 .OR. TESCUS=8
                 CUS_UNI=CSTA
                 CUSTUNS=CCIFUS
            CASE TESCUS=6
                 CUS_UNI=CFOB
                 CUSTUNS=CFOBUS
            CASE TESCUS=7
                 CUS_UNI=CMUN
                 CUSTUNS=CMUNUS
         ENDCASE
         SELE 1
         ***
         CUS_TOT = ROUND(QTarea*CUS_UNI,2)

         Ct_Lin = Ct_Lin + 1

         @ CT_LIN,001 SAY CODMAT
         @ Ct_Lin,017 say OrigEM
         @ Ct_Lin,020 say StatUS
         @ Ct_Lin,024 say DescRI
         @ Ct_Lin,071 say ClaFIS
         @ Ct_Lin,083 say QtAREA pict '@E 99,999,999'
         @ Ct_Lin,095 say Ut
         @ Ct_Lin,098 say CUS_UNI pict '@E 999,999,999.9999'
         @ Ct_Lin,116 say Cus_TOT pict '@E 999,999,999,999.99'
         **@ Ct_Lin,122 say ENDERE
         *** TOTAIS
         cus_TOT1=cus_TOT1 + CUS_TOT         && total p/ AREA
         cus_TOT2=cus_TOT2 + CUS_TOT         && TOTAL p/ cl.fiscal
         cus_totR=cus_TOTR + Cus_TOT         && TOTAL GERAL
         **** Acumular para o Resumo
         If origem>0 .and. origem<101
             Tot_Ori[Origem] = Tot_Ori[Origem] + Cus_Tot
         Endif
         ***
         If Ct_Lin>=58
            Ct_Lin=5
            Folha=Folha+1
         Endif

         SKIP

      Enddo

      Ct_Lin=Ct_Lin+1

      @ CT_Lin,01 say 'TOTAL DA CLASSIF.FISCAL------>'
      @ Ct_Lin,116 say Cus_TOT1 pict '@E 999,999,999,999.99'
      ct_lin=ct_lin+1
      CUS_TOT1=0
   Enddo

   Ct_Lin=Ct_Lin+1
   @ CT_Lin,01 say 'TOTAL DA AREA---------->'
   @ Ct_Lin,116 say Cus_TOT2 pict '@E 999,999,999,999.99'
   CUS_TOT2=0
   F='   '
   ct_lin=5
Enddo
Ct_Lin=Ct_Lin+2
@ CT_Lin,01 say 'TOTAL DA GERAL---------->'
@ Ct_Lin,116 say Cus_TOTR pict '@E 999,999,999,999.99'
EJECT
**
@ 01,01 say USUARIO+SPACE(30)+ 'ST027A=REGISTRO DE INVENTARIO - MODELO 7 DE  '+DTOC(DATA)+SPACE(14)+'FOLHA '+STR(Folha,5)
@ 03,01 say 'CAP-ST027A'+SPACE(13)+' RESUMO GERAL POR ORIGEM - EM :'+SPACE(8)+'    AS :'+SPACE(9)+'HS'
@ 03,55 say DATE()
@ 03,71 say TIME()
@ 05,01 say '  ORIGEM  DESCRICAO-------------------------------  VLR. TOTAL-------'
SELE 3
Cont_Lin=5
For i=1 to 100
  Seek i
  If Tot_Ori[i]#0 .and. !eof()
     Cont_Lin = Cont_Lin + 1
     @ Cont_Lin,05 say i
     @ Cont_Lin,11 say Subs(Deso,1,40)
     @ Cont_Lin,53 say Tot_Ori[i]   pict '@E 99,999,999,999.99'
  EndIf
Next
CLOS DATA
RETURN
**Fim**