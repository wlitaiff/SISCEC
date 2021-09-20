LOCAL FLAG := 'D'
clear
use sipcpro
teste := scrollbarnew(1,1,22,78,,2)
scrollbardisplay( teste )
do whil LASTKEY()#27
   @ 1,10 SAY '         '
   @ 24,10 SAY '         '
	ScrollBarUpdate( teste,recno(),lastrec())
	IF FLAG == 'D'
		skip
	ELSE
	   SKIP - 1
	ENDIF	
	inkey(0.01)
	IF EOF()
	   @ 24,10 SAY '<EOF>'
		inkey(0)
	   FLAG := 'S'
	ENDIF
	IF BOF()
	   @ 1,10 SAY '<BOF>'
		inkey(0)
	   FLAG := 'D'
	ENDIF
enddo
return