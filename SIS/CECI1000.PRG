// Waldemir Litaiff Vasconcelos - Fone - (092) 651 2613
// 28/12/95
// Prepara‡„o dos arquivos de invent rio
//
LOCAL cTela := SAVESCREEN ( 0, 0, LASTROW(), LASTCOL() )
// Alertar Usu rio
IF !M_QUERY ( "Confirma prepara‡„o dos arquivos ?", 23 )
	RETURN ( NIL )
ENDIF
//
IF !M_QUERY ( "Vocˆ j  fez Backup dos Arquivos?", 23 )
	RETURN ( NIL )
ENDIF

// Abre arquivo de locais
IF !ARQNTX("CECTRINV",.F.) .OR. ;
	!ARQNTX("CECCMOV",.F.)
	DBCLOSEALL()
	RETURN
ENDIF
//

M_MESSAGE ( "Arguarde preparando arquivos ...", 23 )

// Preparando CECCMER apartir do CECCMER
SELECT("CECCMER")
//
//COPY TO CECCINV
//
/*IF !ARQNTX("CECCINV",.T.)
   RETURN(NIL)
ENDIF 
REPL CECCINV->SALDOEM WITH 0 ALL  */
	  
/* Preparando CECCLOI apartir do CECCLOJ
SELECT ( "CECCLOJ" )
COPY STRU TO CECCLOI */

// Preparando CECCMOI apartir do CECCMOV
SELECT ( "CECCMOV" )
COPY STRU TO CECCMOI

// Zerar Arquivo de trabalho do Inventario - CECTRINV
SELECT ("CECTRINV")
ZAP

//
DBCLOSEALL()
RESTSCREEN ( 0, 0, LASTROW(), LASTCOL(), cTela )
RETURN ( NIL )