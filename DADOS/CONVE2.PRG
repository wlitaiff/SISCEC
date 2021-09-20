
clear 
@ 01,01 say "Aguarde... Convertendo.:"

Select 1
Use vensai
If !file("vensai.ntx")
   @ 01,01 say "Aguarde... Indexando arquivo -> VENSAI"
   Index on cproduto to vensai
   @ 01,01 say "                               "
   @ 01,01 say "Aguarde... Convertendo.:"
Else
   Set index to vensai
Endif

Select 2
Use Sb1
If !file("SB1.ntx")
   @ 02,01 say "Aguarde... Indexando arquivo -> SB1!"
   Index on B1_COD to SB1
   @ 02,01 say "                               "
   @ 02,01 say "Aguarde... Convertendo.:"
Else
   Set index to vensai
Endif


Select 1
Goto Top
Do While !Eof()
   @ 01,26 say recno()
   Mcod := Cproduto
   Pr1 := Preco1 

   Select 2
   Seek Mcod
   Replace B1_prv1 With Pr1

   Selec 1
   skip
Enddo
Close Data
