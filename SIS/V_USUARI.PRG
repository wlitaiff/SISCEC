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
	use sipcpass shared
	/*if file("acessnew.dbf")
		dele file "acessnew.dbf"
	endif
	if lastkey()==27
		return nil
	endif 
	aray := DBSTRUCT()
	aray[2][3]++
	dbcreate("ACESSNEW",aray)
	sele 2
	use acessnew
	dbgotop()
	sele 1*/
	dbgotop()
	x:=alert("Lista de Usuarios na Impressora?",{"Sim","Nao"})
	if x==1
		nlin:=50
		set device to print
	elseif x==2
		nlin:=20
	else 
		exit		
	endif
	if inkey()==27
		set devi to scree
		exit
	endif
	/*do while !eof()
		sele 2
		dbappend()
		acessnew->nome :=sipcpass->nome
		acessnew->senha:=sipcpass->senha
		sele 1
		dbskip()
	enddo*/
	sele 1
	dbgotop()
	*sele 2
	dbgotop()
	@ 03,10 say "Nome--------------------------     Senha---------------"
	lin:=4
	do while !eof()	
		n_nome  := Criptografa ( nome,   "HAWK" , .F. ) 
		n_senha := Criptografa ( senha,  n_nome , .F. ) 
		n_acesso:= Criptografa ( sipcpass->acesso, n_senha, .F. ) 
		lin++
		@ lin,10 say n_nome
		@ lin,45 say n_senha
		if lin==nlin
			inkey(0)
			if lastkey()==27
				clear
				exit
			endif
		   clear
			@ 03,10 say "Nome--------------------------     Senha------------"
			lin:=4
		endif
		/*n_acesso2:=substr(n_acesso,1,num-1) + '0' + substr(n_acesso,num,len(n_acesso))
		acessnew->acesso:=Criptografa ( n_acesso2, n_senha, .T. ) */
		if inkey()==27
			clear
			exit
		endif
		sele 1
		dbskip()
		/*sele 2
		dbskip()
		if eof()
			inkey(0)
		endif*/
	enddo
	inkey(0)
	dbcloseall()
enddo
set device to scree
clear
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