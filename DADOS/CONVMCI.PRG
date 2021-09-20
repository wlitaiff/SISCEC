Use Sb1010  alias sb1 New
set index to sb10101

Use SB7010 Alias Sb7 New
Set index to Sb70101

Use Sb9010 Alias Sb9 New
Set index to sb90101
Go Top
set device to print
Do While .not. EOF()
    ? Sb9->b9_Cod
    Sele SB1
    dbSeek("01"+SB9->B9_Cod)
    If Found()
        Sele SB7
        Append Blank
//        lock()
        Replace B7_Filial with "01"
        Replace B7_Cod with SB9->B9_Cod
        Replace B7_Local With SB9->B9_Local
        Replace B7_Tipo With SB1->B1_Tipo
        Replace B7_Doc With "INV1197"
        Replace B7_Data with CtoD("11/30/97")
        Replace B7_Quant with SB9->B9_QIni
  //      unlock()
      Else
        @ prow()+1,1 say "nao encontrei codigo "+SB9->B9_Cod

    EndIf
    Sele SB9
    Skip
EndDo
Close All
