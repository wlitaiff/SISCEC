**********
* Arquivo de cabecalho : HAWK.CH
** Objetivo : criar configurac”es padroes para os Sistemas
*** Direitos autorais : Roberto Falc„o Rocha, Hawk Software - 1994
**********



// Define macros para serem usadas nos cabecalhos de relat¢rios
#translate _PAGINA( <nPag> ) => "PAGINA :" + STRZERO( <nPag> ,4 )
#translate _DATA => "DATA :" + DTOC( DATE() )
#translate _HORA => "HORA :" + TIME()