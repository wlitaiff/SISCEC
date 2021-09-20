/***
*
*       Errorsys.prg
*
*  Standard Clipper error handler
*
*  Copyright (c) 1990-1993, Computer Associates International, Inc.
*  All rights reserved.
*
*  Compile:  /m /n /w
*
*/

#include "error.ch"


// put messages to STDERR
#command ? <list,...>   =>  ?? Chr(13) + Chr(10) ; ?? <list>
#command ?? <list,...>  =>  OutErr(<list>)


// used below
#define NTRIM(n)                ( LTrim(Str(n)) )
STATIC nErros := 5
STATIC cErroCorruption := NIL


/***
*       ErrorSys()
*
*       Note:  automatically executes at startup
*/

proc ErrorSys()
        ErrorBlock( {|e| DefError(e)} )
return




/***
*       DefError()
*/
static func DefError(e)
local i, cMessage, aOptions, nChoice, cNome, chave1,chave2,chave3,chave4,chave5
//
IF ( e:genCode == EG_PRINT )
   ALERT("Erro na Impressora ³ "+STRZERO(nErros,2)+" tentativa(s) restante(s)")
   IF nErros > 0
      nErros--
      return (.T.)
   ELSE
      nErros := 05
      ALERT("Desviando p/ o Arquivo <PRINT.ERR>")
      SET PRINT TO PRINT.ERR
      return (.T.)
   ENDIF
ENDIF
			// for network open error, set NETERR() and subsystem default
        if ( e:genCode == EG_OPEN .and. e:osCode == 32 .and. e:canDefault )

                NetErr(.t.)
                return (.f.)                                                                    // NOTE

        end


        // for lock error during APPEND BLANK, set NETERR() and subsystem default
        if ( e:genCode == EG_APPENDLOCK .and. e:canDefault )

                NetErr(.t.)
                return (.f.)                                                                    // NOTE

        end
			
			MostraErro( e )

        // by default, division by zero yields zero
        if ( e:genCode == EG_ZERODIV )
                return (0)
        end
		  
        

        // build error message
        cMessage := ErrorMessage(e)
		  
        // build options array
        // aOptions := {"Break", "Quit"}
        aOptions := {"Quit"}

        if (e:canRetry)
                AAdd(aOptions, "Retry")
        end

        if (e:canDefault)
                AAdd(aOptions, "Default")
        end

        // put up alert box
        nChoice := 0
        while ( nChoice == 0 )

                if ( Empty(e:osCode) )
                        nChoice := Alert( cMessage, aOptions )

                else
                        nChoice := Alert( cMessage + ;
                                                        ";(DOS Error " + NTRIM(e:osCode) + ")", ;
                                                        aOptions )
                end


                if ( nChoice == NIL )
                        exit
                end

        end


        if ( !Empty(nChoice) )

                // do as instructed
                if ( aOptions[nChoice] == "Break" )
                        Break(e)

                elseif ( aOptions[nChoice] == "Retry" )
                        return (.t.)

                elseif ( aOptions[nChoice] == "Default" )
                        return (.f.)

                end

        end


        // display message and traceback
        if ( !Empty(e:osCode) )
                cMessage += " (DOS Error " + NTRIM(e:osCode) + ") "
        end

        ? cMessage
        i := 2
        while ( !Empty(ProcName(i)) )
                ? "Called from", Trim(ProcName(i)) + ;
                        "(" + NTRIM(ProcLine(i)) + ")  "

                i++
        end


        // give up
        ErrorLevel(1)
        KEYBOARD CHR(004) + CHR(013)
        QUIT

return (.f.)




/***
*       ErrorMessage()
*/
static func ErrorMessage(e)
local cMessage


        // start error message
        cMessage := if( e:severity > ES_WARNING, "Error ", "Warning " )


        // add subsystem name if available
        if ( ValType(e:subsystem) == "C" )
                cMessage += e:subsystem()
        else
                cMessage += "???"
        end


        // add subsystem's error code if available
        if ( ValType(e:subCode) == "N" )
                cMessage += ("/" + NTRIM(e:subCode))
        else
                cMessage += "/???"
        end


        // add error description if available
        if ( ValType(e:description) == "C" )
                cMessage += ("  " + e:description)
        end


        // add either filename or operation
        if ( !Empty(e:filename) )
                cMessage += (": " + e:filename)

        elseif ( !Empty(e:operation) )
                cMessage += (": " + e:operation)

        end


return (cMessage)






STATIC FUNCTION MostraError( e )
LOCAL i, cTelaErro,nnopcao,cTexto
IF cErroCorruption # NIL
   SETCOLOR(m->cError1)
   @ 10,10,18,70 BOX "ÛÛÛÛÛÛÛÛ "
   SETCOLOR(m->cError2)
   @ 12,14 SAY "Foi detectado um erro em um dos arquivos do sistema !!"
   @ 13,14 SAY "O erro n„o foi  corrigido,  porque  n„o  foi  poss¡vel"
   @ 14,14 SAY PADC("identificar a chave. O arquivo ‚: "+cErroCorruption,54)
   @ 15,14 SAY "                  Chame o programador                 " COLOR m->cError3 
	@ 16,14 SAY "               PRESSIONE QUALQUER TECLA               "
   INKEY(0)
   SET COLOR TO
   CLS
   QUIT
ENDIF

IF UPPER(e:description) == "CORRUPTION DETECTED" .AND. "NTX" $ UPPER(e:filename)
   IF EMPTY(NETNAME())
      cErroCorruption := e:filename
      memvar->nh := FOPEN(e:filename,2)
      memvar->cTexto := SPACE(512)
      memvar->cindex := FREAD(memvar->nh,@cTexto,512)
      memvar->cindex := ALLTRIM(SUBSTR(memvar->cTexto,23))
      FCLOSE(memvar->nh)
      ordCreate((e:filename),,(memvar->cindex),{||&(memvar->cindex)},)
      cErroCorruption := NIL
      SETCOLOR(m->cError1)
      @ 10,10,17,70 BOX "ÛÛÛÛÛÛÛÛ "
      SETCOLOR(m->cError2)
      @ 12,14 SAY "Foi detectado um erro em um dos arquivos do sistema !!"
      @ 13,14 SAY "O erro j  foi corrigido, por‚m ser  necess rio abortar"
      @ 14,14 SAY "a aplica‡„o."
      @ 14,26 SAY             "           Reinicialize o sistema         " COLOR m->cError3
		@ 15,14 SAY "               PRESSIONE QUALQUER TECLA               "
      INKEY(0)
      SET COLOR TO
      CLS
      QUIT
   ELSE
      SETCOLOR(m->cError1)
      @ 10,10,18,70 BOX "ÛÛÛÛÛÛÛÛ "
      SETCOLOR(m->cError2)
      @ 12,14 SAY "Foi detectado um erro em um dos arquivos do sistema !!"
      @ 13,14 SAY "O erro n„o foi corrigido, porque vocˆ est   rodando  o"
      @ 14,14 SAY PADC("programa em rede. O arquivo ‚: "+e:filename,54)
      @ 15,14 SAY "                  Chame o programador                 " COLOR m->cError3
      @ 16,14 SAY "               PRESSIONE QUALQUER TECLA               "
      INKEY(0)
      SET COLOR TO
      CLS
      QUIT
   ENDIF
ENDIF
//
SETCANCEL(.F.)
SET CURSOR OFF
SET DEVICE TO SCREEN
cTelaErro := SAVESCREEN(00,00,24,79)
SETCOLOR(m->cError4) // N/BG
@ 00,02 CLEA TO 23,78
@ 00,02 SAY PADC("Erro de Sistema",75)
@ 23,04 SAY "Copyright (c) by W&R SoftWare(R)                 1995   ³   "+DTOC(DATE())
SETCOLOR(m->cError2)
@ 01,03 CLEA TO 22,77
@ 02,05 SAY PADC("Aten‡„o: anote os dados abaixo  ou  pressione  <[ENTER]>",72)
@ 03,05 SAY PADC("para imprimir os dados. Chame o CPD                     ",72)
@ 05,05 SAY "Data do erro.............: " + DTOC(DATE()) + "      Hora: " + TIME()
@ 06,05 SAY "Mem¢ria para caracteres..: " + ALLTRIM(STR(MEMORY(0))) + " para blocos: " + ALLTRIM(STR(MEMORY(1))) ;
            +" para RUN: " + ALLTRIM(STR(MEMORY(2)))
DEFERROR2(e)
@ 12,05 SAY "Erro a N¡vel Sistema DOS.: "+LTRIM(STR(e:osCode))
@ 13,05 SAY "Nome do SubSistema.......: "+e:subSystem
@ 14,05 SAY "Erro a N¡vel SubSistema..: "+LTRIM(STR(e:subCode))
@ 15,05 SAY "C¢digo do Erro Gen‚rico..: "+LTRIM(STR(e:genCode))
@ 17,05 SAY "N§ Vezes da Falha........: "+LTRIM(STR(e:tries))
@ 18,05 SAY "N§ do Erro...............: "+LTRIM(STR(e:severity))
@ 19,05 SAY "Possibilita DEFAULT......: "+IF(e:canDefault,"SIM","NAO")
@ 20,05 SAY "Possibilita RETRY........: "+IF(e:canRetry,"SIM","NAO")
@ 21,05 SAY "Pos.Subst. Erro p/ Valor.: "+IF(e:canSubstitute,"SIM","NAO")
IF ALIAS() # ""
   @ 09,05 SAY "Arq. em uso: " + ALIAS() + " ordem: "+INDEXKEY(INDEXORD())
ENDIF
@ 10,40 SAY "Argumento Fun‡„o: "
   IF VALTYPE(e:args) == "A"
      @ 10,58 SAY "Matriz: "+ LTRIM(STR(LEN(e:args)))+" elementos "
      i := 1
      DO WHIL i < 4
         @ 10 + i , 40  SAY  "Elemen[" + STR(i,2) + "]......: "
         @ 10 + i , 58  SAY  e:args[i]
         IF i == LEN(e:args)
            EXIT
         ENDIF
         i++
      ENDDO
   ELSE
      @ 10,60 SAY e:args
   ENDIF
   @ 14,40 TO 22,77
   @ 14,50 SAY " Fun‡”es com erro : "
        m->j := 1
        i := 3
        while ( !Empty(ProcName(i)) )
                @ m->j + 14,41 SAY "Fun‡„o: " + Trim(ProcName(i)) + ;
                        "(" + NTRIM(ProcLine(i)) + ")  "

                i++
                m->j++
                IF m->j > 7
                   EXIT
                ENDIF
        end
IF e:osCode # 4
   GRAVAERRO(e)
ENDIF
INKEY(0)
IF LASTKEY() == 13
DO WHIL .T.
   IF ISPRINTER()
      SET DEVICE TO PRINTER
      @ 00,00 SAY CHR(27) + CHR(18)
      @ 00,07 SAY "W&R Informatica Centro de Desenvolvimento  de Software"
      @ 01,05 SAY "Relat¢rio de erros gen‚ricos"
******
******
******  comeca a impressao do dados dos erros
@ 03,05 SAY "Data do erro.............: " + DTOC(DATE()) + "      Hora: " + TIME()
@ 04,05 SAY "Mem¢ria para caracteres..: " + ALLTRIM(STR(MEMORY(0))) + " para blocos: " + ALLTRIM(STR(MEMORY(1))) ;
            +" para RUN: " + ALLTRIM(STR(MEMORY(2)))
DEFERROR2(e)
@ 10,05 SAY "Erro a N¡vel Sistema DOS.: "+LTRIM(STR(e:osCode))
@ 11,05 SAY "Erro a N¡vel SubSistema..: "+LTRIM(STR(e:subCode))
@ 12,05 SAY "Nome do SubSistema.......: "+e:subSystem
@ 13,05 SAY "C¢digo do Erro Gen‚rico..: "+LTRIM(STR(e:genCode))
@ 15,05 SAY "N§ Vezes da Falha........: "+LTRIM(STR(e:tries))
@ 16,05 SAY "N§ do Erro...............: "+LTRIM(STR(e:severity))
@ 17,05 SAY "Possibilita DEFAULT......: "+IF(e:canDefault,"SIM","NAO")
@ 18,05 SAY "Possibilita RETRY........: "+IF(e:canRetry,"SIM","NAO")
@ 19,05 SAY "Pos.Subst. Erro p/ Valor.: "+IF(e:canSubstitute,"SIM","NAO")
IF ALIAS() # ""
   @ 20,05 SAY "Arquivo em uso...........: "+ALIAS() + " ordem: " + INDEXKEY(INDEXORD())
ENDIF
@ 21,05 SAY "Argumento Fun‡„o: "
   IF VALTYPE(e:args) == "A"
      @ 21,23 SAY "Matriz: "+ LTRIM(STR(LEN(e:args)))+" elementos "
      i := 1
      DO WHIL .T.
         @ 21 + i , 05  SAY  "Elemen[" + STR(i,2) + "]......: "
         @ 21 + i , 23  SAY  e:args[i]
         IF i == LEN(e:args)
            EXIT
         ENDIF
         i++
      ENDDO
   ELSE
      @ 21,25 SAY e:args
   ENDIF
        m->j := i
        i := 3
        while ( !Empty(ProcName(i)) )
                @ m->j + 23,05 SAY "Fun‡„o: " + Trim(ProcName(i)) + ;
                        "(" + NTRIM(ProcLine(i)) + ")  "

                i++
                m->j++
        end
        @ m->j + 25,05 SAY "Fim de relat¢rio de erros"
        @ m->j + 26,05 SAY "Copyright (c) by W&R Software - 1995   ³   "+DTOC(DATE())
        EJECT
        SET DEVICE TO SCREEN
        EXIT
   ELSE
      m->aaoptions := {"Continuar","Sair"}
      nnOPCAO := ALERT("Impressora desligada ou desconectada", m->aaoptions)
      IF nnOPCAO == 1
         LOOP
      ELSE
         EXIT
      ENDIF
   ENDIF
ENDDO
ENDIF
RESTSCREEN(00,00,24,79,cTelaErro)
SETCANCEL(.T.)
SET CURSOR ON
RETURN (NIL)
***************************************************************************

static func DefError2(e)
local i, cMessage, aOptions, nChoice

        if ( e:genCode == EG_ZERODIV )
                return (0)
        end

        if ( e:genCode == EG_OPEN .and. e:osCode == 32 .and. e:canDefault )

                NetErr(.t.)
                return (.f.)                                                                    // NOTE

        end

        if ( e:genCode == EG_APPENDLOCK .and. e:canDefault )

                NetErr(.t.)
                return (.f.)                                                                    // NOTE

        end

        cMessage := ErrorMessage(e)

        @ 08,05 SAY cMessage

return (.t.)
********************************
FUNCTION GRAVAERRO(e)
SET DEVICE TO PRINT
SET PRINTER TO "ERROS.TXT"
@ 00,00 SAY "Data do erro.............: " + DTOC(DATE()) + "      Hora: " + TIME()
@ 01,00 SAY "Mem¢ria para caracteres..: " + ALLTRIM(STR(MEMORY(0)))
@ 02,00 SAY "Erro a N¡vel Sistema DOS.: "+LTRIM(STR(e:osCode))
@ 03,00 SAY "Nome do SubSistema.......: "+e:subSystem
@ 04,00 SAY "Erro a N¡vel SubSistema..: "+LTRIM(STR(e:subCode))
@ 05,00 SAY "C¢digo do Erro Gen‚rico..: "+LTRIM(STR(e:genCode))
@ 06,00 SAY "N§ Vezes da Falha........: "+LTRIM(STR(e:tries))
@ 07,00 SAY "N§ do Erro...............: "+LTRIM(STR(e:severity))
@ 08,00 SAY "Possibilita DEFAULT......: "+IF(e:canDefault,"SIM","NAO")
@ 09,00 SAY "Possibilita RETRY........: "+IF(e:canRetry,"SIM","NAO")
@ 10,00 SAY "Pos.Subst. Erro p/ Valor.: "+IF(e:canSubstitute,"SIM","NAO")
IF ALIAS() # ""
   @ 11,00 SAY "Arq. em uso: " + ALIAS() + " ordem: "+INDEXKEY(INDEXORD())
ENDIF
@ 12,00 SAY "Argumento Fun‡„o: "
m->i := 1
IF VALTYPE(e:args) == "A"
   @ 13,00 SAY "Matriz: "+ LTRIM(STR(LEN(e:args)))+" elementos "
   DO WHIL m->i < 4
      @ 13+m->i,00 SAY "Elemen[" + STR(m->i,2) + "]......: "
      @ 13+m->i,20 SAY e:args[m->i]
      IF m->i == LEN(e:args)
         EXIT
      ENDIF
      m->i++
   ENDDO
ELSE
   @ 13+m->i+1,00 SAY e:args
ENDIF
@ 13+m->i+2,00 SAY " Fun‡”es com erro : "
m->j := 1
m->i := 3
while ( !Empty(ProcName(m->i)) )
        @ 13+m->i+3,00 SAY "Fun‡„o: " + Trim(ProcName(m->i)) + ;
                "(" + NTRIM(ProcLine(m->i)) + ")  "

        m->i++
        m->j++
        IF m->j > 7
           EXIT
        ENDIF
end
SET DEVICE TO SCREEN
SET PRINTER TO
RETURN NIL
