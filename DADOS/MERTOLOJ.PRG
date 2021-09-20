close all
SET DELE ON
*
sele 1
use ceccmer
index on codigom to imer
set index to imer
sele 2
use ceccloj
zap
sele 1
CLEA
?"PROCESSANDO, AGUARDE..."
do while .not. eof()
    c1=1
    c2=codigom
    c3=dtultcm
    c4=dtultvm
    c5=space(1)
    c6=space(1)
    c7=saldoem
    **
    sele 2
    if c7#0
    append blank
    repl codiloj with c1
    repl mercloj with c2
    repl dtucloj with c3
    repl dtuvloj with c4
    repl saldoej with c7
    endif
    sele 1
    skip
enddo
SET DELE OFF
CLEA
?"PROCESSO CONCLUIDO!"
close all

