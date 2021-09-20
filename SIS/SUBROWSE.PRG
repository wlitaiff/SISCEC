PARAMETERS dbfname, indexname, lkey, hkey, pattern, filt_cond, tries
external descend

* I thought I'd through in this kind of utility I have used to do some 
* testing.  Please forgive my on-the-fly program writing style. Use this
* from the C: prompt as a utility to browse a subset of a database, using
* its associated (and updated) index to extract the sub index from.
* 
* SYNTAX:  subrowse <dbfname> <indexname> <lkey> <hkey> <pattern>
* 
* Notice optional "" in example.
* 
* EXAMPLE: 
*
*   subrowse test testindex A            && everything beginning with 'A'
* 
*   subrowse test testindex "A"          && same as above
* 
*   subrowse test testindex "A "         && everything beginning with 'A '
* 
*   subrowse test testindex A B "*THE*"  && Everything between A and B
*                                           with the work "THE" somewhere
*                                           in the key.
*
*   subrowse test testindex A B "*THE*" "lname=='Moon'"    && Same as above
*                                        && but also calls _subeval() with
*                                        && the condition.  Be careful its
*                                        && a valid condition.
*
* 
* 
* 
*   Thanks for your support.....
* 

PUBLIC use_extproc
public times[2]




DO CLSCREEN

if pcount() < 3
    ? "Usage: subrowse <dbfname>, <ntxname>, <lkey> [,<hkey> [,<pattern> [,<filt_cond>]]]"
    quit
endif             


if type("hkey") == "U"
    hkey = ""
endif

if type("pattern") == "U"
    pattern = ""
endif


if type("filt_cond") != "C"
    filt_cond = ""
    use_extproc = .f.
else     
    if filt_cond == ""
        use_extproc = .f.
    else
        use_extproc = .t.
    endif

endif


if type("tries") != "C"
    tries = 3
else
    tries = val(tries)
endif



**  Uncomment this block if you want to display this info
*
*
*?  "dbfname:     "
*??  dbfname
*
*?  "indexname:   "
*??  indexname
*
*?  "lkey:        "
*??  lkey
*
*?  "hkey:        "
*??  hkey
*
*?  "pattern:     "
*??  pattern
*
*?  "use_extproc: " 
*??  use_extproc 
*?
*
*?  "filt_cond: " 
*??  filt_cond 
*?
*
*?  "retry count: " 
*??  tries 
*?
*
*wait
*
*


dbfname = fixfile( dbfname, "dbf" )

if ! file(dbfname)
    ? "Can't find: "+dbfname
    quit
endif


use (dbfname) 




indexname = fixfile(indexname, "ntx" )
if ! file(indexname)
    ? "Cant find: "+indexname
    quit
endif


if file("_sub.ntx")
    wait [File "_sub.ntx" already exists, do you want to overwrite? ] to yn
    if upper(yn) <> "Y"
        quit
    endif
endif






time1 = seconds()    

********* HERE IT IS *************
**********************************

recs = subntx( indexname, "_sub.ntx", lkey, hkey, pattern, use_extproc, tries )

**********************************
**********************************

time2 = seconds()
times[1] = "Total SubNtx() time: "+str( time2-time1 )          

IF recs < 0
    ? "Error returned: "+str(recs)
    quit
endif




set index to _sub

public flds[ fcount() ]
afields( flds )



DO CLSCREEN
@ 0,0 say "          Browsing " + alltrim(str(recs))+ " records.....Press <Esc> to finish...."
browse()                                          


clear
? times[1]

use

erase _sub.ntx


*                           End of main
***************************************************************************


FUNCTION browse

    t = 5
    l = 5
    b = 20
    r = 75


    @ t-1,l-1 clear to b+1,r+1
    @ t-1,l-1 to b+1,r+1 double

    dbedit(t,l,b,r,flds)                                          
    DO CLSCREEN
return ""




FUNCTION fixfile
    parameters filename, ext

    if [.] $ filename
        filename = substr(filename,1, at(".",filename) ) + ext
    else
        filename = trim(filename)+"."+ ext
    endif

return filename 




PROCEDURE _subeval
    rec = subrec()
    key = subkey()
    go rec
    if &FILT_COND   && global variable with a valid condition to check
        reteval(.T.)
    else
        reteval(.F.)
    endif
RETURN 




PROCEDURE CLSCREEN
setcolor("W/B,+N/W")

@ 00,00,24,79 box replicate(chr(177),9)

return
