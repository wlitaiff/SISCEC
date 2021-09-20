clear 
@ 01,01 say "Aguarde... Convertendo.:"

Select 1
Use Vensai
If !file("Vensai.ntx")
   @ 01,01 say "Aguarde... Indexando arquivo!"
   Index on cproduto to vensai
   @ 01,01 say "                               "
   @ 01,01 say "Aguarde... Convertendo.:"
Else
   Set Index to Vensai
Endif

Select 2
Use Sb1010
Set Index to Sb10101

Select 3
Use Sb5010
Goto Top
Do While !Eof()
   @ 01,26 say recno()
   Mcod := b5_cod

   Select 2
   Seek "01"+Mcod
   CodMci := B1_CodMci

   Sele 1
   Seek CodMci
   Pr2 := VlrUnit

   Sele 3
   Replace B5_Prv2 With pr2
   Skip
Enddo
Close Data
