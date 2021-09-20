** PROGRAMA PARA REALIZAR EXPLOSAO DE MATERIAIS EM RELACAO AO FORNECEDOR
** DEPTO: CPD - MCI
**
Clear
Set Talk Off
Set Cons On
Set Dele On
Set Date French

Use SA5010 Alias SA5 New          // Grupo X Fornecedor

Use SA2010 Alias SA2 New          // Fornecedor

Use SB1010 Alias SB1 New          // Produto

Ok = "S"
@ 01, 00 to 03,79 DOUBLE
@ 02, 03 SAY "MCI - AJUSTE DE PRODUTOS EM RELACAO AOS PRODUTOS"
@ 02, 70 SAY DATE()
@ 05, 03 SAY "Realiza conversao S/N ? "
@ 05, 27 get ok Pict "!" Valid ok $ "SN"
If Lastkey() == 27
   Close Data
   Clear
   @ 01,01 SAY "OPERACAO NAO REALIZADA..."
   Return
Endif
@ 10,10 SAY "PRODUTO: "
@ 11,10 SAY "GRUPO  : "
Go top
SOMA:=1
TOTAL:=RECCOUNT()
Do while ! eof()
   @ 10,20 SAY B1_COD
   CodProd := b1_COD
   DesProd := b1_desc
   Grupo   := b1_grupo
   Select SA2                                 // Fornecedor
   go top
   Do while ! eof()
      @ 11,20 SAY RECNO()
      Select SA5                              // Grupo X Fornecedor
      If GRUPO == SA2->A2_GRUPO1
         Append Blank
         Replace A5_LOJA    With "01"
         Replace A5_FORNECE With SA2->A2_COD
         Replace A5_NOMEFOR With SA2->A2_NOME
         Replace A5_PRODUTO With CodProd
         Replace A5_NOMPROD With DesProd
      Endif
      If GRUPO == SA2->A2_GRUPO2
         Append Blank
         Replace A5_LOJA    With "01"
         Replace A5_FORNECE With SA2->A2_COD
         Replace A5_NOMEFOR With SA2->A2_NOME
         Replace A5_PRODUTO With CodProd
         Replace A5_NOMPROD With DesProd
      Endif
      If grupo == SA2->A2_GRUPO3
         Append Blank
         Replace A5_LOJA    With "01"
         Replace A5_FORNECE With SA2->A2_COD
         Replace A5_NOMEFOR With SA2->A2_NOME
         Replace A5_PRODUTO With CodProd
         Replace A5_NOMPROD With DesProd
      Endif
      Select SA2010
      Skip
   Enddo
   SOMA:=SOMA+1
   @ 14,10 SAY STR(INT(SOMA*100/TOTAL),5)+" %"
   Select Sb1010
   Skip
Enddo
Clear
Close Data
@ 01,01 say "FIM DE OPERACAO..."
