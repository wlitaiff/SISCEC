set echo off
set talk off
SET DELE ON
close all
CLEA 
?"PROCESSANDO, AGURADE..."
sele 1
use ceccmer
zap
sele 2
use f:\dadosadv\sb1010
index on b1_cod to icodigo
sele 3
use f:\dadosadv\sb2010
INDEX ON B2_COD TO ICODESTQ
sele 2
Do while .not. eof()
    **
    c1=B1_COD
    c2=B1_CODMCI
    c3=B1_DESC
    c4=B1_UM
    c5=VAL(B1_GRUPO)
    c6=B1_UCOM
    c7=B1_UREV
    c8=0.0000
    c9=B1_CUSTD
    c10=0.000
    c11=B1_UPRC
    c12=B1_PRV1
    C13=B1_CODBAR
    *
    COD_ESTOQ=B1_COD
    SELE 3
    SEEK COD_ESTOQ
    C8=B2_CM1
    C10=B2_QATU
    SELE 1
    APPEN BLANK
    REPL CODIGOM WITH C1
    REPL REFEREM WITH C2
    REPL DESCRIM WITH C3
    REPL UNIDADE WITH C4
    REPL CODLINM WITH C5
    REPL DTULTCM WITH C6
    REPL DTULTVM WITH C7
    REPL CMEDM   WITH C8
    REPL CSTAM   WITH C9
    REPL SALDOEM WITH C10
    REPL PRECCOM WITH C11
    REPL PRECVEM WITH C12
    REPL PRECVEM2 WITH C12*1.05
    REPL CODBARM WITH C13
    **
    SELE 2
    SKIP
ENDDO
CLOSE ALL
SET TALK OFF
SET ECHO OFF
SET DELE OFF
CLEA
?"PROCESSO CONCLUIDO!"
RETURN
