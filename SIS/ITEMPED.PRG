// Gera get's dos Itens dos pedidos itilizando o objeto Get
// By W. Litaiff Vasconcelos
// Data 29/12/1998
// Beta 1
//
// Declaracao de variaveis a serem editadas
Local cProduto:=Space(16),cNome:=Space(20),nQuantidade:=0.000

MEMVAR aObjGet

// Cria um objto Get, atribuindo-o a variavel
// ObjGetPro, sendo posteriormente avaliado pela funcao READMODAL()

Clea screen
cProduto:=Space(16)
nQuantidade:=0.000
//
nLin := 10
nCol := 30

Do While .T.

	IF LASTkEY()=27
		EXIT
	ENDIF

	@ nLin,01 say "Produto.:"
	@ nLin,30 say "Quantid.:"

aObjGet := { GetNew( nLin,12,MEMVARBLOCK("cProduto"),,"@!","W/N,N/W"),;
             GetNew( nLIn,40,MEMVARBLOCK("nQuantidade"),,"@E 99,999.99","W/N,N/W") }
									            
//READMODAL( {ObjGetPro,ObjGetQtd} )
WREAD( aObjGet )

nLin ++

Enddo
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
		col() != aObjGet[nGet]:col + aObjGet[nGet]:pos -1
		
		setpos(aObjGet[nGet]:row,;
				 aObjGet[nGet]:col + aObjGet[nGet]:pos -1 )
				 
	EndIf

EndDo

aObjGet[1]:assign()
aObjGet[2]:assign()
aObjGet[3]:assign()

Return(nil)