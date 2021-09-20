#include "MOUSE.CH"
#include "INKEY.CH"

FUNCTION Minkey(nSecs, nMRow, nMCol, lChkDouble)

   LOCAL nRet    := 0
   LOCAL lLeft   := .F.
   LOCAL lRight  := .F.
   LOCAL lDouble := .F.
   LOCAL nDesc_Tela   := 0
   LOCAL nTime, nTELADES

   // do we want to check for double clicks
   lChkDouble := IIF(lChkDouble == NIL, .F., lChkDouble)

   // turn on the mouse cursor
   MouseOn()

   // don't even check for mouse if it's an INKEY() with
   // no parameters
   IF nSecs == NIL
      nRet := inkey()
   ELSE

      // wait for either a keystroke, a left
      //    button click, or until nSecs have
      //    elapsed
      nDesc_Tela := nTime :=  SECONDS()
      WHILE ( nRet := inkey()) == 0 .AND. ;
         !(lLeft  := LeftButt())    .AND. ;
         !(lRight := RightButt())   .AND. ;
         IIF (nSecs > 0, ;
            (SECONDS() - nTime) < nSecs, .T.)
         IF (SECONDS()-nDesc_Tela) > Conf_CFG("TEMPO")
            nRow := ROW()
            nCol := COL()
            nCursor:=SETCURSOR(0)
            MouseOFF()
            DESCANSO()
            MouseOn()
            SETCURSOR(nCursor)
            SETPOS(nRow,nCol)
            nDesc_Tela := SECONDS()
         ENDIF
      ENDDO

      // check for a double click
      IF lChkDouble .AND. lLeft
         nTime := SECONDS()

         // loop until they let go of the button
         WHILE LeftButt() .AND. (SECONDS() - nTime < 0.20)
         ENDDO

         // check for a second click
         WHILE SECONDS() - nTime < 0.20 .AND. !(lDouble := LeftButt())
         ENDDO

      ENDIF

   ENDIF

   nMRow := MouseRow()
   nMCol := MouseCol()

   // hide the mouse cursor
   MouseOff()

   IF lDouble
      nRet := M_LEFT_DOUBLE
      nRet1:= Pesq_Tecla(nMRow,nMCol)
      nRet := IF(nRet1==NIL,nRet,nRet1)
   ELSEIF lLeft
      nRet := M_LEFT
   ELSEIF lRight
      nRet := M_RIGHT
   ENDIF

RETURN( nRet )
// ÄÄÄ  Minkey ÄÄÄ //

FUNCTION MouseGet(GetList, nPos, nMRow, nMCol)

   LOCAL nNewPos := 0
   LOCAL nHit    := .f.

   // see if which get we clicked on, if any
   WHILE nNewPos < len( GetList) .AND. !nHit

      nNewPos++

      IF nMRow == GetList[nNewPos]:Row .AND. ;
         nMCol >= GetList[nNewPos]:Col .AND. ;
         nMCol <= GetList[nNewPos]:Col + GetLen(GetList[nNewPos])

         nHit := .T.

      ENDIF
   ENDDO

RETURN( IIF(nHit, nNewPos, nPos))
// ÄÄÄ  MouseGet ÄÄÄ //

// This function was pretty much stolen right from Jim
// Tamburrino's Devcon paper from 1992.  It's absolutely
// critical to the proper functioning of the mouse with the
// get system.  Nice job Jim.
FUNCTION GetLen(oGet)

   LOCAL nLen

   DO CASE
      CASE oGet:type == "C"
          nLen := LEN(oGet:varGet())

      CASE oGet:type == "D"
         nLen := 8

      CASE oGet:type == "L"
         nLen := 1

      CASE oGet:type == "N"
         IF EMPTY(oGet:picture)
            nLen := LEN(LTRIM(STR(oGet:varGet())))
         ELSE
            nLen := LEN(oGet:picture)
         ENDIF

   ENDCASE

RETURN(nLen)
// ÄÄÄ  GetLen ÄÄÄ //


FUNCTION Pesq_Tecla(li,co)
LOCAL tecl_p
IF CLICK_EM("<ENTER>",li,co)
     tecl_p=K_ENTER
ELSEIF CLICK_EM("<INS>",li,co)
     tecl_p=K_INS
ELSEIF CLICK_EM("<DEL>",li,co)
     tecl_p=K_DEL
ELSEIF CLICK_EM("Sim",li,co)
     tecl_p= 83
ELSEIF CLICK_EM("N„o",li,co)
     tecl_p= 78
ELSEIF CLICK_EM("F10",li,co)
     tecl_p=K_F10
ELSEIF CLICK_EM("F9",li,co)
     tecl_p=K_F9
ELSEIF CLICK_EM("F8",li,co)
     tecl_p=K_F8
ELSEIF CLICK_EM("F7",li,co)
     tecl_p=K_F7
ELSEIF CLICK_EM("F6",li,co)
     tecl_p=K_F6
ELSEIF CLICK_EM("F5",li,co)
     tecl_p=K_F5
ELSEIF CLICK_EM("F4",li,co)
     tecl_p=K_F4
ELSEIF CLICK_EM("F3",li,co)
     tecl_p=K_F3
ELSEIF CLICK_EM("F2",li,co)
     tecl_p=K_F2
ELSEIF CLICK_EM("F1",li,co)
     tecl_p=K_F1
ELSEIF CLICK_EM("TAB",li,co)
     tecl_p=K_TAB
ELSEIF CLICK_EM(CHR(27),li,co)
     tecl_p=K_LEFT
ELSEIF CLICK_EM(CHR(26),li,co)
     tecl_p=K_RIGHT
ELSEIF CLICK_EM(CHR(24),li,co)
     tecl_p=K_UP
ELSEIF CLICK_EM(CHR(25),li,co)
     tecl_p=K_DOWN
ELSEIF CLICK_EM("PgUp",li,co) .OR. CLICK_EM(CHR(30),li,co)
     tecl_p=K_PGUP
ELSEIF CLICK_EM("PgDn",li,co) .OR. CLICK_EM(CHR(31),li,co)
     tecl_p=K_PGDN
ELSEIF CLICK_EM("Topo",li,co) .OR. CLICK_EM(CHR(174),li,co)
     tecl_p=K_CTRL_PGUP
ELSEIF CLICK_EM("Fim",li,co)  .OR. CLICK_EM(CHR(175),li,co)
     tecl_p=K_CTRL_PGDN
ELSEIF CLICK_EM(CHR(18),li,co)
     tecl_p=74
ELSEIF CLICK_EM("<ESC>",li,co)
     tecl_p=K_ESC
ELSEIF CLICK_EM(CHR(254),li,co)
     tecl_p=K_ESC
ELSEIF 1==2 // e_calc                         // clique da calculadora sobre
     msg="1234567890.+-*/%^#$C=R"     // um numero ou sinal
     FOR i=1 TO LEN(msg)
          IF CLICK_EM(SUBS(msg,i,1),li,co)
               tecl_p=ASC(SUBS(msg,i,1))
               EXIT
          ENDI
     NEXT
ENDI
RETURN (tecl_p)


/*
   Sintaxe: CLICK_EM( <ExpC> <,ExpN1> <,ExpN2> )
   Funcao.: Verifica se ExpC esta sobre as coordenadas ExpN1 e ExpN2
   Retorna: .t. se teve sucesso
*/
STATIC FUNC CLICK_EM(te_cl,li,co)
LOCAL t_s:="", t1, t2, t_
t1=LEN(te_cl)                                                  // salva trecho de tela nas
t_ := SAVESCREEN(li,co-t1,li,co+t1)                            // coordenadas do clique
t1=LEN(t_)
FOR t2=1 TO t1 STEP 2                                          // separa os atributos das letras
     t_s+=SUBST(t_,t2,1)                                       // do trecho salvo
NEXT
t1=AT(te_cl,t_s)                                               // tecla esta sob o cursor?
IF t1>0                                                        // verifica se a tecla nao e'
     t2=ASC(SUBS(t_s,t1-1,1))                                  // um pedaco de palavvra
     t1=ASC(SUBS(t_s,t1+LEN(te_cl),1))
     IF (t1<65 .OR. t1>125) .AND. (t2<65 .OR. t2>125)
          RETU .t.                                             // ok. a tecla foi clicada
     ENDI
ENDI
RETU .f.                                                       // a tecla nao foi clicada
