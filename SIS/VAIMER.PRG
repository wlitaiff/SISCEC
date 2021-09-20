clea
set dele on
sele 1
use scecmat
sele 2
use ceccmer
sele 1
do whil .not. eof()
    c1 = codigo
    c2 = descricao
    c3 = linha
    c4 = divisao
    c5 = fornecedor
    c6 = unidade
    c7 = prvenda
    c8 = prcompra
    c9 = classeabc
    c10= stoqminim
    c11= dtultentra
    c12= dtultsaida
    c13= prmedio
    c14= origem
    c15= dcultentra
    c16= saldoatual
    c17= prfob
    sele 2
    appen blan
    repl codigom with c1
    repl descrim with c2
   * repl codlinm with c3
   * repl coddivm with c4
   * repl fornecm with c5
    repl unidade with c6
    repl precvem  with c7
    repl preccom with c8
    repl claabcm with c9
    repl estminm with c10
    repl dtultcm with c12
    repl cmedm   with c13
    repl origemm with c14
    repl dcultcm with c15
    repl saldoem with c16
    repl cfobm   with c17
    sele 1
    skip
enddo
close all
set dele off
clea