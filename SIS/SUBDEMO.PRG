*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
*³                                                                         ³
*³ Program:  Subdemo.prg                                                   ³
*³                                                                         ³
*³                                                                         ³
*³ Compile:  CLIPPER SUBDEMO                                               ³
*³ Link:     LINK /NOE subdemo,,,clipper extend subntxd                    ³
*³                                                                         ³
*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SET SCOREBOARD OFF

PUBLIC mainscrn

wait_for = 99
no_erase = 0

public alkey[3] 
public aukey[3] 
public awcard[3]
public axproc[3]
public atries[3]

alkey[1]  = "*              "
aukey[1]  = "Brink          "
awcard[1] = "*a*            "
axproc[1] = .T.
atries[1] = -1

alkey[2]  = "C              "
aukey[2]  = "D              "
awcard[2] = "*1990??15*     "
axproc[2] = .F.
atries[2] = -1

alkey[3]  = "L              "
aukey[3]  = "Li             "
awcard[3] = "*              "
axproc[3] = .T.
atries[3] = -1



DO MAKESCRN
SAYMSG("                       SUBNTX() Demonstration Program","",no_erase)


IF ! FILE("SUBDEMO.DBF")
    @ 21,24 SAY      "ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿"
    @ ROW()+1,24 SAY "³                               ³"
    @ ROW()+1,24 SAY "³  SUBDEMO.DBF Not Found......  ³"
    @ ROW()+1,24 SAY "³                               ³"
    @ ROW()+1,24 SAY "ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ"
    QUIT
ENDIF


@ 5,20 SAY       "ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿"
@ ROW()+1,20 SAY "³                                        ³"
@ ROW()+1,20 SAY "³               Note:                    ³"
@ ROW()+1,20 SAY "³                                        ³"
@ ROW()+1,20 SAY "³  - This demo requires approximately    ³"
@ ROW()+1,20 SAY "³    425K of diskspace to run.           ³"
@ ROW()+1,20 SAY "³                                        ³"
@ ROW()+1,20 SAY "³  - Also this creates two files:        ³"
@ ROW()+1,20 SAY "³    SUBDEMO.NTX and _SUBTMP.DBF         ³"
@ ROW()+1,20 SAY "³                                        ³"
@ ROW()+1,20 SAY "³                                        ³"
@ ROW()+1,20 SAY "³    Do you want to continue (Y/N)?      ³"
@ ROW()+1,20 SAY "³                                        ³"
@ ROW()+1,20 SAY "ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ"


yn = "Y"
@ ROW()-2,56 GET yn PICTURE "!" VALID yn$"YN"
READ                      

IF yn != "Y" .OR. lastkey() == 27
    CLEAR
    QUIT
ENDIF



RESTORE SCREEN FROM mainscrn
USE SUBDEMO
IF lastrec() < 75
    DO EXPAND_DBF
ENDIF

IF ! FILE("SUBDEMO.NTX")
    saymsg(" STAND BY WHILE INDEXING.......","",no_erase)
    INDEX ON LNAME+FNAME+DTOS(ORDERDATE) TO SUBDEMO
    RESTORE SCREEN FROM mainscrn
ENDIF

* Define fields for browsing
PUBLIC flds[5]
flds[1]="rec"
flds[2]="fname"
flds[3]="lname"
flds[4]="orderdate"
flds[5]="position"
t = 10
l = 05
b = 20
r = 75




* All records                                               
RESTORE SCREEN FROM mainscrn  
saymsg(" To First browse with all records.........Press any key.......",1,wait_for)
set index to SUBDEMO
go top
seek "Moon"
saymsg(" Browsing all records.....Press any key when finished.....",1,no_erase)
browse()                                          




* Filter method
saymsg(" Next is with a filter......Press any key......",1,wait_for)
go top
seek "Moon"
set filter to lname = "Moon"                                 
saymsg(" Notice when you move past boundaries it takes a VERY LONG time....",1,no_erase)
saymsg(" (probably more than a minute)",2,no_erase)
browse()                                                                        
set filter to





* Subindex method
set index to
saymsg(" Next is with the SubNtx() method.",1,no_erase)
saymsg(" Press any key to begin extracting the subset from the main index.....",2,wait_for)
RESTORE SCREEN FROM mainscrn
num = subntx( "SUBDEMO.NTX", "_SUB.NTX", "Moo" )
RESTORE SCREEN FROM mainscrn
set index to _sub 
saymsg(" Browsing small subset with sub.ntx.......Press any key when finished.....",1,no_erase)
saymsg("",2,no_erase)
browse()
set index to
erase _sub.ntx



FOR i = 1 to 3   && max for demo

    RESTORE SCREEN FROM mainscrn
    saymsg(" Now try some of the other parameters.....",1,no_erase)

    set index to

    * Store different examples for each time
    lkey  = alkey[i]
    ukey  = aukey[i]
    wcard = awcard[i]
    xproc = axproc[i]
    tries = atries[i]                       

    @ 5,4 say "<code> = SubNtx( main, sub, lkey [,ukey [,wcard [, xproc [,tries ]]]] )"

    @ 09, 00, 24 ,79 box "ÚÄ¿³ÙÄÀ³ " 
    @ 10, 01 say "lkey..:                 ....Partial lower key range (required)"
    @ 11, 01 say "ukey..:                 ....Partial upper key range (optional)"
    @ 12, 01 say "wcard.:                 ....Wild Card Pattern (optional)"
    @ 13, 01 say "xproc.:                 ....Use predefined Clipper Procedure* (optional)"
    @ 14, 01 say "tries.:                 ....Number of tries to lock main index file (optional)"

    @ 16, 01 say "   * Note: The predfined Clipper function for this demo is:"
    @ 17, 01 say "           recno() > 1800 .AND. recno() < 2000"

    @ 19, 01 say "   * Here's one records index key to help guide you:"
    @ 20, 01 say "           Offset...........:12345678901234567890123456789012345678"
    @ 21, 01 say "           Key..............:Moon           Skip           19900101"

    @ 23, 01 say "           Contents.........:(LNAME=15)  +  (FNAME=15)  +  DTOS(orderdate)"


    @ 10, 09 get lkey
    @ 11, 09 get ukey
    @ 12, 09 get wcard
    @ 13, 09 get xproc 
    @ 14, 09 get tries picture "999"
    READ
    IF LASTKEY() == 27
        EXIT
    ENDIF

    lkey  = trim(lkey)
    ukey  = trim(ukey)
    wcard = trim(wcard)
    xproc = iif(xproc==.t.,.t.,.f.)
    tries = iif(tries<1,-1,tries)

    saymsg(" ",1,no_erase)
    saymsg(" Press any key to begin extracting the subset from the main index.....",2,wait_for)
    RESTORE SCREEN FROM mainscrn

    num = subntx( "subdemo.ntx", "_sub.ntx", lkey, ukey, wcard, xproc, tries )

    RESTORE SCREEN FROM mainscrn
    set index to _sub 
    saymsg(" Browsing "+str(num,4)+" extracted records with sub.ntx",1,no_erase)
    saymsg(" Press any key when finished....",2,no_erase)
    browse()
    set index to
    erase _sub.ntx

NEXT

close databases
RESTORE SCREEN FROM mainscrn

IF i == 4
    saymsg("Sorry you'll have to start the demo over since it's limited to a total",1,no_erase)
    saymsg("of 5 calls per program execution. (Or send in the order form......<g>)",2,no_erase)
ELSE
    saymsg(" That ends the demo... ",1,no_erase)
ENDIF
@ 23,0 SAY ""
QUIT



FUNCTION browse
    @ t-1,l-1 clear to b+1,r+1
    @ t-1,l-1 to b+1,r+1 double
    dbedit(t,l,b,r,flds)                                          
    RESTORE SCREEN FROM mainscrn
return ""


PROCEDURE _subeval       && This is just a sample _subeval() 
    rnum = subrec()
    * key = subkey()
    * go rnum
    if rnum > 1800 .and. rnum < 2000   && typical condition or macro
        reteval(.T.)
    else
        reteval(.F.)
    endif
RETURN 


PROCEDURE MAKESCRN
    setcolor("W/B,+N/W")
    @ 00,00,24,79 box replicate(chr(177),9)
    @ 00,00,03,79 box "ÚÄ¿³ÙÄÀ³ "
    SAVE SCREEN TO mainscrn
return





PROCEDURE EXPAND_DBF
    saymsg(" STAND BY WHILE EXPANDING SUBDEMO.DBF....","",0)
    COPY TO _SUBTMP
    FOR i = 1 to 49
        APPEND FROM _SUBTMP
    NEXT
    ERASE _SUBTMP.DBF
    REPLACE ALL REC WITH RECNO()
    RESTORE SCREEN FROM mainscrn
RETURN



********
FUNCTION SAYMSG
********
    * Says message on <xline>, and waits  <xpause> secs, unless keypressed
    *  If xpause = 0, it returns without clearing
    *  If xpause = 99 it waits for a keypress
    PARAMETERS xmsg,xline,xpause
    IF type("xline")!=[N]
        xline=2
    ENDIF
    IF type("xpause")=[U]
        xpause=0
    ENDIF
    @ xline,02 SAY SPACE(76)
    @ xline,02 SAY xmsg
    IF xpause = 0
        RETURN ( "" )
    ENDIF
    xpause=IIF(xpause=99,0,xpause)
    INKEY(xpause)
    @ xline,02 SAY SPACE(76)
RETURN( "" )
