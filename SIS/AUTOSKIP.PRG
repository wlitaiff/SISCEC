#include "setcurs.ch"
#include "inkey.ch"

#define TRUE .T.

//Local aObjGet

MEMVAR cCharLower, cCharUpper, nNumeric, aObjGEt         //Assume como PRIVATE

cCharLower := cCharUpper := Space(30)
nNumeric := 0

aObjGet := { GetNew(10,35,MEMVARBLOCK("cCharUpper"),,"@!","W/N,N/W"),;
				 GetNew(11,35,MEMVARBLOCK("cCharLower"),,"@A","W/N,N/W"),;
				 GetNew(12,35,MEMVARBLOCK("nNumeric"  ),,"@E 99,999.99","W/N,N/W") }
cls
//READMODAL( aObjGet )
WRead( aObjGet )
Return(nil)


Function WRead()

Local nKey, nGet := 1, cTime

aObjGet[1]:setFocus()
aObjGet[2]:setFocus()
aObjGet[2]:setFocus()

Do While ( nKey := Inkey() ) != K_RETURN
	
	// Letras Maiusculas
	IF nKey >= ASC("A") .and. nKey <= ASC("Z")
		aObjGet[1]:insert( Chr(nKey) )
		nGet := 1
	// Letras Minusculas
	ELSEIF nKey >= ASC("a") .and. nKey <= ASC("z")
		aObjGet[2]:insert( Chr(nKey) )
		nGet := 2
	// Numeros
	ELSEIF nKey >= ASC("0") .and. nKey <= ASC("9")
		aObjGet[3]:insert( Chr(nKey) )
		nGet := 3	
	ELSEIF nKey == K_BS
		aObjGet[nGet]:backSpace()
		
	ENDIF
		
	IF row() != aObjGet[nGet]:row .or. ;
		col() != aObjGet[nget]:col + aObjGet[nGet]:pos -1
		
		setpos(aObjGet[nGet]:row,;
				 aObjGet[nGet]:col + aObjGet[Nget]:pos -1 )
				 
	EndIf

EndDo

aObjGet[1]:assign()
aObjGet[2]:assign()
aObjGet[3]:assign()

Return(nil)