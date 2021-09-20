#include "Inkey.CH"
#include "SetCurs.CH"
#include "Fileman.ch"
#include "Directry.ch"
#include "Memoedit.ch"
#include "Achoice.ch"
#include "Set.ch"
#include "DBSTRUCT.CH"

#define MY_HSEP		"ÄÂÄ"
#define MY_CSEP		" ³ "
#define MY_FSEP      "ÄÁÄ"
#define fr1          "ÚÄ¿³ÙÄÀ³ "

local num
clear
if !file("SIPCPASS.DBF")
	return nil
endif
num:=0
do while .t.
	sele 1
	use sipcpass
	if file("acessnew.dbf")
		dele file "acessnew.dbf"
	endif
	@ 21,01 to 23,70 double
	@ 22,03 say "N£mero a Incluir :" get num valid !empty(num)
	read
	if lastkey()==27
		return nil
	endif 
	if alert("Confirma InclusÆo de Opcäes",{"Sim","NÆo"})==2
		return nil		
	endif
	aray := DBSTRUCT()
	aray[2][3]++
	dbcreate("ACESSNEW",aray)
	sele 2
	use acessnew
	dbgotop()
	sele 1
	dbgotop()
	do while !eof()
		sele 2
		dbappend()
		acessnew->nome :=sipcpass->nome
		acessnew->senha:=sipcpass->senha
		sele 1
		dbskip()
	enddo
	sele 1
	dbgotop()
	sele 2
	dbgotop()
	do while !eof()	
		n_nome  := Criptografa ( nome,   "HAWK" , .F. ) 
		n_senha := Criptografa ( senha,  n_nome , .F. ) 
		n_acesso:= Criptografa ( sipcpass->acesso, n_senha, .F. ) 
		@ 06,01 say "Nome:   "+n_nome
		@ 07,01 say "Senha:  "+n_senha
		@ 08,01 say "(ant):  "+n_acesso
		n_acesso2:=substr(n_acesso,1,num-1) + '0' + substr(n_acesso,num,len(n_acesso))
		@ 09,01 say "(pos):  "+n_acesso2
		@ 10,01 say "Tamanh (ant): "+str(len(n_acesso))
		@ 11,01 say "Tamanh (pos): "+str(len(n_acesso2))
		acessnew->acesso:=Criptografa ( n_acesso2, n_senha, .T. ) 
		@ 13,01 say "gravado..."
		@ 14,01 say "Nome:   "+n_nome
		@ 15,01 say "Senha:  "+n_senha
		@ 16,01 say "(ant):  "+n_acesso2
		inkey(0)
		sele 1
		dbskip()
		sele 2
		dbskip()
	enddo
	dbcloseall()
	//dele file sipcpass
	//use acessnew
	//copy to sipcpass
enddo
dbcloseall()
if file("acessnew.dbf")
		dele file "acessnew.dbf"
endif



FUNCTION Criptografa( Pstr, Psenha, Pencript )
   Local Tcript, Tx, Tascii
   Local Tlensenha := Len(Trim(Psenha))
         Tcript :=''
         For Tx := 1 to Len(Pstr)
            If Pencript  // .t. emcripta
               Tascii := Asc( Subs ( Pstr, Tx, 1 ) ) +;
                         Asc( Subs ( Psenha,(Tx % Tlensenha ) + 1,1))
            Else
               Tascii := Asc( Subs ( Pstr, Tx, 1 ) ) -;
                         Asc( Subs ( Psenha,(Tx % Tlensenha ) + 1,1))
            EndI
            Tcript := Tcript + Chr(Tascii)
         Next
    Return( Pstr := Tcript)